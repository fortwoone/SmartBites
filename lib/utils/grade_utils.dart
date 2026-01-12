import 'package:flutter/material.dart';
import 'package:smartbites/l10n/app_localizations.dart';

// Widget Nutri-Score
Widget nutriscoreImg(String? grade, AppLocalizations loc) {
  final cleanGrade = (grade?.trim().toLowerCase() ?? 'unknown');
  const unknownPath = "lib/ressources/nutriscore/unknown.png";
  if (['a', 'b', 'c', 'd', 'e'].contains(cleanGrade)) {
     final lang = loc.localeName.startsWith('fr') ? 'fr' : 'en';
     final path = "lib/ressources/nutriscore/$cleanGrade-new-$lang.png";
     return Image.asset(path, fit: BoxFit.contain, scale: 2.75, errorBuilder: (_, __, ___) => Image.asset(unknownPath, scale: 2.75));
  }
  return Image.asset(unknownPath, fit: BoxFit.contain, scale: 2.75);
}

// Widget NOVA
Widget novaImg(String? grade) {
  final cleanGrade = (grade?.toString().trim() ?? 'unknown');
  if (['1', '2', '3', '4'].contains(cleanGrade)) {
    return Image.asset("lib/ressources/nova/$cleanGrade.png", fit: BoxFit.contain, scale: 2.75, errorBuilder: (_, __, ___) => const SizedBox.shrink());
  }
  return const SizedBox.shrink();
}
