import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool _hidePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
          if (state is UserAuthenticated) {
            context.goNamed(
              state.user.isAdmin
                  ? AppRouteNames.adminDashboard
                  : AppRouteNames.home,
            );
          }

          if (state is UserError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: AuthCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeader(
                  title: 'Welcome back',
                  subtitle: 'Login to continue your study plan',
                ),

                AuthTextField(
                  label: 'Email',
                  controller: _email,
                  hint: 'you@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v != null && v.contains('@') ? null : 'Invalid email',
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  label: 'Password',
                  controller: _password,
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
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        context.pushNamed(AppRouteNames.forgotPassword),
                    child: const Text('Forgot password?'),
                  ),
                ),

                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    return AuthSubmitButton(
                      loading: state is UserLoading,
                      onPressed: _login,
                      text: 'Login',
                    );
                  },
                ),

                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: () => context.pushNamed(AppRouteNames.register),
                    child: const Text("Don't have an account? Register"),
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
