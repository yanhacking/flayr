import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/common/widgets/my_cached_image.dart';
import 'package:untitled/utilities/const.dart';
import 'bill_split_screen.dart';
import 'group_fund_screen.dart';
import 'payment_service.dart';

// ─────────────────────────────────────────────
//  FLAYR Pay — Main Hub Screen
// ─────────────────────────────────────────────
class FlayrPayScreen extends StatefulWidget {
  final int? toUserId;
  final String? toUsername;
  final String? toProfileUrl;
  final String? toFullName;

  const FlayrPayScreen({
    Key? key,
    this.toUserId,
    this.toUsername,
    this.toProfileUrl,
    this.toFullName,
  }) : super(key: key);

  @override
  State<FlayrPayScreen> createState() => _FlayrPayScreenState();
}

class _FlayrPayScreenState extends State<FlayrPayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressScale;

  String _amount = '0';
  String _note = '';
  bool _isPublic = true;
  bool _sending = false;

  // Payment method selection
  PaymentMethod _selectedMethod = PaymentMethod.stripe;

  static const _quickAmounts = ['5', '10', '20', '50'];

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 140));
    _pressScale = Tween<double>(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _appendDigit(String d) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_amount == '0') _amount = d;
      else if (_amount.length < 6) _amount = _amount + d;
    });
  }

  void _deleteDigit() {
    HapticFeedback.selectionClick();
    setState(() {
      _amount = _amount.length <= 1 ? '0' : _amount.substring(0, _amount.length - 1);
    });
  }

  Future<void> _send() async {
    if (_amount == '0') return;
    final double amt = double.tryParse(_amount) ?? 0;
    if (amt <= 0) return;

    if (widget.toUserId == null) {
      Get.snackbar('Select recipient', 'Choose who to send to',
          backgroundColor: fSurface, colorText: fTextPrimary);
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _sending = true);

    final myId = SessionManager.shared.getUserID();
    bool success;

    if (_selectedMethod == PaymentMethod.stripe) {
      success = await StripePaymentService.pay(
        fromUserId: myId,
        toUserId:   widget.toUserId!,
        amount:     amt,
        note:       _note.isNotEmpty ? _note : null,
        isPublic:   _isPublic,
      );
    } else {
      success = await PayPalPaymentService.pay(
        fromUserId: myId,
        toUserId:   widget.toUserId!,
        amount:     amt,
        note:       _note.isNotEmpty ? _note : null,
        isPublic:   _isPublic,
      );
    }

    setState(() => _sending = false);

    if (success) {
      Get.back();
      Get.snackbar('', '',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        messageText: _successBanner(
          '\$$_amount sent to ${widget.toFullName ?? widget.toUsername}! ✅',
          _selectedMethod == PaymentMethod.stripe ? 'Paid via Stripe 💳' : 'Paid via PayPal',
        ),
      );
    }
  }

  Widget _successBanner(String title, String sub) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: flayrGradient as Gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: neonGlow(fGradMid, blur: 16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(title, style: MyTextStyle.gilroyBold(color: Colors.white, size: 14)),
        Text(sub,   style: MyTextStyle.gilroyLight(color: Colors.white70, size: 12)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fBG,
      body: Stack(
        children: [
          Positioned(top: -80, left: -50,
            child: Container(width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  fGradStart.withValues(alpha: 0.1), Colors.transparent])))),
          Positioned(bottom: -80, right: -50,
            child: Container(width: 260, height: 260,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  fGradEnd.withValues(alpha: 0.08), Colors.transparent])))),

          SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(children: [
                    GestureDetector(
                      onTap: Get.back,
                      child: _iconBtn(Icons.arrow_back_ios_new_rounded),
                    ),
                    const Spacer(),
                    ShaderMask(
                      shaderCallback: (b) => flayrGradient.createShader(b),
                      blendMode: BlendMode.srcIn,
                      child: Text('FLAYR PAY', style: MyTextStyle.gilroyBold(color: Colors.white, size: 18)),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ]),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [

                      // ── Social Pay features ──────────────────
                      Row(children: [
                        Expanded(child: _featureCard(
                          emoji: '🍕', label: 'Split Bill',
                          color: fGradMid,
                          onTap: () => Get.to(() => const BillSplitScreen()),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _featureCard(
                          emoji: '✈️', label: 'Group Fund',
                          color: fNeonBlue,
                          onTap: () => Get.to(() => const GroupFundScreen()),
                        )),
                      ]),

                      const SizedBox(height: 20),

                      // ── Recipient card (if provided) ─────────
                      if (widget.toUserId != null) ...[
                        _recipientCard(),
                        const SizedBox(height: 20),
                      ],

                      // ── Amount display ───────────────────────
                      ShaderMask(
                        shaderCallback: (b) => flayrGradient.createShader(b),
                        blendMode: BlendMode.srcIn,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(padding: const EdgeInsets.only(top: 14),
                                child: Text('\$', style: MyTextStyle.gilroyBold(color: Colors.white, size: 30))),
                            const SizedBox(width: 4),
                            Text(_amount, style: const TextStyle(
                                fontFamily: 'gilroy_extrabold', fontSize: 72,
                                color: Colors.white, letterSpacing: -3)),
                          ],
                        ),
                      ),

                      // Quick amounts
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _quickAmounts.map((a) => GestureDetector(
                          onTap: () { setState(() => _amount = a); HapticFeedback.selectionClick(); },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: _amount == a ? fGradStart.withValues(alpha: 0.15) : fSurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _amount == a ? fGradStart.withValues(alpha: 0.5) : fBorder,
                                width: 0.8),
                              boxShadow: _amount == a ? neonGlow(fGradStart, blur: 6) : null,
                            ),
                            child: Text('\$$a', style: TextStyle(
                              fontFamily: 'gilroy_bold', fontSize: 13,
                              color: _amount == a ? fGradStart : fTextSecondary)),
                          ),
                        )).toList(),
                      ),

                      const SizedBox(height: 18),

                      // Note field
                      _inputField(hint: 'Add a note (🍕 Pizza night...)', onChanged: (v) => _note = v),
                      const SizedBox(height: 12),

                      // Public toggle
                      _publicToggle(),
                      const SizedBox(height: 20),

                      // ── Payment method selector ──────────────
                      _paymentMethodSelector(),
                      const SizedBox(height: 24),

                      // ── Numpad ──────────────────────────────
                      _Numpad(onDigit: _appendDigit, onDelete: _deleteDigit),
                      const SizedBox(height: 20),

                      // ── Send button ─────────────────────────
                      GestureDetector(
                        onTapDown: (_) => _pressCtrl.forward(),
                        onTapUp: (_) { _pressCtrl.reverse(); _send(); },
                        onTapCancel: () => _pressCtrl.reverse(),
                        child: AnimatedBuilder(
                          animation: _pressScale,
                          builder: (_, child) => Transform.scale(scale: _pressScale.value, child: child),
                          child: Container(
                            width: double.infinity, height: 56,
                            decoration: BoxDecoration(
                              gradient: flayrGradient as Gradient,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: neonGlow(fGradMid, blur: 16),
                            ),
                            child: Center(child: _sending
                                ? const SizedBox(width: 22, height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Icon(
                                      _selectedMethod == PaymentMethod.stripe
                                          ? Icons.credit_card_rounded
                                          : Icons.account_balance_wallet_rounded,
                                      color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      _amount != '0'
                                          ? 'Send \$$_amount via ${_selectedMethod == PaymentMethod.stripe ? "Stripe" : "PayPal"}'
                                          : 'Enter an amount',
                                      style: MyTextStyle.gilroyBold(color: Colors.white, size: 15)),
                                  ])),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard({
    required String emoji,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: MyTextStyle.gilroyBold(color: fTextPrimary, size: 13)),
            Text('Tap to open', style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 10)),
          ]),
          const Spacer(),
          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color),
        ]),
      ),
    );
  }

  Widget _recipientCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: flayrGlassDecoration(radius: 16),
      child: Row(children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: flayrGradient as Gradient,
            boxShadow: neonGlow(fGradMid, blur: 6),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.5),
            child: MyCachedProfileImage(
                imageUrl: widget.toProfileUrl, width: 42, height: 42,
                fullName: widget.toFullName, cornerRadius: 10),
          ),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.toFullName ?? 'User',
              style: MyTextStyle.gilroyBold(color: fTextPrimary, size: 15)),
          Text('@${widget.toUsername ?? ''}',
              style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 12)),
        ]),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: fNeonGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8),
            border: Border.all(color: fNeonGreen.withValues(alpha: 0.25), width: 0.8),
          ),
          child: Text('Instant', style: MyTextStyle.gilroyBold(color: fNeonGreen, size: 12)),
        ),
      ]),
    );
  }

  Widget _paymentMethodSelector() {
    return Row(children: [
      Expanded(child: GestureDetector(
        onTap: () { setState(() => _selectedMethod = PaymentMethod.stripe); HapticFeedback.selectionClick(); },
        child: _methodCard(
          icon: Icons.credit_card_rounded,
          label: 'Credit Card',
          sublabel: 'Stripe',
          color: fGradStart,
          isSelected: _selectedMethod == PaymentMethod.stripe,
        ),
      )),
      const SizedBox(width: 12),
      Expanded(child: GestureDetector(
        onTap: () { setState(() => _selectedMethod = PaymentMethod.paypal); HapticFeedback.selectionClick(); },
        child: _methodCard(
          icon: Icons.account_balance_wallet_rounded,
          label: 'PayPal',
          sublabel: 'Wallet / Bank',
          color: fNeonBlue,
          isSelected: _selectedMethod == PaymentMethod.paypal,
        ),
      )),
    ]);
  }

  Widget _methodCard({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required bool isSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.10) : fSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? color.withValues(alpha: 0.45) : fBorder,
          width: isSelected ? 1.2 : 0.7),
        boxShadow: isSelected ? neonGlow(color, blur: 8) : null,
      ),
      child: Row(children: [
        Icon(icon, size: 20, color: isSelected ? color : fTextMuted),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontFamily: 'gilroy_bold', fontSize: 13,
              color: isSelected ? color : fTextPrimary)),
          Text(sublabel, style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 10)),
        ]),
      ]),
    );
  }

  Widget _publicToggle() {
    return Row(children: [
      const Icon(Icons.public_rounded, size: 16, color: fTextMuted),
      const SizedBox(width: 8),
      Text('Visible on feed', style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 13)),
      const Spacer(),
      GestureDetector(
        onTap: () { setState(() => _isPublic = !_isPublic); HapticFeedback.selectionClick(); },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44, height: 26,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: _isPublic ? flayrGradient as Gradient : null,
            color: _isPublic ? null : fSurface2,
            border: Border.all(color: _isPublic ? Colors.transparent : fBorder),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: _isPublic ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.all(3), width: 20, height: 20,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _inputField({required String hint, required Function(String) onChanged}) {
    return Container(
      decoration: flayrGlassDecoration(radius: 14),
      child: TextField(
        onChanged: onChanged,
        style: MyTextStyle.gilroyRegular(color: fTextPrimary, size: 14),
        maxLength: 60,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: MyTextStyle.gilroyLight(color: fTextMuted, size: 13),
          prefixIcon: const Icon(Icons.edit_outlined, size: 18, color: fTextMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          counterText: '',
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon) => Container(
    width: 40, height: 40,
    decoration: BoxDecoration(
      color: fSurface, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: fBorder)),
    child: Icon(icon, size: 16, color: fTextSecondary),
  );
}

// ─────────────────────────────────────────────
//  Numpad
// ─────────────────────────────────────────────
class _Numpad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  const _Numpad({required this.onDigit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in [['1','2','3'],['4','5','6'],['7','8','9'],['','0','⌫']])
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((d) {
                if (d.isEmpty) return const SizedBox(width: 80, height: 52);
                return GestureDetector(
                  onTap: () => d == '⌫' ? onDelete() : onDigit(d),
                  child: Container(
                    width: 80, height: 52,
                    decoration: BoxDecoration(
                      color: fSurface, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: fBorder, width: 0.6)),
                    child: Center(
                      child: Text(d, style: TextStyle(
                        fontFamily: d == '⌫' ? 'gilroy_regular' : 'gilroy_bold',
                        fontSize: d == '⌫' ? 18 : 22,
                        color: d == '⌫' ? fTextSecondary : fTextPrimary)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
