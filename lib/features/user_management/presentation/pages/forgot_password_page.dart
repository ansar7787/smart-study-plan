import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_study_plan/config/routes/app_routes.dart';
import 'package:smart_study_plan/di/service_locator.dart';
import 'package:smart_study_plan/features/user_management/presentation/cubit/reset_password_cubit.dart';

import '../widgets/auth/auth_card.dart';
import '../widgets/auth/auth_header.dart';
import '../widgets/auth/auth_scaffold.dart';
import '../widgets/auth/auth_submit_button.dart';
import '../widgets/auth/auth_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ResetPasswordCubit>(),
      child: AuthScaffold(
        child: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
          listener: (context, state) {
            if (state is ResetPasswordSuccess) {
              context.goNamed(AppRouteNames.resetEmailSent);
            }

            if (state is ResetPasswordFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            return AuthCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthHeader(
                      title: 'Reset password',
                      subtitle: 'We’ll send you a reset link',
                    ),

                    AuthTextField(
                      label: 'Email',
                      controller: _email,
                      hint: 'you@example.com',
                      icon: Icons.email_outlined,
                      validator: (v) =>
                          v != null && v.contains('@') ? null : 'Invalid email',
                    ),

                    const SizedBox(height: 24),

                    AuthSubmitButton(
                      loading: state is ResetPasswordLoading,
                      text: 'Send reset link',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<ResetPasswordCubit>().sendResetLink(
                            _email.text.trim(),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: TextButton(
                        onPressed: () => context.goNamed(AppRouteNames.login),
                        child: const Text('Back to login'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
