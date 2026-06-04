import 'dart:convert';
import 'dart:ui';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:untitled/common/extensions/date_time_extension.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/extensions/image_extension.dart';
import 'package:untitled/common/extensions/int_extension.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/common/widgets/buttons/play_button.dart';
import 'package:untitled/common/widgets/menu.dart';
import 'package:untitled/common/widgets/my_cached_image.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/models/posts_model.dart';
import 'package:untitled/screens/post/comment/comment_screen.dart';
import 'package:untitled/screens/post/post_controller.dart';
import 'package:untitled/screens/profile_screen/profile_screen.dart';
import 'package:untitled/screens/tag_screen/tag_screen.dart';
import 'package:untitled/utilities/const.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';
import '../extra_views/back_button.dart';
import '../tag_screen/tag_controller.dart';
import 'double_click_like.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final Function(int postID) onDeletePost;
  final Function() refreshView;

  const PostCard({
    super.key,
    required this.post,
    required this.onDeletePost,
    required this.refreshView,
  });

  @override
  Widget build(BuildContext context) {
    final controller = PostController(post, onDeletePost, refreshView);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: fSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fBorder, width: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 10, 0),
              child: PostTopBar(controller: controller),
            ),

            // ── Description ───────────────────────────
            if (controller.post.desc != null && controller.post.desc!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: PostDescriptionView(controller: controller),
              ),

            // ── Media content ─────────────────────────
            if (controller.post.content?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _contentView(controller),
              )
            else if (controller.post.linkPreview != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: UrlMetaDataCard(metadata: controller.post.linkPreview!),
              ),

            // ── Bottom bar ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: PostBottomBar(controller: controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contentView(PostController controller) {
    switch (controller.post.type) {
      case PostType.image:
        return _PostImageView(controller: controller);
      case PostType.video:
        return _PostVideoView(controller: controller);
      case PostType.audio:
        return _PostAudioView(controller: controller);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─────────────────────────────────────────────
//  Top Bar
// ─────────────────────────────────────────────
class PostTopBar extends StatelessWidget {
  final PostController controller;
  final bool isForVideo;

  const PostTopBar({Key? key, required this.controller, this.isForVideo = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(
        () => ProfileScreen(userId: controller.post.userId ?? 0),
        preventDuplicates: false,
      ),
      child: Row(
        children: [
          // Avatar with optional neon ring + mood badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [fGradStart, fGradEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: neonGlow(fGradMid, blur: 8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1.5),
                  child: MyCachedProfileImage(
                    imageUrl: controller.post.user?.profile,
                    width: 41,
                    height: 41,
                    fullName: controller.post.user?.fullName,
                    cornerRadius: 12,
                  ),
                ),
              ),
              // Mood badge
              if ((controller.post.user?.moodEmoji ?? '').isNotEmpty)
                Positioned(
                  right: -6,
                  bottom: -6,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: fSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: fBorder, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      controller.post.user!.moodEmoji!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),

          // Name + username
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        controller.post.user?.fullName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: MyTextStyle.gilroyBold(
                          color: isForVideo ? fTextPrimary : fTextPrimary,
                          size: 15,
                        ),
                      ),
                    ),
                    VerifyIcon(user: controller.post.user),
                  ],
                ),
                Text(
                  '@${controller.post.user?.username ?? ''}',
                  style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 13),
                ),
              ],
            ),
          ),

          // Time + menu
          Text(
            controller.post.date.timeAgo(),
            style: MyTextStyle.gilroyLight(size: 12, color: fTextMuted),
          ),
          const SizedBox(width: 6),
          PostMenuButton(controller: controller, isForVideo: isForVideo),
          if (isForVideo) ...[const SizedBox(width: 8), const XMarkButton()],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Description
// ─────────────────────────────────────────────
class PostDescriptionView extends StatelessWidget {
  final PostController controller;
  final bool isForVideo;

  const PostDescriptionView({
    Key? key,
    required this.controller,
    this.isForVideo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReadMoreText(
      controller.post.desc ?? '',
      style: MyTextStyle.outfitLight(
        size: 14,
        color: isForVideo ? fTextSecondary : fTextPrimary,
      ),
      annotations: [
        Annotation(
          regExp: RegExp(r'#([a-zA-Z0-9_]+)'),
          spanBuilder: ({required String text, TextStyle? textStyle}) => TextSpan(
            text: text,
            style: textStyle?.copyWith(
              color: fNeonBlue,
              fontFamily: 'outfit_medium',
              fontSize: 14,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (text.startsWith('#')) {
                  Get.delete<TagController>().then((_) {
                    Get.to(
                      () => TagScreen(tag: text, isForReel: false),
                      preventDuplicates: false,
                    );
                  });
                }
              },
          ),
        ),
      ],
      trimMode: TrimMode.Line,
      trimLines: 4,
      trimCollapsedText: '  ${LKeys.showMore.tr}',
      trimExpandedText: '  ${LKeys.showLess.tr}',
      moreStyle: MyTextStyle.outfitRegular(color: fGradStart, size: 13),
      lessStyle: MyTextStyle.outfitRegular(color: fGradStart, size: 13),
    );
  }
}

// ─────────────────────────────────────────────
//  Bottom Bar — Vibe Score replaces simple like
// ─────────────────────────────────────────────
class PostBottomBar extends StatelessWidget {
  final PostController controller;
  final bool isForVideo;

