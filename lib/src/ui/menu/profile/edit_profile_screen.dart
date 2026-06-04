import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ketamiz/src/theme/app_theme.dart';
import 'package:ketamiz/src/ui/dialogs/bottom_dialog.dart';
import 'package:ketamiz/src/ui/dialogs/center_dialog.dart';
import 'package:ketamiz/src/ui/dialogs/snack_bar.dart';
import 'package:ketamiz/src/ui/widgets/buttons/secondary_button.dart';
import 'package:ketamiz/src/ui/widgets/containers/leading_back.dart';
import 'package:ketamiz/src/ui/widgets/textfield/main_textfield.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_16h_500w.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_18h_500w.dart';
import '../../../bloc/profile_bloc.dart';
import '../../../resources/repository.dart';
import '../../../utils/image_helper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final Repository _repository = Repository();
  bool isLoadingImage = false;
  bool isSaving = false;
  XFile avatar = XFile("");

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController fatherController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentInfo();
  }

  Future<void> _loadCurrentInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      firstNameController.text = prefs.getString('first_name') ?? '';
      lastNameController.text = prefs.getString('last_name') ?? '';
      fatherController.text = prefs.getString('father_name') ?? '';
      emailController.text = prefs.getString('email') ?? '';
      phoneController.text = prefs.getString('phone') ?? '';
    });
  }

  Future<void> _saveChanges() async {
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty) {
      CenterDialog.showActionFailed(
        context,
        translate("ketamiz.error"),
        translate("home.fill_all_fields"),
      );
      return;
    }

    setState(() => isSaving = true);

    final response = await _repository.fetchUpdateProfile(
      firstNameController.text.trim(),
      lastNameController.text.trim(),
      fatherController.text.trim(),
      emailController.text.trim(),
    );

    if (!mounted) return;
    setState(() => isSaving = false);

    if (response.isSuccess) {
      final result = response.result;
      final ok = result is Map &&
          (result['status'] == 'success' || result['status'] == 200);
      if (ok) {
        // Update local prefs immediately so the UI reflects changes instantly,
        // then sync /auth/me from the server (best-effort).
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('first_name', firstNameController.text.trim());
        await prefs.setString('last_name', lastNameController.text.trim());
        await prefs.setString('father_name', fatherController.text.trim());
        await prefs.setString('email', emailController.text.trim());
        blocProfile.fetchMe();
        if (!mounted) return;
        CustomSnackBar().showSnackBar(
          context,
          translate("profile.profile_updated"),
          1,
        );
        Navigator.pop(context, true);
      } else {
        final msg = (result is Map ? result['message']?.toString() : null) ??
            translate("auth.something_went_wrong");
        CenterDialog.showActionFailed(
            context, translate("ketamiz.error"), msg);
      }
    } else {
      CenterDialog.showActionFailed(
        context,
        translate("ketamiz.error"),
        response.result is Map && response.result['message'] != null
            ? response.result['message']
            : translate("auth.connection_failed"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LeadingBack(),
        title: Text16h500w(title: translate("profile.account_details")),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.only(
                        top: 22, bottom: 92, left: 16, right: 16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 5),
                              blurRadius: 25,
                              spreadRadius: 0,
                              color: AppTheme.dark.withOpacity(0.2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 96,
                              width: 96,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: isLoadingImage
                                    ? Container(
                                        padding: const EdgeInsets.all(16),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppTheme.purple),
                                          ),
                                        ),
                                      )
                                    : avatar.path.isNotEmpty
                                        ? Container(
                                            width: 96,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              image: DecorationImage(
                                                image: FileImage(
                                                    File(avatar.path)),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: 96,
                                            height: 96,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: Image.asset(
                                                "assets/images/avatar.jpg",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text18h500w(
                                  title: translate("profile.your_image"),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        // BottomDialog.showUploadImage(
                                        //   context,
                                        //   onGallery: () {
                                        //     // final pickedFile = await picker.pickImage(
                                        //     //   source: ImageSource.gallery,
                                        //     // );
                                        //     // if (pickedFile != null) {
                                        //     //   setState(() {
                                        //     //     isLoadingImage = true;
                                        //     //   });
                                        //     //   var response = await Repository()
                                        //     //       .fetchProfileImageSend(
                                        //     //     pickedFile.path,
                                        //     //   );
                                        //     //   if (response.isSuccess) {
                                        //     //     setState(() {
                                        //     //       isLoadingImage = false;
                                        //     //     });
                                        //     //     var result = ProfileModel.fromJson(
                                        //     //         response.result);
                                        //     //     if (result.status == 1) {
                                        //     //       setState(() {
                                        //     //         isLoadingImage = false;
                                        //     //         snapshot.data!.avatar =
                                        //     //             result.user.avatar;
                                        //     //         avatar = result.user.avatar;
                                        //     //       });
                                        //     //       SharedPreferences prefs =
                                        //     //           await SharedPreferences
                                        //     //               .getInstance();
                                        //     //       prefs.setString(
                                        //     //         "avatar",
                                        //     //         result.user.avatar,
                                        //     //       );
                                        //     //       blocProfile.fetchMe();
                                        //     //     } else {
                                        //     //       setState(() {
                                        //     //         isLoadingImage = false;
                                        //     //       });
                                        //     //       if (response.status == -1) {
                                        //     //         BottomDialog.showAction(
                                        //     //           context,
                                        //     //           'Connection Failed',
                                        //     //           'You do not have internet connection, please try again',
                                        //     //           'assets/icons/alert.svg',
                                        //     //         );
                                        //     //       } else {
                                        //     //         BottomDialog.showAction(
                                        //     //           context,
                                        //     //           'Action Failed',
                                        //     //           'Uploading Image Failed, Please try again after sometime',
                                        //     //           'assets/icons/alert.svg',
                                        //     //         );
                                        //     //       }
                                        //     //     }
                                        //     //   } else {
                                        //     //     BottomDialog.showAction(
                                        //     //       context,
                                        //     //       'Action Failed',
                                        //     //       'Could not upload the image, please try again',
                                        //     //       'assets/icons/alert.svg',
                                        //     //     );
                                        //     //     setState(() {
                                        //     //       isLoadingImage = false;
                                        //     //     });
                                        //     //   }
                                        //     // }
                                        //   },
                                        //   onCamera: () {
                                        //     // final pickedFile = await picker.pickImage(
                                        //     //   source: ImageSource.camera,
                                        //     // );
                                        //     // if (pickedFile != null) {
                                        //     //   setState(() {
                                        //     //     isLoadingImage = true;
                                        //     //   });
                                        //     //   var response = await Repository()
                                        //     //       .fetchProfileImageSend(
                                        //     //     pickedFile.path,
                                        //     //   );
                                        //     //   if (response.isSuccess) {
                                        //     //     setState(() {
                                        //     //       isLoadingImage = false;
                                        //     //     });
                                        //     //     var result = ProfileModel.fromJson(
                                        //     //         response.result);
                                        //     //     if (result.status == 1) {
                                        //     //       setState(() {
                                        //     //         isLoadingImage = false;
                                        //     //         snapshot.data!.avatar =
                                        //     //             result.user.avatar;
                                        //     //         avatar = result.user.avatar;
                                        //     //       });
                                        //     //       SharedPreferences prefs =
                                        //     //           await SharedPreferences
                                        //     //               .getInstance();
                                        //     //       prefs.setString(
                                        //     //         "avatar",
                                        //     //         result.user.avatar,
                                        //     //       );
                                        //     //       blocProfile.fetchMe();
                                        //     //     } else {
                                        //     //       setState(() {
                                        //     //         isLoadingImage = false;
                                        //     //       });
                                        //     //       if (response.status == -1) {
                                        //     //         BottomDialog.showAction(
                                        //     //           context,
                                        //     //           'Connection Failed',
                                        //     //           'You do not have internet connection, please try again',
                                        //     //           'assets/icons/alert.svg',
                                        //     //         );
                                        //     //       } else {
                                        //     //         BottomDialog.showAction(
                                        //     //           context,
                                        //     //           'Action Failed',
                                        //     //           'Uploading Image Failed, Please try again after sometime',
                                        //     //           'assets/icons/alert.svg',
                                        //     //         );
                                        //     //       }
                                        //     //     }
                                        //     //   } else {
                                        //     //     BottomDialog.showAction(
                                        //     //       context,
                                        //     //       'Action Failed',
                                        //     //       'Could not upload the image, please try again',
                                        //     //       'assets/icons/alert.svg',
                                        //     //     );
                                        //     //   }
                                        //     // }
                                        //   },
                                        // );
                                        BottomDialog.showUploadImage(
                                          context,
                                          onGallery: () =>
                                              _pickImage(ImageSource.gallery),
                                          onCamera: () =>
                                              _pickImage(ImageSource.camera),
                                        );
                                      },
                                      child: Container(
                                        height: 32,
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                    192) /
                                                2,
                                        decoration: BoxDecoration(
                                          color: AppTheme.light,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            bottomLeft: Radius.circular(12),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              offset: const Offset(0, 5),
                                              blurRadius: 25,
                                              spreadRadius: 0,
                                              color: AppTheme.shadow
                                                  .withOpacity(0.2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            translate("edit"),
                                            style: const TextStyle(
                                              fontFamily: AppTheme.fontFamily,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              height: 1.375,
                                              color: AppTheme.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _deleteImage();
                                      },
                                      child: Container(
                                        height: 32,
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                    192) /
                                                2,
                                        decoration: BoxDecoration(
                                          color: AppTheme.orange,
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(12),
                                            bottomRight: Radius.circular(12),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              offset: const Offset(0, 10),
                                              blurRadius: 75,
                                              spreadRadius: 0,
                                              color: const Color(0xFF939393)
                                                  .withOpacity(0.07),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            translate("delete"),
                                            style: const TextStyle(
                                              fontFamily: AppTheme.fontFamily,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              height: 1.375,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      MainTextField(
                        hintText: translate("profile.first_name"),
                        icon: Icons.person,
                        controller: firstNameController,
                      ),
                      const SizedBox(height: 16),
                      MainTextField(
                        hintText: translate("profile.father_name"),
                        icon: Icons.person,
                        controller: fatherController,
                      ),
                      const SizedBox(height: 16),
                      MainTextField(
                        hintText: translate("profile.last_name"),
                        icon: Icons.person,
                        controller: lastNameController,
                      ),
                      const SizedBox(height: 16),
                      MainTextField(
                        hintText: translate("profile.email_address"),
                        icon: Icons.email,
                        controller: emailController,
                      ),
                      const SizedBox(height: 16),
                      AbsorbPointer(
                        child: Opacity(
                          opacity: 0.6,
                          child: MainTextField(
                            hintText: translate("profile.phone_number"),
                            icon: Icons.phone,
                            controller: phoneController,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: SecondaryButton(
                        title: translate("profile.save_changes"),
                        onTap: isSaving ? () {} : _saveChanges,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
            if (isSaving)
              Container(
                color: AppTheme.black.withOpacity(0.45),
                child: Center(
                  child: Container(
                    height: 96,
                    width: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.purple),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await ImageHelper.pick(source).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image picker timed out.')),
            );
          }
          return null;
        },
      );
      if (image != null && mounted) {
        setState(() {
          avatar = image;
        });
      } else if (mounted) {
        final Permission permission = source == ImageSource.camera
            ? Permission.camera
            : Permission.photos;
        final PermissionStatus status = await permission.status;
        debugPrint('Permission status: $status');
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: Text(
              'This app needs ${source == ImageSource.camera ? "camera" : "photo library"} access to upload car images.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final bool opened = await openAppSettings();
                  if (!opened && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Unable to open Settings.')),
                    );
                  } else if (mounted) {
                    await Future.delayed(const Duration(seconds: 1));
                    final status = await permission.status;
                    debugPrint('Updated permission status: $status');
                    if (status.isGranted || status.isLimited) {
                      await _pickImage(source);
                    }
                  }
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Error picking image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing $source: $e')),
        );
      }
    }
  }

  void _deleteImage() {
    if (mounted) {
      setState(() {
        avatar = XFile("");
      });
    }
  }

}
