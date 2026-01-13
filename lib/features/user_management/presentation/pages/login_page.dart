import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_study_plan/config/routes/app_routes.dart';
import 'package:smart_study_plan/features/user_management/presentation/bloc/user_bloc.dart';
import 'package:smart_study_plan/features/user_management/presentation/widgets/auth_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _password = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _hidePassword = true;
  bool _loginSuccess = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _login() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    HapticFeedback.lightImpact();

    context.read<UserBloc>().add(
      LoginUserEvent(email: _email.text.trim(), password: _password.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocListener<UserBloc, UserState>(
        listenWhen: (p, c) => p is UserLoading && c is! UserLoading,
        listener: (context, state) {
          /// LOGIN SUCCESS
          if (state is UserLoginSuccess) {
            setState(() => _loginSuccess = true);

            Future.delayed(const Duration(milliseconds: 500), () {
              context.goNamed(
                state.user.isAdmin
                    ? AppRouteNames.adminDashboard
                    : AppRouteNames.home,
              );
            });
          }

          /// ERROR
          if (state is UserError) {
            HapticFeedback.heavyImpact();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Container(
                        width: 420,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Welcome back',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Login to continue your study plan',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF64748B),
                                ),
                              ),

                              const SizedBox(height: 32),

                              /// EMAIL
                              AuthTextField(
                                label: 'Email',
                                controller: _email,
                                focusNode: _emailFocus,
                                nextFocusNode: _passwordFocus,
                                hint: 'you@example.com',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => v == null || !v.contains('@')
                                    ? 'Enter a valid email'
                                    : null,
                              ),

                              const SizedBox(height: 16),

                              /// PASSWORD
                              AuthTextField(
                                label: 'Password',
                                controller: _password,
                                focusNode: _passwordFocus,
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                obscureText: _hidePassword,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Password is required'
                                    : null,
                                suffix: IconButton(
                                  onPressed: () => setState(
                                    () => _hidePassword = !_hidePassword,
                                  ),
                                  icon: Icon(
                                    _hidePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => context.pushNamed(
                                    AppRouteNames.forgotPassword,
                                  ),
                                  child: const Text('Forgot password?'),
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// LOGIN BUTTON
                              BlocBuilder<UserBloc, UserState>(
                                builder: (context, state) {
                                  final loading = state is UserLoading;

                                  return SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: loading ? null : _login,
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        child: loading
                                            ? const SizedBox(
                                                key: ValueKey('loading'),
                                                height: 22,
                                                width: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : _loginSuccess
                                            ? const Icon(
                                                Icons.check,
                                                key: ValueKey('success'),
                                                color: Colors.white,
                                              )
                                            : const Text(
                                                'Login',
                                                key: ValueKey('text'),
                                              ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 20),

                              Center(
                                child: TextButton(
                                  onPressed: () =>
                                      context.pushNamed(AppRouteNames.register),
                                  child: const Text(
                                    "Don't have an account? Register",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
