## Repo snapshot for AI coding agents

This is a small Flutter app (Dart, null-safety) named `uniperks`. Key facts an agent should know to be immediately productive:

- Entry point: `lib/main.dart` — app launches `LoginPage` from `lib/auth/login_page.dart`.
- UI pages: `lib/pages/` (e.g. `product_catalog_page.dart`, `cart_page.dart`, `quiz_page.dart`, `shop_page.dart`, `voucher_page.dart`).
- Services: `lib/services/` contains the app's business logic. These are simple, in-memory static stores (no network/backend):
  - `product_service.dart` — static `_products` list and CRUD-like helpers (e.g. `getAllProducts()`, `getProduct(id)`).
  - `cart_service.dart` — cart state stored per username in a `Map<String, List<CartItem>>` and manipulated via static methods like `addToCart(username, product)`.
  - `quiz_service.dart`, `daily_quiz_service.dart`, `user_coins_service.dart`, `user_service.dart` — follow same static-data pattern.

Design implications (why code is structured this way):
- Simple static services are used as the app "model"/data layer. Mutations are done by calling static methods; UI widgets read from services on build or via setState in pages.
- User identity is represented as a plain `String` username in services (not a remote auth token). When adding features that require auth or persistence, update services and pages consistently.

Patterns the agent should follow when editing code
- When changing data shapes (models in `lib/models/`), update all services that construct or consume those models (e.g. `Product`, `CartItem`).
- Keep edits idiomatic Dart: null-safety, prefer small focused changes, preserve existing static-service pattern unless implementing a cross-cutting migration (document migrations).
- Avoid adding heavy dependencies. If a package is needed, add it to `pubspec.yaml` and run `flutter pub get` (see workflows below).

Examples of common code-level tasks and where to look
- Add a new product: `lib/services/product_service.dart` — append to `_products` and use `getAllProducts()` in `product_catalog_page.dart`.
- Update cart logic: `lib/services/cart_service.dart` — methods expect a `username` string; pages call `CartService.addToCart(username, product)`.
- Quiz modules/questions: `lib/services/quiz_service.dart` — `_moduleQuestions` map contains question lists. Use `getQuestionsByModule(moduleId)`.

Build / test / debug workflows (commands for PowerShell)
- Install deps: `flutter pub get`
- Run app on connected device/emulator: `flutter run -d <deviceId>`
- Build Android APK: `flutter build apk --release`
- Run unit/widget tests: `flutter test`
- Hot-reload during development: use `r` in the `flutter run` console or the Flutter tooling in IDE.

Project-specific conventions
- In-memory static services are the authoritative source for state. Do not introduce alternative global state containers without a clear migration plan.
- Files under `lib/services` are the place for business logic; `lib/pages` contains UI and minimal glue.
- Keep UI changes local to pages; if logic is needed by multiple pages, add or update a service.

Integration points and external dependencies
- Currently the app uses no network backend or external APIs — image URLs use placeholder services (e.g. `https://via.placeholder.com/...`).
- If adding network or persistence, wire it into services and document required configuration (e.g. adding API keys to `local.properties` or to platform-specific config).

Quick checks an agent should make before submitting changes
- Run `flutter analyze` (or rely on IDE) to catch lint/type issues.
- Run `flutter test` to verify widget/unit tests (there is `test/widget_test.dart`).
- Search for usages when modifying models or service method signatures (IDE find-usages or `grep`).

When in doubt, reference these files first
- `lib/main.dart` — app entry and theme.
- `lib/services/*.dart` — business logic and state.
- `lib/pages/*` and `lib/auth/*` — UI and navigation flow.

If you need clarification or notice missing wiring (persistence, auth), leave an explanatory TODO in code and ping the maintainers for design direction.

---
Please review these notes and tell me if you'd like more examples (small code snippets illustrating service->page calls) or extra sections (CI/build specifics, contributor conventions).
