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

  /// `Welcome to Idle Game! (working title)\nAnd idle incremental game.\nThis is a work in progress.\n\nHere is a brief tutorial to show you how to play.\nTap anywhere to continue.`
  String get tutorial_step_welcome {
    return Intl.message(
      'Welcome to Idle Game! (working title)\nAnd idle incremental game.\nThis is a work in progress.\n\nHere is a brief tutorial to show you how to play.\nTap anywhere to continue.',
      name: 'tutorial_step_welcome',
      desc: '',
      args: [],
    );
  }

  /// `This is your playground, where your adventure is played.`
  String get tutorial_step_playground {
    return Intl.message(
      'This is your playground, where your adventure is played.',
      name: 'tutorial_step_playground',
      desc: '',
      args: [],
    );
  }

  /// `This area shows the current scene.\nEach Taps here will make the worker move by a step`
  String get tutorial_step_scene {
    return Intl.message(
      'This area shows the current scene.\nEach Taps here will make the worker move by a step',
      name: 'tutorial_step_scene',
      desc: '',
      args: [],
    );
  }

  /// `His level and experience are displayed here.`
  String get tutorial_step_header {
    return Intl.message(
      'His level and experience are displayed here.',
      name: 'tutorial_step_header',
      desc: '',
      args: [],
    );
  }

  /// `Speaking of the worker, here he is.\nHis health and stamina will be displayed above him when relevant.`
  String get tutorial_step_worker {
    return Intl.message(
      'Speaking of the worker, here he is.\nHis health and stamina will be displayed above him when relevant.',
      name: 'tutorial_step_worker',
      desc: '',
      args: [],
    );
  }

  /// `When upgraded and automated, his speed in the current scene is displayed here.\nThis speed can represent his walking speed or his regeneration speed depending on the scene.`
  String get tutorial_step_rate {
    return Intl.message(
      'When upgraded and automated, his speed in the current scene is displayed here.\nThis speed can represent his walking speed or his regeneration speed depending on the scene.',
      name: 'tutorial_step_rate',
      desc: '',
      args: [],
    );
  }

  /// `Use these buttons to switch scenes.\nThere is two types of scenes.`
  String get tutorial_step_switch_buttons {
    return Intl.message(
      'Use these buttons to switch scenes.\nThere is two types of scenes.',
      name: 'tutorial_step_switch_buttons',
      desc: '',
      args: [],
    );
  }

  /// `Those scenes spawn encounters for the worker to confront.\nEach confrontation with an encounter consumes stamina and can damage the worker.\nResources are earned when an encounter is defeated.`
  String get tutorial_step_encounter_scenes_buttons {
    return Intl.message(
      'Those scenes spawn encounters for the worker to confront.\nEach confrontation with an encounter consumes stamina and can damage the worker.\nResources are earned when an encounter is defeated.',
      name: 'tutorial_step_encounter_scenes_buttons',
      desc: '',
      args: [],
    );
  }

  /// `Those scenes allow the worker to rest and regain HP and SP.`
  String get tutorial_step_rest_scene_button {
    return Intl.message(
      'Those scenes allow the worker to rest and regain HP and SP.',
      name: 'tutorial_step_rest_scene_button',
      desc: '',
      args: [],
    );
  }

  /// `Tapping here opens the upgrades panel.\nIt is where you upgrade and automate your worker`
  String get tutorial_step_upgrade_button {
    return Intl.message(
      'Tapping here opens the upgrades panel.\nIt is where you upgrade and automate your worker',
      name: 'tutorial_step_upgrade_button',
      desc: '',
      args: [],
    );
  }

  /// `Your resources are shown at the top of the screen.`
  String get tutorial_step_resource_panel {
    return Intl.message(
      'Your resources are shown at the top of the screen.',
      name: 'tutorial_step_resource_panel',
      desc: '',
      args: [],
    );
  }

  /// `Use the bottom panel to add more playgrounds,\nallowing you to collect more resources.`
  String get tutorial_step_bottom_panel {
    return Intl.message(
      'Use the bottom panel to add more playgrounds,\nallowing you to collect more resources.',
      name: 'tutorial_step_bottom_panel',
      desc: '',
      args: [],
    );
  }

  /// `You are almost done.`
  String get tutorial_step_almost {
    return Intl.message(
      'You are almost done.',
      name: 'tutorial_step_almost',
      desc: '',
      args: [],
    );
  }

  /// `Tutorial complete!\nYou can replay it any time.`
  String get tutorial_step_complete {
    return Intl.message(
      'Tutorial complete!\nYou can replay it any time.',
      name: 'tutorial_step_complete',
      desc: '',
      args: [],
    );
  }

  /// `Tap to close.`
  String get tutorial_step_close {
    return Intl.message(
      'Tap to close.',
      name: 'tutorial_step_close',
      desc: '',
      args: [],
    );
  }

  /// `Replay tutorial`
  String get tutorial_replay_button {
    return Intl.message(
      'Replay tutorial',
      name: 'tutorial_replay_button',
      desc: '',
      args: [],
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
