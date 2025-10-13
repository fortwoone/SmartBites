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
  String get new_sl => 'New Shopping List';

  @override
  String get name_shop_list => 'Please enter a name for the new shopping list: ';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';
}
