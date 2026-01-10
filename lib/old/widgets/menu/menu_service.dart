import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuService {
  static Future<void> disconnect(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  static void navigateIfNotCurrent(
    BuildContext context,
    String routeName,
    String currentRoute,
    VoidCallback onClose,
  ) {
    if (routeName == currentRoute) {
      onClose();
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
    );

    onClose();
  }
}

