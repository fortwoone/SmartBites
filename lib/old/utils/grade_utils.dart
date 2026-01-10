import 'package:flutter/material.dart';
import 'package:SmartBites/l10n/app_localizations.dart';

Widget nutriscoreImg(String grade, AppLocalizations loc){
    debugPrint(grade);
    if (grade == "unknown" || grade == "not-applicable"){
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

Widget novaImg(String grade){
    return Image.asset(
        "lib/ressources/nova/$grade.png",
        fit: BoxFit.contain,
        scale:2.75
    );
}
