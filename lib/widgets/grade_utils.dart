import 'package:flutter/material.dart';
import 'package:food/l10n/app_localizations.dart';

Widget nutriscoreImg(String grade, AppLocalizations loc){
    if (grade == "unknown"){
        return Image.asset(
            "lib/ressources/nutriscore/unknown.png",
            fit: BoxFit.contain,
            scale:2.75
        );
    }
    return Image.asset(
        "lib/ressources/nutriscore/$grade-new-${loc.localeName.substring(0, 2)}.png",
        fit: BoxFit.contain,
        scale: 2.75
    );
}
