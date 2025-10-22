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
  String get login_failed => 'Erreur lors de la connexion';

  @override
  String get fill_fields => 'Vous devez renseigner tous les champs';

  @override
  String get email_hint => 'Veuillez entrer votre adresse mail';

  @override
  String get hint_passwd => 'Veuillez entrer votre mot de passe';

  @override
  String get register => 'S\'inscrire';

  @override
  String get shopping_lists => 'Listes de courses';

  @override
  String get new_list => 'Nouvelle liste de courses';

  @override
  String get register_failed => 'Erreur lors de l\'inscription';

  @override
  String get cancel => 'Annuler';

  @override
  String get validate => 'Valider';

  @override
  String get register_success => 'Inscription validé';
  String get list => 'Liste : ';
}
