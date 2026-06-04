import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/managers/subscription_manager.dart';
import 'package:untitled/utilities/const.dart';

class FlayrPremiumScreen extends StatefulWidget {
  const FlayrPremiumScreen({Key? key}) : super(key: key);

  @override
  State<FlayrPremiumScreen> createState() => _FlayrPremiumScreenState();
}

class _FlayrPremiumScreenState extends State<FlayrPremiumScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late AnimationController _floatCtrl;
  late Animation<double> _glowAnim;
  late Animation<double> _floatAnim;

  int _selectedPlanIndex = 1; // default: yearly (index 1)
  bool _loading = false;

  final _plans = SubscriptionManager.shared.plans;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    _glowAnim  = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _glowCtrl,  curve: Curves.easeInOut));
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    if (_loading) return;
    HapticFeedback.mediumImpact();
    setState(() => _loading = true);

    final plan    = _plans[_selectedPlanIndex];
    final success = await SubscriptionManager.shared.subscribe(plan);

    setState(() => _loading = false);

    if (success) {
      HapticFeedback.heavyImpact();
      Get.back(result: true);
      Get.snackbar('', '',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        messageText: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: flayrGradient as Gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: neonGlow(fGradMid, blur: 18),
          ),
          child: Row(children: [
            const Text('💎', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text('Welcome to FLAYR Premium! 🎉',
                  style: MyTextStyle.gilroyBold(color: Colors.white, size: 14)),
              Text('Your badge is now active.',
                  style: MyTextStyle.gilroyLight(color: Colors.white70, size: 12)),
            ]),
          ]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAlreadySubscribed = isSubscribe;

    return Scaffold(
      backgroundColor: fBG,
      body: Stack(
        children: [
          // ── Animated background ──────────────────
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, __) => Stack(children: [
              Positioned(top: -100, left: -80,
                child: Container(width: 400, height: 400,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      fGradStart.withValues(alpha: 0.10 + 0.05 * _glowAnim.value),
                      Colors.transparent])))),
              Positioned(top: 100, right: -100,
                child: Container(width: 350, height: 350,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      fGradEnd.withValues(alpha: 0.08 + 0.04 * _glowAnim.value),
                      Colors.transparent])))),
            ]),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(children: [
                    GestureDetector(
                      onTap: Get.back,
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: fSurface, borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: fBorder)),
                        child: const Icon(Icons.close_rounded, size: 18, color: fTextSecondary),
                      ),
                    ),
                    const Spacer(),
                    if (isAlreadySubscribed)
                      GestureDetector(
                        onTap: SubscriptionManager.shared.openCustomerPortal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: fSurface, borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: fBorder)),
                          child: Text('Manage', style: MyTextStyle.gilroyBold(color: fTextSecondary, size: 13)),
                        ),
                      ),
                  ]),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // ── Crown / badge ────────────────────────
                        AnimatedBuilder(
                          animation: _floatAnim,
                          builder: (_, __) => Transform.translate(
                            offset: Offset(0, _floatAnim.value),
                            child: AnimatedBuilder(
                              animation: _glowAnim,
                              builder: (_, __) => Container(
                                width: 100, height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const RadialGradient(colors: [
                                    Color(0xFF3D2000), Color(0xFF1A0E00)]),
                                  border: Border.all(color: fGradStart.withValues(alpha: 0.6), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: fGradStart.withValues(alpha: 0.4 + 0.2 * _glowAnim.value),
                                      blurRadius: 30 + 10 * _glowAnim.value),
                                    BoxShadow(
                                      color: fGradEnd.withValues(alpha: 0.2 + 0.1 * _glowAnim.value),
                                      blurRadius: 50),
                                  ],
                                ),
                                child: const Center(
                                  child: Text('💎', style: TextStyle(fontSize: 44)),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Title ────────────────────────────────
                        ShaderMask(
                          shaderCallback: (b) => flayrGradient.createShader(b),
                          blendMode: BlendMode.srcIn,
                          child: const Text('FLAYR Premium',
                              style: TextStyle(fontFamily: 'gilroy_extrabold',
                                  fontSize: 34, color: Colors.white, letterSpacing: -1)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isAlreadySubscribed
                              ? 'Your premium is active ✓'
                              : 'Unlock everything. No limits.',
                          style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 15),
                        ),

                        const SizedBox(height: 28),

                        // ── Active badge (if subscribed) ─────────
                        if (isAlreadySubscribed) ...[
                          _activeBadge(),
                          const SizedBox(height: 24),
                        ],

                        // ── Plan selector ─────────────────────────
                        if (!isAlreadySubscribed) ...[
                          _planSelector(),
                          const SizedBox(height: 20),
                        ],

                        // ── Features list ─────────────────────────
                        _featuresList(),

                        const SizedBox(height: 24),

                        // ── Stripe badge ─────────────────────────
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.lock_rounded, size: 14, color: fTextMuted),
                          const SizedBox(width: 6),
                          Text('Secured by Stripe — No App Store fees',
                              style: MyTextStyle.gilroyLight(color: fTextMuted, size: 12)),
                        ]),

                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('Cancel anytime · ',
                              style: MyTextStyle.gilroyLight(color: fTextMuted, size: 11)),
                          Text('Billed via Stripe',
                              style: MyTextStyle.gilroyLight(color: fTextMuted, size: 11)),
                        ]),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),

                // ── Bottom CTA ────────────────────────────
                if (!isAlreadySubscribed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(children: [
                      // Subscribe button
                      GestureDetector(
                        onTap: _subscribe,
                        child: Container(
                          width: double.infinity, height: 56,
                          decoration: BoxDecoration(
                            gradient: flayrGradient as Gradient,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: neonGlow(fGradMid, blur: 18),
                          ),
                          child: Center(child: _loading
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  const Text('💎', style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Start ${_plans[_selectedPlanIndex].period == 'month' ? 'Monthly' : 'Yearly'} · ${_plans[_selectedPlanIndex].price}',
                                    style: MyTextStyle.gilroyBold(color: Colors.white, size: 16),
                                  ),
                                ])),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Restore
                      GestureDetector(
                        onTap: () async {
                          setState(() => _loading = true);
                          await SubscriptionManager.shared.restorePurchase();
                          setState(() => _loading = false);
                          if (isSubscribe) Get.back(result: true);
                        },
                        child: Text('Restore subscription',
                            style: MyTextStyle.gilroyRegular(color: fTextSecondary, size: 13)),
                      ),
                    ]),
                  ),

                if (isAlreadySubscribed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: GestureDetector(
                      onTap: SubscriptionManager.shared.openCustomerPortal,
                      child: Container(
                        width: double.infinity, height: 52,
                        decoration: BoxDecoration(
                          color: fSurface, borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: fBorder)),
                        child: Center(child: Text('Manage or Cancel Subscription',
                            style: MyTextStyle.gilroyBold(color: fTextSecondary, size: 14))),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: fGradStart.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fGradStart.withValues(alpha: 0.3), width: 0.8),
        boxShadow: neonGlow(fGradStart, blur: 8),
      ),
      child: Row(children: [
        const Text('✅', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Premium Active', style: MyTextStyle.gilroyBold(color: fGradStart, size: 15)),
          Text('Your verified badge is shown on your profile',
              style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 12)),
        ]),
      ]),
    );
  }

  Widget _planSelector() {
    return Column(
      children: List.generate(_plans.length, (i) {
        final plan = _plans[i];
        final sel  = _selectedPlanIndex == i;
        return GestureDetector(
          onTap: () { setState(() => _selectedPlanIndex = i); HapticFeedback.selectionClick(); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: sel ? fGradStart.withValues(alpha: 0.07) : fSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: sel ? fGradStart.withValues(alpha: 0.5) : fBorder,
                width: sel ? 1.4 : 0.7),
              boxShadow: sel ? neonGlow(fGradStart, blur: 10) : null,
            ),
            child: Row(children: [
              // Radio
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: sel ? flayrGradient as Gradient : null,
                  color: sel ? null : fSurface2,
                  border: Border.all(
                    color: sel ? Colors.transparent : fBorder, width: 1),
                ),
                child: sel ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
              ),
              const SizedBox(width: 14),

              // Plan info
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(plan.name,
                        style: TextStyle(
                          fontFamily: 'gilroy_bold', fontSize: 15,
                          color: sel ? fGradStart : fTextPrimary)),
                    if (plan.isPopular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: flayrGradient as Gradient,
                          borderRadius: BorderRadius.circular(6)),
                        child: const Text('BEST VALUE',
                            style: TextStyle(fontFamily: 'gilroy_bold', fontSize: 9, color: Colors.white)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 2),
                  Row(children: [
                    Text('${plan.price} / ${plan.period}',
                        style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 13)),
                    if (plan.savings.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(plan.savings,
                          style: MyTextStyle.gilroyBold(color: fNeonGreen, size: 11)),
                    ],
                  ]),
                ]),
              ),
            ]),
          ),
        );
      }),
    );
  }

  Widget _featuresList() {
    final plan = _plans[_selectedPlanIndex];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: fSurface, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fBorder, width: 0.7)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What you get', style: MyTextStyle.gilroyBold(color: fTextPrimary, size: 15)),
          const SizedBox(height: 14),
          ...plan.features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              const SizedBox(width: 2),
              Expanded(child: Text(f,
                  style: MyTextStyle.gilroyRegular(color: fTextPrimary, size: 14))),
            ]),
          )),
        ],
      ),
    );
  }
}
