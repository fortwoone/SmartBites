// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Demo';

  @override
  String get homePageTitle => 'Home Page';

  @override
  String get pushButtonMessage => 'You have pushed the button this many times:';

  @override
  String get increment => 'Increment';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get perform_login => 'Log in';

  @override
  String get login_failed => 'Error during logging';

  @override
  String get fill_fields => 'You have to fill all fields';

  @override
  String get email_hint => 'Enter your mail';

  @override
  String get hint_passwd => 'Enter your password';

  @override
  String get register => 'Register';

  @override
  String get shopping_lists => 'Shopping Lists';

  @override
  String get new_list => 'New Shopping List';

  @override
  String get register_failed => 'Error during register';

  @override
  String get cancel => 'Cancel';

  @override
  String get validate => 'Validate';

  @override
  String get register_success => 'Succesfully registered';
  String get list => 'List: ';
}
