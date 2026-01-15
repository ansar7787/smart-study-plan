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

  bool _hidePassword = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
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
        listenWhen: (p, c) => p is UserLoading && c is! UserLoading,
        listener: (context, state) {
          if (state is UserAuthenticated) {
            context.goNamed(AppRouteNames.login);
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
                  title: 'Create account',
                  subtitle: 'Sign up to start planning smarter',
                ),

                AuthTextField(
                  label: 'Full name',
                  controller: _name,
                  hint: 'John Doe',
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v != null && v.isNotEmpty ? null : 'Name required',
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  label: 'Email',
                  controller: _email,
                  hint: 'you@example.com',
                  icon: Icons.email_outlined,
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
                      v != null && v.length >= 6 ? null : 'Min 6 characters',
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
                const SizedBox(height: 16),

                AuthTextField(
                  label: 'Confirm password',
                  controller: _confirm,
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
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    return AuthSubmitButton(
                      loading: state is UserLoading,
                      onPressed: _register,
                      text: 'Create account',
                    );
                  },
                ),

                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: () => context.goNamed(AppRouteNames.login),
                    child: const Text('Already have an account? Login'),
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
