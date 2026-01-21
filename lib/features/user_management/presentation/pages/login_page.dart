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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<UserBloc>().add(
        LoginUserEvent(email: _email.text.trim(), password: _password.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state.status == UserStatus.authenticated && state.user != null) {
            context.goNamed(
              state.user!.isAdmin
                  ? AppRouteNames.adminDashboard
                  : AppRouteNames.home,
            );
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
                const AuthHeader(
                  title: 'Welcome back',
                  subtitle: 'Login to continue your study plan',
                ),

                AuthTextField(
                  label: 'Email',
                  controller: _email,
                  focusNode: _emailFocus,
                  nextFocusNode: _passwordFocus,
                  hint: 'you@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v != null && v.contains('@') ? null : 'Invalid email',
                ),
                SizedBox(height: 16.h), // ScreenUtil

                AuthTextField(
                  label: 'Password',
                  controller: _password,
                  focusNode: _passwordFocus,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscureText: _hidePassword,
                  validator: (v) =>
                      v != null && v.isNotEmpty ? null : 'Password required',
                  suffix: IconButton(
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20.sp, // ScreenUtil
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        context.pushNamed(AppRouteNames.forgotPassword),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    return AuthSubmitButton(
                      loading: state.status == UserStatus.loading,
                      onPressed: _login,
                      text: 'Login',
                    );
                  },
                ),

                SizedBox(height: 32.h),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14.sp,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.pushNamed(AppRouteNames.register),
                        child: Text(
                          "Register",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
