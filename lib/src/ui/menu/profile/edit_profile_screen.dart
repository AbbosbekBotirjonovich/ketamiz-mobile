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
    final localAvatar = prefs.getString('local_avatar') ?? '';
    setState(() {
      firstNameController.text = prefs.getString('first_name') ?? '';
      lastNameController.text = prefs.getString('last_name') ?? '';
      fatherController.text = prefs.getString('father_name') ?? '';
      emailController.text = prefs.getString('email') ?? '';
      phoneController.text = prefs.getString('phone') ?? '';
      avatar = localAvatar.isNotEmpty ? XFile(localAvatar) : XFile("");
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const LeadingBack(),
        title: Text16h500w(title: translate("profile.account_details")),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            ListView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
              children: [
                _buildAvatarSection(),
                const SizedBox(height: 20),
                MainTextField(
                  hintText: translate("profile.first_name"),
                  icon: Icons.person_outline,
                  controller: firstNameController,
                  fillColor: Colors.white,
                ),
                const SizedBox(height: 12),
                MainTextField(
                  hintText: translate("profile.last_name"),
                  icon: Icons.person_outline,
                  controller: lastNameController,
                  fillColor: Colors.white,
                ),
                const SizedBox(height: 12),
                MainTextField(
                  hintText: translate("profile.father_name"),
                  icon: Icons.person_outline,
                  controller: fatherController,
                  fillColor: Colors.white,
                ),
                const SizedBox(height: 12),
                MainTextField(
                  hintText: translate("profile.email_address"),
                  icon: Icons.email_outlined,
                  controller: emailController,
                  fillColor: Colors.white,
                ),
                const SizedBox(height: 12),
                AbsorbPointer(
                  child: Opacity(
                    opacity: 0.6,
                    child: MainTextField(
                      hintText: translate("profile.phone_number"),
                      icon: Icons.phone_outlined,
                      controller: phoneController,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: SecondaryButton(
                  title: translate("profile.save_changes"),
                  onTap: isSaving ? () {} : _saveChanges,
                ),
              ),
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

  // ── Avatar section ────────────────────────────────────────────────────────
  Widget _buildAvatarSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text18h500w(title: translate("profile.your_image")),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _imageActionButton(
                        icon: Icons.edit_outlined,
                        label: translate("edit"),
                        color: AppTheme.purple,
                        onTap: _openImagePicker,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _imageActionButton(
                        icon: Icons.delete_outline,
                        label: translate("delete"),
                        color: AppTheme.red,
                        onTap: _deleteImage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final hasImage =
        avatar.path.isNotEmpty && File(avatar.path).existsSync();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 88,
          height: 88,
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppTheme.purple, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: isLoadingImage
              ? const Padding(
                  padding: EdgeInsets.all(28),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.5,
                  ),
                )
              : hasImage
                  ? Image.file(File(avatar.path),
                      width: 88, height: 88, fit: BoxFit.cover)
                  : _initialsText(),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: GestureDetector(
            onTap: _openImagePicker,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.light, width: 1.5),
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  size: 14, color: AppTheme.purple),
            ),
          ),
        ),
      ],
    );
  }

  Widget _initialsText() {
    final f = firstNameController.text.trim();
    final l = lastNameController.text.trim();
    var initials = '';
    if (f.isNotEmpty) initials += f.substring(0, 1);
    if (l.isNotEmpty) initials += l.substring(0, 1);
    if (initials.isEmpty) initials = 'U';
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _imageActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openImagePicker() {
    BottomDialog.showUploadImage(
      context,
      onGallery: () => _pickImage(ImageSource.gallery),
      onCamera: () => _pickImage(ImageSource.camera),
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('local_avatar', image.path);
        if (!mounted) return;
        setState(() => avatar = image);
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
              'This app needs ${source == ImageSource.camera ? "camera" : "photo library"} access to upload your image.',
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

  Future<void> _deleteImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('local_avatar');
    if (mounted) setState(() => avatar = XFile(""));
  }
}
