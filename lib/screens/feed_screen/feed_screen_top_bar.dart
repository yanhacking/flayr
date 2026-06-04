import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/extensions/image_extension.dart';
import 'package:untitled/screens/audio_space/audio_spaces_screen/audio_spaces_screen.dart';
import 'package:untitled/screens/extra_views/logo_tag.dart';
import 'package:untitled/screens/notification_screen/notification_screen.dart';
import 'package:untitled/screens/random_screen/random_screen.dart';
import 'package:untitled/screens/search_screen/search_screen.dart';
import 'package:untitled/utilities/const.dart';

class FeedScreenTopBar extends StatelessWidget {
  const FeedScreenTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: fBG.withValues(alpha: 0.88),
            border: Border(
              bottom: BorderSide(color: fBorder, width: 0.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                // Notification
                _IconBtn(
                  icon: Icons.notifications_outlined,
                  onTap: () => Get.to(() => const NotificationScreen()),
                ),
                const SizedBox(width: 4),

                // Random discover
                _IconBtn(
                  icon: Icons.shuffle_rounded,
                  onTap: () => Get.to(() => RandomScreen()),
                ),

                // Center logo
                const Expanded(child: Center(child: LogoTagSmall())),

                // Audio Spaces
                _IconBtn(
                  icon: Icons.spatial_audio_off_rounded,
                  onTap: () => Get.to(() => const AudioSpacesScreen()),
                  hasGradient: true,
                ),
                const SizedBox(width: 4),

                // Search
                _IconBtn(
                  icon: Icons.search_rounded,
                  onTap: () => Get.to(() => const SearchScreen()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool hasGradient;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.hasGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: fSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: fBorder, width: 0.6),
        ),
        child: Center(
          child: hasGradient
              ? ShaderMask(
                  shaderCallback: (b) => flayrGradient.createShader(b),
                  blendMode: BlendMode.srcIn,
                  child: Icon(icon, size: 20, color: Colors.white),
                )
              : Icon(icon, size: 20, color: fTextSecondary),
        ),
      ),
    );
  }
}
