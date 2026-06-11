// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Idle Game';

  @override
  String get upgrade_button => 'Upgrade';

  @override
  String get upgrade_maxed_button => 'Maxed out';

  @override
  String worker_level_indicator(num level) {
    return 'Lvl. $level';
  }

  @override
  String worker_damage_indicator(String damage) {
    return '$damage Dmg.';
  }

  @override
  String worker_health_indicator(String current, String maximum) {
    return '$current / $maximum HP';
  }

  @override
  String worker_stamina_indicator(String current, String maximum) {
    return '$current / $maximum SP';
  }

  @override
  String per_second_indicator(String damage) {
    return '$damage/s';
  }

  @override
  String get tutorial_step_welcome =>
      'Welcome to Idle Game! (working title)\nAnd idle incremental game.\nThis is a work in progress.\n\nHere is a brief tutorial to show you how to play.\nTap anywhere to continue.';

  @override
  String get tutorial_step_playground =>
      'This is your playground, where your adventure is played.';

  @override
  String get tutorial_step_scene =>
      'This area shows the current scene.\nEach Taps here will make the worker move by a step';

  @override
  String get tutorial_step_header =>
      'His level and experience are displayed here.';

  @override
  String get tutorial_step_worker =>
      'Speaking of the worker, here he is.\nHis health and stamina will be displayed above him when relevant.';

  @override
  String get tutorial_step_rate =>
      'When upgraded and automated, his speed in the current scene is displayed here.\nThis speed can represent his walking speed or his regeneration speed depending on the scene.';

  @override
  String get tutorial_step_switch_buttons =>
      'Use these buttons to switch scenes.\nThere is two types of scenes.';

  @override
  String get tutorial_step_encounter_scenes_buttons =>
      'Those scenes spawn encounters for the worker to confront.\nEach confrontation with an encounter consumes stamina and can damage the worker.\nResources are earned when an encounter is defeated.';

  @override
  String get tutorial_step_rest_scene_button =>
      'Those scenes allow the worker to rest and regain HP and SP.';

  @override
  String get tutorial_step_upgrade_button =>
      'Tapping here opens the upgrades panel.\nIt is where you upgrade and automate your worker';

  @override
  String get tutorial_step_resource_panel =>
      'Your resources are shown at the top of the screen.';

  @override
  String get tutorial_step_bottom_panel =>
      'Use the bottom panel to add more playgrounds,\nallowing you to collect more resources.';

  @override
  String get tutorial_step_almost => 'You are almost done.';

  @override
  String get tutorial_step_complete =>
      'Tutorial complete!\nYou can replay it any time.';

  @override
  String get tutorial_step_close => 'Tap to close.';

  @override
  String get tutorial_replay_button => 'Replay tutorial';
}
