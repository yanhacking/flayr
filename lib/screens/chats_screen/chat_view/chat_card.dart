import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/extensions/date_time_extension.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/extensions/int_extension.dart';
import 'package:untitled/common/managers/context_menu_widget.dart';
import 'package:untitled/common/widgets/my_cached_image.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/models/chat.dart';
import 'package:untitled/screens/chats_screen/chats_screen_controller.dart';
import 'package:untitled/screens/chats_screen/chatting_screen/chatting_view.dart';
import 'package:untitled/screens/extra_views/back_button.dart';
import 'package:untitled/utilities/const.dart';

class ChatCard extends StatelessWidget {
  final ChatUserRoom chatUserRoom;
  final ChatsScreensController controller;

  const ChatCard({Key? key, required this.chatUserRoom, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ContextMenuWidget(
        child: GestureDetector(
          onTap: () {
            Get.to(() => ChattingView(chatUserRoom: chatUserRoom));
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: fSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: fBorder, width: 0.6),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              children: [
                // Avatar with gradient ring for unread
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: (chatUserRoom.newMsgCount != 0)
                        ? const LinearGradient(colors: [fGradStart, fGradEnd])
                        : null,
                    color: (chatUserRoom.newMsgCount == 0) ? fBorder : null,
                  ),
                  padding: const EdgeInsets.all(1.5),
                  child: MyCachedProfileImage(
                    imageUrl: chatUserRoom.profileImage,
                    fullName: chatUserRoom.title,
                    width: 48,
                    height: 48,
                    cornerRadius: 12,
                  ),
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
                              chatUserRoom.title ?? '',
                              style: MyTextStyle.gilroyBold(size: 15, color: fTextPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const VerifyIcon(),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        chatUserRoom.lastMsg ?? '',
                        style: MyTextStyle.gilroyLight(size: 13, color: fTextMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      chatUserRoom.time?.timeAgo() ?? '',
                      style: MyTextStyle.gilroyLight(size: 11, color: fTextMuted),
                    ),
                    const SizedBox(height: 4),
                    if ((chatUserRoom.newMsgCount ?? 0) != 0)
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [fGradStart, fGradEnd]),
                        ),
                        child: Text(
                          chatUserRoom.newMsgCount == -1
                              ? ''
                              : chatUserRoom.newMsgCount?.makeToString() ?? '',
                          style: MyTextStyle.gilroySemiBold(size: 11, color: Colors.white),
                        ),
                      )
                    else
                      const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
        menuProvider: (request) {
          return Menu(children: [
            MenuAction(
              title: chatUserRoom.newMsgCount == 0 ? LKeys.markAsUnread.tr : LKeys.markAsRead.tr,
              callback: () => controller.markToggle(chatUserRoom),
            ),
            MenuAction(
              title: LKeys.clearChat.tr,
              callback: () => controller.clearChat(chatUserRoom),
            ),
            MenuAction(
              title: LKeys.deleteChat.tr,
              callback: () => controller.deleteChat(chatUserRoom),
            ),
          ]);
        },
      ),
    );
  }
}
