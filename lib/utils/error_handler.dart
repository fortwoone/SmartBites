import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';

// ==============================================================================
// UTILS : Error Handler
// ==============================================================================
String getReadableErrorMessage(dynamic error, BuildContext context) {
  final loc = AppLocalizations.of(context)!;
  final msg = error.toString().toLowerCase();
  if (error is AuthException) {
    if (msg.contains('invalid login credentials') || msg.contains('invalid credentials')) {
      return loc.error_invalid_credentials;
    }
    if (msg.contains('user not found') || msg.contains('user does not exist')) {
      return loc.error_user_not_found;
    }
    if (msg.contains('invalid password') || msg.contains('wrong password')) {
      return loc.error_wrong_password;
    }
    if (msg.contains('user already registered') || msg.contains('email already exists')) {
      return loc.error_email_already_exists;
    }
    if (msg.contains('password should be at least') || msg.contains('weak password')) {
      return loc.error_weak_password;
    }
    if (msg.contains('invalid email') || msg.contains('invalid format')) {
      return loc.error_invalid_email;
    }
    if (msg.contains('email not confirmed') || msg.contains('confirmation required')) {
      return loc.error_email_not_confirmed;
    }
    if (msg.contains('too many requests')) {
      return loc.error_too_many_requests;
    }
    return '${loc.unexpected_error}\n(AuthException: ${error.message})';
  }
  if (msg.contains('socketexception') ||
      msg.contains('networkexception') || 
      msg.contains('failed host lookup') ||
      msg.contains('connection refused')) {
    return loc.error_network;
  }
  return loc.unexpected_error;
}
