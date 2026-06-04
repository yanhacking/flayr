import 'dart:ui';

import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/extensions/image_extension.dart';
import 'package:untitled/common/extensions/int_extension.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/common/widgets/buttons/floating_btn_for_creating.dart';
import 'package:untitled/common/widgets/functions.dart';
import 'package:untitled/common/widgets/menu.dart';
import 'package:untitled/common/widgets/my_cached_image.dart';
import 'package:untitled/enums/reel_page_type.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/models/registration.dart';
import 'package:untitled/screens/chats_screen/chatting_screen/chatting_view.dart';
import 'package:untitled/screens/extra_views/back_button.dart';
import 'package:untitled/screens/feed_screen/feed_screen.dart';
import 'package:untitled/screens/follow_button/follow_button.dart';
import 'package:untitled/screens/profile_screen/follower_following/follower_following_screen.dart';
import 'package:untitled/screens/profile_screen/full_image_screen.dart';
import 'package:untitled/screens/profile_screen/profile_controller.dart';
import 'package:untitled/screens/reels_screen/reels_grid.dart';
import 'package:untitled/screens/report_screen/report_sheet.dart';
import 'package:untitled/screens/rooms_screen/room_card.dart';
import 'package:untitled/screens/setting_screen/setting_screen.dart';
import 'package:untitled/screens/social_quests/social_quests_screen.dart';
import 'package:untitled/screens/story_screen/story_screen.dart';
import 'package:untitled/utilities/const.dart';

class ProfileScreen extends StatelessWidget {
  final num userId;

