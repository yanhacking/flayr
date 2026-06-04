import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/utilities/const.dart';

// ─────────────────────────────────────────────
//  Social Quests — Modèles
// ─────────────────────────────────────────────
enum QuestDifficulty { easy, medium, hard }

class SocialQuest {
  final String emoji;
  final String title;
  final String description;
  final int points;
  final QuestDifficulty difficulty;
  final bool completed;

  const SocialQuest({
    required this.emoji,
    required this.title,
    required this.description,
    required this.points,
    required this.difficulty,
    this.completed = false,
  });

  Color get difficultyColor {
    switch (difficulty) {
      case QuestDifficulty.easy:   return fNeonGreen;
      case QuestDifficulty.medium: return fGradStart;
      case QuestDifficulty.hard:   return fGradEnd;
    }
  }

  String get difficultyLabel {
    switch (difficulty) {
      case QuestDifficulty.easy:   return 'Easy';
      case QuestDifficulty.medium: return 'Medium';
      case QuestDifficulty.hard:   return 'Hard';
    }
  }
}

const List<SocialQuest> kDailyQuests = [
  SocialQuest(
    emoji: '🔥',
    title: 'Drop a fire post',
    description: 'Share something that will get 🔥 vibes today',
    points: 50,
    difficulty: QuestDifficulty.easy,
  ),
  SocialQuest(
    emoji: '💬',
    title: 'Start a conversation',
    description: 'Comment on 3 different posts meaningfully',
    points: 75,
    difficulty: QuestDifficulty.easy,
  ),
  SocialQuest(
    emoji: '🎤',
    title: 'Go live in a Room',
    description: 'Join an audio room and speak for at least 2 minutes',
    points: 120,
    difficulty: QuestDifficulty.medium,
  ),
  SocialQuest(
    emoji: '🎬',
    title: 'Post a Reel',
    description: 'Upload a reel with music. Bonus if it gets 10+ vibes',
    points: 150,
    difficulty: QuestDifficulty.medium,
  ),
  SocialQuest(
    emoji: '💎',
    title: 'Send a Tip',
    description: 'Send a tip to a creator you love via FLAYR Pay',
    points: 100,
    difficulty: QuestDifficulty.medium,
  ),
  SocialQuest(
    emoji: '🕰️',
    title: 'Seal a capsule',
    description: 'Create a Time Capsule that opens in 1+ month',
    points: 200,
    difficulty: QuestDifficulty.hard,
  ),
  SocialQuest(
    emoji: '🤝',
    title: 'Make a connection',
    description: 'Follow 2 new people with matching interests',
    points: 80,
    difficulty: QuestDifficulty.easy,
    completed: true,
  ),
];

// ─────────────────────────────────────────────
//  Social Quests Screen
// ─────────────────────────────────────────────
class SocialQuestsScreen extends StatelessWidget {
  const SocialQuestsScreen({Key? key}) : super(key: key);

  static const int _totalPoints = 1340;
  static const int _todayPoints = 80;
  static const int _level = 7;

