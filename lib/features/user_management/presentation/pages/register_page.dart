import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:smart_study_plan/config/routes/app_routes.dart';
import 'package:smart_study_plan/features/user_management/presentation/bloc/user_bloc.dart';
import 'package:smart_study_plan/features/user_management/presentation/widgets/auth/auth_card.dart';
import 'package:smart_study_plan/features/user_management/presentation/widgets/auth/auth_header.dart';
import 'package:smart_study_plan/features/user_management/presentation/widgets/auth/auth_scaffold.dart';
import 'package:smart_study_plan/features/user_management/presentation/widgets/auth/auth_submit_button.dart';
import 'package:smart_study_plan/features/user_management/presentation/widgets/auth/auth_text_field.dart';

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
    if (_formKey.currentState!.validate()) {
      context.read<UserBloc>().add(
        RegisterUserEvent(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: BlocListener<UserBloc, UserState>(
        listenWhen: (p, c) =>
            p.status == UserStatus.loading && c.status != UserStatus.loading,
        listener: (context, state) {
          if (state.status == UserStatus.authenticated) {
            // Navigate to home on successful registration
            context.goNamed(AppRouteNames.home);
          }

          if (state.status == UserStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: AuthCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10.h), // Reduced top spacing
                const AuthHeader(
                  title: 'Create account',
                  subtitle: 'Sign up to start planning smarter',
                ),

                AuthTextField(
                  label: 'Full name',
                  controller: _name,
                  focusNode: _nameFocus,
                  nextFocusNode: _emailFocus,
                  hint: 'John Doe',
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v != null && v.isNotEmpty ? null : 'Name required',
                ),
                SizedBox(height: 12.h), // Less gap

                AuthTextField(
                  label: 'Email',
                  controller: _email,
                  focusNode: _emailFocus,
                  nextFocusNode: _passwordFocus,
                  hint: 'you@example.com',
                  icon: Icons.email_outlined,
                  validator: (v) =>
                      v != null && v.contains('@') ? null : 'Invalid email',
                ),
                SizedBox(height: 12.h), // Less gap

                AuthTextField(
                  label: 'Password',
                  controller: _password,
                  focusNode: _passwordFocus,
                  nextFocusNode: _confirmFocus,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscureText: _hidePassword,
                  validator: (v) =>
                      v != null && v.length >= 6 ? null : 'Min 6 characters',
                  suffix: IconButton(
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20.sp,
                    ),
                  ),
                ),
                SizedBox(height: 12.h), // Less gap

                AuthTextField(
                  label: 'Confirm password',
                  controller: _confirm,
                  focusNode: _confirmFocus,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscureText: _hideConfirm,
                  validator: (v) =>
                      v == _password.text ? null : 'Passwords do not match',
                  suffix: IconButton(
                    onPressed: () =>
                        setState(() => _hideConfirm = !_hideConfirm),
                    icon: Icon(
                      _hideConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20.sp,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    return AuthSubmitButton(
                      loading: state.status == UserStatus.loading,
                      onPressed: _register,
                      text: 'Create account',
                    );
                  },
                ),

                SizedBox(height: 24.h),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14.sp,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.goNamed(AppRouteNames.login),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h), // Standard bottom spacing
              ],
            ),
          ),
        ),
      ),
    );
  }
}
