import 'package:flutter/material.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/screens/extra_views/logo_tag.dart';
import 'package:untitled/utilities/const.dart';

class RoomScreenTopBar extends StatelessWidget {
  const RoomScreenTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: fBG,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 13, right: 20, left: 20, bottom: 16),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const LogoTag(),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: fGradStart.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: fGradStart.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.headphones_rounded, size: 14, color: fGradStart),
                  const SizedBox(width: 6),
                  Text('Rooms', style: MyTextStyle.gilroyBold(color: fGradStart, size: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
