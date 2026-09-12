# Idle Game [Working title]

An idle incremental game made with Flutter and Flame.

[![Made with Flutter](https://img.shields.io/badge/Made%20with-Flutter-blue?logo=flutter)](https://flutter.dev)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-Flame%20%F0%9F%94%A5-272727.svg)](https://flame-engine.org)
[![Enhanced with Gemini](https://img.shields.io/badge/Enhanced_with-Gemini-blue?logo=googlegemini&color=007fff)](https://gemini.google.com/)
[![Enhanced with Claude Code](https://img.shields.io/badge/Enhanced%20with-Claude%20Code-orange?logo=claude)](https://claude.com/product/claude-code)
[![Enhanced with Junie](https://img.shields.io/badge/Enhanced_with-Junie-green?logo=intellijidea)](https://junie.jetbrains.com/)

## Description [WIP]

Manage a team of workers to gather resources.

<img width="270" height="606" alt="Screenshot_20260912_202028" src="https://github.com/user-attachments/assets/b2147ddc-50ac-48c9-a991-0e3b5fed99df" />
<img width="270" height="606" alt="Screenshot_20260912_202032" src="https://github.com/user-attachments/assets/d7a31ea7-ccaa-48de-91f8-e3139b0de1be" />

## Features & Roadmap [WIP]

- [x] Basic game logic
- [x] Basic game UI
- [x] Localization setup
- [x] Basic tutorial
- [x] Basic identity (sprites, sound, etc...)
- [ ] Progression persistence
- [ ] Offline progression
- [ ] Replace basic resources with loot pool
- [ ] Game Balance
- [ ] Definitive identity
- [ ] Complete tutorial
- [ ] AND MORE!!!

## Technical stack [WIP]

This project is built using:

- [Flutter](https://flutter.dev/)
- [Flame](https://flame-engine.org/)

This project is using:

- [collection](https://pub.dev/packages/collection)
- [intl](https://pub.dev/packages/intl)
- [flame_audio](https://pub.dev/packages/flame_audio)
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
- [flutter_soloud](https://pub.dev/packages/flutter_soloud)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
- [google_fonts](https://pub.dev/packages/google_fonts)
- [logger](https://pub.dev/packages/logger)

This project art is made with:

- [Aseprite](https://aseprite.org/)
- [Strudel REPL](https://strudel.cc/)

## 🏗️ Architecture [WIP]

```
lib/
├── core/                                   #
│   ├── audio/                              # Audio player
│   ├── game/                               #
│   |   ├── components/                     # Flame components
│   |   └── idle_game.dart                  # Flame game engine
│   └── styles/                             # App style settings and values
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
│       ├── tutorial_overlay_widget.dart    # Tutorial overlay
│       └── upgrade_overlay_widget.dart     # Upgrade overlay 
│
├── utils/                                  # Utilities
│   ├── build_context_helper.dart           # Helper to access context-related methods (localization, styles, etc.)
│   ├── logger_helper.dart                  # Helper to access the logger
│   └── shared_preferences_helper.dart      # Helper to access the shared preferences
│
└── main.dart                               # Entry point
```

