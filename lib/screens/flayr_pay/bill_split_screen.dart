import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/common/widgets/my_cached_image.dart';
import 'package:untitled/utilities/const.dart';
import 'payment_service.dart';

// ─────────────────────────────────────────────
//  Models
// ─────────────────────────────────────────────
class SplitParticipant {
  final int userId;
  final String fullName;
  final String? username;
  final String? profile;
  double share;
  bool hasPaid;

  SplitParticipant({
    required this.userId,
    required this.fullName,
    this.username,
    this.profile,
    this.share = 0,
    this.hasPaid = false,
  });
}

// ─────────────────────────────────────────────
//  Bill Split Screen
// ─────────────────────────────────────────────
class BillSplitScreen extends StatefulWidget {
  const BillSplitScreen({Key? key}) : super(key: key);

  @override
  State<BillSplitScreen> createState() => _BillSplitScreenState();
}

class _BillSplitScreenState extends State<BillSplitScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;

  final _totalCtrl = TextEditingController();
  final _titleCtrl = TextEditingController(text: '');
  final _searchCtrl = TextEditingController();

  double get _total => double.tryParse(_totalCtrl.text) ?? 0;

  final List<SplitParticipant> _participants = [];
  List<dynamic> _searchResults = [];
  bool _searching = false;
  bool _sending = false;
  bool _splitEqual = true;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    // Add myself as first participant
    final me = SessionManager.shared.getUser();
    if (me != null) {
      _participants.add(SplitParticipant(
        userId:   me.id ?? 0,
        fullName: me.fullName ?? 'You',
        username: me.username,
        profile:  me.profile,
        hasPaid:  true,
      ));
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _totalCtrl.dispose();
    _titleCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  double get _sharePerPerson =>
      _participants.isEmpty ? 0 : _total / _participants.length;

  void _recalculateShares() {
    if (!_splitEqual) return;
    final share = _sharePerPerson;
    for (final p in _participants) {
      p.share = share;
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() { _searchResults = []; _searching = false; });
      return;
    }
    setState(() => _searching = true);
    try {
      final res = await http.post(
        Uri.parse('${apiURL}searchProfile'),
        body: {
          'my_user_id': SessionManager.shared.getUserID().toString(),
          'keyword':    query,
          'start':      '0',
          'limit':      '10',
        },
      );
      final data = jsonDecode(res.body);
      setState(() {
        _searchResults = data['data'] ?? [];
        _searching = false;
      });
    } catch (_) {
      setState(() => _searching = false);
    }
  }

  void _addParticipant(dynamic user) {
    final id = user['id'] as int;
    if (_participants.any((p) => p.userId == id)) return;
    setState(() {
      _participants.add(SplitParticipant(
        userId:   id,
        fullName: user['full_name'] ?? '',
        username: user['username'],
        profile:  user['profile'],
      ));
      _searchResults = [];
      _searchCtrl.clear();
      _recalculateShares();
    });
    HapticFeedback.selectionClick();
  }

  void _removeParticipant(int userId) {
    final me = SessionManager.shared.getUserID();
    if (userId == me) return; // can't remove yourself
    setState(() {
      _participants.removeWhere((p) => p.userId == userId);
      _recalculateShares();
    });
  }

  Future<void> _createSplit() async {
    if (_total <= 0) {
      Get.snackbar('Missing total', 'Enter the total bill amount',
          backgroundColor: fSurface, colorText: fTextPrimary);
      return;
    }
    if (_participants.length < 2) {
      Get.snackbar('Add people', 'Add at least one other person',
          backgroundColor: fSurface, colorText: fTextPrimary);
      return;
    }

    setState(() => _sending = true);
    _recalculateShares();

    try {
      final me = SessionManager.shared.getUser();
      final res = await http.post(
        Uri.parse('${apiURL}createBillSplit'),
        body: {
          'creator_user_id': me?.id.toString() ?? '0',
          'title':           _titleCtrl.text.isNotEmpty ? _titleCtrl.text : 'Bill Split',
          'total_amount':    _total.toString(),
          'participant_ids': _participants.map((p) => p.userId).join(','),
          'share_per_person': _sharePerPerson.toStringAsFixed(2),
        },
      );

      final data = jsonDecode(res.body);
      setState(() => _sending = false);

      if (data['status'] == true) {
        HapticFeedback.heavyImpact();
        Get.back(result: data['data']);
        Get.snackbar('', '',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          messageText: _successBanner(
            '🍕 Split created!',
            '\$${ _sharePerPerson.toStringAsFixed(2)} per person · ${_participants.length} people',
          ),
        );
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed', backgroundColor: cRed);
      }
    } catch (e) {
      setState(() => _sending = false);
      Get.snackbar('Error', e.toString(), backgroundColor: cRed);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: MyTextStyle.gilroyBold(color: Colors.white, size: 15)),
          Text(sub,   style: MyTextStyle.gilroyLight(color: Colors.white70, size: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fBG,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: Get.back,
                    child: _iconBtn(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Spacer(),
                  ShaderMask(
                    shaderCallback: (b) => flayrGradient.createShader(b),
                    blendMode: BlendMode.srcIn,
                    child: const Text('🍕 Split the Bill',
                        style: TextStyle(fontFamily: 'gilroy_bold', fontSize: 18, color: Colors.white)),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Total amount ─────────────────────
                    AnimatedBuilder(
                      animation: _glowCtrl,
                      builder: (_, __) => Container(
                        decoration: BoxDecoration(
                          color: fSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _total > 0
                                ? fGradStart.withValues(alpha: 0.4 + 0.15 * _glowCtrl.value)
                                : fBorder,
                            width: 1,
                          ),
                          boxShadow: _total > 0 ? neonGlow(fGradStart, blur: 10) : null,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total bill amount',
                                style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 13)),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ShaderMask(
                                  shaderCallback: (b) => flayrGradient.createShader(b),
                                  blendMode: BlendMode.srcIn,
                                  child: const Text('\$', style: TextStyle(
                                      fontFamily: 'gilroy_bold', fontSize: 32, color: Colors.white)),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: TextField(
                                    controller: _totalCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: const TextStyle(
                                        fontFamily: 'gilroy_extrabold', fontSize: 48,
                                        color: fTextPrimary, letterSpacing: -2),
                                    decoration: const InputDecoration(
                                      hintText: '0.00',
                                      hintStyle: TextStyle(color: fTextMuted, fontSize: 48,
                                          fontFamily: 'gilroy_extrabold', letterSpacing: -2),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (v) => setState(_recalculateShares),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Title ────────────────────────────
                    _inputField(
                      controller: _titleCtrl,
                      hint: '🍕 Dinner at La Casa, 🍺 Bar night...',
                      label: 'Add a title (optional)',
                    ),

                    const SizedBox(height: 20),

                    // ── Per person amount ────────────────
                    if (_total > 0 && _participants.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: fGradStart.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: fGradStart.withValues(alpha: 0.25), width: 0.8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calculate_rounded, size: 18, color: fGradStart),
                            const SizedBox(width: 8),
                            Text(
                              '\$${_sharePerPerson.toStringAsFixed(2)} per person',
                              style: MyTextStyle.gilroyBold(color: fGradStart, size: 14),
                            ),
                            const Spacer(),
                            Text(
                              '${_participants.length} people',
                              style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 12),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // ── Participants ─────────────────────
                    Row(
                      children: [
                        Text('Participants',
                            style: MyTextStyle.gilroyBold(color: fTextPrimary, size: 16)),
                        const Spacer(),
                        Text('${_participants.length} people',
                            style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 13)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ..._participants.map((p) => _participantRow(p)),

                    const SizedBox(height: 12),

                    // ── Search to add ────────────────────
                    _inputField(
                      controller: _searchCtrl,
                      hint: 'Search friends to add...',
                      label: '+ Add participant',
                      prefixIcon: Icons.search_rounded,
                      onChanged: _searchUsers,
                    ),

                    if (_searching)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator(color: fGradStart, strokeWidth: 2)),
                      ),

                    if (_searchResults.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: fSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: fBorder),
                        ),
                        child: Column(
                          children: _searchResults.take(5).map((u) {
                            return GestureDetector(
                              onTap: () => _addParticipant(u),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    MyCachedProfileImage(
                                        imageUrl: u['profile'], width: 36, height: 36,
                                        fullName: u['full_name'], cornerRadius: 10),
                                    const SizedBox(width: 12),
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(u['full_name'] ?? '',
                                          style: MyTextStyle.gilroyBold(color: fTextPrimary, size: 14)),
                                      Text('@${u['username'] ?? ''}',
                                          style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 12)),
                                    ]),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        gradient: flayrGradient as Gradient,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('Add', style: TextStyle(
                                          fontFamily: 'gilroy_bold', fontSize: 12, color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // ── Create button ────────────────────
                    GestureDetector(
                      onTap: _sending ? null : _createSplit,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: flayrGradient as Gradient,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: neonGlow(fGradMid, blur: 14),
                        ),
                        child: Center(
                          child: _sending
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  const Text('🍕', style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Text(
                                    _total > 0
                                        ? 'Create Split · \$${_sharePerPerson.toStringAsFixed(2)}/person'
                                        : 'Create Split',
                                    style: MyTextStyle.gilroyBold(color: Colors.white, size: 15),
                                  ),
                                ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _participantRow(SplitParticipant p) {
    final isMe = p.userId == SessionManager.shared.getUserID();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? fGradStart.withValues(alpha: 0.06) : fSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe ? fGradStart.withValues(alpha: 0.2) : fBorder,
          width: 0.7,
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: isMe ? flayrGradient as Gradient : null,
              boxShadow: isMe ? neonGlow(fGradMid, blur: 6) : null,
            ),
            child: Padding(
              padding: isMe ? const EdgeInsets.all(1.5) : EdgeInsets.zero,
              child: MyCachedProfileImage(
                  imageUrl: p.profile, width: 36, height: 36,
                  fullName: p.fullName, cornerRadius: 9),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isMe ? '${p.fullName} (you)' : p.fullName,
                  style: MyTextStyle.gilroyBold(color: fTextPrimary, size: 14)),
              Text('@${p.username ?? ''}',
                  style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 12)),
            ]),
          ),
          if (_total > 0)
            Text(
              '\$${p.share.toStringAsFixed(2)}',
              style: MyTextStyle.gilroyBold(color: fGradStart, size: 14),
            ),
          const SizedBox(width: 10),
          if (!isMe)
            GestureDetector(
              onTap: () => _removeParticipant(p.userId),
              child: const Icon(Icons.remove_circle_outline_rounded, size: 18, color: cRed),
            ),
          if (isMe)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: flayrGradient as Gradient,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Paid', style: TextStyle(
                  fontFamily: 'gilroy_bold', fontSize: 10, color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: fSurface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fBorder),
      ),
      child: Icon(icon, size: 16, color: fTextSecondary),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required String label,
    IconData? prefixIcon,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fSurface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fBorder, width: 0.7),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: MyTextStyle.gilroyRegular(color: fTextPrimary, size: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: MyTextStyle.gilroyLight(color: fTextMuted, size: 13),
          labelText: label,
          labelStyle: MyTextStyle.gilroyLight(color: fTextSecondary, size: 12),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: fTextMuted) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
