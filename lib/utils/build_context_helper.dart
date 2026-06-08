import 'package:flutter/cupertino.dart';

import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/generated/intl/app_localizations.dart';
import 'package:idle_game/generated/intl/app_localizations_en.dart';

extension BuildContextHelper on BuildContext {
  AppLocalizations get text {
    // if no locale was found, returns a default
    return AppLocalizations.of(this) ?? AppLocalizationsEn();
  }
}

extension GameBuildContextHelper on IdleGame {
  AppLocalizations get text {
    final context = buildContext;
    if (context == null || !context.mounted) {
      // if no context was found, returns a default
      return AppLocalizationsEn();
    } else {
      // if no locale was found, returns a default
      return AppLocalizations.of(context) ?? AppLocalizationsEn();
    }
  }
}
