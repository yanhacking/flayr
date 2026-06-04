import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:untitled/utilities/const.dart';

// ─────────────────────────────────────────────
//  Stripe Payment Service
// ─────────────────────────────────────────────
class StripePaymentService {
  static Future<bool> pay({
    required int fromUserId,
    required int toUserId,
    required double amount,
    String? note,
    bool isPublic = true,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${apiURL}createStripeIntent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'from_user_id': fromUserId,
          'to_user_id':   toUserId,
          'amount':       amount,
          'note':         note,
          'is_public':    isPublic,
        }),
      );

      final body = jsonDecode(res.body);
      if (body['status'] != true) throw Exception(body['message'] ?? 'Payment setup failed');

      final clientSecret = body['client_secret'] as String;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'FLAYR Pay',
          style: ThemeMode.dark,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary:            const Color(0xFFFFB800),
              background:         const Color(0xFF111111),
              componentBackground: const Color(0xFF1A1A1A),
              primaryText:        const Color(0xFFF8F8F8),
            ),
            shapes: const PaymentSheetShape(borderRadius: 16),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return false;
      Get.snackbar('Payment Error', e.error.localizedMessage ?? 'Failed',
          backgroundColor: cRed, colorText: cWhite);
      return false;
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: cRed, colorText: cWhite);
      return false;
    }
  }
}

// ─────────────────────────────────────────────
//  PayPal Payment Service
// ─────────────────────────────────────────────
class PayPalPaymentService {
  static Future<bool> pay({
    required int fromUserId,
    required int toUserId,
    required double amount,
    String? note,
    bool isPublic = true,
  }) async {
    try {
      const returnUrl = '${baseURL}paypal/success';
      const cancelUrl = '${baseURL}paypal/cancel';

      final res = await http.post(
        Uri.parse('${apiURL}createPaypalOrder'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'from_user_id': fromUserId,
          'to_user_id':   toUserId,
          'amount':       amount,
          'note':         note,
          'is_public':    isPublic,
          'return_url':   returnUrl,
          'cancel_url':   cancelUrl,
        }),
      );

      final body = jsonDecode(res.body);
      if (body['status'] != true) throw Exception(body['message'] ?? 'PayPal setup failed');

      final approvalUrl = body['approval_url'] as String?;
      final orderId     = body['order_id'] as String?;
      if (approvalUrl == null) throw Exception('No approval URL');

      final approved = await Get.to<bool>(
        () => PayPalWebViewScreen(
          approvalUrl: approvalUrl,
          returnUrl:   returnUrl,
          cancelUrl:   cancelUrl,
        ),
      );

      if (approved != true) return false;

      final captureRes = await http.post(
        Uri.parse('${apiURL}capturePaypalOrder'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'order_id':     orderId,
          'from_user_id': fromUserId,
          'to_user_id':   toUserId,
        }),
      );

      return jsonDecode(captureRes.body)['status'] == true;
    } catch (e) {
      Get.snackbar('PayPal Error', e.toString(), backgroundColor: cRed, colorText: cWhite);
      return false;
    }
  }
}

// ─────────────────────────────────────────────
//  PayPal WebView Screen
// ─────────────────────────────────────────────
class PayPalWebViewScreen extends StatefulWidget {
  final String approvalUrl;
  final String returnUrl;
  final String cancelUrl;

  const PayPalWebViewScreen({
    Key? key,
    required this.approvalUrl,
    required this.returnUrl,
    required this.cancelUrl,
  }) : super(key: key);

  @override
  State<PayPalWebViewScreen> createState() => _PayPalWebViewScreenState();
}

class _PayPalWebViewScreenState extends State<PayPalWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(fBG)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (req) {
            if (req.url.startsWith(widget.returnUrl)) {
              Get.back(result: true);
              return NavigationDecision.prevent;
            }
            if (req.url.startsWith(widget.cancelUrl)) {
              Get.back(result: false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
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
          child: const Text('PayPal',
              style: TextStyle(fontFamily: 'gilroy_bold', fontSize: 18, color: Colors.white)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: fTextSecondary),
          onPressed: () => Get.back(result: false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            Container(
              color: fBG,
              child: const Center(
                child: CircularProgressIndicator(color: fGradStart),
              ),
            ),
        ],
      ),
    );
  }
}
