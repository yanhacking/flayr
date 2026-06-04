import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/localization/languages.dart';
import 'package:untitled/models/setting_model.dart';
import 'package:untitled/screens/extra_views/back_button.dart';
import 'package:untitled/screens/extra_views/buttons.dart';
import 'package:untitled/screens/extra_views/top_bar.dart';
import 'package:untitled/screens/profile_picture_screen/profile_picture_screen.dart';
import 'package:untitled/screens/profile_verification_screen/profile_verification_controller.dart';
import 'package:untitled/screens/rooms_you_own/create_room_screen/create_room_screen.dart';
import 'package:untitled/utilities/const.dart';

class ProfileVerificationScreen extends StatelessWidget {
  const ProfileVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ProfileVerificationController controller = ProfileVerificationController();
    return Scaffold(
      body: Column(
        children: [
          const TopBarForInView(title: LKeys.profileVerification),
          Expanded(
            child: SingleChildScrollView(
              child: GetBuilder(
                  init: controller,
                  builder: (controller) {
                    return Column(
                      children: [
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              SessionManager.shared.getUser()?.username ?? '',
                              style: MyTextStyle.gilroyBold(),
                            ),
                            const SizedBox(width: 5),
                            const VerifyIcon(isPlaceholder: true)
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: Get.width * 0.75,
                          child: Text(
                            LKeys.profileVerificationDesc.tr,
                            style: MyTextStyle.gilroyLight(color: cLightText, size: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (SessionManager.shared.getSettings()?.isInAppPurchaseEnabled == 1) ...[
                          segmentController(controller),
                          const Divider(),
                          methodCard(controller, controller.selectedMethod),
                        ],
                        controller.selectedMethod.method == VerificationMethod.document
                            ? documentVerificationView(controller)
                            : subscriptionView(controller),
                        const SizedBox(height: 40),
                        CommonButton(
                          text: (controller.selectedMethod.method == VerificationMethod.document)
                              ? LKeys.submit
                              : LKeys.subscribe,
                          onTap: controller.submitRequest,
                        )
                      ],
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget subscriptionView(ProfileVerificationController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: fGradStart.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: fGradStart.withValues(alpha: 0.25), width: 0.8),
            ),
            child: Column(
              children: [
                const Text('💎', style: TextStyle(fontSize: 38)),
                const SizedBox(height: 10),
                ShaderMask(
                  shaderCallback: (b) => flayrGradient.createShader(b),
                  blendMode: BlendMode.srcIn,
                  child: Text('FLAYR Premium',
                      style: MyTextStyle.gilroyBold(color: Colors.white, size: 20)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get your verified badge, unlimited FLAYR Pay, and more.\n\$4.99 / month  ·  \$39.99 / year (save 33%)',
                  style: MyTextStyle.gilroyLight(color: fTextSecondary, size: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: const [
                    _Chip('✓ Badge vérifié'),
                    _Chip('✓ FLAYR Pay'),
                    _Chip('✓ Sans pub'),
                    _Chip('✓ Quests ⚡'),
                    _Chip('✓ Rooms prioritaires'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.lock_rounded, size: 12, color: fTextMuted),
                  const SizedBox(width: 4),
                  Text('Secured by Stripe — No App Store fees',
                      style: MyTextStyle.gilroyLight(color: fTextMuted, size: 11)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: controller.restorePurchase,
            child: Text(
              LKeys.restorePurchase.tr,
              style: MyTextStyle.gilroyMedium(color: cLightText),
            ),
          ),
        ],
      ),
    );
  }

  Widget segmentController(ProfileVerificationController controller) {
    return CupertinoSlidingSegmentedControl(
      children: {
        controller.methods.first: buildSegment(LKeys.method1, 0, controller),
        controller.methods.last:  buildSegment(LKeys.method2, 1, controller),
      },
      groupValue: controller.selectedMethod,
      backgroundColor: cLightBg,
      thumbColor: cPrimary,
      padding: const EdgeInsets.all(0),
      onValueChanged: (value) {
        if (value is VerificationMethodModel) {
          controller.onChangeMethod(value);
        }
      },
    );
  }

  Widget buildSegment(String text, int index, ProfileVerificationController controller) {
    return Container(
      alignment: Alignment.center,
      width: (Get.width / 2) - 30,
      child: Text(
        text.tr.toUpperCase(),
        style: MyTextStyle.gilroySemiBold(
          size: 13,
          color: controller.selectedMethod == controller.methods[index] ? cBlack : cLightText,
        ).copyWith(letterSpacing: 2),
      ),
    );
  }

  Widget documentVerificationView(ProfileVerificationController controller) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const CreateRoomHeading(title: LKeys.fullName),
          MyTextField(
            controller: controller.fullNameController,
            placeHolder: SessionManager.shared.getUser()?.fullName ?? '',
          ),
          const SizedBox(height: 10),
          const CreateRoomHeading(title: LKeys.documentType),
          dropDown(controller),
          GestureDetector(
            onTap: controller.selectDocument,
            child: Container(
              decoration: BoxDecoration(
                color: cLightBg,
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Text(
                controller.selectedDocument?.name.replaceAll('image_picker_', '') ?? LKeys.selectDocument.tr,
                textAlign: TextAlign.center,
                style: MyTextStyle.gilroyLight(color: cLightText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const CreateRoomHeading(title: LKeys.yourSelfie),
          ProfileImagePicker(
            controller: controller,
            boxSize: Get.width / 2,
            radius: 100,
            onTap: () => controller.pickImage(source: ImageSource.camera),
          ),
        ],
      ),
    );
  }

  Widget dropDown(ProfileVerificationController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: cLightBg, borderRadius: BorderRadius.circular(8)),
      child: DropdownButton<SettingCommon>(
        borderRadius: BorderRadius.circular(12),
        dropdownColor: cLightBg,
        value: controller.selectedType,
        elevation: 16,
        isExpanded: true,
        underline: const SizedBox(),
        style: MyTextStyle.gilroyMedium(color: cLightText),
        onChanged: controller.onChangeType,
        items: controller.types.map<DropdownMenuItem<SettingCommon>>((SettingCommon value) {
          return DropdownMenuItem<SettingCommon>(
            value: value,
            child: Text(value.title ?? ''),
          );
        }).toList(),
      ),
    );
  }

  Widget methodCard(ProfileVerificationController controller, VerificationMethodModel method) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(method.title.tr, style: MyTextStyle.gilroyMedium(size: 18, color: cDarkText)),
          const SizedBox(height: 3),
          Text(method.desc.tr,  style: MyTextStyle.gilroyLight(size: 14,  color: cLightText)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fSurface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fBorder, width: 0.6),
      ),
      child: Text(label, style: const TextStyle(fontFamily: 'gilroy_regular', fontSize: 11, color: fTextSecondary)),
    );
  }
}
