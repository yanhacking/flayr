import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/extensions/int_extension.dart';
import 'package:untitled/common/widgets/my_cached_image.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/models/room_model.dart';
import 'package:untitled/screens/chats_screen/chatting_screen/chatting_view.dart';
import 'package:untitled/screens/rooms_screen/room_controller.dart';
import 'package:untitled/screens/rooms_screen/room_sheet.dart';
import 'package:untitled/utilities/const.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final bool isFromHome;

  const RoomCard({Key? key, required this.room, this.isFromHome = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = RoomController(room);
    return GetBuilder(
        tag: '${room.id}',
        init: controller,
        builder: (controller) {
          return GestureDetector(
            onTap: () {
              if (controller.room.getUserAccessType() == GroupUserAccessType.member || controller.room.getUserAccessType() == GroupUserAccessType.admin || controller.room.getUserAccessType() == GroupUserAccessType.coAdmin) {
                Get.to(() => ChattingView(room: controller.room))?.then(controller.onBack);
              } else {
                Get.bottomSheet(
                    RoomSheet(
                      controller: controller,
                      room: controller.room,
                    ),
                    isScrollControlled: true);
              }
            },
            child: isFromHome ? homeCard(controller) : simpleCard(controller),
          );
        });
  }

  Widget simpleCard(RoomController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: fBorder, width: 0.6),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with neon ring
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(colors: [fGradStart, fGradEnd]),
              boxShadow: neonGlow(fGradMid, blur: 8),
            ),
            padding: const EdgeInsets.all(1.5),
            child: MyCachedImage(imageUrl: controller.room.photo, width: 58, height: 58, cornerRadius: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.room.title ?? '',
                        style: MyTextStyle.gilroyBold(size: 16, color: fTextPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: fGradStart.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: fGradStart.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.headphones_rounded, size: 12, color: fGradStart),
                          const SizedBox(width: 4),
                          Text(
                            (controller.room.totalMember ?? 0).makeToString(),
                            style: MyTextStyle.gilroySemiBold(size: 12, color: fGradStart),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  controller.room.desc ?? '',
                  style: MyTextStyle.outfitLight(color: fTextSecondary, size: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: controller.room.getInterests().map((e) {
                    return RoomCardInterestTagToShow(tag: e.title ?? '', color: fNeonBlue);
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget homeCard(RoomController controller) {
    return AspectRatio(
      aspectRatio: .7,
      child: ClipSmoothRect(
        radius: const SmoothBorderRadius.all(SmoothRadius(cornerRadius: 15, cornerSmoothing: cornerSmoothing)),
        child: Column(
          children: [
            ClipSmoothRect(
              radius: const SmoothBorderRadius.vertical(top: SmoothRadius(cornerRadius: 15, cornerSmoothing: cornerSmoothing)),
              child: MyCachedImage(imageUrl: controller.room.photo, width: double.infinity, height: 110),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: ShapeDecoration(color: cDarkGreen, shape: SmoothRectangleBorder(borderRadius: SmoothBorderRadius.vertical(bottom: SmoothRadius(cornerRadius: 15, cornerSmoothing: 1)))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.room.title ?? '',
                          style: MyTextStyle.gilroySemiBold(color: cWhite),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${controller.room.getInterestWithHashtag().toLowerCase()}',
                          style: MyTextStyle.gilroyRegular(color: cPrimary),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ],
                    ),
                    RichText(
                      text: TextSpan(text: (controller.room.totalMember ?? 0).makeToString(), style: MyTextStyle.gilroySemiBold(size: 14, color: cWhite), children: [
                        TextSpan(
                          text: ' ${LKeys.members.tr}',
                          style: MyTextStyle.gilroyLight(size: 14, color: cWhite),
                        )
                      ]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RoomCardInterestTagToShow extends StatelessWidget {
  const RoomCardInterestTagToShow({Key? key, required this.tag, this.color = fGradStart}) : super(key: key);
  final String tag;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.6),
      ),
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      child: Text(
        tag.toUpperCase(),
        style: MyTextStyle.gilroyBold(size: 11, color: color).copyWith(letterSpacing: 0.5),
      ),
    );
  }
}
