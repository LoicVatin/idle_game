// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(damage) => "${damage}/s";

  static String m1(damage) => "${damage} Dmg.";

  static String m2(current, maximum) => "${current} / ${maximum} HP";

  static String m3(level) => "Lvl. ${level}";

  static String m4(current, maximum) => "${current} / ${maximum} SP";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "app_name": MessageLookupByLibrary.simpleMessage("Idle Game"),
    "per_second_indicator": m0,
    "tutorial_replay_button": MessageLookupByLibrary.simpleMessage(
      "Replay tutorial",
    ),
    "tutorial_step_almost": MessageLookupByLibrary.simpleMessage(
      "You are almost done.",
    ),
    "tutorial_step_bottom_panel": MessageLookupByLibrary.simpleMessage(
      "Use the bottom panel to add more playgrounds,\nallowing you to collect more resources.",
    ),
    "tutorial_step_close": MessageLookupByLibrary.simpleMessage(
      "Tap to close.",
    ),
    "tutorial_step_complete": MessageLookupByLibrary.simpleMessage(
      "Tutorial complete!\nYou can replay it any time.",
    ),
    "tutorial_step_encounter_scenes_buttons": MessageLookupByLibrary.simpleMessage(
      "Those scenes spawn encounters for the worker to confront.\nEach confrontation with an encounter consumes stamina and can damage the worker.\nResources are earned when an encounter is defeated.",
    ),
    "tutorial_step_header": MessageLookupByLibrary.simpleMessage(
      "His level and experience are displayed here.",
    ),
    "tutorial_step_playground": MessageLookupByLibrary.simpleMessage(
      "This is your playground, where your adventure is played.",
    ),
    "tutorial_step_rate": MessageLookupByLibrary.simpleMessage(
      "When upgraded and automated, his speed in the current scene is displayed here.\nThis speed can represent his walking speed or his regeneration speed depending on the scene.",
    ),
    "tutorial_step_resource_panel": MessageLookupByLibrary.simpleMessage(
      "Your resources are shown at the top of the screen.",
    ),
    "tutorial_step_rest_scene_button": MessageLookupByLibrary.simpleMessage(
      "Those scenes allow the worker to rest and regain HP and SP.",
    ),
    "tutorial_step_scene": MessageLookupByLibrary.simpleMessage(
      "This area shows the current scene.\nEach Taps here will make the worker move by a step",
    ),
    "tutorial_step_switch_buttons": MessageLookupByLibrary.simpleMessage(
      "Use these buttons to switch scenes.\nThere is two types of scenes.",
    ),
    "tutorial_step_upgrade_button": MessageLookupByLibrary.simpleMessage(
      "Tapping here opens the upgrades panel.\nIt is where you upgrade and automate your worker",
    ),
    "tutorial_step_welcome": MessageLookupByLibrary.simpleMessage(
      "Welcome to Idle Game! (working title)\nAnd idle incremental game.\nThis is a work in progress.\n\nHere is a brief tutorial to show you how to play.\nTap anywhere to continue.",
    ),
    "tutorial_step_worker": MessageLookupByLibrary.simpleMessage(
      "Speaking of the worker, here he is.\nHis health and stamina will be displayed above him when relevant.",
    ),
    "upgrade_button": MessageLookupByLibrary.simpleMessage("Upgrade"),
    "upgrade_maxed_button": MessageLookupByLibrary.simpleMessage("Maxed out"),
    "worker_damage_indicator": m1,
    "worker_health_indicator": m2,
    "worker_level_indicator": m3,
    "worker_stamina_indicator": m4,
  };
}
