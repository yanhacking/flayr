import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:proste_indexed_stack/proste_indexed_stack.dart';
import 'package:untitled/common/managers/ads/banner_ad.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/common/widgets/functions.dart';
import 'package:untitled/screens/chats_screen/chats_screen.dart';
import 'package:untitled/screens/chats_screen/chats_screen_controller.dart';
import 'package:untitled/screens/dashboard_reels_screen/dashboard_reels_screen.dart';
import 'package:untitled/screens/feed_screen/feed_screen.dart';
import 'package:untitled/screens/profile_screen/profile_screen.dart';
import 'package:untitled/screens/rooms_screen/rooms_screen.dart';
import 'package:untitled/screens/feed_screen/feed_screen.dart' show refreshIndicatorKey;
import 'package:untitled/screens/tabbar/tabbar_controller.dart';
import 'package:untitled/utilities/const.dart';

class TabBarScreen extends StatelessWidget {
  TabBarScreen({Key? key}) : super(key: key);
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final TabBarController controller = Get.put(TabBarController());
    final ChatsScreensController chatCtrl = Get.put(ChatsScreensController());
    Functions.changStatusBar(StatusBarStyle.black);

    return Scaffold(
      backgroundColor: fBG,
      body: GetBuilder<TabBarController>(
        init: controller,
        builder: (ctrl) {
          return Stack(
            children: [
              // ── Screen content ──────────────────────────
              Column(
                children: [
                  Expanded(
                    child: ProsteIndexedStack(
                      index: ctrl.selectedTab,
                      children: [
                        IndexedStackChild(child: FeedScreen(scrollController: scrollController)),
                        IndexedStackChild(child: RoomsScreen()),
                        IndexedStackChild(child: DashboardReelsScreen(), preload: true),
                        IndexedStackChild(child: ChatsScreen(), preload: true),
                        IndexedStackChild(
                          child: ProfileScreen(
                            isFromTabBar: true,
                            userId: SessionManager.shared.getUserID(),
                          ),
                          preload: true,
                        ),
                      ],
                    ),
                  ),
                  BannerAdView(),
                  // Space for floating nav
                  const SizedBox(height: 90),
                ],
              ),

              // ── Floating bottom nav ──────────────────────
              Positioned(
                left: 20,
                right: 20,
                bottom: 24,
                child: GetBuilder<ChatsScreensController>(
                  init: chatCtrl,
                  builder: (chatCtrl) {
                    return _FlayrNavBar(
                      selectedIndex: ctrl.selectedTab,
                      hasUnread: chatCtrl.isNewMessage,
                      onTap: (index) {
                        if (index == 0 && ctrl.selectedTab == 0) {
                          HapticFeedback.mediumImpact();
                          if (scrollController.offset == 0) {
                            refreshIndicatorKey.currentState?.show();
                          } else {
                            scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOut,
                            );
                          }
                        }
                        ctrl.selectIndex(index);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Floating FLAYR Nav Bar
// ─────────────────────────────────────────────
class _FlayrNavBar extends StatelessWidget {
  final int selectedIndex;
  final bool hasUnread;
  final ValueChanged<int> onTap;

  const _FlayrNavBar({
    required this.selectedIndex,
    required this.hasUnread,
    required this.onTap,
  });

  static const _icons = [
    Icons.home_rounded,
    Icons.spatial_audio_rounded,
    Icons.play_circle_fill_rounded,
    Icons.chat_bubble_rounded,
    Icons.person_rounded,
  ];

  static const _labels = ['Feed', 'Rooms', 'Reels', 'Chat', 'Me'];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: fSurface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: fBorder, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (i) {
              return _NavItem(
                icon: _icons[i],
                label: _labels[i],
                isSelected: selectedIndex == i,
                hasBadge: i == 3 && hasUnread,
                onTap: () => onTap(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool hasBadge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.hasBadge,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 1.22)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_NavItem old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _ctrl.forward().then((_) => _ctrl.reverse());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: Get.width / 5 - 8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Neon glow pill behind icon when selected
                if (widget.isSelected)
                  Container(
                    width: 44,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [fGradStart, fGradEnd],
                      ),
                      boxShadow: neonGlow(fGradMid, blur: 12),
                    ),
                  ),

                AnimatedBuilder(
                  animation: _scale,
                  builder: (_, __) => Transform.scale(
                    scale: _scale.value,
                    child: widget.isSelected
                        ? ShaderMask(
                            shaderCallback: (b) => flayrGradient.createShader(b),
                            blendMode: BlendMode.srcIn,
                            child: Icon(widget.icon, size: 22, color: Colors.white),
                          )
                        : Icon(widget.icon, size: 22, color: fTextMuted),
                  ),
                ),

                // Unread badge
                if (widget.hasBadge)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: cRed,
                        shape: BoxShape.circle,
                        boxShadow: neonGlow(cRed, blur: 6),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: widget.isSelected ? 'gilroy_bold' : 'gilroy_regular',
                fontSize: 10,
                color: widget.isSelected ? fGradStart : fTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

