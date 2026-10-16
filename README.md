# Rick and Morty

A Flutter app for browsing and searching the characters of the Rick and Morty universe, built on
the public [Rick and Morty API](https://rickandmortyapi.com/documentation). It runs on Android,
iOS and the web, and is split into small Dart packages so the network, data and domain layers
can be read and tested on their own.

- **Web demo:** <https://abigotado.github.io/rick-and-morty/>
- **Android APK:** open the latest successful
  [CI run on `main`](https://github.com/abigotado/rick-and-morty/actions/workflows/ci.yml?query=branch%3Amain)
  and download the `rick-and-morty-apk` artifact (requires a GitHub login; kept for 30 days).

## Features

- Character catalog with image, name and status (plus species).
- Infinite scroll: the next page loads as you approach the end of the list.
- Search by name, debounced, with the matching part of each name highlighted.
- Loading, error and empty states: skeleton placeholders on first load, a retry screen when the
  first page fails, an inline retry footer when a later page fails, and an empty-search screen
  with a "Clear search" action.
- Details screen: image, status, species, gender, origin and current location, opened from the
  list with a `Hero` transition.
- Going back from details returns to the list with its items, query and scroll position intact.
- Deep links (`/character/:id`, or a page refresh on the web) load the character by id.
- Adaptive layout: a list on phones, a grid of cards above 600 px.
- Reduced motion: entrance animations, shimmer and press effects are skipped when the platform
  asks for fewer animations.

## Architecture

A [pub workspace](https://dart.dev/tools/pub/workspaces) with three packages and the app on top.
Dependencies point one way and never form a cycle:

```
rick_and_morty_api  <-  characters_data  ->  characters_domain  <-  app (lib/features)
    (network)            (repositories)         (contracts)          (blocs + screens)
```

| Layer | Owns |
| --- | --- |
| `packages/rick_and_morty_api` | Dio + Retrofit client, `json_serializable` DTOs, `CharactersService`, a sealed `ApiException`. Knows nothing about the domain. |
| `packages/characters_domain` | Pure Dart: `Equatable` entities, a sealed `Failure`, the `ICharactersRepository` contract. Depends only on `equatable`. |
| `packages/characters_data` | `CharacterMapper` (DTO to entity) and `CharactersRepository`. The only place where DTOs meet entities. |
| `lib/` | Composition root (`main.dart`), routing, theme, shared widgets, and the character features. Features depend on `characters_domain` only. |

**Errors.** The service turns every Dio and parsing error into an `ApiException`
(connection, response with status code, format). The repository translates those into a
`Failure` (`NetworkFailure`, `ServerFailure`, `NotFoundFailure`), so nothing from Dio reaches a
bloc. A search with no matches (the API answers 404) becomes an empty page, not an error. Blocs
catch `Failure` and expose it in state; the UI maps it to a message with an exhaustive `switch`.

**State.** `flutter_bloc`: a `CharactersBloc` for the list and a `CharacterDetailsCubit` for
details. Event concurrency comes from `bloc_concurrency`: search uses a debounced `restartable`
transformer, so a new query cancels both the pending wait and the in-flight request.

**Dependency injection.** No service locator. `main.dart` builds the graph by hand
(Dio, service, repository) and hands the repository to `App`, which exposes it with a
`RepositoryProvider`. Each screen is a `XPage` that creates its bloc with `BlocProvider`, plus a
`XView` that only renders.

**Routing.** `go_router`. Details live at `/character/:id` as a child route of `/`, so the list
page stays mounted underneath and keeps its state without any caching. The tapped character is
passed through `extra` for an instant render; without it, the cubit fetches by id.

### Key decisions

- **Stale-response guard in search.** Every first-page load bumps a token; a response from a
  superseded load is dropped, so a slow answer for an old query cannot overwrite a newer one.
- **Single-flight pagination.** The bloc emits a "loading next page" status before its first
  `await`, and `canLoadMore` checks it, so the same page is never requested twice. Pagination
  logic lives in a reusable `InfiniteScrollMixin`, which also re-checks after a page arrives,
  since a page that does not fill the screen never produces a scroll event.
- **Images.** `cached_network_image`, decoded at display size (`memCacheWidth`) rather than at
  source resolution. The mapper accepts only `https` URLs on the API host; anything else falls
  back to a placeholder.
- **Network.** HTTPS base URL, 10 s timeouts, request logging in debug builds only.
- **No use-case layer.** Blocs talk to the repository directly; at this size an extra layer
  would only forward calls.

## Getting started

The Flutter version is pinned in `.fvmrc` (3.44.8). The commands below use
[FVM](https://fvm.app); with that exact Flutter version on your `PATH`, drop the `fvm` prefix.

```bash
fvm install
fvm flutter pub get
```

Run the app:

```bash
fvm flutter devices               # list running simulators, emulators and devices
fvm flutter run -d <device-id>    # an iOS simulator or an Android emulator/device
fvm flutter run -d chrome         # web
```

The DTOs and the Retrofit client use code generation. The generated `*.g.dart` files are
committed; after changing a DTO or the API interface, regenerate them:

```bash
cd packages/rick_and_morty_api
fvm dart run build_runner build
```

## Testing

App tests (widgets, blocs, shared UI):

```bash
fvm flutter test
```

Package tests, run from each package directory:

```bash
for package in packages/*/; do (cd "$package" && fvm dart test); done
```

Covered: DTO parsing and the service's error mapping (against a fake HTTP adapter), the mapper
and the repository's `ApiException` to `Failure` translation, entities, the list bloc
(pagination, debounce, retries, stale responses), the details cubit, the infinite-scroll mixin,
the shared widgets including the `Hero` flight, the list and details screens in each of their
states, and routing (list state kept on back, deep links, invalid and non-canonical ids).

Everything CI checks, in one go:

```bash
(cd packages/rick_and_morty_api && fvm dart run build_runner build) && test -z "$(git status --porcelain)"
find lib test packages -name '*.dart' ! -name '*.g.dart' ! -path '*/.dart_tool/*' -print0 \
  | xargs -0 fvm dart format --output=none --set-exit-if-changed
fvm flutter analyze
(set -e; for package in packages/*/; do (cd "$package" && fvm dart test); done)
fvm flutter test
```

## CI

GitHub Actions (`.github/workflows/ci.yml`) runs on every push to `main` and `stage`:

1. Install dependencies with `--enforce-lockfile`.
2. Re-run `build_runner` and fail if the generated files differ from the committed ones.
3. Check formatting (`dart format`, generated files excluded).
4. `flutter analyze` with [`very_good_analysis`](https://pub.dev/packages/very_good_analysis)
   and strict casts, inference and raw types.
5. Run the package tests, then the app tests with coverage.

On `main` only, after the checks pass:

- **APK:** a release build, obfuscated with split debug info, uploaded as the
  `rick-and-morty-apk` artifact (symbols go to `rick-and-morty-apk-symbols`).
- **Web:** a release build with a Content Security Policy added to `index.html`, deployed to
  GitHub Pages.

Third-party actions are pinned by commit SHA.

## Design notes

A dark-only Material 3 theme called "Portal": a near-black green ground, portal-green
(`#97CE4C`) accent, and the [Space Grotesk](https://fonts.google.com/specimen/Space+Grotesk)
font, bundled under the SIL Open Font License (registered in the app's license page). The list
header collapses with the scroll; empty and error states use a small portal illustration.
All animations respect the platform's reduced-motion setting.

## Known limitations and next steps

- The release APK is signed with the debug key; a real release would need its own keystore.
- The API rate-limits requests. HTTP 429 is shown as a retryable "Too many requests" error. On
  the web the 429 response carries no CORS headers, so the browser hides it and the app shows a
  connection error instead.
- No offline cache beyond images: without a connection only the error state is available.
- No localization; UI strings are English only.
- On the web, the in-app back button pops the route, which go_router records as a new history
  entry; pressing the browser's Back right after it reopens the details page.
