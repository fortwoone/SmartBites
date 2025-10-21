// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Flutter Démo';

  @override
  String get homePageTitle => 'Page d\'accueil';

  @override
  String get pushButtonMessage => 'Vous avez appuyé sur le bouton autant de fois :';

  @override
  String get increment => 'Incrémenter';

  @override
  String get login => 'Connexion';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get perform_login => 'Se connecter';

  @override
  String get shopping_lists => 'Listes de courses';

  @override
  String get new_list => 'Nouvelle liste de courses';

  @override
  String get list => 'Liste : ';
}
