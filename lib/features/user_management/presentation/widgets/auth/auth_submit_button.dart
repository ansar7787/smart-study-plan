import 'package:flutter/material.dart';

class AuthSubmitButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;
  final String text;

  const AuthSubmitButton({
    super.key,
    required this.loading,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: loading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  text,
                  key: const ValueKey('text'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
