import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/utilities/const.dart';

// ─────────────────────────────────────────────
//  Time Capsule — Écran de création
// ─────────────────────────────────────────────
class TimeCapsuleScreen extends StatefulWidget {
  const TimeCapsuleScreen({Key? key}) : super(key: key);

  @override
  State<TimeCapsuleScreen> createState() => _TimeCapsuleScreenState();
}

class _TimeCapsuleScreenState extends State<TimeCapsuleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;

  int _selectedDelay = 1; // index into _delays
  String _message = '';
  bool _isPrivate = false;

  static const _delays = [
    _Delay(label: '24h',    days: 1,   emoji: '⚡'),
    _Delay(label: '1 week', days: 7,   emoji: '📅'),
    _Delay(label: '1 month',days: 30,  emoji: '🌙'),
    _Delay(label: '1 year', days: 365, emoji: '✨'),
  ];

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  DateTime get _openDate =>
      DateTime.now().add(Duration(days: _delays[_selectedDelay].days));

  void _seal() {
    if (_message.trim().isEmpty) return;
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (_) => _SealedDialog(
        delay: _delays[_selectedDelay],
        openDate: _openDate,
        onConfirm: () {
          Get.back(); // close dialog
          Get.back(); // close screen
          Get.snackbar('', '',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            messageText: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: fSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: fGradEnd.withValues(alpha: 0.4)),
                boxShadow: neonGlow(fGradEnd, blur: 16),
              ),
              child: Row(
                children: [
                  const Text('🕰️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Capsule sealed!',
                            style: MyTextStyle.gilroyBold(color: fTextPrimary, size: 14)),
                        Text(
                          'Opens on ${_openDate.day}/${_openDate.month}/${_openDate.year}',
                          style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fBG,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Animated purple glow
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _glowCtrl,
              builder: (_, __) => Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      fNeonPurple.withValues(alpha: 0.12 + 0.06 * _glowCtrl.value),
                      fGradEnd.withValues(alpha: 0.06 + 0.03 * _glowCtrl.value),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────
                  Row(
                    children: [
                      GestureDetector(
                        onTap: Get.back,
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: fSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: fBorder),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 16, color: fTextSecondary),
                        ),
                      ),
                      const Spacer(),
                      const Text('🕰️', style: TextStyle(fontSize: 26)),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Title ────────────────────────────
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [fNeonPurple, fGradEnd],
                    ).createShader(b),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      'Time Capsule',
                      style: MyTextStyle.gilroyBold(color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Write a message that unlocks in the future.\nYour followers get notified when it opens.',
                    style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 14),
                  ),

                  const SizedBox(height: 32),

                  // ── Message box ───────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: fSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: fBorder, width: 0.8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('✍️', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text('Your message',
                                style: MyTextStyle.gilroyBold(
                                    color: fTextSecondary, size: 13)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          onChanged: (v) => setState(() => _message = v),
                          maxLines: 6,
                          maxLength: 500,
                          style: MyTextStyle.gilroyRegular(color: fTextPrimary, size: 15),
                          decoration: InputDecoration(
                            hintText:
                                'What do you want your future self (and followers) to read?',
                            hintStyle:
                                MyTextStyle.gilroyLight(color: fTextMuted, size: 14),
                            border: InputBorder.none,
                            counterStyle:
                                MyTextStyle.gilroyLight(color: fTextMuted, size: 11),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Delay selector ────────────────────
                  Text('When does it open?',
                      style: MyTextStyle.gilroyBold(color: fTextPrimary, size: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(_delays.length, (i) {
                      final d = _delays[i];
                      final sel = _selectedDelay == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedDelay = i);
                            HapticFeedback.selectionClick();
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: sel
                                  ? fNeonPurple.withValues(alpha: 0.12)
                                  : fSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: sel
                                    ? fNeonPurple.withValues(alpha: 0.5)
                                    : fBorder,
                                width: sel ? 1.2 : 0.7,
                              ),
                              boxShadow: sel ? neonGlow(fNeonPurple, blur: 8) : null,
                            ),
                            child: Column(
                              children: [
                                Text(d.emoji,
                                    style: const TextStyle(fontSize: 18)),
                                const SizedBox(height: 4),
                                Text(d.label,
                                    style: TextStyle(
                                      fontFamily: 'gilroy_bold',
                                      fontSize: 11,
                                      color: sel ? fNeonPurple : fTextSecondary,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Open date preview
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: fNeonPurple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: fNeonPurple.withValues(alpha: 0.2), width: 0.8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_clock_rounded,
                            size: 16, color: fNeonPurple),
                        const SizedBox(width: 8),
                        Text(
                          'Opens on ${_openDate.day}/${_openDate.month}/${_openDate.year}',
                          style: MyTextStyle.gilroyMedium(color: fNeonPurple, size: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Privacy toggle ────────────────────
                  Row(
                    children: [
                      const Icon(Icons.visibility_outlined,
                          size: 16, color: fTextMuted),
                      const SizedBox(width: 8),
                      Text('Private (only you can see it)',
                          style:
                              MyTextStyle.gilroyLight(color: fTextSecondary, size: 13)),
                      const Spacer(),
                      _FlayrSwitch(
                        value: _isPrivate,
                        onChanged: (v) => setState(() => _isPrivate = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Seal button ───────────────────────
                  GestureDetector(
                    onTap: _seal,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: _message.trim().isNotEmpty
                            ? const LinearGradient(
                                colors: [fNeonPurple, fGradEnd])
                            : null,
                        color: _message.trim().isEmpty ? fSurface2 : null,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: _message.trim().isNotEmpty
                            ? neonGlow(fNeonPurple, blur: 16)
                            : null,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔒', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              'Seal the capsule',
                              style: MyTextStyle.gilroyBold(
                                color: _message.trim().isNotEmpty
                                    ? Colors.white
                                    : fTextMuted,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Delay {
  final String label;
  final int days;
  final String emoji;
  const _Delay({required this.label, required this.days, required this.emoji});
}

// ─────────────────────────────────────────────
class _SealedDialog extends StatelessWidget {
  final _Delay delay;
  final DateTime openDate;
  final VoidCallback onConfirm;

  const _SealedDialog({
    required this.delay,
    required this.openDate,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: fSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: fNeonPurple.withValues(alpha: 0.4)),
          boxShadow: neonGlow(fNeonPurple, blur: 24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🕰️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Seal this capsule?',
                style: MyTextStyle.gilroyBold(color: fTextPrimary, size: 20)),
            const SizedBox(height: 8),
            Text(
              'It will open on ${openDate.day}/${openDate.month}/${openDate.year}.\nYour followers will be notified!',
              textAlign: TextAlign.center,
              style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: fSurface2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: fBorder),
                      ),
                      child: Center(
                        child: Text('Cancel',
                            style: MyTextStyle.gilroyRegular(
                                color: fTextSecondary, size: 14)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [fNeonPurple, fGradEnd]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: neonGlow(fNeonPurple, blur: 10),
                      ),
                      child: Center(
                        child: Text('Seal it!',
                            style: MyTextStyle.gilroyBold(
                                color: Colors.white, size: 14)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FlayrSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _FlayrSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44, height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: value
              ? const LinearGradient(colors: [fNeonPurple, fGradEnd])
              : null,
          color: value ? null : fSurface2,
          border: Border.all(color: value ? Colors.transparent : fBorder),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 20, height: 20,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