  const PostBottomBar({Key? key, required this.controller, this.isForVideo = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Comment button
        GetBuilder<PostController>(
          init: controller,
          tag: '${controller.post.id}',
          id: 'comment',
          builder: (_) => GestureDetector(
            onTap: () {
              Get.bottomSheet(
                CommentScreen(postController: controller),
                isScrollControlled: true,
                ignoreSafeArea: false,
              ).then((_) {
                controller.update(['comment']);
                controller.update();
                controller.refreshView();
              });
            },
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 20,
                  color: isForVideo ? fTextPrimary : fTextSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  controller.post.commentsCount.makeToString(),
                  style: MyTextStyle.gilroyRegular(
                    size: 13,
                    color: isForVideo ? fTextPrimary : fTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 14),

        // Vibe Score — replaces plain "like"
        Expanded(child: _VibeScoreRow(controller: controller, isForVideo: isForVideo)),

        // Share
        GestureDetector(
          onTap: controller.sharePost,
          child: Icon(
            Icons.ios_share_rounded,
            size: 20,
            color: isForVideo ? fTextPrimary : fTextSecondary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Vibe Score Row  🔥 💧 🌪️ 💎
// ─────────────────────────────────────────────
class _VibeScoreRow extends StatelessWidget {
  final PostController controller;
  final bool isForVideo;

  const _VibeScoreRow({required this.controller, required this.isForVideo});

  static const _vibes = [
    _Vibe(emoji: '🔥', label: 'fire',  color: fVibeFireColor),
    _Vibe(emoji: '💧', label: 'chill', color: fVibeChillColor),
    _Vibe(emoji: '🌪️', label: 'wild',  color: fVibeWildColor),
    _Vibe(emoji: '💎', label: 'deep',  color: fVibeDeepColor),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final liked    = controller.isLiked.value;
      final vibe     = controller.currentVibe.value;
      final count    = controller.post.likesCount ?? 0;
      final active   = _vibes.firstWhere((v) => v.label == vibe,
          orElse: () => _vibes.first);

      return Row(
        children: [
          // Main vibe button — shows active reaction
          GestureDetector(
            onTap: controller.toggleFav,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: liked ? active.color.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: liked ? active.color.withValues(alpha: 0.4) : fBorder,
                  width: 0.8,
                ),
                boxShadow: liked ? neonGlow(active.color, blur: 8) : null,
              ),
              child: Row(
                children: [
                  Text(active.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 5),
                  Text(
                    count.makeToString(),
                    style: MyTextStyle.gilroyBold(
                      size: 13,
                      color: liked ? active.color : fTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Quick vibe reactions (compact row — skip the active one)
          for (final v in _vibes.where((v) => v.label != vibe || !liked))
            _MiniVibeButton(vibe: v, controller: controller),
        ],
      );
    });
  }
}

class _MiniVibeButton extends StatelessWidget {
  final _Vibe vibe;
  final PostController controller;

  const _MiniVibeButton({required this.vibe, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.setVibe(vibe.label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        child: Text(vibe.emoji, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}

class _Vibe {
  final String emoji;
  final String label;
  final Color color;
  const _Vibe({required this.emoji, required this.label, required this.color});
}

// ─────────────────────────────────────────────
//  Menu
// ─────────────────────────────────────────────
class PostMenuButton extends StatelessWidget {
  final PostController controller;
  final bool isForVideo;

  const PostMenuButton({Key? key, required this.controller, required this.isForVideo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Menu(
      isFromPost: true,
      items: [
        if (SessionManager.shared.getUserID() == controller.post.userId)
          PopupMenuItem(
            textStyle: MyTextStyle.gilroyRegular(color: fTextPrimary),
            onTap: controller.showWhoLikedThePost,
            child: Text(LKeys.seeWhoLikedPost.tr),
          ),
        PopupMenuItem(
          textStyle: MyTextStyle.gilroyRegular(color: fTextPrimary),
          onTap: controller.deleteOrReport,
          child: Text(
            controller.post.userId == SessionManager.shared.getUserID()
                ? LKeys.delete.tr
                : LKeys.report.tr,
          ),
        ),
        if (SessionManager.shared.getUserID() != controller.post.userId &&
            SessionManager.shared.getUser()?.isModerator == 1)
          PopupMenuItem(
            textStyle: MyTextStyle.gilroyRegular(color: fTextPrimary),
            onTap: controller.deletePosyByModerator,
            child: Text(LKeys.delete.tr),
          ),
        PopupMenuItem(
          textStyle: MyTextStyle.gilroyRegular(color: fTextPrimary),
          onTap: controller.sharePost,
          child: Text(LKeys.share.tr),
        ),
      ],
      isForVideo: isForVideo,
    );
  }
}

// ─────────────────────────────────────────────
//  Image view
// ─────────────────────────────────────────────
class PostImagesPageView extends StatelessWidget {
  final PostController controller;

  const PostImagesPageView({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.post.content?.isEmpty != false) return const SizedBox.shrink();

    return GetBuilder<PostController>(
      init: controller,
      tag: '${controller.post.id}',
      id: 'pageView',
      builder: (ctrl) {
        final count = controller.post.content?.length ?? 0;
        final double? height = count == 1 ? null : Get.width;

        return count == 1
            ? _imageWidget(imageUrl: controller.post.content?.first.content, height: height)
            : SizedBox(
                height: Get.width,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView.builder(
                      onPageChanged: ctrl.onPageChange,
                      itemCount: count,
                      itemBuilder: (_, i) => _imageWidget(
                        imageUrl: controller.post.content![i].content,
                        height: height,
                      ),
                    ),
                    // Page indicator
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(count, (i) {
                          final selected = ctrl.selectedImageIndex == i;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: selected ? 18 : 5,
                            height: 5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: selected ? flayrGradient : null,
                              color: selected ? null : fTextMuted,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }

  Widget _imageWidget({String? imageUrl, double? height}) {
    return ZoomOverlay(
      modalBarrierColor: Colors.black.withValues(alpha: 0.75),
      minScale: 1,
      maxScale: 3.0,
      animationCurve: Curves.fastOutSlowIn,
      animationDuration: const Duration(milliseconds: 300),
      twoTouchOnly: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: BoxConstraints(maxHeight: Get.height / 1.4),
          child: FadeInImage(
            placeholder: AssetImage(MyImages.placeHolderImage),
            image: NetworkImage(imageUrl?.addBaseURL() ?? ''),
            imageErrorBuilder: (_, __, ___) =>
                Image.asset(MyImages.placeHolderImage, height: Get.width),
            width: Get.width,
            height: height,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _PostImageView extends StatelessWidget {
  final PostController controller;
  const _PostImageView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return DoubleClickLikeAnimator(
      child: PostImagesPageView(controller: controller),
      onAnimation: () {
        if (controller.post.isLike == 0) controller.likeFromDoubleTap();
      },
      onTap: controller.openVideoSheet,
    );
  }
}

class _PostVideoView extends StatelessWidget {
  final PostController controller;
  const _PostVideoView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return DoubleClickLikeAnimator(
      child: GestureDetector(
        onTap: controller.openVideoSheet,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: Get.width,
                width: double.infinity,
                child: MyCachedImage(
                  imageUrl: controller.post.content?.first.thumbnail ?? '',
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.35),
                    ],
                  ),
                ),
              ),
              // Gradient play button
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: flayrGradient as Gradient,
                  boxShadow: neonGlow(fGradMid, blur: 16),
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 30),
              ),
            ],
          ),
        ),
      ),
      onAnimation: () {
        if (controller.post.isLike == 0) controller.likeFromDoubleTap();
      },
      onTap: controller.openVideoSheet,
    );
  }
}

class _PostAudioView extends StatelessWidget {
  final PostController controller;
  const _PostAudioView({required this.controller});

  @override
  Widget build(BuildContext context) {
    List<double> waves = [];
    try {
      waves = (jsonDecode(controller.post.content?.first.audioWaves ?? '[]') as List)
          .map((e) => e as double)
          .toList();
    } catch (_) {}
    if (controller.post.content?.isEmpty == true) return const SizedBox.shrink();

    return GestureDetector(
      onTap: controller.openAudioSheet,
      child: WaveCard(waves: waves),
    );
  }
}

// Re-export so callers can still reference PostImagesPageView for video sheets
class PostVideoElement extends StatelessWidget {
  final PostController controller;
  const PostVideoElement({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) => _PostVideoView(controller: controller);
}

class PostAudioElement extends StatelessWidget {
  final PostController controller;
  const PostAudioElement({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) => _PostAudioView(controller: controller);
}
