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

  /// No description provided for @login_title.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_title;

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
  /// **'Enter your email'**
  String get email_hint;

  /// No description provided for @hint_passwd.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get hint_passwd;

  /// No description provided for @login_register_action.
  ///
  /// In en, this message translates to:
  /// **' Create an account'**
  String get login_register_action;

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

  /// No description provided for @change_language.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get change_language;

  /// No description provided for @take_photo.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get take_photo;

  /// No description provided for @choose_from_gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get choose_from_gallery;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @change_password.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get change_password;

  /// No description provided for @current_password.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get current_password;

  /// No description provided for @new_password.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get new_password;

  /// No description provided for @confirm_new_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirm_new_password;

  /// No description provided for @fields_required.
  ///
  /// In en, this message translates to:
  /// **'All fields are required'**
  String get fields_required;

  /// No description provided for @passwords_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwords_mismatch;

  /// No description provided for @password_updated.
  ///
  /// In en, this message translates to:
  /// **'Password updated. Please log in again.'**
  String get password_updated;

  /// No description provided for @photo_update_success.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated successfully'**
  String get photo_update_success;

  /// No description provided for @change_photo_title.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get change_photo_title;

  /// No description provided for @edit_name_title.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get edit_name_title;

  /// No description provided for @edit_name_label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get edit_name_label;

  /// No description provided for @name_updated.
  ///
  /// In en, this message translates to:
  /// **'Name updated'**
  String get name_updated;

  /// No description provided for @edit_name_tile_title.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get edit_name_tile_title;

  /// No description provided for @edit_name_tile_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your display name'**
  String get edit_name_tile_subtitle;

  /// No description provided for @history_subtitle.
  ///
  /// In en, this message translates to:
  /// **'View your previous shopping lists'**
  String get history_subtitle;

  /// No description provided for @logout_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get logout_subtitle;

  /// No description provided for @change_password_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your password'**
  String get change_password_subtitle;

  /// No description provided for @load_user_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user data'**
  String get load_user_error;

  /// No description provided for @avatar_upload_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload avatar'**
  String get avatar_upload_failed;

  /// No description provided for @avatar_pick_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image'**
  String get avatar_pick_failed;

  /// No description provided for @name_update_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update name'**
  String get name_update_failed;

  /// No description provided for @password_update_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update password'**
  String get password_update_failed;

  /// No description provided for @user_not_authenticated.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get user_not_authenticated;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @generic_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get generic_error;

  /// No description provided for @recipe_page.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipe_page;

  /// No description provided for @delete_recipe.
  ///
  /// In en, this message translates to:
  /// **'Delete the recipe'**
  String get delete_recipe;

  /// No description provided for @deleteRecipeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this recipe'**
  String get deleteRecipeConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @invalidID.
  ///
  /// In en, this message translates to:
  /// **'invalid ID'**
  String get invalidID;

  /// No description provided for @recipeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Recipe deleted !'**
  String get recipeDeleted;

  /// No description provided for @myRecipes.
  ///
  /// In en, this message translates to:
  /// **'My recipes'**
  String get myRecipes;

  /// No description provided for @showMyRecipes.
  ///
  /// In en, this message translates to:
  /// **'Show my recipes'**
  String get showMyRecipes;

  /// No description provided for @allRecipes.
  ///
  /// In en, this message translates to:
  /// **'Show all recipes'**
  String get allRecipes;

  /// No description provided for @noRecipeFound.
  ///
  /// In en, this message translates to:
  /// **'No recipe founded.'**
  String get noRecipeFound;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get noTitle;

  /// No description provided for @recipe.
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get recipe;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @preparation.
  ///
  /// In en, this message translates to:
  /// **'Preparation'**
  String get preparation;

  /// No description provided for @baking.
  ///
  /// In en, this message translates to:
  /// **'Baking'**
  String get baking;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @noIngredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredient'**
  String get noIngredients;

  /// No description provided for @noIngredientsAdded.
  ///
  /// In en, this message translates to:
  /// **'No ingredient added'**
  String get noIngredientsAdded;

  /// No description provided for @barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add an ingredient'**
  String get addIngredient;

  /// No description provided for @addIngredientManual.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient manually'**
  String get addIngredientManual;

  /// No description provided for @addIngredientSearch.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient by searching'**
  String get addIngredientSearch;

  /// No description provided for @nameIngredient.
  ///
  /// In en, this message translates to:
  /// **'Name of the ingredient'**
  String get nameIngredient;

  /// No description provided for @hintIngredient.
  ///
  /// In en, this message translates to:
  /// **'Ex : Tomato'**
  String get hintIngredient;

  /// No description provided for @updatedRecipe.
  ///
  /// In en, this message translates to:
  /// **'Recipe updated successfully'**
  String get updatedRecipe;

  /// No description provided for @addedRecipe.
  ///
  /// In en, this message translates to:
  /// **'Recipe added successfully'**
  String get addedRecipe;

  /// No description provided for @updateRecipe.
  ///
  /// In en, this message translates to:
  /// **'Update the recipe'**
  String get updateRecipe;

  /// No description provided for @addRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add a recipe'**
  String get addRecipe;

  /// No description provided for @nameRecipe.
  ///
  /// In en, this message translates to:
  /// **'Name of the recipe'**
  String get nameRecipe;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get enterName;

  /// No description provided for @timePreparing.
  ///
  /// In en, this message translates to:
  /// **'Time of preparation (min)'**
  String get timePreparing;

  /// No description provided for @timeBaking.
  ///
  /// In en, this message translates to:
  /// **'Time of baking(min)'**
  String get timeBaking;

  /// No description provided for @enterInstructions.
  ///
  /// In en, this message translates to:
  /// **'Please enter some instructions'**
  String get enterInstructions;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

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

  /// No description provided for @nova_explanation.
  ///
  /// In en, this message translates to:
  /// **'The NOVA indicator defines how much processing food has gone through before reaching shelves.'**
  String get nova_explanation;

  /// No description provided for @nova_1_title.
  ///
  /// In en, this message translates to:
  /// **'Unprocessed or minimally processed foods'**
  String get nova_1_title;

  /// No description provided for @nova_1_explanation.
  ///
  /// In en, this message translates to:
  /// **'Unprocessed (or natural) foods are edible parts of plants (seeds, fruits, leaves, stems, roots) or of animals (muscle, offal, eggs, milk), and also fungi, algae and water, after separation from nature.\n\nMinimally processed foods are natural foods altered by processes that include removal of inedible or unwanted parts, and drying, crushing, grinding, fractioning, filtering, roasting, boiling, non-alcoholic fermentation, pasteurization, refrigeration, chilling, freezing, placing in containers and vacuum-packaging. These processes are designed to preserve natural foods, to make them suitable for storage, or to make them safe or edible or more pleasant to consume. Many unprocessed or minimally processed foods are prepared and cooked at home or in restaurant kitchens in combination with processed culinary ingredients as dishes or meals.'**
  String get nova_1_explanation;

  /// No description provided for @nova_2_title.
  ///
  /// In en, this message translates to:
  /// **'Processed culinary ingredients'**
  String get nova_2_title;

  /// No description provided for @nova_2_explanation.
  ///
  /// In en, this message translates to:
  /// **'Processed culinary ingredients, such as oils, butter, sugar and salt, are substances derived from Group 1 foods or from nature by processes that include pressing, refining, grinding, milling and drying. The purpose of such processes is to make durable products that are suitable for use in home and restaurant kitchens to prepare, season and cook Group 1 foods and to make with them varied and enjoyable hand-made dishes and meals, such as stews, soups and broths, salads, breads, preserves, drinks and desserts. They are not meant to be consumed by themselves, and are normally used in combination with Group 1 foods to make freshly prepared drinks, dishes and meals.'**
  String get nova_2_explanation;

  /// No description provided for @nova_3_title.
  ///
  /// In en, this message translates to:
  /// **'Processed foods'**
  String get nova_3_title;

  /// No description provided for @nova_3_explanation.
  ///
  /// In en, this message translates to:
  /// **'Processed foods, such as bottled vegetables, canned fish, fruits in syrup, cheeses and freshly made breads, are made essentially by adding salt, oil, sugar or other substances from Group 2 to Group 1 foods.\n\nProcesses include various preservation or cooking methods, and, in the case of breads and cheese, non-alcoholic fermentation. Most processed foods have two or three ingredients, and are recognizable as modified versions of Group 1 foods. They are edible by themselves or, more usually, in combination with other foods. The purpose of processing here is to increase the durability of Group 1 foods, or to modify or enhance their sensory qualities.'**
  String get nova_3_explanation;

  /// No description provided for @nova_4_title.
  ///
  /// In en, this message translates to:
  /// **'Ultra-processed foods'**
  String get nova_4_title;

  /// No description provided for @nova_4_explanation.
  ///
  /// In en, this message translates to:
  /// **'Ultra-processed foods, such as soft drinks, sweet or savoury packaged snacks, reconstituted meat products and pre-prepared frozen dishes, are not modified foods but formulations made mostly or entirely from substances derived from foods and additives, with little if any intact Group 1 food.\n\nIngredients of these formulations usually include those also used in processed foods, such as sugars, oils, fats or salt. But ultra-processed products also include other sources of energy and nutrients not normally used in culinary preparations. Some of these are directly extracted from foods, such as casein, lactose, whey and gluten.\n\nMany are derived from further processing of food constituents, such as hydrogenated or interesterified oils, hydrolysed proteins, soya protein isolate, maltodextrin, invert sugar and high-fructose corn syrup.\n\nAdditives in ultra-processed foods include some also used in processed foods, such as preservatives, antioxidants and stabilizers. Classes of additives found only in ultra-processed products include those used to imitate or enhance the sensory qualities of foods or to disguise unpalatable aspects of the final product. These additives include dyes and other colours, colour stabilizers; flavours, flavour enhancers, non-sugar sweeteners; and processing aids such as carbonating, firming, bulking and anti-bulking, de-foaming, anti-caking and glazing agents, emulsifiers, sequestrants and humectants.\n\nA multitude of sequences of processes is used to combine the usually many ingredients and to create the final product (hence \'ultra-processed\'). The processes include several with no domestic equivalents, such as hydrogenation and hydrolysation, extrusion and moulding, and pre-processing for frying.\n\nThe overall purpose of ultra-processing is to create branded, convenient (durable, ready to consume), attractive (hyper-palatable) and highly profitable (low-cost ingredients) food products designed to displace all other food groups. Ultra-processed food products are usually packaged attractively and marketed intensively.'**
  String get nova_4_explanation;

  /// No description provided for @nova_unknown_title.
  ///
  /// In en, this message translates to:
  /// **'Unknown group'**
  String get nova_unknown_title;

  /// No description provided for @nova_unknown_explanation.
  ///
  /// In en, this message translates to:
  /// **'There is no provided NOVA group for this product.'**
  String get nova_unknown_explanation;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get createdBy;

  /// No description provided for @unexpected_error.
  ///
  /// In en, this message translates to:
  /// **'An error occured. Please retry and verify your password and email.'**
  String get unexpected_error;

  /// No description provided for @filterTime.
  ///
  /// In en, this message translates to:
  /// **'Filter by time'**
  String get filterTime;

  /// No description provided for @cookingTime.
  ///
  /// In en, this message translates to:
  /// **'Cooking time'**
  String get cookingTime;

  /// No description provided for @showingCooking.
  ///
  /// In en, this message translates to:
  /// **'⏱️ Showing recipes ≤'**
  String get showingCooking;

  /// No description provided for @viewRecipe.
  ///
  /// In en, this message translates to:
  /// **'Recipe details'**
  String get viewRecipe;

  /// No description provided for @list_menu.
  ///
  /// In en, this message translates to:
  /// **'Grocery list'**
  String get list_menu;

  /// No description provided for @close_menu.
  ///
  /// In en, this message translates to:
  /// **'Close menu'**
  String get close_menu;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading in progress'**
  String get loading;

  /// No description provided for @empty_list.
  ///
  /// In en, this message translates to:
  /// **'Your list is empty'**
  String get empty_list;

  /// No description provided for @name_list.
  ///
  /// In en, this message translates to:
  /// **'List\'s name'**
  String get name_list;

  /// No description provided for @error_invalid_credentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Please check your credentials.'**
  String get error_invalid_credentials;

  /// No description provided for @error_user_not_found.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email. Please sign up.'**
  String get error_user_not_found;

  /// No description provided for @error_wrong_password.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get error_wrong_password;

  /// No description provided for @error_email_already_exists.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email. Please log in.'**
  String get error_email_already_exists;

  /// No description provided for @error_weak_password.
  ///
  /// In en, this message translates to:
  /// **'Your password must contain at least 6 characters.'**
  String get error_weak_password;

  /// No description provided for @error_invalid_email.
  ///
  /// In en, this message translates to:
  /// **'The email address is not valid. Please check the format.'**
  String get error_invalid_email;

  /// No description provided for @error_network.
  ///
  /// In en, this message translates to:
  /// **'Internet connection problem. Please check your network.'**
  String get error_network;

  /// No description provided for @error_too_many_requests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a few minutes before trying again.'**
  String get error_too_many_requests;

  /// No description provided for @error_email_not_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email before logging in. Check your mailbox.'**
  String get error_email_not_confirmed;

  /// No description provided for @passwords_not_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwords_not_match;

  /// No description provided for @password_too_short.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least 6 characters.'**
  String get password_too_short;

  /// No description provided for @register_title.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get register_title;

  /// No description provided for @subtitle_register.
  ///
  /// In en, this message translates to:
  /// **'Join SmartBite today !'**
  String get subtitle_register;

  /// No description provided for @register_login.
  ///
  /// In en, this message translates to:
  /// **'Already have an account ?'**
  String get register_login;

  /// No description provided for @register_login_action.
  ///
  /// In en, this message translates to:
  /// **' Log in'**
  String get register_login_action;

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Happy to see you again !'**
  String get login_subtitle;

  /// No description provided for @hint_conf_passwd.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get hint_conf_passwd;

  /// No description provided for @conf_passwd.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get conf_passwd;

  /// No description provided for @login_register.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account ?'**
  String get login_register;
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