  @override
  Widget build(BuildContext context) {
    final completed = kDailyQuests.where((q) => q.completed).length;
    final total = kDailyQuests.length;

    return Scaffold(
      backgroundColor: fBG,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
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
                  ShaderMask(
                    shaderCallback: (b) => flayrGradient.createShader(b),
                    blendMode: BlendMode.srcIn,
                    child: Text('Daily Quests',
                        style: MyTextStyle.gilroyBold(color: Colors.white, size: 18)),
                  ),
                  const Spacer(),
                  // Points badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: flayrGradient as Gradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: neonGlow(fGradMid, blur: 8),
                    ),
                    child: Row(
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text('$_totalPoints',
                            style: MyTextStyle.gilroyBold(
                                color: Colors.white, size: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Level & Progress card ───────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: fSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: fBorder, width: 0.7),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Level badge
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            gradient: flayrGradient as Gradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: neonGlow(fGradMid, blur: 10),
                          ),
                          child: Center(
                            child: Text('L$_level',
                                style: MyTextStyle.gilroyBold(
                                    color: Colors.white, size: 16)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('FLAYR Level $_level',
                                  style: MyTextStyle.gilroyBold(
                                      color: fTextPrimary, size: 15)),
                              const SizedBox(height: 2),
                              Text('+$_todayPoints pts today',
                                  style: MyTextStyle.gilroyLight(
                                      color: fNeonGreen, size: 12)),
                              const SizedBox(height: 8),
                              // Progress bar
                              Stack(
                                children: [
                                  Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: fSurface2,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: 0.62,
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        gradient: flayrGradient as Gradient,
                                        borderRadius: BorderRadius.circular(3),
                                        boxShadow: neonGlow(fGradMid, blur: 4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('62%',
                            style: MyTextStyle.gilroyBold(
                                color: fGradStart, size: 14)),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Container(height: 0.5, color: fBorder),
                    const SizedBox(height: 14),

                    // Daily progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatPill(
                            label: 'Completed',
                            value: '$completed/$total',
                            color: fNeonGreen),
                        _StatPill(
                            label: 'Points available',
                            value: '${kDailyQuests.where((q) => !q.completed).fold(0, (s, q) => s + q.points)}',
                            color: fGradStart),
                        _StatPill(label: 'Streak', value: '4 🔥', color: fVibeFireColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Quests list ─────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: kDailyQuests.length,
                itemBuilder: (_, i) => _QuestCard(quest: kDailyQuests[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _QuestCard extends StatefulWidget {
  final SocialQuest quest;
  const _QuestCard({required this.quest});

  @override
  State<_QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<_QuestCard> {
  bool _claimed = false;

  @override
  Widget build(BuildContext context) {
    final done = widget.quest.completed || _claimed;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: done ? fSurface.withValues(alpha: 0.5) : fSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: done
              ? fNeonGreen.withValues(alpha: 0.3)
              : fBorder,
          width: 0.7,
        ),
        boxShadow: done ? neonGlow(fNeonGreen, blur: 6) : null,
      ),
      child: Row(
        children: [
          // Emoji icon
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: done
                  ? fNeonGreen.withValues(alpha: 0.1)
                  : widget.quest.difficultyColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: done
                    ? fNeonGreen.withValues(alpha: 0.3)
                    : widget.quest.difficultyColor.withValues(alpha: 0.25),
              ),
            ),
            child: Center(
              child: done
                  ? const Text('✅', style: TextStyle(fontSize: 20))
                  : Text(widget.quest.emoji,
                      style: const TextStyle(fontSize: 20)),
            ),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.quest.title,
                  style: TextStyle(
                    fontFamily: 'gilroy_bold',
                    fontSize: 14,
                    color: done ? fTextMuted : fTextPrimary,
                    decoration: done ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.quest.description,
                  style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 12),
                  maxLines: 2,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            widget.quest.difficultyColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: widget.quest.difficultyColor.withValues(alpha: 0.25),
                          width: 0.7,
                        ),
                      ),
                      child: Text(
                        widget.quest.difficultyLabel,
                        style: TextStyle(
                          fontFamily: 'gilroy_bold',
                          fontSize: 10,
                          color: widget.quest.difficultyColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Points / claim
          done
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: fNeonGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: fNeonGreen.withValues(alpha: 0.3), width: 0.7),
                  ),
                  child: Text('Done',
                      style: MyTextStyle.gilroyBold(
                          color: fNeonGreen, size: 12)),
                )
              : GestureDetector(
                  onTap: () {
                    setState(() => _claimed = true);
                    HapticFeedback.heavyImpact();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: flayrGradient as Gradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: neonGlow(fGradMid, blur: 8),
                    ),
                    child: Column(
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 12)),
                        Text('+${widget.quest.points}',
                            style: MyTextStyle.gilroyBold(
                                color: Colors.white, size: 12)),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
              fontFamily: 'gilroy_extrabold',
              fontSize: 16,
              color: color,
            )),
        Text(label,
            style: MyTextStyle.gilroyLight(color: fTextMuted, size: 10)),
      ],
    );
  }
}
