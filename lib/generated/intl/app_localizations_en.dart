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
}
