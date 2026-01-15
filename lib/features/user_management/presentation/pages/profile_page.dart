import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:smart_study_plan/config/routes/app_routes.dart';
import '../bloc/user_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  File? _tempAvatar;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final state = context.read<UserBloc>().state;
      if (state is UserAuthenticated) {
        _nameController.text = state.user.name;
        _initialized = true;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: colors.surface,
        elevation: 0,
      ),

      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoggedOut || state is UserNotAuthenticated) {
            context.goNamed(AppRouteNames.login);
          }

          if (state is UserError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },

        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is! UserAuthenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            final isLoading = state is UserLoading;
            final user = state.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _ProfileHeader(
                    name: user.name,
                    email: user.email,
                    imageUrl: user.photoUrl,
                    tempImage: _tempAvatar,
                    onEditAvatar: isLoading ? () {} : _pickAvatar,
                  ),

                  const SizedBox(height: 28),

                  _ProfileCard(
                    title: 'Personal Information',
                    child: Column(
                      children: [
                        _ProfileField(
                          label: 'Full name',
                          controller: _nameController,
                        ),
                        const SizedBox(height: 12),
                        _ReadonlyField(label: user.email, value: user.email),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<UserBloc>().add(
                                UpdateUserEvent(
                                  name: _nameController.text.trim(),
                                ),
                              );
                            },
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save Changes'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<UserBloc>().add(const LogoutEvent());
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.error,
                      ),
                      child: const Text('Log out'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();

    final image = await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AvatarPickerSheet(picker: picker),
    );

    if (!mounted || image == null) return;

    setState(() {
      _tempAvatar = File(image.path);
    });

    context.read<UserBloc>().add(UpdateUserAvatarEvent(File(image.path)));
  }
}

/* ---------------- UI COMPONENTS ---------------- */

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? imageUrl;
  final File? tempImage;
  final VoidCallback onEditAvatar;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.tempImage,
    required this.onEditAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.08),
            colors.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: colors.primary.withValues(alpha: 0.15),
                backgroundImage: tempImage != null
                    ? FileImage(tempImage!)
                    : imageUrl != null
                    ? NetworkImage(imageUrl!)
                    : null,
                child: imageUrl == null && tempImage == null
                    ? Icon(Icons.person, size: 42, color: colors.primary)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onEditAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ProfileCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _ProfileField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadonlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextField(
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        hintText: value,
        filled: true,
        labelStyle: TextStyle(fontSize: 13),
        fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _AvatarPickerSheet extends StatelessWidget {
  final ImagePicker picker;

  const _AvatarPickerSheet({required this.picker});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PickerTile(
            icon: Icons.camera_alt,
            label: 'Take photo',
            onTap: () async {
              final image = await picker.pickImage(source: ImageSource.camera);
              if (!context.mounted) return;
              Navigator.pop(context, image);
            },
          ),
          _PickerTile(
            icon: Icons.photo_library,
            label: 'Choose from gallery',
            onTap: () async {
              final image = await picker.pickImage(source: ImageSource.gallery);
              if (!context.mounted) return;
              Navigator.pop(context, image);
            },
          ),
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
  }
}
