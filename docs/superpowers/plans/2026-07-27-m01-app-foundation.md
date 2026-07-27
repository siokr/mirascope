# M01 App Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Flutter counter template with a tested mirascope application foundation containing generated Riverpod wiring, theme, startup handling, and the four MVP 0.1 routes.

**Architecture:** Keep `main.dart` thin and build the app through a bootstrap function. Centralize the `GoRouter` and theme under `src/app`, expose simple feature pages, and use Riverpod only for dependency/UI-state wiring. Drift dependencies are installed now, but database tables and repositories remain M01-005 work.

**Tech Stack:** Flutter, Dart, Riverpod with code generation, go_router, Drift, build_runner, flutter_test.

## Global Constraints

- The project remains a Flutter application at the repository root.
- MVP 0.1 supports Windows only.
- Routes are handwritten; no routing generator is added.
- Domain code must not depend on Flutter, Riverpod, go_router, or Drift.
- Drift-generated types must not be passed into widgets.
- Freezed is not added.
- No `manga`, `auth`, `sync`, `server`, or Rust directories are created.
- Generated Dart files are committed.
- Database tables, TXT import, and reader behavior are outside this plan.

---

## File Responsibility Map

### Modify

- `pubspec.yaml`: add accepted runtime and generator dependencies.
- `analysis_options.yaml`: enable `custom_lint`.
- `lib/main.dart`: thin async entrypoint that runs bootstrap.
- `docs/mvp-task-list.md`: mark M01-001, M01-002, and M01-003 with evidence-based status after verification.

### Create

- `lib/src/app/app.dart`: `MirascopeApp` and `MaterialApp.router`.
- `lib/src/app/app_name_provider.dart`: generated Riverpod smoke provider.
- `lib/src/app/app_name_provider.g.dart`: generated provider output.
- `lib/src/app/bootstrap/bootstrap.dart`: startup initialization and failure mapping.
- `lib/src/app/bootstrap/startup_error_app.dart`: startup failure UI.
- `lib/src/app/router/app_router.dart`: centralized `GoRouter`.
- `lib/src/app/router/app_routes.dart`: route path constants.
- `lib/src/app/theme/app_theme.dart`: light and dark themes.
- `lib/src/core/errors/app_failure.dart`: stable application failure model.
- `lib/src/core/logging/app_logger.dart`: root logger initialization.
- `lib/src/features/library/presentation/library_page.dart`: initial route and settings navigation.
- `lib/src/features/settings/presentation/settings_page.dart`: settings placeholder.
- `lib/src/features/novel/presentation/novel_details_page.dart`: typed media ID placeholder.
- `lib/src/features/novel/presentation/novel_reader_page.dart`: typed media ID reader placeholder.
- `lib/src/shared/widgets/empty_state.dart`: reusable empty-state widget.

### Replace

- `test/widget_test.dart`: remove counter test and test the mirascope app shell.

### Create Tests

- `test/src/app/app_name_provider_test.dart`
- `test/src/app/theme/app_theme_test.dart`
- `test/src/app/router/app_router_test.dart`
- `test/src/app/bootstrap/bootstrap_test.dart`
- `test/src/core/errors/app_failure_test.dart`

---

### Task 1: Install the Accepted Foundation Dependencies

**Files:**

- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`
- Modify: `analysis_options.yaml`
- Create: `lib/src/app/app_name_provider.dart`
- Create: `lib/src/app/app_name_provider.g.dart`
- Create: `test/src/app/app_name_provider_test.dart`

**Interfaces:**

- Consumes: ADR 0001 and ADR 0003.
- Produces: `appNameProvider`, a generated `Provider<String>` used as a code-generation smoke test.

- [ ] **Step 1: Add runtime and development dependencies**

Run:

```bash
flutter pub add flutter_riverpod riverpod_annotation go_router drift drift_flutter path_provider logging
flutter pub add --dev build_runner riverpod_generator riverpod_lint custom_lint drift_dev
```

Expected: dependency resolution exits 0 and updates `pubspec.yaml` plus `pubspec.lock`.

- [ ] **Step 2: Enable the Riverpod custom lint plugin**

Add to `analysis_options.yaml` above `linter:`:

```yaml
analyzer:
  plugins:
    - custom_lint
