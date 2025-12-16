import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:SmartBites/l10n/app_localizations.dart';
import '../../utils/color_constants.dart';

class LoginHeader extends StatelessWidget {
  final String? subtitle;
  final double logoSize;

  const LoginHeader({super.key, this.subtitle, this.logoSize = 96});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryPeach.withAlpha(51),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'lib/ressources/logo_App.png',
              width: logoSize,
              height: logoSize,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          loc?.login ?? 'Connexion',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle ?? 'Heureux de vous revoir !',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

