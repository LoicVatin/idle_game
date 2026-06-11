import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'intl/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Idle Game'**
  String get app_name;

  /// No description provided for @upgrade_button.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade_button;

  /// No description provided for @upgrade_maxed_button.
  ///
  /// In en, this message translates to:
  /// **'Maxed out'**
  String get upgrade_maxed_button;

  /// No description provided for @worker_level_indicator.
  ///
  /// In en, this message translates to:
  /// **'Lvl. {level}'**
  String worker_level_indicator(num level);

  /// No description provided for @worker_damage_indicator.
  ///
  /// In en, this message translates to:
  /// **'{damage} Dmg.'**
  String worker_damage_indicator(String damage);

  /// No description provided for @worker_health_indicator.
  ///
  /// In en, this message translates to:
  /// **'{current} / {maximum} HP'**
  String worker_health_indicator(String current, String maximum);

  /// No description provided for @worker_stamina_indicator.
  ///
  /// In en, this message translates to:
  /// **'{current} / {maximum} SP'**
  String worker_stamina_indicator(String current, String maximum);

  /// No description provided for @per_second_indicator.
  ///
  /// In en, this message translates to:
  /// **'{damage}/s'**
  String per_second_indicator(String damage);

  /// No description provided for @tutorial_step_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Idle Game! (working title)\nAnd idle incremental game.\nThis is a work in progress.\n\nHere is a brief tutorial to show you how to play.\nTap anywhere to continue.'**
  String get tutorial_step_welcome;

  /// No description provided for @tutorial_step_playground.
  ///
  /// In en, this message translates to:
  /// **'This is your playground, where your adventure is played.'**
  String get tutorial_step_playground;

  /// No description provided for @tutorial_step_scene.
  ///
  /// In en, this message translates to:
  /// **'This area shows the current scene.\nEach Taps here will make the worker move by a step'**
  String get tutorial_step_scene;

  /// No description provided for @tutorial_step_header.
  ///
  /// In en, this message translates to:
  /// **'His level and experience are displayed here.'**
  String get tutorial_step_header;

  /// No description provided for @tutorial_step_worker.
  ///
  /// In en, this message translates to:
  /// **'Speaking of the worker, here he is.\nHis health and stamina will be displayed above him when relevant.'**
  String get tutorial_step_worker;

  /// No description provided for @tutorial_step_rate.
  ///
  /// In en, this message translates to:
  /// **'When upgraded and automated, his speed in the current scene is displayed here.\nThis speed can represent his walking speed or his regeneration speed depending on the scene.'**
  String get tutorial_step_rate;

  /// No description provided for @tutorial_step_switch_buttons.
  ///
  /// In en, this message translates to:
  /// **'Use these buttons to switch scenes.\nThere is two types of scenes.'**
  String get tutorial_step_switch_buttons;

  /// No description provided for @tutorial_step_encounter_scenes_buttons.
  ///
  /// In en, this message translates to:
  /// **'Those scenes spawn encounters for the worker to confront.\nEach confrontation with an encounter consumes stamina and can damage the worker.\nResources are earned when an encounter is defeated.'**
  String get tutorial_step_encounter_scenes_buttons;

  /// No description provided for @tutorial_step_rest_scene_button.
  ///
  /// In en, this message translates to:
  /// **'Those scenes allow the worker to rest and regain HP and SP.'**
  String get tutorial_step_rest_scene_button;

  /// No description provided for @tutorial_step_upgrade_button.
  ///
  /// In en, this message translates to:
  /// **'Tapping here opens the upgrades panel.\nIt is where you upgrade and automate your worker'**
  String get tutorial_step_upgrade_button;

  /// No description provided for @tutorial_step_resource_panel.
  ///
  /// In en, this message translates to:
  /// **'Your resources are shown at the top of the screen.'**
  String get tutorial_step_resource_panel;

  /// No description provided for @tutorial_step_bottom_panel.
  ///
  /// In en, this message translates to:
  /// **'Use the bottom panel to add more playgrounds,\nallowing you to collect more resources.'**
  String get tutorial_step_bottom_panel;

  /// No description provided for @tutorial_step_almost.
  ///
  /// In en, this message translates to:
  /// **'You are almost done.'**
  String get tutorial_step_almost;

  /// No description provided for @tutorial_step_complete.
  ///
  /// In en, this message translates to:
  /// **'Tutorial complete!\nYou can replay it any time.'**
  String get tutorial_step_complete;

  /// No description provided for @tutorial_step_close.
  ///
  /// In en, this message translates to:
  /// **'Tap to close.'**
  String get tutorial_step_close;

  /// No description provided for @tutorial_replay_button.
  ///
  /// In en, this message translates to:
  /// **'Replay tutorial'**
  String get tutorial_replay_button;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