```

- [ ] **Step 3: Write the failing provider test**

Create `test/src/app/app_name_provider_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/app/app_name_provider.dart';

void main() {
  test('appNameProvider exposes the product name', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(appNameProvider), 'mirascope');
  });
}
```

- [ ] **Step 4: Run the test to verify it fails**

Run:

```bash
flutter test test/src/app/app_name_provider_test.dart
```

Expected: FAIL because `app_name_provider.dart` or `appNameProvider` does not exist.

- [ ] **Step 5: Implement the generated provider**

Create `lib/src/app/app_name_provider.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_name_provider.g.dart';

@riverpod
String appName(Ref ref) => 'mirascope';
```

- [ ] **Step 6: Generate code**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: `lib/src/app/app_name_provider.g.dart` is generated without conflicts.

- [ ] **Step 7: Run the provider test**

Run:

```bash
flutter test test/src/app/app_name_provider_test.dart
```

Expected: PASS.

- [ ] **Step 8: Run static analysis**

Run:

```bash
flutter analyze
```

Expected: no errors.

- [ ] **Step 9: Commit**

```bash
git add pubspec.yaml pubspec.lock analysis_options.yaml lib/src/app/app_name_provider.dart lib/src/app/app_name_provider.g.dart test/src/app/app_name_provider_test.dart
git commit -m "build: add Flutter foundation dependencies"
```

### Task 2: Add the Failure Model, Theme, and Feature Shell Pages

**Files:**

- Create: `lib/src/core/errors/app_failure.dart`
- Create: `lib/src/app/theme/app_theme.dart`
- Create: `lib/src/shared/widgets/empty_state.dart`
- Create: `lib/src/features/library/presentation/library_page.dart`
- Create: `lib/src/features/settings/presentation/settings_page.dart`
- Create: `lib/src/features/novel/presentation/novel_details_page.dart`
- Create: `lib/src/features/novel/presentation/novel_reader_page.dart`
- Create: `test/src/core/errors/app_failure_test.dart`
- Create: `test/src/app/theme/app_theme_test.dart`

**Interfaces:**

- Produces: `AppFailure`, `AppTheme.light`, `AppTheme.dark`, `EmptyState`, and four feature page widgets.
- Consumes: Flutter Material only; no database or repository types.

- [ ] **Step 1: Write the failing failure-model test**

Create `test/src/core/errors/app_failure_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/core/errors/app_failure.dart';

