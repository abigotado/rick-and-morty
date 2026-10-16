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

The same checks CI runs:

```bash
(cd packages/rick_and_morty_api && fvm dart run build_runner build) && test -z "$(git status --porcelain)"
find lib test packages -name '*.dart' ! -name '*.g.dart' ! -path '*/.dart_tool/*' -print0 \
  | xargs -0 fvm dart format --output=none --set-exit-if-changed
fvm flutter analyze
(set -e; for package in packages/*/; do (cd "$package" && fvm dart test); done)
fvm flutter test
```
