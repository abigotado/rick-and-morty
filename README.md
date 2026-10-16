# Rick and Morty

A Flutter app to browse and search characters from the
[Rick and Morty API](https://rickandmortyapi.com/documentation).

## Getting started

The Flutter version is pinned in `.fvmrc` (use [FVM](https://fvm.app) or install that version).

```bash
fvm flutter pub get
fvm flutter run
```

## Checks

```bash
fvm dart format --output=none --set-exit-if-changed lib test
fvm flutter analyze
fvm flutter test
```
