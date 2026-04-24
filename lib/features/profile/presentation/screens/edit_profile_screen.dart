import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/extensions/context_extension.dart';
import 'package:pickle_pick/features/auth/presentation/providers/auth_providers.dart';

@RoutePage()
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).value;
    _nameController = TextEditingController(
      text: user?.userMetadata?['full_name'] as String? ?? '',
    );
    _phoneController = TextEditingController(
      text: user?.userMetadata?['phone'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);

      if (_pickedImage != null) {
        final bytes = await _pickedImage!.readAsBytes();
        await authNotifier.updateAvatar(bytes, _pickedImage!.name);
      }

      await authNotifier.updateProfile({
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.updateSuccess)),
        );
        context.router.back();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.l10n.error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).value;
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.editProfile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Avatar Picker ─────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: AppSizes.avatarRadius,
                        backgroundColor: Colors.white10,
                        backgroundImage: _pickedImage != null
                            ? null
                            : (avatarUrl != null
                                ? NetworkImage(avatarUrl)
                                : null),
                        child: _pickedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.avatarRadius,
                                ),
                                child: Image.network(
                                  '',
                                  errorBuilder: (context, e, s) => const Icon(
                                    Icons.check,
                                    size: AppSizes.iconXL,
                                  ),
                                ),
                              )
                            : (avatarUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: AppSizes.avatarRadius,
                                    color: Colors.white38,
                                  )
                                : null),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.p4),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: AppSizes.iconMedium,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.p32),

              // ─── Full Name Field ───────────────────────────────────────
              Text(
                context.l10n.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.bodySmall,
                ),
              ),
              const SizedBox(height: AppSizes.p8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: context.l10n.hintDisplayName,
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r16),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? context.l10n.valEmptyName
                    : null,
              ),

              const SizedBox(height: AppSizes.p20),

              // ─── Phone Field ───────────────────────────────────────────
              Text(
                context.l10n.labelPhone,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.bodySmall,
                ),
              ),
              const SizedBox(height: AppSizes.p8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: context.l10n.hintPhone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r16),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? context.l10n.valEmptyPhone
                    : null,
              ),

              const SizedBox(height: AppSizes.p40),

              // ─── Save Button ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          context.l10n.btnSaveChanges,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