void main() {
  test('AppFailure keeps a stable code and safe message', () {
    const failure = AppFailure(
      code: 'startup_failed',
      message: '应用启动失败',
    );

    expect(failure.code, 'startup_failed');
    expect(failure.message, '应用启动失败');
    expect(failure.toString(), 'AppFailure(startup_failed)');
  });
}
```

- [ ] **Step 2: Run the failure-model test**

Run:

```bash
flutter test test/src/core/errors/app_failure_test.dart
```

Expected: FAIL because `AppFailure` does not exist.

- [ ] **Step 3: Implement `AppFailure`**

Create `lib/src/core/errors/app_failure.dart`:

```dart
final class AppFailure implements Exception {
  const AppFailure({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => 'AppFailure($code)';
}
```

- [ ] **Step 4: Write the failing theme test**

Create `test/src/app/theme/app_theme_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/app/theme/app_theme.dart';

void main() {
  test('app themes use Material 3 and matching brightness', () {
    expect(AppTheme.light.useMaterial3, isTrue);
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.useMaterial3, isTrue);
    expect(AppTheme.dark.brightness, Brightness.dark);
  });
}
```

- [ ] **Step 5: Run the theme test**

Run:

```bash
flutter test test/src/app/theme/app_theme_test.dart
```

Expected: FAIL because `AppTheme` does not exist.

- [ ] **Step 6: Implement the themes**

Create `lib/src/app/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: const Color(0xFF5B5BD6),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: const Color(0xFF8C8CFF),
  );
}
```

- [ ] **Step 7: Implement the reusable empty state**

Create `lib/src/shared/widgets/empty_state.dart`:

```dart
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              if (action case final action?) ...[
                const SizedBox(height: 20),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 8: Implement the four shell pages**

Create `LibraryPage` with:

```dart
Scaffold(
  appBar: AppBar(
    title: const Text('媒体库'),
    actions: [
      IconButton(
        key: const Key('open-settings'),
        onPressed: onOpenSettings,
        tooltip: '设置',
        icon: const Icon(Icons.settings_outlined),
      ),
    ],
  ),
  body: const EmptyState(
    icon: Icons.menu_book_outlined,
    title: '媒体库还是空的',
    message: '导入一本 TXT 小说，开始建立你的本地书架。',
  ),
)
```

`LibraryPage` constructor:

```dart
const LibraryPage({required this.onOpenSettings, super.key});
final VoidCallback onOpenSettings;
```

Create `SettingsPage` with an AppBar title `设置` and body text `阅读与应用设置将在后续任务中完善。`.

Create `NovelDetailsPage`:

```dart
const NovelDetailsPage({required this.mediaItemId, super.key});
final String mediaItemId;
```

Render AppBar title `小说详情` and text `媒体 ID：$mediaItemId`.

Create `NovelReaderPage` with the same constructor shape, AppBar title `阅读器`, and text `正在准备媒体：$mediaItemId`.

- [ ] **Step 9: Run focused tests**

Run:

```bash
flutter test test/src/core/errors/app_failure_test.dart test/src/app/theme/app_theme_test.dart
```

Expected: both tests PASS.

- [ ] **Step 10: Commit**

```bash
git add lib/src/core/errors/app_failure.dart lib/src/app/theme/app_theme.dart lib/src/shared/widgets/empty_state.dart lib/src/features test/src/core/errors/app_failure_test.dart test/src/app/theme/app_theme_test.dart
git commit -m "feat: add app theme and feature shells"
```

### Task 3: Add Centralized Routing and the App Widget

**Files:**

- Create: `lib/src/app/router/app_routes.dart`
- Create: `lib/src/app/router/app_router.dart`
- Create: `lib/src/app/app.dart`
- Create: `test/src/app/router/app_router_test.dart`
- Replace: `test/widget_test.dart`

**Interfaces:**

- Consumes: `LibraryPage`, `SettingsPage`, `NovelDetailsPage`, `NovelReaderPage`, `AppTheme`.
- Produces: `AppRoutes`, `createAppRouter({String initialLocation})`, `MirascopeApp({GoRouter? router})`.

- [ ] **Step 1: Write failing route tests**

Create `test/src/app/router/app_router_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/app/app.dart';
import 'package:mirascope/src/app/router/app_router.dart';

void main() {
  testWidgets('starts on the media library', (tester) async {
    await tester.pumpWidget(const MirascopeApp());
    await tester.pumpAndSettle();

    expect(find.text('媒体库'), findsOneWidget);
    expect(find.text('媒体库还是空的'), findsOneWidget);
  });

  testWidgets('opens settings from the library', (tester) async {
    await tester.pumpWidget(const MirascopeApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();

    expect(find.text('设置'), findsOneWidget);
  });

  testWidgets('passes the media id to novel details', (tester) async {
    final router = createAppRouter(initialLocation: '/novel/book-42');
    await tester.pumpWidget(MirascopeApp(router: router));
    await tester.pumpAndSettle();

    expect(find.text('小说详情'), findsOneWidget);
    expect(find.text('媒体 ID：book-42'), findsOneWidget);
  });

  testWidgets('shows a recoverable page for a blank media id', (tester) async {
    final router = createAppRouter(initialLocation: '/novel/%20');
    await tester.pumpWidget(MirascopeApp(router: router));
    await tester.pumpAndSettle();

    expect(find.text('无法打开该内容'), findsOneWidget);
    expect(find.text('返回媒体库'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run route tests**

Run:

```bash
flutter test test/src/app/router/app_router_test.dart
```

Expected: FAIL because the router and app widget do not exist.

- [ ] **Step 3: Define route constants**

Create `lib/src/app/router/app_routes.dart`:

```dart
abstract final class AppRoutes {
  static const library = '/library';
  static const settings = '/settings';
  static const novelDetails = '/novel/:mediaItemId';
  static const novelReader = '/novel/:mediaItemId/read';
}
```

- [ ] **Step 4: Implement the centralized router**

Create `lib/src/app/router/app_router.dart`.

Required signature:

```dart
GoRouter createAppRouter({String initialLocation = AppRoutes.library})
```

Required behavior:

- `/library` builds `LibraryPage(onOpenSettings: () => context.go(AppRoutes.settings))`;
- `/settings` builds `const SettingsPage()`;
- `/novel/:mediaItemId` validates `Uri.decodeComponent(mediaItemId).trim().isNotEmpty`;
- `/novel/:mediaItemId/read` performs the same validation;
- invalid IDs build a Scaffold containing `无法打开该内容` and a `返回媒体库` button that calls `context.go(AppRoutes.library)`;
- `errorBuilder` uses the same recoverable error page.

Implement a private `_RouteErrorPage` inside `app_router.dart`; do not create a global feature for one routing error.

- [ ] **Step 5: Implement `MirascopeApp`**

Create `lib/src/app/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mirascope/src/app/router/app_router.dart';
import 'package:mirascope/src/app/theme/app_theme.dart';

class MirascopeApp extends StatefulWidget {
  const MirascopeApp({this.router, super.key});

  final GoRouter? router;

  @override
  State<MirascopeApp> createState() => _MirascopeAppState();
}

class _MirascopeAppState extends State<MirascopeApp> {
  late final GoRouter _router;
  late final bool _ownsRouter;

  @override
  void initState() {
    super.initState();
    _ownsRouter = widget.router == null;
    _router = widget.router ?? createAppRouter();
  }

  @override
  void dispose() {
    if (_ownsRouter) {
      _router.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'mirascope',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}
```

- [ ] **Step 6: Replace the counter smoke test**

Replace `test/widget_test.dart` with:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/app/app.dart';

void main() {
  testWidgets('renders the mirascope library shell', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MirascopeApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('媒体库'), findsOneWidget);
    expect(find.text('Flutter Demo'), findsNothing);
    expect(find.byTooltip('Increment'), findsNothing);
  });
}
```

- [ ] **Step 7: Run route and shell tests**

Run:

```bash
flutter test test/src/app/router/app_router_test.dart test/widget_test.dart
```

Expected: all tests PASS.

- [ ] **Step 8: Commit**

```bash
git add lib/src/app/app.dart lib/src/app/router test/src/app/router/app_router_test.dart test/widget_test.dart
git commit -m "feat: add app routing and shell"
```

### Task 4: Add Bootstrap Success and Failure Paths

**Files:**

- Create: `lib/src/core/logging/app_logger.dart`
- Create: `lib/src/app/bootstrap/bootstrap.dart`
- Create: `lib/src/app/bootstrap/startup_error_app.dart`
- Modify: `lib/main.dart`
- Create: `test/src/app/bootstrap/bootstrap_test.dart`

**Interfaces:**

- Produces: `initializeAppLogging()`, `buildRootWidget({Future<void> Function()? initialize})`, `StartupErrorApp`.
- Consumes: `MirascopeApp`, `AppFailure`, `ProviderScope`.

- [ ] **Step 1: Write failing bootstrap tests**

Create `test/src/app/bootstrap/bootstrap_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirascope/src/app/app.dart';
import 'package:mirascope/src/app/bootstrap/bootstrap.dart';
import 'package:mirascope/src/app/bootstrap/startup_error_app.dart';

void main() {
  testWidgets('successful initialization builds the app', (tester) async {
    final root = await buildRootWidget(initialize: () async {});

    await tester.pumpWidget(root);
    await tester.pumpAndSettle();

    expect(find.byType(MirascopeApp), findsOneWidget);
  });

  testWidgets('failed initialization builds a safe startup error', (
    tester,
  ) async {
    final root = await buildRootWidget(
      initialize: () async => throw StateError('database path is private'),
    );

    await tester.pumpWidget(root);

    expect(find.byType(StartupErrorApp), findsOneWidget);
    expect(find.text('应用启动失败'), findsOneWidget);
    expect(find.text('startup_failed'), findsOneWidget);
    expect(find.textContaining('database path is private'), findsNothing);
  });
}
```

- [ ] **Step 2: Run bootstrap tests**

Run:

```bash
flutter test test/src/app/bootstrap/bootstrap_test.dart
```

Expected: FAIL because bootstrap types do not exist.

- [ ] **Step 3: Implement logging initialization**

Create `lib/src/core/logging/app_logger.dart`:

```dart
import 'package:logging/logging.dart';

final appLogger = Logger('mirascope');

void initializeAppLogging() {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = Level.INFO;
}
```

Do not print log records or add file export yet; that belongs to M01-004.

- [ ] **Step 4: Implement the startup error app**

Create `lib/src/app/bootstrap/startup_error_app.dart` as a MaterialApp with:

- title `mirascope`;
- a Scaffold body centered in a max-width 480 box;
- heading `应用启动失败`;
- safe explanation `初始化未完成，应用没有修改或删除本地数据。`;
- visible stable code `startup_failed`;
- no raw exception text.

- [ ] **Step 5: Implement bootstrap**

Create `lib/src/app/bootstrap/bootstrap.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mirascope/src/app/app.dart';
import 'package:mirascope/src/app/bootstrap/startup_error_app.dart';
import 'package:mirascope/src/core/logging/app_logger.dart';

typedef AppInitializer = Future<void> Function();

Future<Widget> buildRootWidget({AppInitializer? initialize}) async {
  initializeAppLogging();

  try {
    await (initialize ?? _initializeFoundation)();
    return const ProviderScope(child: MirascopeApp());
  } on Object catch (error, stackTrace) {
    appLogger.severe('startup_failed', error, stackTrace);
    return const StartupErrorApp(code: 'startup_failed');
  }
}

Future<void> _initializeFoundation() async {}
```

The empty default initializer is intentional: opening Drift belongs to M01-005. This seam exists so M01-005 can add database initialization without changing `main.dart`.

- [ ] **Step 6: Replace `main.dart`**

Use:

```dart
import 'package:flutter/material.dart';
import 'package:mirascope/src/app/bootstrap/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(await buildRootWidget());
}
```

- [ ] **Step 7: Run bootstrap and full tests**

Run:

```bash
flutter test test/src/app/bootstrap/bootstrap_test.dart
flutter test
```

Expected: all tests PASS and no counter test remains.

- [ ] **Step 8: Commit**

```bash
git add lib/main.dart lib/src/app/bootstrap lib/src/core/logging test/src/app/bootstrap
git commit -m "feat: add safe app bootstrap"
```

### Task 5: Verify the Windows Foundation and Update Task Status

**Files:**

- Modify: `docs/mvp-task-list.md`

**Interfaces:**

- Consumes: Tasks 1-4 and the MVP quality strategy.
- Produces: verified M01-001/M01-002/M01-003 status and final evidence.

- [ ] **Step 1: Generate and format**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
dart format .
```

Expected: generation exits 0 and formatting changes are applied.

- [ ] **Step 2: Run static analysis**

Run:

```bash
flutter analyze
```

Expected: no issues.

- [ ] **Step 3: Run the complete test suite**

Run:

```bash
flutter test
```

Expected: all tests PASS with 0 failures.

- [ ] **Step 4: Build Windows**

Run:

```bash
flutter build windows
```

Expected: exit 0 and a Windows release executable is produced.

- [ ] **Step 5: Verify generated files and scope**

Run:

```bash
git status --short
rg -n "MyApp|MyHomePage|Counter increments|Flutter Demo" lib test
rg --files lib/src
```

Expected:

- generated Riverpod output is tracked;
- no counter-template identifiers remain;
- no `manga`, `auth`, `sync`, `server`, or Rust source directories were added;
- only expected formatting, generated, and task-status changes are present.

- [ ] **Step 6: Update task status**

In `docs/mvp-task-list.md`:

- set M01-001 to `done`;
- set M01-002 to `done`;
- set M01-003 to `done`;
- add one evidence line under each task containing the relevant commit(s) and the fresh verification commands.

Do not mark M01-004 or M01-005 done.

- [ ] **Step 7: Validate documentation diff**

Run:

```bash
git diff --check
```

Expected: exit 0.

- [ ] **Step 8: Commit**

```bash
git add docs/mvp-task-list.md
git commit -m "docs: record app foundation completion"
```

- [ ] **Step 9: Verify clean final state**

Run:

```bash
git status --short
git log -5 --oneline
```

Expected: clean working tree and five focused implementation commits after the design checkpoint.
