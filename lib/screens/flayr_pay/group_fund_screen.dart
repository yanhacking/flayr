import 'dart:convert';
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
//  Group Fund Screen — Create / View / Contribute
// ─────────────────────────────────────────────
class GroupFundScreen extends StatefulWidget {
  final Map<String, dynamic>? existingFund;
  const GroupFundScreen({Key? key, this.existingFund}) : super(key: key);

  @override
  State<GroupFundScreen> createState() => _GroupFundScreenState();
}

class _GroupFundScreenState extends State<GroupFundScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbitCtrl;

  final _titleCtrl  = TextEditingController();
  final _descCtrl   = TextEditingController();
  final _goalCtrl   = TextEditingController();
  final _searchCtrl = TextEditingController();

  final List<String> _categoryEmojis = ['✈️','🎉','🎁','🏖️','🍕','🎮','🏋️','📚','🎵','💍'];
  String _selectedEmoji = '✈️';

  DateTime? _deadline;
  List<dynamic> _searchResults = [];
  final List<Map<String, dynamic>> _invitedUsers = [];
  bool _searching = false;
  bool _sending = false;

  bool get _isViewing => widget.existingFund != null;

  double get _goal     => _isViewing ? (widget.existingFund!['goal_amount'] as num).toDouble()     : (double.tryParse(_goalCtrl.text) ?? 0);
  double get _collected => _isViewing ? (widget.existingFund!['collected_amount'] as num? ?? 0).toDouble() : 0;
  double get _progress  => _goal > 0 ? (_collected / _goal).clamp(0.0, 1.0) : 0;

  @override
  void initState() {
    super.initState();
    _orbitCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    if (_isViewing) {
      final f = widget.existingFund!;
      _titleCtrl.text = f['title'] ?? '';
      _descCtrl.text  = f['description'] ?? '';
      _selectedEmoji  = f['emoji'] ?? '✈️';
    }
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _goalCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: fGradStart, surface: fSurface),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) { setState(() => _searchResults = []); return; }
    setState(() => _searching = true);
    try {
      final res = await http.post(Uri.parse('${apiURL}searchProfile'), body: {
        'my_user_id': SessionManager.shared.getUserID().toString(),
        'keyword':    query, 'start': '0', 'limit': '10',
      });
      setState(() { _searchResults = jsonDecode(res.body)['data'] ?? []; _searching = false; });
    } catch (_) { setState(() => _searching = false); }
  }

  void _inviteUser(Map<String, dynamic> user) {
    if (_invitedUsers.any((u) => u['id'] == user['id'])) return;
    setState(() { _invitedUsers.add(user); _searchResults = []; _searchCtrl.clear(); });
    HapticFeedback.selectionClick();
  }

  Future<void> _createFund() async {
    if (_titleCtrl.text.trim().isEmpty) {
      Get.snackbar('Missing title', 'Give your fund a name', backgroundColor: fSurface, colorText: fTextPrimary);
      return;
    }
    if (_goal <= 0) {
      Get.snackbar('Missing goal', 'Set a funding goal', backgroundColor: fSurface, colorText: fTextPrimary);
      return;
    }

    setState(() => _sending = true);
    try {
      final me = SessionManager.shared.getUser();
      final res = await http.post(Uri.parse('${apiURL}createGroupFund'), body: {
        'creator_user_id': me?.id.toString() ?? '0',
        'title':           _titleCtrl.text.trim(),
        'description':     _descCtrl.text.trim(),
        'emoji':           _selectedEmoji,
        'goal_amount':     _goal.toString(),
        'deadline':        _deadline?.toIso8601String() ?? '',
        'invited_ids':     _invitedUsers.map((u) => u['id'].toString()).join(','),
      });

      final data = jsonDecode(res.body);
      setState(() => _sending = false);

      if (data['status'] == true) {
        HapticFeedback.heavyImpact();
        Get.back(result: data['data']);
        Get.snackbar('', '',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          messageText: _successBanner('✈️ Fund created!', 'Share the link with your group'),
        );
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed', backgroundColor: cRed);
      }
    } catch (e) {
      setState(() => _sending = false);
      Get.snackbar('Error', e.toString(), backgroundColor: cRed);
    }
  }

  Future<void> _contribute(double amount, PaymentMethod method) async {
    if (!_isViewing) return;
    final me = SessionManager.shared.getUser();
    final creatorId = widget.existingFund!['creator_user_id'] as int? ?? 0;

    bool success;
    if (method == PaymentMethod.stripe) {
      success = await StripePaymentService.pay(
        fromUserId: me?.id ?? 0,
        toUserId:   creatorId,
        amount:     amount,
        note:       '${_selectedEmoji} ${_titleCtrl.text}',
        isPublic:   true,
      );
    } else {
      success = await PayPalPaymentService.pay(
        fromUserId: me?.id ?? 0,
        toUserId:   creatorId,
        amount:     amount,
        note:       '${_selectedEmoji} ${_titleCtrl.text}',
        isPublic:   true,
      );
    }

    if (success) {
      // Update contribution via API
      await http.post(Uri.parse('${apiURL}contributeToFund'), body: {
        'user_id': me?.id.toString() ?? '0',
        'fund_id': widget.existingFund!['id'].toString(),
        'amount':  amount.toString(),
      });
      HapticFeedback.heavyImpact();
      Get.back(result: true);
    }
  }

  Widget _successBanner(String title, String sub) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [fNeonBlue, fNeonPurple]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: neonGlow(fNeonBlue, blur: 16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(title, style: MyTextStyle.gilroyBold(color: Colors.white, size: 15)),
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
          // Background orbit glow
          Positioned(top: -60, right: -60,
            child: AnimatedBuilder(animation: _orbitCtrl,
              builder: (_, __) => Transform.rotate(
                angle: _orbitCtrl.value * 2 * 3.14159,
                child: Container(width: 300, height: 300,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      fNeonBlue.withValues(alpha: 0.12), fNeonPurple.withValues(alpha: 0.06), Colors.transparent,
                    ]))),
              ),
            ),
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
                      child: _iconBtn(Icons.arrow_back_ios_new_rounded),
                    ),
                    const Spacer(),
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(colors: [fNeonBlue, fNeonPurple]).createShader(b),
                      blendMode: BlendMode.srcIn,
                      child: Text(_isViewing ? '${_selectedEmoji} ${_titleCtrl.text}' : '✈️ Group Fund',
                          style: const TextStyle(fontFamily: 'gilroy_bold', fontSize: 18, color: Colors.white)),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ]),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _isViewing ? _viewContent() : _createContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  VIEW existing fund
  // ─────────────────────────────────────────
  Widget _viewContent() {
    final f = widget.existingFund!;
    final daysLeft = f['deadline'] != null
        ? DateTime.parse(f['deadline']).difference(DateTime.now()).inDays
        : null;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Fund orb
      Center(
        child: Container(
          width: 120, height: 120,
          decoration: BoxDecoration(shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              fNeonBlue.withValues(alpha: 0.3), fNeonPurple.withValues(alpha: 0.15), fSurface,
            ]),
            border: Border.all(color: fNeonBlue.withValues(alpha: 0.3), width: 1.5),
            boxShadow: neonGlow(fNeonBlue, blur: 20),
          ),
          child: Center(child: Text(_selectedEmoji, style: const TextStyle(fontSize: 48))),
        ),
      ),
      const SizedBox(height: 16),

      // Progress card
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: fSurface, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: fBorder, width: 0.7),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f['title'] ?? '', style: MyTextStyle.gilroyBold(color: fTextPrimary, size: 18)),
              const SizedBox(height: 4),
              Text(f['description'] ?? '', style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 13)),
            ])),
            if (daysLeft != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: fNeonBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: fNeonBlue.withValues(alpha: 0.25), width: 0.8),
                ),
                child: Text('$daysLeft days', style: MyTextStyle.gilroyBold(color: fNeonBlue, size: 12)),
              ),
          ]),
          const SizedBox(height: 20),

          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('\$${_collected.toStringAsFixed(0)}',
                style: const TextStyle(fontFamily: 'gilroy_extrabold', fontSize: 36,
                    color: fNeonBlue, letterSpacing: -1)),
            const SizedBox(width: 6),
            Padding(padding: const EdgeInsets.only(bottom: 5),
                child: Text('/ \$${_goal.toStringAsFixed(0)}',
                    style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 16))),
          ]),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress, minHeight: 8,
              backgroundColor: fSurface2,
              valueColor: const AlwaysStoppedAnimation(fNeonBlue),
            ),
          ),
          const SizedBox(height: 6),
          Text('${(_progress * 100).toInt()}% funded',
              style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 12)),
        ]),
      ),

      const SizedBox(height: 20),

      // Contribute section
      Text('Contribute', style: MyTextStyle.gilroyBold(color: fTextPrimary, size: 16)),
      const SizedBox(height: 12),

      Row(children: [
        for (final amt in [10.0, 25.0, 50.0, 100.0])
          Expanded(child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _quickContributeBtn(amt),
          )),
      ]),
    ]);
  }

  Widget _quickContributeBtn(double amount) {
    return GestureDetector(
      onTap: () => _showPaymentPicker(amount),
      child: Container(
        height: 48, decoration: BoxDecoration(
          gradient: flayrGradient as Gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: neonGlow(fGradMid, blur: 8),
        ),
        child: Center(child: Text('\$${amount.toInt()}',
            style: MyTextStyle.gilroyBold(color: Colors.white, size: 15))),
      ),
    );
  }

  void _showPaymentPicker(double amount) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
            color: fSurface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4,
              decoration: BoxDecoration(color: fBorder, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('Contribute \$${amount.toInt()}',
              style: MyTextStyle.gilroyBold(color: fTextPrimary, size: 20)),
          const SizedBox(height: 6),
          Text('Choose your payment method',
              style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 14)),
          const SizedBox(height: 24),

          _payMethodBtn(
            icon: Icons.credit_card_rounded,
            label: 'Pay with Card',
            sublabel: 'Stripe — Visa, Mastercard, Amex',
            color: fGradStart,
            onTap: () { Get.back(); _contribute(amount, PaymentMethod.stripe); },
          ),
          const SizedBox(height: 12),
          _payMethodBtn(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Pay with PayPal',
            sublabel: 'PayPal balance or bank account',
            color: fNeonBlue,
            onTap: () { Get.back(); _contribute(amount, PaymentMethod.paypal); },
          ),
        ]),
      ),
      isScrollControlled: true,
    );
  }

  Widget _payMethodBtn({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
        ),
        child: Row(children: [
          Container(width: 42, height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: MyTextStyle.gilroyBold(color: fTextPrimary, size: 15)),
            Text(sublabel, style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 12)),
          ]),
          const Spacer(),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  CREATE new fund
  // ─────────────────────────────────────────
  Widget _createContent() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Emoji selector
      Text('Choose an emoji', style: MyTextStyle.gilroyBold(color: fTextPrimary, size: 15)),
      const SizedBox(height: 10),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categoryEmojis.map((e) {
            final sel = _selectedEmoji == e;
            return GestureDetector(
              onTap: () { setState(() => _selectedEmoji = e); HapticFeedback.selectionClick(); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                width: 48, height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: sel ? fNeonBlue.withValues(alpha: 0.12) : fSurface,
                  border: Border.all(color: sel ? fNeonBlue.withValues(alpha: 0.5) : fBorder,
                      width: sel ? 1.2 : 0.7),
                  boxShadow: sel ? neonGlow(fNeonBlue, blur: 8) : null,
                ),
                child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
              ),
            );
          }).toList(),
        ),
      ),

      const SizedBox(height: 20),
      _inputField(controller: _titleCtrl, hint: 'Miami Trip 2026, Wedding Gift...', label: 'Fund title *'),
      const SizedBox(height: 12),
      _inputField(controller: _descCtrl, hint: 'What\'s this fund for?', label: 'Description (optional)', maxLines: 3),
      const SizedBox(height: 12),
      _inputField(controller: _goalCtrl, hint: '1200', label: 'Goal amount (\$) *',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixText: '\$', onChanged: (_) => setState(() {})),

      const SizedBox(height: 12),

      // Deadline picker
      GestureDetector(
        onTap: _pickDeadline,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: fSurface, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: fBorder, width: 0.7),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today_rounded, size: 18, color: fTextMuted),
            const SizedBox(width: 12),
            Text(
              _deadline != null
                  ? 'Deadline: ${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                  : 'Set a deadline (optional)',
              style: MyTextStyle.gilroyRegular(
                  color: _deadline != null ? fTextPrimary : fTextMuted, size: 14),
            ),
          ]),
        ),
      ),

      if (_goal > 0) ...[
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: fNeonBlue.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14),
            border: Border.all(color: fNeonBlue.withValues(alpha: 0.25), width: 0.8),
          ),
          child: Row(children: [
            const Icon(Icons.flag_rounded, size: 18, color: fNeonBlue),
            const SizedBox(width: 8),
            Text('Goal: \$${double.tryParse(_goalCtrl.text)?.toStringAsFixed(0) ?? '0'}',
                style: MyTextStyle.gilroyBold(color: fNeonBlue, size: 14)),
          ]),
        ),
      ],

      const SizedBox(height: 20),

      // Invite people
      Text('Invite people (optional)', style: MyTextStyle.gilroyBold(color: fTextPrimary, size: 15)),
      const SizedBox(height: 10),
      if (_invitedUsers.isNotEmpty)
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _invitedUsers.map((u) => Chip(
            label: Text('@${u['username'] ?? u['full_name']}',
                style: MyTextStyle.gilroyBold(color: fNeonBlue, size: 12)),
            backgroundColor: fNeonBlue.withValues(alpha: 0.08),
            side: BorderSide(color: fNeonBlue.withValues(alpha: 0.3), width: 0.8),
            deleteIconColor: fTextSecondary,
            onDeleted: () => setState(() => _invitedUsers.remove(u)),
          )).toList(),
        ),
      const SizedBox(height: 8),
      _inputField(controller: _searchCtrl, hint: 'Search friends...', label: '+ Invite',
          prefixIcon: Icons.search_rounded, onChanged: _searchUsers),

      if (_searchResults.isNotEmpty)
        Container(
          decoration: BoxDecoration(color: fSurface, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: fBorder)),
          child: Column(
            children: _searchResults.take(4).map((u) => GestureDetector(
              onTap: () => _inviteUser(Map<String, dynamic>.from(u as Map)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(children: [
                  MyCachedProfileImage(imageUrl: u['profile'], width: 32, height: 32,
                      fullName: u['full_name'], cornerRadius: 9),
                  const SizedBox(width: 10),
                  Text(u['full_name'] ?? '', style: MyTextStyle.gilroyBold(color: fTextPrimary, size: 13)),
                  const Spacer(),
                  const Icon(Icons.add_circle_outline_rounded, size: 18, color: fNeonBlue),
                ]),
              ),
            )).toList(),
          ),
        ),

      const SizedBox(height: 32),

      // Create button
      GestureDetector(
        onTap: _sending ? null : _createFund,
        child: Container(
          width: double.infinity, height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [fNeonBlue, fNeonPurple]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: neonGlow(fNeonBlue, blur: 14),
          ),
          child: Center(child: _sending
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_selectedEmoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text('Create Fund', style: MyTextStyle.gilroyBold(color: Colors.white, size: 16)),
                ])),
        ),
      ),
      const SizedBox(height: 40),
    ]);
  }

  Widget _iconBtn(IconData icon) => Container(
    width: 40, height: 40,
    decoration: BoxDecoration(color: fSurface, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fBorder)),
    child: Icon(icon, size: 16, color: fTextSecondary),
  );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required String label,
    IconData? prefixIcon,
    String? prefixText,
    int maxLines = 1,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(color: fSurface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: fBorder, width: 0.7)),
      child: TextField(
        controller: controller, maxLines: maxLines, keyboardType: keyboardType,
        onChanged: onChanged,
        style: MyTextStyle.gilroyRegular(color: fTextPrimary, size: 14),
        decoration: InputDecoration(
          hintText: hint, hintStyle: MyTextStyle.gilroyLight(color: fTextMuted, size: 13),
          labelText: label, labelStyle: MyTextStyle.gilroyLight(color: fTextSecondary, size: 12),
          prefixText: prefixText, prefixStyle: MyTextStyle.gilroyBold(color: fGradStart, size: 16),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: fTextMuted) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
