import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/extensions/image_extension.dart';
import 'package:untitled/common/widgets/no_data_view.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/models/chat.dart';
import 'package:untitled/screens/chats_screen/chat_view/chat_card.dart';
import 'package:untitled/screens/chats_screen/chats_screen_controller.dart';
import 'package:untitled/screens/extra_views/logo_tag.dart';
import 'package:untitled/utilities/const.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ChatsScreensController controller = Get.find<ChatsScreensController>();
    return GetBuilder<ChatsScreensController>(
        init: controller,
        builder: (controller) {
          return Container(
            color: fBG,
            child: Column(
              children: [
                top(controller),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      segmentController(controller),
                      const SizedBox(height: 12),
                      Expanded(
                        child: PageView(
                          controller: controller.controller,
                          onPageChanged: controller.onChangePage,
                          children: [
                            chatList(controller, 1),
                            chatList(controller, 2),
                            chatList(controller, 0),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget chatList(ChatsScreensController controller, int type) {
    List<ChatUserRoom> chats = (type == 2) ? controller.filterRoomChats : controller.filterChats.where((element) => element.type == type).toList();

    return NoDataView(
      showShow: chats.isEmpty,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 0),
        itemCount: chats.length,
        itemBuilder: (context, index) {
          var chatUserRoom = chats[index];
          return ChatCard(
            chatUserRoom: chatUserRoom,
            controller: controller,
          );
        },
      ),
    );
  }

  Widget segmentController(ChatsScreensController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: fSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fBorder, width: 0.6),
      ),
      child: Row(
        children: [
          _SegTab(label: LKeys.chats.tr, index: 0, controller: controller),
          _SegTab(label: LKeys.rooms.tr, index: 1, controller: controller),
          _SegTab(label: LKeys.requests.tr, index: 2, controller: controller),
        ],
      ),
    );
  }

  Widget buildSegment(String text, int index, ChatsScreensController controller) {
    return Container(
      alignment: Alignment.center,
      width: (Get.width / 3) - 30,
      child: Text(
        text.toUpperCase(),
        style: MyTextStyle.gilroySemiBold(size: 13, color: controller.selectedPage == index ? fTextPrimary : fTextMuted).copyWith(letterSpacing: 2),
      ),
    );
  }

  Widget top(ChatsScreensController controller) {
    double imageSize = controller.isSearching ? 17 : 22;
    return Container(
      color: fBG,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              controller.isSearching
                  ? Expanded(
                      child: TextField(
                        onChanged: controller.onChange,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: LKeys.searchHere.tr,
                          hintStyle: MyTextStyle.gilroyRegular(color: fTextMuted),
                          border: InputBorder.none,
                          counterText: '',
                          isDense: true,
                          contentPadding: const EdgeInsets.all(0),
                        ),
                        cursorColor: fGradStart,
                        style: MyTextStyle.gilroyRegular(color: fTextPrimary),
                        controller: controller.textEditingController,
                        textInputAction: TextInputAction.newline,
                        autofocus: true,
                      ),
                    )
                  : Expanded(
                      child: Row(
                        children: [
                          SizedBox(width: imageSize),
                          const Spacer(),
                          const LogoTag(),
                          const Spacer(),
                        ],
                      ),
                    ),
              GestureDetector(
                child: Icon(
                  controller.isSearching ? Icons.close_rounded : Icons.search_rounded,
                  color: fTextSecondary,
                  size: imageSize + 4,
                ),
                onTap: () {
                  controller.textEditingController.text = "";
                  controller.isSearching = !controller.isSearching;
                  controller.update();
                  controller.onChange('');
                },
              ),
            ],
          )),
    );
  }
}

class _SegTab extends StatelessWidget {
  final String label;
  final int index;
  final ChatsScreensController controller;

  const _SegTab({required this.label, required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    final active = controller.selectedPage == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.onChangeSegment(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: active ? flayrGradient as Gradient : null,
            boxShadow: active ? neonGlow(fGradMid, blur: 8) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label.toUpperCase(),
            style: MyTextStyle.gilroySemiBold(
              size: 11,
              color: active ? Colors.white : fTextMuted,
            ).copyWith(letterSpacing: 1.5),
          ),
        ),
      ),
    );
  }
}

class ChatSheetButton extends StatelessWidget {
  final String title;
  final Function() onTap;

  const ChatSheetButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(alignment: Alignment.center, width: double.infinity, color: fSurface, child: Text(title, style: MyTextStyle.gilroySemiBold(color: fTextPrimary, size: 18))),
      onTap: () {
        Get.back();
        onTap();
      },
    );
  }
}
