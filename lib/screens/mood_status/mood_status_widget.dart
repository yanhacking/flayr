import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/utilities/const.dart';

// ─────────────────────────────────────────────
//  Mood Status — Modèle
// ─────────────────────────────────────────────
class MoodStatus {
  final String emoji;
  final String label;
  final String subLabel;
  final Color color;

  const MoodStatus({
    required this.emoji,
    required this.label,
    required this.subLabel,
    required this.color,
  });
}

const List<MoodStatus> kMoodPresets = [
  MoodStatus(emoji: '🎮', label: 'Gaming',   subLabel: 'In the zone',     color: fNeonBlue),
  MoodStatus(emoji: '🎵', label: 'Music',    subLabel: 'Vibing hard',      color: fNeonPurple),
  MoodStatus(emoji: '🔥', label: 'Creating', subLabel: 'Making something', color: fVibeFireColor),
  MoodStatus(emoji: '🏋️', label: 'Workout', subLabel: 'Getting gains',    color: fNeonGreen),
  MoodStatus(emoji: '😴', label: 'Chilling', subLabel: 'Do not disturb',   color: fTextMuted),
  MoodStatus(emoji: '✈️', label: 'Travel',  subLabel: 'On the go',        color: fGradStart),
  MoodStatus(emoji: '📚', label: 'Study',   subLabel: 'Head down',        color: fGradEnd),
  MoodStatus(emoji: '🌙', label: 'Late night', subLabel: 'Night owl',     color: fNeonPurple),
];

// ─────────────────────────────────────────────
//  Compact badge shown on profile / feed card
// ─────────────────────────────────────────────
class MoodBadge extends StatelessWidget {
  final MoodStatus mood;
  final bool compact;

  const MoodBadge({Key? key, required this.mood, this.compact = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: mood.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mood.color.withValues(alpha: 0.3), width: 0.8),
        boxShadow: neonGlow(mood.color, blur: 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mood.emoji, style: TextStyle(fontSize: compact ? 12 : 14)),
          const SizedBox(width: 4),
          Text(
            mood.label,
            style: TextStyle(
              fontFamily: 'gilroy_bold',
              fontSize: compact ? 11 : 12,
              color: mood.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Mood Picker Bottom Sheet
// ─────────────────────────────────────────────
class MoodPickerSheet extends StatefulWidget {
  final MoodStatus? current;
  final ValueChanged<MoodStatus?> onSelected;

  const MoodPickerSheet({Key? key, this.current, required this.onSelected})
      : super(key: key);

  @override
  State<MoodPickerSheet> createState() => _MoodPickerSheetState();
}

class _MoodPickerSheetState extends State<MoodPickerSheet> {
  MoodStatus? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: fSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: fBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),

          // Title
          Row(
            children: [
              ShaderMask(
                shaderCallback: (b) => flayrGradient.createShader(b),
                blendMode: BlendMode.srcIn,
                child: Text(
                  'Set your mood',
                  style: MyTextStyle.gilroyBold(color: Colors.white, size: 20),
                ),
              ),
              const Spacer(),
              if (_selected != null)
                GestureDetector(
                  onTap: () {
                    setState(() => _selected = null);
                    widget.onSelected(null);
                    HapticFeedback.selectionClick();
                    Get.back();
                  },
                  child: Text(
                    'Clear',
                    style: MyTextStyle.gilroyRegular(color: fTextSecondary, size: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // Mood grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3.0,
            ),
            itemCount: kMoodPresets.length,
            itemBuilder: (_, i) {
              final mood = kMoodPresets[i];
              final isSelected = _selected?.label == mood.label;
              return GestureDetector(
                onTap: () {
                  setState(() => _selected = mood);
                  HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? mood.color.withValues(alpha: 0.15)
                        : fSurface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? mood.color.withValues(alpha: 0.5)
                          : fBorder,
                      width: isSelected ? 1.2 : 0.7,
                    ),
                    boxShadow: isSelected ? neonGlow(mood.color, blur: 8) : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(mood.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mood.label,
                            style: TextStyle(
                              fontFamily: 'gilroy_bold',
                              fontSize: 13,
                              color: isSelected ? mood.color : fTextPrimary,
                            ),
                          ),
                          Text(
                            mood.subLabel,
                            style: TextStyle(
                              fontFamily: 'gilroy_light',
                              fontSize: 10,
                              color: isSelected
                                  ? mood.color.withValues(alpha: 0.7)
                                  : fTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          // Confirm button
          GestureDetector(
            onTap: () {
              if (_selected != null) {
                widget.onSelected(_selected);
                HapticFeedback.mediumImpact();
                Get.back();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: _selected != null ? flayrGradient as Gradient : null,
                color: _selected != null ? null : fSurface2,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _selected != null ? neonGlow(fGradMid, blur: 14) : null,
              ),
              child: Center(
                child: Text(
                  _selected != null ? 'Set "${_selected!.label}" mood' : 'Pick a mood first',
                  style: MyTextStyle.gilroyBold(
                    color: _selected != null ? Colors.white : fTextMuted,
                    size: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper to open the picker
void showMoodPicker({
  MoodStatus? current,
  required ValueChanged<MoodStatus?> onSelected,
}) {
  Get.bottomSheet(
    MoodPickerSheet(current: current, onSelected: onSelected),
    isScrollControlled: true,
    ignoreSafeArea: false,
  );
}
