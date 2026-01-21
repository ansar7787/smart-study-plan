import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorHandler {
  static String getMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'The email address is already in use by another account.';
        case 'invalid-email':
          return 'The email address is unavailable or invalid.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'user-disabled':
          return 'This user has been disabled. Please contact support.';
        case 'too-many-requests':
          return 'Too many login attempts. Please try again later.';
        case 'operation-not-allowed':
          return 'Operation not allowed. Please contact support.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'invalid-credential':
        case 'invalid-verification-code':
        case 'invalid-verification-id':
          return 'Invalid credentials. Please check your details and try again.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email address but different sign-in credentials.';
        case 'requires-recent-login':
          return 'This operation is sensitive and requires recent authentication. Log in again before retrying this request.';
        case 'provider-already-linked':
          return 'The provider has already been linked to the user.';
        case 'credential-already-in-use':
          return 'This credential is already associated with a different user account.';
        default:
          return error.message ?? 'An unknown authentication error occurred.';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
