import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter Demo'**
  String get appTitle;

  /// No description provided for @homePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Home Page'**
  String get homePageTitle;

  /// No description provided for @pushButtonMessage.
  ///
  /// In en, this message translates to:
  /// **'You have pushed the button this many times:'**
  String get pushButtonMessage;

  /// No description provided for @increment.
  ///
  /// In en, this message translates to:
  /// **'Increment'**
  String get increment;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @perform_login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get perform_login;

  /// No description provided for @login_failed.
  ///
  /// In en, this message translates to:
  /// **'Error during logging'**
  String get login_failed;

  /// No description provided for @fill_fields.
  ///
  /// In en, this message translates to:
  /// **'You have to fill all fields'**
  String get fill_fields;

  /// No description provided for @email_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your mail'**
  String get email_hint;

  /// No description provided for @hint_passwd.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get hint_passwd;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @shopping_lists.
  ///
  /// In en, this message translates to:
  /// **'Shopping Lists'**
  String get shopping_lists;

  /// No description provided for @new_list.
  ///
  /// In en, this message translates to:
  /// **'New Shopping List'**
  String get new_list;

  /// No description provided for @register_failed.
  ///
  /// In en, this message translates to:
  /// **'Error during register'**
  String get register_failed;

  /// No description provided for @validate.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get validate;

  /// No description provided for @register_success.
  ///
  /// In en, this message translates to:
  /// **'Succesfully registered'**
  String get register_success;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List: '**
  String get list;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @list_name_already_used.
  ///
  /// In en, this message translates to:
  /// **'There is already a shopping list using this name. Please choose another name.'**
  String get list_name_already_used;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete_list.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this shopping list? This action can\'t be undone!'**
  String get delete_list;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @add_product.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get add_product;

  /// No description provided for @add_product_msg.
  ///
  /// In en, this message translates to:
  /// **'Please type the barcode of the product you wish to add to this list. (NOTE: this is a dummy input dialogue. Later versions should instead display a product search screen.)'**
  String get add_product_msg;

  /// No description provided for @delete_product.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to remove this product from the current shopping list? You can\'t undo this action!'**
  String get delete_product;

  /// No description provided for @recipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipes;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @hint_search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get hint_search;

  /// No description provided for @slists.
  ///
  /// In en, this message translates to:
  /// **'Shopping Lists'**
  String get slists;

  /// No description provided for @enter_product_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter a product name.'**
  String get enter_product_name;

  /// No description provided for @add_this_product.
  ///
  /// In en, this message translates to:
  /// **'Add this product'**
  String get add_this_product;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @product_list.
  ///
  /// In en, this message translates to:
  /// **'See my products lists'**
  String get product_list;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename the list'**
  String get rename;

  /// No description provided for @product_details.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get product_details;

  /// No description provided for @energy_kcal_100g.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy_kcal_100g;

  /// No description provided for @fat_100g.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat_100g;

  /// No description provided for @saturated_fat_100g.
  ///
  /// In en, this message translates to:
  /// **'Saturated Fat'**
  String get saturated_fat_100g;

  /// No description provided for @carbohydrates_100g.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get carbohydrates_100g;

  /// No description provided for @sugars_100g.
  ///
  /// In en, this message translates to:
  /// **'Sugars'**
  String get sugars_100g;

  /// No description provided for @fiber_100g.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get fiber_100g;

  /// No description provided for @proteins_100g.
  ///
  /// In en, this message translates to:
  /// **'Proteins'**
  String get proteins_100g;

  /// No description provided for @salt_100g.
  ///
  /// In en, this message translates to:
  /// **'Salt'**
  String get salt_100g;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @nova_group.
  ///
  /// In en, this message translates to:
  /// **'NOVA Group'**
  String get nova_group;

  /// No description provided for @nutritional_intake.
  ///
  /// In en, this message translates to:
  /// **'Nutritional Intake'**
  String get nutritional_intake;

  /// No description provided for @ni_units.
  ///
  /// In en, this message translates to:
  /// **'per 100g / 100ml'**
  String get ni_units;

  /// No description provided for @unknown_brand.
  ///
  /// In en, this message translates to:
  /// **'Unknown brand'**
  String get unknown_brand;

  /// No description provided for @no_ingredient_data.
  ///
  /// In en, this message translates to:
  /// **'No available information about ingredients.'**
  String get no_ingredient_data;

  /// No description provided for @no_nutritional_data.
  ///
  /// In en, this message translates to:
  /// **'No available information about nutritional intake.'**
  String get no_nutritional_data;

  /// No description provided for @unnamed_product.
  ///
  /// In en, this message translates to:
  /// **'No Name Available'**
  String get unnamed_product;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
