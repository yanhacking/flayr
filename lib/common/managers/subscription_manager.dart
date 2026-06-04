import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/common/api_service/user_service.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/utilities/const.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ─────────────────────────────────────────────
//  Subscription status global flag
// ─────────────────────────────────────────────
bool isSubscribe = false;

// ─────────────────────────────────────────────
//  Plan model
// ─────────────────────────────────────────────
class FlayrPlan {
  final String id;         // Stripe price ID
  final String name;
  final String price;
  final String period;     // 'monthly' | 'yearly'
  final String savings;    // e.g. 'Save 33%'
  final List<String> features;
  final bool isPopular;

  const FlayrPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    this.savings = '',
    required this.features,
    this.isPopular = false,
  });
}

// ─────────────────────────────────────────────
//  Subscription Manager — Stripe-based
// ─────────────────────────────────────────────
class SubscriptionManager {
  static final shared = SubscriptionManager();

  // Available plans (populated from backend or defined locally)
  List<FlayrPlan> plans = const [
    FlayrPlan(
      id:      stripePriceMonthly,
      name:    'FLAYR Premium',
      price:   '\$4.99',
      period:  'month',
      features: [
        '✅ Badge vérifié ✓',
        '✅ FLAYR Pay illimité',
        '✅ Capsules temporelles illimitées',
        '✅ Quests double points ⚡',
        '✅ Rooms prioritaires',
        '✅ Sans publicité',
      ],
    ),
    FlayrPlan(
      id:      stripePriceYearly,
      name:    'FLAYR Premium Annuel',
      price:   '\$39.99',
      period:  'year',
      savings: 'Save 33%',
      isPopular: true,
      features: [
        '✅ Tout du plan mensuel',
        '✅ Badge Gold exclusif 💛',
        '✅ Accès anticipé aux nouvelles features',
        '✅ Support prioritaire',
      ],
    ),
  ];

  // Initialise — vérifie le statut d'abonnement depuis le backend
  Future<void> initPlatformState() async {
    await checkSubscriptionStatus();
  }

  // ─────────────────────────────────────────────
  //  Check subscription status from backend
  // ─────────────────────────────────────────────
  Future<bool> checkSubscriptionStatus() async {
    try {
      final userId = SessionManager.shared.getUserID();
      if (userId == 0) return false;

      final res = await http.post(
        Uri.parse('${apiURL}getSubscriptionStatus'),
        body: {'user_id': userId.toString()},
      );

      final data = jsonDecode(res.body);
      isSubscribe = data['is_active'] == true;
      log('✅ Subscription Status: ${isSubscribe ? "Active" : "Inactive"}');
      return isSubscribe;
    } catch (e) {
      log('Subscription check error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  //  Open Stripe Checkout in WebView
  // ─────────────────────────────────────────────
  Future<bool> subscribe(FlayrPlan plan) async {
    try {
      final userId = SessionManager.shared.getUserID();

      // Ask backend to create a Stripe Checkout Session
      final res = await http.post(
        Uri.parse('${apiURL}createSubscriptionCheckout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id':  userId,
          'price_id': plan.id,
        }),
      );

      final data = jsonDecode(res.body);
      if (data['status'] != true) {
        Get.snackbar('Error', data['message'] ?? 'Could not start checkout',
            backgroundColor: cRed, colorText: cWhite);
        return false;
      }

      final checkoutUrl = data['checkout_url'] as String;
      final successUrl  = data['success_url'] as String;
      final cancelUrl   = data['cancel_url'] as String;

      // Open Stripe Checkout WebView
      final result = await Get.to<bool>(
        () => _StripeCheckoutWebView(
          checkoutUrl: checkoutUrl,
          successUrl:  successUrl,
          cancelUrl:   cancelUrl,
        ),
      );

      if (result != true) return false;

      // Verify subscription is active
      await checkSubscriptionStatus();

      if (isSubscribe) {
        // Update user verification status
        UserService.shared.editProfile(
          isVerified: 3,
          completion: (_) {},
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: cRed, colorText: cWhite);
      return false;
    }
  }

  // ─────────────────────────────────────────────
  //  Open Stripe Customer Portal (manage / cancel)
  // ─────────────────────────────────────────────
  Future<void> openCustomerPortal() async {
    try {
      final userId = SessionManager.shared.getUserID();
      final res = await http.post(
        Uri.parse('${apiURL}createSubscriptionPortal'),
        body: {'user_id': userId.toString()},
      );

      final data = jsonDecode(res.body);
      if (data['status'] != true) {
        Get.snackbar('Error', data['message'] ?? 'Could not open portal',
            backgroundColor: cRed, colorText: cWhite);
        return;
      }

      final portalUrl = data['portal_url'] as String;

      await Get.to<void>(
        () => _StripePortalWebView(portalUrl: portalUrl),
      );

      // Re-check status after returning
      await checkSubscriptionStatus();
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: cRed, colorText: cWhite);
    }
  }

  // ─────────────────────────────────────────────
  //  Restore subscription check (re-sync with Stripe)
  // ─────────────────────────────────────────────
  Future<bool?> restorePurchase() async {
    final active = await checkSubscriptionStatus();
    if (active) {
      UserService.shared.editProfile(isVerified: 3, completion: (_) {});
    }
    return active;
  }
}

// ─────────────────────────────────────────────
//  Stripe Checkout WebView
// ─────────────────────────────────────────────
class _StripeCheckoutWebView extends StatefulWidget {
  final String checkoutUrl;
  final String successUrl;
  final String cancelUrl;

  const _StripeCheckoutWebView({
    required this.checkoutUrl,
    required this.successUrl,
    required this.cancelUrl,
  });

  @override
  State<_StripeCheckoutWebView> createState() => _StripeCheckoutWebViewState();
}

class _StripeCheckoutWebViewState extends State<_StripeCheckoutWebView> {
  late final WebViewController _ctrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(fBG)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _loading = false),
        onNavigationRequest: (req) {
          if (req.url.startsWith(widget.successUrl)) {
            Get.back(result: true);
            return NavigationDecision.prevent;
          }
          if (req.url.startsWith(widget.cancelUrl)) {
            Get.back(result: false);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fBG,
      appBar: AppBar(
        backgroundColor: fSurface,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (b) => flayrGradient.createShader(b),
          blendMode: BlendMode.srcIn,
          child: const Text('FLAYR Premium',
              style: TextStyle(fontFamily: 'gilroy_bold', fontSize: 17, color: Colors.white)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: fTextSecondary),
          onPressed: () => Get.back(result: false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _ctrl),
          if (_loading)
            Container(
              color: fBG,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: fGradStart),
                    SizedBox(height: 16),
                    Text('Loading secure checkout…',
                        style: TextStyle(color: fTextSecondary, fontFamily: 'gilroy_regular')),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Stripe Customer Portal WebView
// ─────────────────────────────────────────────
class _StripePortalWebView extends StatefulWidget {
  final String portalUrl;
  const _StripePortalWebView({required this.portalUrl});

  @override
  State<_StripePortalWebView> createState() => _StripePortalWebViewState();
}

class _StripePortalWebViewState extends State<_StripePortalWebView> {
  late final WebViewController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(fBG)
      ..loadRequest(Uri.parse(widget.portalUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fBG,
      appBar: AppBar(
        backgroundColor: fSurface,
        title: const Text('Manage Subscription',
            style: TextStyle(fontFamily: 'gilroy_bold', fontSize: 17, color: fTextPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: fTextSecondary),
          onPressed: Get.back,
        ),
      ),
      body: WebViewWidget(controller: _ctrl),
    );
  }
}
