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

  @override
  String get cancel => 'Annuler';

  @override
  String get error => 'Erreur';

  @override
  String get list_name_already_used => 'Il y a déjà une liste de courses avec le nom que vous avez écrit. Choisissez-en un autre.';

  @override
  String get confirm => 'Confirmation';

  @override
  String get delete_list => 'Voulez-vous vraiment supprimer cette liste de courses ? Attention, cette action est irréversible !';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';
}
