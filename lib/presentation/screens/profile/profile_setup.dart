import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/localization/app_localizations.dart';
import 'package:task_tracker/core/utils/app_validators.dart';
import 'package:task_tracker/core/utils/extensions/context_extension.dart';
import 'package:task_tracker/core/utils/extensions/widget_extensions.dart';
import 'package:task_tracker/core/utils/loading_overlay.dart';
import 'package:task_tracker/core/utils/message_utils.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

/// Profile setup screen for collecting user information.
///
/// Shown when user data is null or profile is incomplete.
/// Also used for editing existing profile data.
class ProfileSetup extends StatefulWidget {
  /// If true, the form is pre-filled with existing data for editing
  final bool isEditing;

  const ProfileSetup({super.key, this.isEditing = false});

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedGender;
  String? _photoBase64;
  File? _selectedImageFile;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();

    // Pre-fill data if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillData();
    });
  }

  void _prefillData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.userData;
    if (user != null) {
      _emailController.text = user.email;
      if (widget.isEditing || user.isProfileComplete) {
        _firstNameController.text = user.firstName ?? '';
        _lastNameController.text = user.lastName ?? '';
        _selectedGender = user.gender;
        if (user.age != null) _ageController.text = user.age.toString();
        _locationController.text = user.location ?? '';
        if (user.hasProfilePhoto) {
          _photoBase64 = user.photoUrl;
        }
        if (mounted) setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedImageFile = file;
          _photoBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast(e.toString());
      }
    }
  }

  void _showImageSourceSheet() {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                loc?.translate('choose_photo_source') ?? 'Choose Photo Source',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: loc?.translate('camera') ?? 'Camera',
                    color: AppColors.warning,
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildSourceOption(
                    icon: Icons.photo_library_rounded,
                    label: loc?.translate('gallery') ?? 'Gallery',
                    color: AppColors.success,
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final loc = AppLocalizations.of(context);

    final success = await context.withLoading(
        message: loc?.translate('profile_updating') ?? 'Profile updating...',
        future: authProvider.saveProfileSetup(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim().isEmpty
          ? null
          : _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      photoUrl: _photoBase64,
      gender: _selectedGender,
      age: _ageController.text.trim().isEmpty
          ? null
          : int.tryParse(_ageController.text.trim()),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
    ));

    if (mounted) {
      if (success) {
        context.showSuccessToast(
          loc?.translate('profile_updated') ?? 'Profile updated successfully',
        );
        if (widget.isEditing && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      } else {
        context.showErrorToast(
          authProvider.errorMessage ?? 'Failed to save profile',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;
    final horizontalPadding = isWide ? screenWidth * 0.15 : 20.0;

    return Scaffold(
      appBar: widget.isEditing
          ? AppBar(
              title: Text(
                loc?.translate('edit_profile') ?? 'Edit Profile',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: true,
              foregroundColor: context.theme.primaryColor,
            )
          : null,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (!widget.isEditing) ...[
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    loc?.translate('profile_setup_title') ??
                        'Set Up Your Profile',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc?.translate('user-profile-error') ??
                        "Let's set up your profile!",
                    style: theme.textTheme.labelLarge?.copyWith(),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),

                // ── Profile Photo ──
                _buildPhotoSection(loc, theme, isDark),
                const SizedBox(height: 32),

                // ── Form Fields (using extension methods) ──
                context.themedTextField(
                  controller: _firstNameController,
                  label: loc?.translate('first_name') ?? 'First Name',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (val) => Validators.validateRequired(
                    val,
                    fieldName: 'First Name',
                    context: context,
                  ),
                ),
                const SizedBox(height: 16),

                context.themedTextField(
                  controller: _lastNameController,
                  label: loc?.translate('last_name') ?? 'Last Name',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),

                context.themedTextField(
                  controller: _emailController,
                  label: loc?.translate('email') ?? 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => Validators.validateEmail(
                    val,
                    errorMessage:
                        loc?.translate('email_required_profile') ??
                        'Email is required',
                    context: context,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Gender Dropdown ──
                _buildGenderDropdown(loc, theme, isDark),
                const SizedBox(height: 16),

                context.themedTextField(
                  controller: _ageController,
                  label: loc?.translate('age') ?? 'Age',
                  prefixIcon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  hint: loc?.translate('enter_age') ?? 'Enter your age',
                ),
                const SizedBox(height: 16),

                context.themedTextField(
                  controller: _locationController,
                  label: loc?.translate('location') ?? 'Location',
                  prefixIcon: Icons.location_on_outlined,
                  hint:
                      loc?.translate('enter_location') ?? 'Enter your location',
                ),
                const SizedBox(height: 36),

                // ── Save Button (using extension) ──
                context.themedElevatedButton(
                  label: loc?.translate('save_profile') ?? 'Save Profile',
                  onPressed: _saveProfile,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(
    AppLocalizations? loc,
    ThemeData theme,
    bool isDark,
  ) {
    return Center(
      child: GestureDetector(
        onTap: _showImageSourceSheet,
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                    theme.colorScheme.secondary.withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: _selectedImageFile != null
                    ? Image.file(
                        _selectedImageFile!,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      )
                    : (_photoBase64 != null && _photoBase64!.isNotEmpty)
                    ? Image.memory(
                        base64Decode(_photoBase64!),
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_rounded,
                            size: 36,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc?.translate('tap_to_add_photo') ?? 'Tap to add',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.6,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            // Camera badge
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.scaffoldBackgroundColor,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(
    AppLocalizations? loc,
    ThemeData theme,
    bool isDark,
  ) {
    final genderOptions = [
      {'value': 'male', 'label': loc?.translate('male') ?? 'Male'},
      {'value': 'female', 'label': loc?.translate('female') ?? 'Female'},
      {'value': 'other', 'label': loc?.translate('other_gender') ?? 'Other'},
      {
        'value': 'prefer_not_to_say',
        'label': loc?.translate('prefer_not_to_say') ?? 'Prefer not to say',
      },
    ];

    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      decoration: InputDecoration(
        labelText: loc?.translate('gender') ?? 'Gender',
        prefixIcon: Icon(
          Icons.wc_rounded,
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
        ),
        filled: true,
        fillColor: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: genderOptions
          .map(
            (g) => DropdownMenuItem<String>(
              value: g['value'],
              child: Text(g['label']!,
              style: theme.textTheme.bodyLarge),
            ),
          )
          .toList(),
      onChanged: (val) => setState(() => _selectedGender = val),
    );
  }
}