  const ProfileScreen({Key? key, this.isFromTabBar = false, required this.userId}) : super(key: key);
  final bool isFromTabBar;

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = ProfileController(userId.toInt(), isFromTabBar);
    final bool isMyProfile = controller.userID == SessionManager.shared.getUserID();
    Functions.changStatusBar(StatusBarStyle.white);
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          GetBuilder(
              id: controller.scrollID,
              tag: controller.scrollID,
              init: controller,
              builder: (controller) {
                return RefreshIndicator(
                  triggerMode: RefreshIndicatorTriggerMode.anywhere,
                  color: refreshIndicatorColor,
                  backgroundColor: refreshIndicatorBgColor,
                  onRefresh: () async {
                    await controller.getProfile(isForRefresh: true);
                    await controller.fetchUserPosts(isForRefresh: true);
                    await controller.fetchReels(shouldRefresh: true);
                  },
                  child: CustomScrollView(
                    controller: controller.scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      GetBuilder(
                          id: controller.scrollID,
                          tag: controller.scrollID,
                          init: controller,
                          builder: (_) {
                            var temp = (controller.currentExtent * 0.28);
                            var size = temp < 35.0 ? 35.0 : temp;
                            var o = (-1 * (size - 70)) * 0.02857143;
                            var opacity = 1 - (o > 1.0 ? 1.0 : o);
                            return SliverAppBar(
                              pinned: true,
                              backgroundColor: Colors.transparent,
                              expandedHeight: controller.maxExtent,
                              collapsedHeight: 60,
                              stretch: true,
                              shadowColor: Colors.transparent,
                              leadingWidth: 0,
                              automaticallyImplyLeading: false,
                              flexibleSpace: FlexibleSpaceBar(
                                expandedTitleScale: 1,
                                titlePadding: const EdgeInsets.all(0),
                                collapseMode: CollapseMode.pin,
                                title: Stack(
                                  children: [
                                    Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            var backgroundImage = controller.user?.backgroundImage ?? '';
                                            if (backgroundImage.isNotEmpty) {
                                              Get.context!.pushTransparentRoute(
                                                FullImageScreen(
                                                  image: backgroundImage,
                                                  tag: 'BackgroundImage_${controller.userID}_${controller.idForImage}',
                                                  width: Get.width,
                                                  height: null,
                                                  cornerRadius: 0,
                                                ),
                                              );
                                            }
                                          },
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Container(color: cBlack),
                                              Hero(
                                                tag: 'BackgroundImage_${controller.userID}_${controller.idForImage}',
                                                child: MyCachedImage(
                                                  imageUrl: controller.user?.backgroundImage ?? '',
                                                  width: Get.width,
                                                  height: 170 + Get.mediaQuery.viewInsets.top,
                                                ),
                                              ),
                                              ClipRRect(
                                                // Clip it cleanly.
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(sigmaX: (1 - opacity) * 10, sigmaY: (1 - opacity) * 10),
                                                  child: Container(
                                                    color: Colors.black.withValues(alpha: (1 - opacity) / 2),
                                                    alignment: Alignment.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: isFromTabBar ? 15 : 45, vertical: 12),
                                          child: temp < 5 ? namePlate(controller, isFromTop: true) : Container(),
                                        ),
                                        top(controller, opacity)
                                      ],
                                    ),
                                    SafeArea(
                                      child: Container(
                                        // padding: const EdgeInsets.only(top: 18, right: 15, left: 7),
                                        child: Row(
                                          children: [
                                            !isFromTabBar
                                                ? GestureDetector(
                                                    onTap: () {
                                                      Get.back();
                                                    },
                                                    child: const Icon(
                                                      Icons.chevron_left_rounded,
                                                      color: cWhite,
                                                      size: 30,
                                                    ),
                                                  )
                                                : const SizedBox(
                                                    width: 30,
                                                    height: 30,
                                                  ),
                                            const Spacer(),
                                            if (isMyProfile)
                                              InkWell(
                                                onTap: () {
                                                  Get.to(() => const SettingScreen())?.then((value) {
                                                    controller.updateMyProfile();
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.only(top: 18, right: 15, left: 15, bottom: 15),
                                                  child: const Icon(
                                                    Icons.settings,
                                                    size: 24,
                                                    color: cWhite,
                                                  ),
                                                ),
                                              )
                                            else
                                              Container(
                                                padding: const EdgeInsets.only(top: 18, right: 15, left: 15, bottom: 15),
                                                child: profileMenu(controller),
                                              )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                stretchModes: const [StretchMode.zoomBackground],
                                // background: GestureDetector(
                                //   child: MyCachedImage(
                                //     imageUrl: controller.user?.backgroundImage ?? '',
                                //     // width: Get.width,
                                //     height: 190 + Get.mediaQuery.viewInsets.top,
                                //   ),
                                // ),
                              ),
                            );
                          }),
                      SliverToBoxAdapter(
                        child: Obx(
                          () => Column(
                            children: [
                              details(controller),
                              SizedBox(height: 10),
                              segmentController(controller),
                              SizedBox(height: 10),
                              if (controller.selectedPage.value == 0) postsView(controller) else gridReelsView(controller),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }),
          isMyProfile
              ? GetBuilder(
                  init: controller,
                  builder: (controller) {
                    return FloatingBtnForCreating(
                      onPostBack: (post) {
                        controller.fetchUserPosts(isForRefresh: true);
                      },
                      onStoryBack: () {
                        controller.getStories();
                      },
                      onReelBack: (reel) {
                        controller.fetchReels(shouldRefresh: true);
                      },
                    );
                  })
              : Container(),
        ],
      ),
    );
  }

  Widget gridReelsView(ProfileController controller) {
    return ReelsGrid(
      reels: controller.reels,
      reelType: ReelPageType.user,
      isLoading: controller.isLoading,
      onFetchMoreData: controller.fetchReels,
      shrinkWrap: true,
      user: controller.user,
      menus: [
        if (controller.userID == SessionManager.shared.getUserID())
          ContextMenuElement(
            title: LKeys.delete.tr,
            onTap: controller.deleteReel,
          ),
        if (SessionManager.shared.getUser()?.isModerator == 1 && controller.userID != SessionManager.shared.getUserID())
          ContextMenuElement(
            title: LKeys.delete.tr,
            onTap: controller.deleteReelByModerator,
          ),
      ],
    );
  }

  Widget top(ProfileController controller, double opacity) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 58,
          color: cBlack.withValues(alpha: opacity),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(width: isFromTabBar ? 0 : (1 - opacity) * 25),
                  GestureDetector(
                    onLongPress: () {
                      Get.context!.pushTransparentRoute(
                        FullImageScreen(
                          image: (controller.user?.profile ?? ''),
                          tag: 'ProfileImage${controller.userID}_${controller.idForImage}',
                          width: Get.width - 100,
                          height: Get.width - 100,
                        ),
                      );
                    },
                    onTap: () {
                      if ((controller.user?.stories ?? []).isNotEmpty) {
                        Get.bottomSheet(StoryScreen(users: [controller.user ?? User()], index: 0), isScrollControlled: true, ignoreSafeArea: false).then((value) {
                          controller.getStories();
                        });
                      } else {
                        Get.context!.pushTransparentRoute(
                          FullImageScreen(
                            image: (controller.user?.profile ?? ''),
                            tag: 'ProfileImage${controller.userID}_${controller.idForImage}',
                            width: Get.width - 100,
                            height: Get.width - 100,
                          ),
                        );
                      }
                    },
                    child: Opacity(
                      opacity: opacity,
                      child: Hero(
                        tag: 'ProfileImage${controller.userID}_${controller.idForImage}',
                        transitionOnUserGestures: true,
                        child: ClipSmoothRect(
                          radius: const SmoothBorderRadius.all(SmoothRadius(cornerRadius: 15, cornerSmoothing: cornerSmoothing)),
                          child: Container(
                            padding: EdgeInsets.all(2),
                            color: (controller.user?.stories ?? []).isEmpty ? Colors.transparent : (controller.user?.isAllStoryShown() == false ? cPrimary : cLightText),
                            child: MyCachedImage(
                              imageUrl: (controller.user?.profile ?? ''),
                              width: opacity == 0 ? 0 : 85,
                              height: opacity == 0 ? 0 : 85,
                              cornerRadius: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  (!(controller.user?.isBlockedByMe() ?? false)) ? Opacity(opacity: opacity, child: followBtn(controller)) : Container(),
                ],
              ),
            ),
            Container(
              height: 10,
            ),
          ],
        ),
      ],
    );
  }

  Widget namePlate(ProfileController controller, {bool isFromTop = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            Flexible(
              child: ShaderMask(
                shaderCallback: (bounds) => flayrGradient.createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Text(
                  controller.user?.fullName ?? '',
                  style: MyTextStyle.gilroyBlack(color: Colors.white, size: isFromTop ? 20 : 26),
                  maxLines: 1,
                ),
              ),
            ),
            VerifyIcon(user: controller.user),
          ],
        ),
        Text(
          '@${controller.user?.username ?? ''}',
          style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 13),
        ),
      ],
    );
  }

  Widget details(ProfileController controller) {
    return GetBuilder(
        init: controller,
        tag: "${controller.userID}",
        builder: (controller) {
          return controller.user == null
              ? Container()
              : Container(
                  padding: const EdgeInsets.all(15),
                  color: fBG,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      namePlate(controller),
                      const SizedBox(height: 10),
                      // Followers / Following stats
                      Row(
                        children: [
                          _StatChip(
                            value: controller.user?.followers?.makeToString() ?? '0',
                            label: LKeys.followers.tr,
                            onTap: () => Get.to(() => FollowerFollowingScreen(isForFollowing: false, user: controller.user)),
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            value: controller.user?.following?.makeToString() ?? '0',
                            label: LKeys.following.tr,
                            onTap: () => Get.to(() => FollowerFollowingScreen(isForFollowing: true, user: controller.user)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (controller.user?.bio != null && controller.user!.bio!.isNotEmpty)
                        Column(
                          children: [
                            DetectableText(
                              maxLines: null,
                              detectionRegExp: detectionRegExp(atSign: false, url: true)!,
                              onTap: (p0) async { controller.handleURL(url: p0); },
                              lessStyle: MyTextStyle.gilroyMedium(color: fGradStart),
                              moreStyle: MyTextStyle.gilroyMedium(color: fGradStart),
                              trimCollapsedText: LKeys.showMore.tr,
                              trimExpandedText: '  ${LKeys.showLess.tr}',
                              text: controller.user?.bio ?? '',
                              basicStyle: MyTextStyle.gilroyLight(size: 14, color: fTextSecondary),
                              detectedStyle: MyTextStyle.gilroyRegular(size: 14, color: fGradStart),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      Wrap(
                        children: (controller.user?.getInterestsStringList() ?? []).map((e) {
                          return RoomCardInterestTagToShow(
                            tag: e,
                          );
                        }).toList(),
                      ),
                      // Mood badge row
                      if ((controller.user?.moodEmoji ?? '').isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: fSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: fBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(controller.user!.moodEmoji!, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                controller.user?.moodLabel ?? '',
                                style: MyTextStyle.gilroyRegular(color: fTextSecondary, size: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Quests shortcut (own profile only)
                      if (controller.userID == SessionManager.shared.getUserID()) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => Get.to(() => const SocialQuestsScreen()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1A1A1A), Color(0xFF222222)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: fGradStart.withValues(alpha: 0.35)),
                              boxShadow: neonGlow(fGradMid, blur: 8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('⚡', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daily Quests',
                                      style: MyTextStyle.gilroyBold(color: fGradStart, size: 14),
                                    ),
                                    Text(
                                      'Earn points & level up',
                                      style: MyTextStyle.gilroyLight(color: fTextMuted, size: 11),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const Icon(Icons.chevron_right_rounded, color: fTextMuted, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
        });
  }

  Widget postsView(ProfileController controller) {
    return FeedsView(
      controller: controller,
      id: '${controller.userID}_${controller.profileFeedID}',
    );
  }

  Widget followBtn(ProfileController controller) {
    return GetBuilder<ProfileController>(
      init: controller,
      tag: "${controller.userID}",
      builder: (controller) {
        return controller.user?.id == SessionManager.shared.getUserID()
            ? Container()
            : GestureDetector(
                onTap: () {
                  Get.to(() => ChattingView(user: controller.user));
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(color: cPrimary.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: Image.asset(
                        MyImages.chatProfile,
                        width: 22,
                        height: 22,
                        color: cWhite,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (controller.user?.followingStatus != null)
                      FollowButton(
                        user: controller.user,
                        child: (isFollowing) {
                          return Container(
                            padding: const EdgeInsets.only(right: 25, left: 25, top: 10, bottom: 8),
                            decoration: BoxDecoration(color: isFollowing ? cDarkText.withValues(alpha: 0.7) : cWhite, borderRadius: BorderRadius.circular(100)),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  isFollowing ? LKeys.unFollow.tr : LKeys.follow.tr,
                                  style: MyTextStyle.gilroyBold(color: isFollowing ? cLightText : cBlack),
                                ),
                                Opacity(
                                  opacity: 0,
                                  child: Text(
                                    LKeys.unFollow.tr,
                                    style: MyTextStyle.gilroyBold(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        onChange: (user) {
                          controller.user?.followingStatus = user?.followingStatus;
                          controller.update();
                        },
                      ),
                  ],
                ),
              );
      },
    );
  }

  Widget profileMenu(ProfileController controller) {
    return Menu(items: [
      PopupMenuItem(
        onTap: controller.shareProfile,
        textStyle: MyTextStyle.gilroyMedium(),
        child: Text(LKeys.share.tr),
      ),
      PopupMenuItem(
        onTap: () {
          Future.delayed(const Duration(milliseconds: 1), () {
            Get.bottomSheet(ReportSheet(user: controller.user), isScrollControlled: true);
          });
        },
        textStyle: MyTextStyle.gilroyMedium(),
        child: Text(LKeys.report.tr),
      ),
      PopupMenuItem(
        textStyle: MyTextStyle.gilroyMedium(),
        child: Text(controller.user?.isBlockedByMe() ?? false ? LKeys.unBlock.tr : LKeys.block.tr),
        onTap: controller.blockUnblock,
      ),
      if (SessionManager.shared.getUserID() != controller.user?.id && SessionManager.shared.getUser()?.isModerator == 1 && controller.user?.isBlock == 0 && (controller.user?.isModerator != 1))
        PopupMenuItem(
          textStyle: MyTextStyle.gilroyMedium(),
          child: Text(LKeys.blockGlobally.tr),
          onTap: controller.blockByModerator,
        )
    ]);
  }

  Widget segmentController(ProfileController controller) {
    return Obx(
      () => CupertinoSlidingSegmentedControl(
        children: {0: buildSegment(LKeys.feed, 0, controller), 1: buildSegment(LKeys.reels, 1, controller)},
        groupValue: controller.selectedPage.value,
        // backgroundColor: cWhite.withValues(alpha: 0.12),
        // thumbColor: cWhite,
        backgroundColor: cLightText.withValues(alpha: 0.2),
        thumbColor: cBlack,
        padding: const EdgeInsets.all(0),
        onValueChanged: (value) {
          controller.onChangeSegment(value ?? 0);
        },
      ),
    );
  }

  Widget buildSegment(String text, int index, ProfileController controller) {
    final active = controller.selectedPage.value == index;
    return Container(
      alignment: Alignment.center,
      width: (Get.width / 2) - 30,
      child: Text(
        text.tr.toUpperCase(),
        style: MyTextStyle.gilroySemiBold(size: 13, color: active ? fTextPrimary : fTextMuted)
            .copyWith(letterSpacing: 2),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback onTap;

  const _StatChip({required this.value, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: fSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: fBorder, width: 0.8),
        ),
        child: Row(
          children: [
            Text(value, style: MyTextStyle.gilroyBold(color: fTextPrimary, size: 15)),
            const SizedBox(width: 4),
            Text(label, style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 13)),
          ],
        ),
      ),
    );
  }
}
