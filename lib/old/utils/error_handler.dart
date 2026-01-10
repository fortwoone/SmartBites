import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';

String getReadableErrorMessage(dynamic error, BuildContext context) {
  final loc = AppLocalizations.of(context)!;

  if (error is AuthException) {
    final msg = error.message.toLowerCase();

    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials')) {
      return loc.error_invalid_credentials;
    }

    if (msg.contains('user not found') ||
        msg.contains('user does not exist')) {
      return loc.error_user_not_found;
    }

    if (msg.contains('invalid password') ||
        msg.contains('wrong password')) {
      return loc.error_wrong_password;
    }

    if (msg.contains('user already registered') ||
        msg.contains('email already exists') ||
        msg.contains('already registered')) {
      return loc.error_email_already_exists;
    }

    if (msg.contains('password should be at least') ||
        msg.contains('weak password')) {
      return loc.error_weak_password;
    }

    if (msg.contains('invalid email') ||
        msg.contains('invalid format')) {
      return loc.error_invalid_email;
    }

    if (msg.contains('email not confirmed') ||
        msg.contains('confirmation required')) {
      return loc.error_email_not_confirmed;
    }

    if (msg.contains('too many requests')) {
      return loc.error_too_many_requests;
    }
    return '${loc.unexpected_error}\n${error.message}';
  }

  final errorStr = error.toString();
  if (errorStr.contains('SocketException') ||
      errorStr.contains('NetworkException') ||
      errorStr.contains('Failed host lookup')) {
    return loc.error_network;
  }
  return '${loc.unexpected_error}\n$errorStr';
}
