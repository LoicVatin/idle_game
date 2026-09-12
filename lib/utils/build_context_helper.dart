import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:idle_game/core/game/idle_game.dart';
import 'package:idle_game/generated/intl/app_localizations.dart';
import 'package:idle_game/generated/intl/app_localizations_en.dart';
import 'package:idle_game/utils/logger_helper.dart';

extension BuildContextHelper on BuildContext {
  AppLocalizations get text {
    // if no locale was found, returns a default
    return AppLocalizations.of(this) ?? AppLocalizationsEn();
  }

  bool get isWebDesktop {
    return kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);
  }

  bool get isWebMobile {
    return kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
  }

  bool get isLandscape {
    return MediaQuery.orientationOf(this) == Orientation.landscape;
  }
}

extension GameBuildContextHelper on IdleGame {
  AppLocalizations get text {
    final context = buildContext;
    if (context == null || !context.mounted) {
      // if no context was found, returns a default
      appLogger.w(
        "Context null or not mounted, default to english localization",
      );
      return AppLocalizationsEn();
    } else {
      // if no locale was found, returns a default
      return AppLocalizations.of(context) ?? AppLocalizationsEn();
    }
  }
}
