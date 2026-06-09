// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Idle Game`
  String get app_name {
    return Intl.message('Idle Game', name: 'app_name', desc: '', args: []);
  }

  /// `Upgrade`
  String get upgrade_button {
    return Intl.message('Upgrade', name: 'upgrade_button', desc: '', args: []);
  }

  /// `Maxed out`
  String get upgrade_maxed_button {
    return Intl.message(
      'Maxed out',
      name: 'upgrade_maxed_button',
      desc: '',
      args: [],
    );
  }

  /// `Lvl. {level}`
  String worker_level_indicator(num level) {
    return Intl.message(
      'Lvl. $level',
      name: 'worker_level_indicator',
      desc: '',
      args: [level],
    );
  }

  /// `{damage} Dmg.`
  String worker_damage_indicator(String damage) {
    return Intl.message(
      '$damage Dmg.',
      name: 'worker_damage_indicator',
      desc: '',
      args: [damage],
    );
  }

  /// `{current} / {maximum} HP`
  String worker_health_indicator(String current, String maximum) {
    return Intl.message(
      '$current / $maximum HP',
      name: 'worker_health_indicator',
      desc: '',
      args: [current, maximum],
    );
  }

  /// `{current} / {maximum} SP`
  String worker_stamina_indicator(String current, String maximum) {
    return Intl.message(
      '$current / $maximum SP',
      name: 'worker_stamina_indicator',
      desc: '',
      args: [current, maximum],
    );
  }

  /// `{damage}/s`
  String per_second_indicator(String damage) {
    return Intl.message(
      '$damage/s',
      name: 'per_second_indicator',
      desc: '',
      args: [damage],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[Locale.fromSubtags(languageCode: 'en')];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
