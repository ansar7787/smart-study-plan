import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:smart_study_plan/config/routes/app_routes.dart';
import '../bloc/user_bloc.dart';

import '../../../analytics/presentation/bloc/analytics_bloc.dart';
import '../../../analytics/presentation/bloc/analytics_event.dart';
import '../../../analytics/presentation/bloc/analytics_state.dart';
import '../../../../config/theme/bloc/theme_cubit.dart';
import '../../../../di/service_locator.dart';

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
      if (state.status == UserStatus.authenticated && state.user != null) {
        _nameController.text = state.user!.name;
        _initialized = true;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<UserBloc>().add(const LogoutEvent());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendFeedback() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'muhammedansar7787@gmail.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': 'Smart Study Plan Feedback',
      }),
    );

    try {
      if (!await launchUrl(
        emailLaunchUri,
        mode: LaunchMode.externalApplication,
      )) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch email app')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error launching email: $e')));
      }
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  void _showAboutDialog(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/logo/app_logo.png',
                  width: 64.w,
                  height: 64.h,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Smart Study Plan',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Version 1.0.0',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'A smart study planner powered by AI to help you achieve your goals effectively.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
          'This feature is coming soon! For now, please use the "Forgot Password" on the login screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (context) {
        final bloc = getIt<AnalyticsBloc>();
        final userState = context.read<UserBloc>().state;
        if (userState.status == UserStatus.authenticated &&
            userState.user != null) {
          bloc.add(LoadAnalyticsEvent(userId: userState.user!.id));
        }
        return bloc;
      },
      child: Scaffold(
        backgroundColor: colors.surfaceContainerLowest,
        body: BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state.status == UserStatus.unauthenticated) {
              context.goNamed(AppRouteNames.login);
            }
            if (state.status == UserStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state.status != UserStatus.authenticated ||
                  state.user == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final isLoading = state.status == UserStatus.loading;
              final user = state.user!;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ------------------------------------------------------------
                  // 🖼️ HEADER
                  // ------------------------------------------------------------
                  SliverAppBar.large(
                    expandedHeight: 280.h,
                    pinned: true,
                    backgroundColor: colors.surface,
                    surfaceTintColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  colors.primaryContainer.withValues(
                                    alpha: 0.5,
                                  ),
                                  colors.surfaceContainerLowest,
                                ],
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 48.h), // Space for status bar
                              GestureDetector(
                                onTap: isLoading ? null : _pickAvatar,
                                child: Stack(
                                  children: [
                                    Hero(
                                      tag: 'profile_avatar',
                                      child: Container(
                                        padding: EdgeInsets.all(4.r),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: colors.primary.withValues(
                                              alpha: 0.2,
                                            ),
                                            width: 3.w,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: colors.shadow.withValues(
                                                alpha: 0.1,
                                              ),
                                              blurRadius: 20.r,
                                              offset: Offset(0, 10.h),
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 64.r,
                                          backgroundColor:
                                              colors.surfaceContainerHigh,
                                          backgroundImage: _tempAvatar != null
                                              ? FileImage(_tempAvatar!)
                                              : (user.photoUrl != null
                                                        ? CachedNetworkImageProvider(
                                                            user.photoUrl!,
                                                          )
                                                        : null)
                                                    as ImageProvider?,
                                          child:
                                              user.photoUrl == null &&
                                                  _tempAvatar == null
                                              ? Text(
                                                  user.name.isNotEmpty
                                                      ? user.name[0]
                                                            .toUpperCase()
                                                      : '?',
                                                  style: TextStyle(
                                                    fontSize: 40.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: colors.primary,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 4.w,
                                      child: Container(
                                        padding: EdgeInsets.all(10.r),
                                        decoration: BoxDecoration(
                                          color: colors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: colors.surface,
                                            width: 3.w,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.camera_alt_rounded,
                                          size: 20.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                user.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.onSurface,
                                      fontSize: 28.sp,
                                    ),
                              ),
                              Text(
                                user.email,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 14.sp,
                                    ),
                              ),
                            ],
                          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                        ],
                      ),
                    ),
                  ),

                  // ------------------------------------------------------------
                  // 📊 STATS
                  // ------------------------------------------------------------
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      child:
                          Row(
                                children: [
                                  Expanded(
                                    child:
                                        BlocBuilder<
                                          AnalyticsBloc,
                                          AnalyticsState
                                        >(
                                          builder: (context, state) {
                                            final hours =
                                                state
                                                    .overview
                                                    ?.snapshot
                                                    .totalStudyHours
                                                    .toStringAsFixed(1) ??
                                                '0.0';
                                            return _StatCard(
                                              label: 'Hours',
                                              value: hours,
                                              icon: Icons
                                                  .access_time_filled_rounded,
                                              color: Colors.orange,
                                            );
                                          },
                                        ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child:
                                        BlocBuilder<
                                          AnalyticsBloc,
                                          AnalyticsState
                                        >(
                                          builder: (context, state) {
                                            final tasks =
                                                state
                                                    .overview
                                                    ?.snapshot
                                                    .completedTasks
                                                    .toString() ??
                                                '0';
                                            return _StatCard(
                                              label: 'Tasks',
                                              value: tasks,
                                              icon: Icons.check_circle_rounded,
                                              color: Colors.green,
                                            );
                                          },
                                        ),
                                  ),
                                ],
                              )
                              .animate()
                              .fadeIn(delay: 200.ms)
                              .slideY(begin: 0.2, end: 0),
                    ),
                  ),

                  // ------------------------------------------------------------
                  // ⚙️ SETTINGS
                  // ------------------------------------------------------------
                  SliverPadding(
                    padding: EdgeInsets.all(20.r),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SizedBox(height: 12.h),

                        _SettingsSectionTitle(title: 'Account'),
                        _SettingsGroup(
                          children: [
                            _SettingsTile(
                              icon: Icons.person_outline_rounded,
                              title: 'Name',
                              trailing: SizedBox(
                                width: 140.w,
                                child: TextField(
                                  controller: _nameController,
                                  textAlign: TextAlign.end,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Your name',
                                    isDense: true,
                                  ),
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontSize: 16.sp),
                                ),
                              ),
                            ),
                            const Divider(height: 1, indent: 56),
                            _SettingsTile(
                              icon: Icons.lock_outline_rounded,
                              title: 'Change Password',
                              onTap: () => _showChangePasswordDialog(context),
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),
                        _SettingsSectionTitle(title: 'Preferences'),
                        _SettingsGroup(
                          children: [
                            _SettingsTile(
                              icon: Icons.notifications_none_rounded,
                              title: 'Notifications',
                              trailing: Switch(
                                value: true,
                                onChanged: (v) {}, // Mock
                              ),
                            ),
                            const Divider(height: 1, indent: 56),
                            BlocBuilder<ThemeCubit, ThemeMode>(
                              builder: (context, mode) {
                                final isDark = context
                                    .read<ThemeCubit>()
                                    .isDarkMode;
                                return _SettingsTile(
                                  icon: isDark
                                      ? Icons.dark_mode_rounded
                                      : Icons.light_mode_rounded,
                                  title: 'Dark Mode',
                                  trailing: Switch(
                                    value: isDark,
                                    onChanged: (v) => context
                                        .read<ThemeCubit>()
                                        .toggleTheme(v),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),
                        _SettingsSectionTitle(title: 'Support'),
                        _SettingsGroup(
                          children: [
                            _SettingsTile(
                              icon: Icons.feedback_outlined,
                              title: 'Send Feedback',
                              onTap: _sendFeedback,
                            ),
                            const Divider(height: 1, indent: 56),
                            _SettingsTile(
                              icon: Icons.info_outline_rounded,
                              title: 'About App',
                              onTap: () => _showAboutDialog(context),
                            ),
                          ],
                        ),

                        SizedBox(height: 32.h),

                        // SAVE BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: FilledButton.icon(
                            onPressed: isLoading
                                ? null
                                : () {
                                    final name = _nameController.text.trim();
                                    if (name.isNotEmpty) {
                                      context.read<UserBloc>().add(
                                        UpdateUserEvent(name: name),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Profile updated successfully',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            icon: isLoading
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.check_rounded),
                            label: Text(
                              isLoading ? 'Saving...' : 'Save Changes',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // LOGOUT BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: OutlinedButton.icon(
                            onPressed: () => _showLogoutDialog(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.error,
                              side: BorderSide(
                                color: colors.error.withValues(alpha: 0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            icon: const Icon(Icons.logout_rounded),
                            label: Text(
                              'Log Out',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          ),
                        ),
                        SizedBox(height: 48.h),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
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

class _SettingsSectionTitle extends StatelessWidget {
  final String title;
  const _SettingsSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 12.w, bottom: 8.h),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
              fontSize: 24.sp,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20.sp,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right_rounded,
            size: 20.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
    );
  }
}

class _AvatarPickerSheet extends StatelessWidget {
  final ImagePicker picker;

  const _AvatarPickerSheet({required this.picker});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded),
            title: const Text('Take photo'),
            onTap: () async {
              final image = await picker.pickImage(source: ImageSource.camera);
              if (!context.mounted) return;
              Navigator.pop(context, image);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded),
            title: const Text('Choose from gallery'),
            onTap: () async {
              final image = await picker.pickImage(source: ImageSource.gallery);
              if (!context.mounted) return;
              Navigator.pop(context, image);
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
