import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/extensions/image_extension.dart';
import 'package:untitled/common/managers/navigation.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/screens/login_screen/login_controller.dart';
import 'package:untitled/utilities/const.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeIn  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: fBG,
      body: Stack(
        children: [
          // Background radial glow top-right
          Positioned(
            top: -80,
            right: -60,
            child: _GlowBlob(color: fGradEnd, size: 320),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: _GlowBlob(color: fGradStart, size: 280),
          ),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // ── Logo & tagline ──────────────────────
                    Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (b) => flayrGradient.createShader(b),
                          blendMode: BlendMode.srcIn,
                          child: const Text(
                            'FLAYR',
                            style: TextStyle(
                              fontFamily: 'gilroy_extrabold',
                              fontSize: 62,
                              letterSpacing: 5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          appTagline,
                          style: TextStyle(
                            fontFamily: 'gilroy_light',
                            fontSize: 14,
                            letterSpacing: 2.5,
                            color: fTextSecondary,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // ── Headline ────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LKeys.signInTo.tr,
                            style: MyTextStyle.gilroyBold(color: fTextPrimary, size: 28),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            LKeys.signInDesc.tr,
                            style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 15),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Login buttons (glassmorphism card) ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: fSurface.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: fBorder, width: 0.8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              children: [
                                _FlayrLoginButton(
                                  text: LKeys.signInWithGoogle,
                                  assetName: MyImages.google,
                                  onTap: controller.googleLogin,
                                  accentColor: const Color(0xFF4285F4),
                                ),
                                _FlayrDivider(),
                                _FlayrLoginButton(
                                  text: LKeys.signInWithEmail,
                                  assetName: MyImages.email,
                                  onTap: controller.emailLogin,
                                  accentColor: fGradStart,
                                ),
                                if (GetPlatform.isIOS) ...[
                                  _FlayrDivider(),
                                  _FlayrLoginButton(
                                    text: LKeys.signInWithApple,
                                    assetName: MyImages.apple,
                                    onTap: controller.appleLogin,
                                    accentColor: fTextPrimary,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // ── Terms ───────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          Text(
                            LKeys.bySelectingAgree.tr,
                            textAlign: TextAlign.center,
                            style: MyTextStyle.gilroyLight(color: fTextMuted, size: 12),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(LKeys.iAgreeTo.tr,
                                  style: MyTextStyle.gilroyLight(color: fTextMuted, size: 12)),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => Navigate.openURLSheet(
                                    title: LKeys.termsOfUse.tr, url: termsURL),
                                child: ShaderMask(
                                  shaderCallback: (b) => flayrGradient.createShader(b),
                                  blendMode: BlendMode.srcIn,
                                  child: Text(LKeys.termsOfUse.tr,
                                      style: MyTextStyle.gilroySemiBold(
                                          color: Colors.white, size: 12)),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(LKeys.and.tr,
                                  style: MyTextStyle.gilroyLight(color: fTextMuted, size: 12)),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => Navigate.openURLSheet(
                                    title: LKeys.privacyPolicy.tr, url: privacyURL),
                                child: ShaderMask(
                                  shaderCallback: (b) => flayrGradient.createShader(b),
                                  blendMode: BlendMode.srcIn,
                                  child: Text(LKeys.privacyPolicy.tr,
                                      style: MyTextStyle.gilroySemiBold(
                                          color: Colors.white, size: 12)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _FlayrLoginButton extends StatefulWidget {
  final String text;
  final String assetName;
  final VoidCallback onTap;
  final Color accentColor;

  const _FlayrLoginButton({
    required this.text,
    required this.assetName,
    required this.onTap,
    required this.accentColor,
  });

  @override
  State<_FlayrLoginButton> createState() => _FlayrLoginButtonState();
}

class _FlayrLoginButtonState extends State<_FlayrLoginButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.accentColor.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: Center(
                  child: Image.asset(widget.assetName, width: 20, height: 20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.text.tr,
                  style: MyTextStyle.gilroyMedium(color: fTextPrimary, size: 15),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: fTextMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlayrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      color: fBorder,
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
