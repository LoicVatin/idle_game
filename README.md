# Idle Game [Working title]

An idle incremental game made with Flutter and Flame.

[![Made with Flutter](https://img.shields.io/badge/Made%20with-Flutter-blue?logo=flutter)](https://flutter.dev)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-Flame%20%F0%9F%94%A5-272727.svg)](https://flame-engine.org)
[![Enhanced with Gemini](https://img.shields.io/badge/Enhanced_with-Gemini-blue?logo=googlegemini&color=007fff)](https://gemini.google.com/)
[![Enhanced with Junie](https://img.shields.io/badge/Enhanced_with-Junie-green?logo=intellijidea)](https://junie.jetbrains.com/)

## Description [WIP]

Manage a team of workers to gather resources.

## Features & Roadmap [WIP]

- [x] Basic game logic
- [x] Basic game UI
- [x] Localization setup
- [ ] Basic identity (sprites, sound, etc...)
- [ ] Progression persistence
- [ ] Offline progression
- [ ] Definitive identity

## Technical stack [WIP]

This project is built using:

- [Flutter](https://flutter.dev/)
- [Flame](https://flame-engine.org/)

This project is using:

- [collection](https://pub.dev/packages/collection)
- [intl](https://pub.dev/packages/intl)
- [flame_audio](https://pub.dev/packages/flame_audio)
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
- [google_fonts](https://pub.dev/packages/google_fonts)
- [logger](https://pub.dev/packages/logger)

## 🏗️ Architecture [WIP]

```
lib/
├── core/                                   #
│   └── game/                               #
│       ├── components/                     # Flame components
│       └── idle_game.dart                  # Flame game engine
│
├── data/                                   # Datasource
│   └── models/                             # Models
│
├── generated/                              #
│   ├── intl/                               # Localization
│   └── l10n.dart                           #
│
├── l10n/                                   # Localization references files
│   └── intl_en.dart                        # English localization (default)
│
├── presentation/                           #
│   ├── core/                               #
│   │   └── game_provider.dart              # Main game provider
│   │
│   └── home/                               #
│       ├── home_screen.dart                # Home screen
│       └── upgrade_overlay_widget.dart     # Upgrade overlay 
│
├── utils/                                  # Utilities
│   └── build_context_helper.dart           # Helper to access context-related methods (localization, styles, etc.)
│
└── main.dart                               # Entry point
```

