import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_study_plan/config/routes/app_routes.dart';
import 'package:smart_study_plan/features/user_management/presentation/bloc/user_bloc.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      buildWhen: (prev, curr) =>
          curr.status == UserStatus.authenticated &&
          (prev.status != UserStatus.authenticated ||
              prev.user?.name != curr.user?.name ||
              prev.user?.photoUrl != curr.user?.photoUrl),
      builder: (context, state) {
        if (state.status != UserStatus.authenticated || state.user == null) {
          return const SizedBox.shrink();
        }

        final user = state.user!;
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        final hour = DateTime.now().hour;
        final greeting = hour < 12
            ? 'Good morning'
            : hour < 17
            ? 'Good afternoon'
            : hour < 21
            ? 'Good evening'
            : 'Good night';

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: InkWell(
            onTap: () => context.pushNamed(AppRouteNames.profile),
            borderRadius: BorderRadius.circular(22),
            child: Ink(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withValues(alpha: 0.10),
                    colors.secondary.withValues(alpha: 0.08),
                  ],
                ),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                children: [
                  /// AVATAR
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                      image: user.photoUrl != null
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(user.photoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: user.photoUrl == null
                        ? Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.primary,
                            ),
                          )
                        : null,
                  ),

                  const SizedBox(width: 14),

                  /// TEXT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
