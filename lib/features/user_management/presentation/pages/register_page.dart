import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_study_plan/config/routes/app_routes.dart';
import 'package:smart_study_plan/features/user_management/presentation/bloc/user_bloc.dart';
import 'package:smart_study_plan/features/user_management/presentation/widgets/auth_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _hidePassword = true;
  bool _hideConfirm = true;
  bool _registerSuccess = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();

    super.dispose();
  }

  void _register() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    HapticFeedback.lightImpact();

    context.read<UserBloc>().add(
      RegisterUserEvent(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false, // ⭐ prevents keyboard jump
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocListener<UserBloc, UserState>(
        listenWhen: (p, c) => p is UserLoading && c is! UserLoading,
        listener: (context, state) {
          /// REGISTER SUCCESS
          if (state is UserRegisterSuccess) {
            setState(() => _registerSuccess = true);

            Future.delayed(const Duration(milliseconds: 500), () {
              context.goNamed(AppRouteNames.login);
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
                                'Create account',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Sign up to start planning smarter',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF64748B),
                                ),
                              ),

                              const SizedBox(height: 32),

                              /// NAME
                              AuthTextField(
                                label: 'Full name',
                                controller: _name,
                                focusNode: _nameFocus,
                                nextFocusNode: _emailFocus,
                                hint: 'John Doe',
                                icon: Icons.person_outline,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Name is required'
                                    : null,
                              ),

                              const SizedBox(height: 16),

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
                                nextFocusNode: _confirmFocus,
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                obscureText: _hidePassword,
                                validator: (v) => v != null && v.length >= 6
                                    ? null
                                    : 'Minimum 6 characters',
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

                              const SizedBox(height: 16),

                              /// CONFIRM PASSWORD
                              AuthTextField(
                                label: 'Confirm password',
                                controller: _confirm,
                                focusNode: _confirmFocus,
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                obscureText: _hideConfirm,
                                validator: (v) => v == _password.text
                                    ? null
                                    : 'Passwords do not match',
                                suffix: IconButton(
                                  onPressed: () => setState(
                                    () => _hideConfirm = !_hideConfirm,
                                  ),
                                  icon: Icon(
                                    _hideConfirm
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              /// REGISTER BUTTON
                              BlocBuilder<UserBloc, UserState>(
                                builder: (context, state) {
                                  final loading = state is UserLoading;

                                  return SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: loading ? null : _register,
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
                                            : _registerSuccess
                                            ? const Icon(
                                                Icons.check,
                                                key: ValueKey('success'),
                                                color: Colors.white,
                                              )
                                            : const Text(
                                                'Create account',
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
                                      context.goNamed(AppRouteNames.login),
                                  child: const Text(
                                    'Already have an account? Login',
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
