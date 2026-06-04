import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/widgets/buttons/floating_btn_for_creating.dart';
import 'package:untitled/common/widgets/loader_widget.dart';
import 'package:untitled/common/widgets/no_data_view.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/screens/feed_screen/feed_screen_controller.dart';
export 'package:untitled/screens/feed_screen/feed_screen_controller.dart' show FeedScreenController;
import 'package:untitled/screens/feed_screen/feed_screen_top_bar.dart';
import 'package:untitled/screens/feed_screen/feed_stories_controller.dart';
import 'package:untitled/screens/feed_screen/feed_story_screen.dart';
import 'package:untitled/screens/post/post_card.dart';
import 'package:untitled/screens/rooms_screen/room_card.dart';
import 'package:untitled/utilities/const.dart';

final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
    GlobalKey<RefreshIndicatorState>();

class FeedScreen extends StatelessWidget {
  final ScrollController scrollController;

  const FeedScreen({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = FeedScreenController(
        isFromFeedScreen: true, scrollController: scrollController);
    final feedStoriesCtrl = FeedStoriesController();

    return Scaffold(
      backgroundColor: fBG,
      body: GetBuilder<FeedStoriesController>(
        init: feedStoriesCtrl,
        builder: (storiesCtrl) {
          return GetBuilder<FeedScreenController>(
            init: controller,
            builder: (ctrl) {
              return Stack(
                children: [
                  Column(
                    children: [
                      // ── Top bar ────────────────────────────
                      const FeedScreenTopBar(),

                      // ── Content ────────────────────────────
                      Expanded(
                        child: ctrl.isLoading.value && ctrl.posts.isEmpty
                            ? LoaderWidget()
                            : RefreshIndicator(
                                key: refreshIndicatorKey,
                                triggerMode: RefreshIndicatorTriggerMode.anywhere,
                                color: refreshIndicatorColor,
                                backgroundColor: refreshIndicatorBgColor,
                                onRefresh: () async {
                                  await ctrl.fetchFeeds(isForRefresh: true);
                                  await storiesCtrl.fetchStories();
                                  return storiesCtrl.fetchMyStories();
                                },
                                child: SingleChildScrollView(
                                  controller: ctrl.scrollController,
                                  primary: false,
                                  child: Column(
                                    children: [
                                      // Stories row
                                      FeedStoryScreen(controller: storiesCtrl),
                                      const SizedBox(height: 8),

                                      // Posts list
                                      _FeedsView(controller: ctrl),

                                      // Bottom padding for floating navbar
                                      const SizedBox(height: 100),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),

                  // FAB create
                  FloatingBtnForCreating(
                    onPostBack: (feed) {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        ctrl.posts.insert(0, feed);
                        ctrl.update([ctrl.feedViewID]);
                        ctrl.update();
                      });
                    },
                    onStoryBack: () => storiesCtrl.fetchMyStories(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Public wrapper used by ProfileScreen, TagScreen, SinglePostScreen
// ─────────────────────────────────────────────
class FeedsView extends StatelessWidget {
  final FeedScreenController controller;
  final String id;

  const FeedsView({Key? key, required this.controller, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedScreenController>(
      init: controller,
      tag: id,
      builder: (ctrl) {
        return NoDataView(
          showShow: ctrl.posts.isEmpty && !ctrl.isLoading.value,
          title: LKeys.noPosts.tr,
          child: SafeArea(
            top: false,
            child: ListView.builder(
              primary: false,
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 4),
              itemCount: ctrl.posts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  post: ctrl.posts[index],
                  onDeletePost: (id) {
                    ctrl.posts.removeWhere((p) => p.id == id);
                    ctrl.update();
                  },
                  refreshView: ctrl.update,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
class _FeedsView extends StatelessWidget {
  final FeedScreenController controller;

  const _FeedsView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedScreenController>(
      init: controller,
      tag: controller.feedViewID,
      builder: (ctrl) {
        return NoDataView(
          showShow: ctrl.posts.isEmpty && !ctrl.isLoading.value,
          title: LKeys.noPosts.tr,
          child: SafeArea(
            top: false,
            child: ListView.builder(
              primary: false,
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 4),
              itemCount: ctrl.posts.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    // Suggested rooms banner after post #2
                    if (index == 2 && ctrl.suggestedRooms.isNotEmpty)
                      _SuggestedRoomsBanner(rooms: ctrl.suggestedRooms),

                    PostCard(
                      post: ctrl.posts[index],
                      onDeletePost: (id) {
                        ctrl.posts.removeWhere((p) => p.id == id);
                        ctrl.update();
                      },
                      refreshView: ctrl.update,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Suggested Rooms Banner — dark neon style
// ─────────────────────────────────────────────
class _SuggestedRoomsBanner extends StatelessWidget {
  final List rooms;

  const _SuggestedRoomsBanner({required this.rooms});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: fSurface,
        border: Border(
          top: BorderSide(color: fBorder, width: 0.5),
          bottom: BorderSide(color: fBorder, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              ShaderMask(
                shaderCallback: (b) => flayrGradient.createShader(b),
                blendMode: BlendMode.srcIn,
                child: const Icon(Icons.spatial_audio_rounded, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                LKeys.suggested.tr,
                style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 14),
              ),
              const SizedBox(width: 4),
              ShaderMask(
                shaderCallback: (b) => flayrGradient.createShader(b),
                blendMode: BlendMode.srcIn,
                child: Text(
                  LKeys.rooms.tr,
                  style: MyTextStyle.gilroyBold(color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: rooms.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: RoomCard(room: rooms[i], isFromHome: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
