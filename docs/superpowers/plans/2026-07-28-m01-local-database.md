# M01-005 Local Database Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build schema v1, domain-safe repositories, atomic writes, migrations, and startup injection for the mirascope local database.

**Architecture:** Drift owns SQLite schema, constraints, transactions, and migrations under `core/database`. Feature-owned domain models and repository interfaces do not import Drift; feature data implementations map between those models and generated rows. Production opens `mirascope.sqlite` in the application-support directory, while tests inject an in-memory database.

**Tech Stack:** Flutter 3.44.8, Dart 3.12.2, Riverpod 3.4.1, Drift 2.34.x, drift_flutter 0.3.1, drift_dev 2.34.x, build_runner 2.15.x, UUID package selected by `flutter pub add uuid`, flutter_test.

## Global Constraints

- schema v1 contains exactly `MediaItem`, `LibraryEntry`, `ContentUnit`, `ReadingProgress`, `ReaderPreference`, and `ImportRecord`; no bookmark table.
- Domain identifiers are application-generated UUID strings.
- Persist enums as stable English strings, never enum ordinals.
- Persist times as UTC milliseconds and expose `DateTime` in domain models.
- Archive a library entry by setting `archivedAt`; do not delete it.
- Permanent application-data deletion cascades from `MediaItem` but never modifies the user's source file.
- Drift-generated types must not appear in Widget APIs or domain repository interfaces.
- A database open or migration failure must not delete, replace, or silently recreate the database.
- UI and ordinary logs must not expose raw exceptions, source text, or complete private paths.
- Use TDD for each behavior and commit after every independently verified task.

---

### Task 1: Add Domain Models, Stable Enums, and UUID Generation

**Files:**

- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`
- Create: `lib/src/core/ids/id_generator.dart`
- Create: `lib/src/features/library/domain/media_item.dart`
- Create: `lib/src/features/library/domain/library_entry.dart`
- Create: `lib/src/features/novel/domain/content_unit.dart`
- Create: `lib/src/features/novel/domain/reading_progress.dart`
- Create: `lib/src/features/settings/domain/reader_preference.dart`
- Create: `lib/src/features/importing/domain/import_record.dart`
- Create: `test/src/core/ids/id_generator_test.dart`
- Create: `test/src/features/domain/domain_model_test.dart`

**Interfaces:**

- Produces: `IdGenerator.newId()`, `UuidIdGenerator`, six immutable domain models, and stable enum `storageValue` codecs.
- Consumes: no database code.

- [ ] **Step 1: Add the UUID dependency**

Run:

```powershell
flutter pub add uuid
```

Expected: dependency resolution exits 0 and `uuid` appears under `dependencies`.

- [ ] **Step 2: Write failing UUID and enum-codec tests**

Create tests with these assertions:

```dart
test('UuidIdGenerator creates distinct UUID values', () {
  final generator = UuidIdGenerator();
  final first = generator.newId();
  final second = generator.newId();

  expect(first, isNot(second));
  expect(
    RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    ).hasMatch(first),
    isTrue,
  );
});

test('domain enums use stable storage values', () {
  expect(MediaType.novel.storageValue, 'novel');
  expect(ContentUnitType.chapter.storageValue, 'chapter');
  expect(ImportStatus.completed.storageValue, 'completed');
  expect(PreferenceScope.mediaItem.storageValue, 'mediaItem');
  expect(ReadingMode.vertical.storageValue, 'vertical');
});
```

- [ ] **Step 3: Run tests and observe the missing-type failure**

Run:

```powershell
flutter test --no-pub test/src/core/ids/id_generator_test.dart test/src/features/domain/domain_model_test.dart
```

Expected: FAIL because the ID generator and domain models do not exist.

- [ ] **Step 4: Implement the ID boundary and immutable domain models**

Use this ID interface:

```dart
abstract interface class IdGenerator {
  String newId();
}

final class UuidIdGenerator implements IdGenerator {
  const UuidIdGenerator();

  @override
  String newId() => const Uuid().v4();
}
```

Create enums with explicit `storageValue` constructor arguments and `fromStorageValue` methods that throw `ArgumentError.value` for unknown data:

```dart
enum MediaType { novel('novel'), manga('manga') }
enum ContentUnitType { chapter('chapter') }
enum PreferenceScope { global('global'), mediaItem('mediaItem') }
enum ReadingMode { vertical('vertical') }
enum ImportSourceKind {
  txtFile('txtFile'),
  epubFile('epubFile'),
  mangaDirectory('mangaDirectory'),
  mangaArchive('mangaArchive'),
}
enum ImportStatus {
  pending('pending'),
  completed('completed'),
  failed('failed'),
  missing('missing'),
}
```

Implement immutable classes with these exact fields:

```text
MediaItem: id, mediaType, title, subtitle?, creator?, description?, coverRef?, createdAt, updatedAt
LibraryEntry: id, mediaItemId, favorite, addedAt, lastOpenedAt?, archivedAt?
ContentUnit: id, mediaItemId, unitType, title, orderIndex, contentRef, sourceLocator, contentHash
ReadingProgress: id, mediaItemId, contentUnitId, locator, fraction, updatedAt, revision
ReaderPreference: id, scope, mediaItemId?, fontSize?, lineHeight?, themeKey?, readingMode?, updatedAt
ImportRecord: id, mediaItemId, sourcePath, sourceKind, fileSize, modifiedAt?, fingerprint, status, errorCode?, createdAt
```

Constructors must be `const` where Dart permits. Do not add JSON serialization in this task.

- [ ] **Step 5: Run focused tests and static analysis**

Run:

```powershell
dart format lib/src/core/ids lib/src/features test/src/core/ids test/src/features/domain
flutter test --no-pub test/src/core/ids/id_generator_test.dart test/src/features/domain/domain_model_test.dart
flutter analyze --no-pub
```

Expected: focused tests PASS and analysis reports no issues.

- [ ] **Step 6: Commit**

```powershell
git add pubspec.yaml pubspec.lock lib/src/core/ids lib/src/features test/src/core/ids test/src/features/domain
git commit -m "新增数据库领域模型"
```

---

### Task 2: Define schema v1 and Its Database Constraints

**Files:**

- Create: `lib/src/core/database/converters/date_time_millis_converter.dart`
- Create: `lib/src/core/database/tables/media_items.dart`
- Create: `lib/src/core/database/tables/library_entries.dart`
- Create: `lib/src/core/database/tables/content_units.dart`
- Create: `lib/src/core/database/tables/reading_progress_entries.dart`
- Create: `lib/src/core/database/tables/reader_preferences.dart`
- Create: `lib/src/core/database/tables/import_records.dart`
- Create: `lib/src/core/database/app_database.dart`
- Generate: `lib/src/core/database/app_database.g.dart`
- Create: `test/src/core/database/database_test_support.dart`
- Create: `test/src/core/database/app_database_test.dart`

**Interfaces:**

- Produces: `AppDatabase(QueryExecutor executor)`, `AppDatabase.inMemory()`, schema version 1, six generated table/data classes.
- Consumes: stable storage values from Task 1.

- [ ] **Step 1: Write failing structure and constraint tests**

Use a fresh in-memory database per test:

```dart
AppDatabase createTestDatabase() {
  return AppDatabase(NativeDatabase.memory());
}
```

Test all of these behaviors:

```text
schemaVersion equals 1
foreign_keys pragma equals 1
duplicate library_entries.media_item_id is rejected
duplicate (content_units.media_item_id, order_index) is rejected
negative content unit order is rejected
reading fraction below 0 or above 1 is rejected
negative reading revision is rejected
global preference with a media ID is rejected
mediaItem preference without a media ID is rejected
two global preferences are rejected
two preferences for one media item are rejected
negative import file size is rejected
unsupported enum strings are rejected
```

Insert parent rows before dependent rows and close the database with `addTearDown(database.close)`.

- [ ] **Step 2: Run the structure test and observe failure**

Run:

```powershell
flutter test --no-pub test/src/core/database/app_database_test.dart
```

Expected: FAIL because `AppDatabase` and table declarations do not exist.

- [ ] **Step 3: Implement UTC millisecond conversion**

Use one Drift converter:

```dart
class DateTimeMillisConverter extends TypeConverter<DateTime, int> {
  const DateTimeMillisConverter();

  @override
  DateTime fromSql(int fromDb) =>
      DateTime.fromMillisecondsSinceEpoch(fromDb, isUtc: true);

  @override
  int toSql(DateTime value) => value.toUtc().millisecondsSinceEpoch;
}
```

Apply it to every timestamp column. Nullable timestamp columns use the nullable converter form supported by generated Drift columns.

- [ ] **Step 4: Implement the six table declarations**

Use these exact database names and keys:

```text
media_items: text id primary key
library_entries: text id primary key; unique media_item_id
content_units: text id primary key; unique media_item_id + order_index
reading_progress: text id primary key; unique media_item_id
reader_preferences: text id primary key
import_records: text id primary key
```

Declare explicit `references(..., onDelete: KeyAction.cascade)` for every `media_item_id` and for `reading_progress.content_unit_id`. Add these SQL checks through Drift `customConstraints`:

```sql
media_type IN ('novel', 'manga')
unit_type IN ('chapter')
order_index >= 0
fraction >= 0 AND fraction <= 1
revision >= 0
scope IN ('global', 'mediaItem')
((scope = 'global' AND media_item_id IS NULL) OR
 (scope = 'mediaItem' AND media_item_id IS NOT NULL))
source_kind IN ('txtFile', 'epubFile', 'mangaDirectory', 'mangaArchive')
status IN ('pending', 'completed', 'failed', 'missing')
file_size >= 0
```

Because the Dart table class is named `ReadingProgressEntries`, override its table name explicitly:

```dart
@override
String get tableName => 'reading_progress';
```

Create named indexes in `AppDatabase` migration setup:

```sql
CREATE INDEX media_items_type_updated_idx
  ON media_items(media_type, updated_at);
CREATE UNIQUE INDEX reader_preferences_global_idx
  ON reader_preferences(scope) WHERE scope = 'global';
CREATE UNIQUE INDEX reader_preferences_media_idx
  ON reader_preferences(media_item_id) WHERE scope = 'mediaItem';
CREATE INDEX import_records_fingerprint_idx
  ON import_records(fingerprint);
```

- [ ] **Step 5: Implement `AppDatabase`**

Use:

```dart
@DriftDatabase(
  tables: [
    MediaItems,
    LibraryEntries,
    ContentUnits,
    ReadingProgressEntries,
    ReaderPreferences,
    ImportRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.inMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createV1Indexes();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
```

`_createV1Indexes` executes the four exact index statements from Step 4.

- [ ] **Step 6: Generate Drift code**

Run:

```powershell
dart run build_runner build
```

Expected: exit 0 and `app_database.g.dart` is generated.

- [ ] **Step 7: Run structure tests**

Run:

```powershell
flutter test --no-pub test/src/core/database/app_database_test.dart
flutter analyze --no-pub
```

Expected: all constraint tests PASS and analysis reports no issues.

- [ ] **Step 8: Commit**

```powershell
git add lib/src/core/database test/src/core/database
git commit -m "建立本地数据库结构"
```

---

### Task 3: Implement the Media Library Repository

**Files:**

- Create: `lib/src/features/library/domain/library_item.dart`
- Create: `lib/src/features/library/domain/media_library_repository.dart`
- Create: `lib/src/features/library/data/drift_media_library_repository.dart`
- Create: `test/src/features/library/data/drift_media_library_repository_test.dart`

**Interfaces:**

- Produces: `MediaLibraryRepository`, `DriftMediaLibraryRepository`.
- Consumes: `AppDatabase`, `MediaItem`, `LibraryEntry`.

- [ ] **Step 1: Define the domain interface in a failing repository test**

Use this exact interface:

```dart
abstract interface class MediaLibraryRepository {
  Stream<List<LibraryItem>> watchActiveLibrary();
  Future<MediaItem?> findMediaItem(String mediaItemId);
  Future<void> archive(String mediaItemId, DateTime archivedAt);
  Future<void> restore(String mediaItemId);
  Future<void> deleteApplicationData(String mediaItemId);
}
```

`LibraryItem` contains a `MediaItem mediaItem` and `LibraryEntry libraryEntry`.

Test:

```text
active stream excludes archived entries
archive removes an item from the active stream
restore returns the same library entry ID
results order by lastOpenedAt descending, then addedAt descending
deleting a media item removes database dependents
```

- [ ] **Step 2: Run the repository test and observe failure**

Run:

```powershell
flutter test --no-pub test/src/features/library/data/drift_media_library_repository_test.dart
```

Expected: FAIL because repository types do not exist.

- [ ] **Step 3: Implement Drift mapping and queries**

Join `libraryEntries` to `mediaItems`, filter `archivedAt.isNull()`, and map every generated row into domain types. Archive and restore update the existing row selected by `mediaItemId`.

Permanent deletion must execute:

```dart
await database.transaction(() async {
  await (database.delete(database.mediaItems)
        ..where((row) => row.id.equals(mediaItemId)))
      .go();
});
```

Foreign keys perform dependent cleanup. The repository must not import `dart:io`.

- [ ] **Step 4: Run focused tests and analysis**

Run:

```powershell
dart format lib/src/features/library test/src/features/library
flutter test --no-pub test/src/features/library/data/drift_media_library_repository_test.dart
flutter analyze --no-pub
```

Expected: repository tests PASS and analysis reports no issues.

- [ ] **Step 5: Commit**

```powershell
git add lib/src/features/library test/src/features/library
git commit -m "新增媒体库数据仓库"
```

---

### Task 4: Implement Atomic Import Persistence

**Files:**

- Create: `lib/src/features/importing/domain/successful_import.dart`
- Create: `lib/src/features/importing/domain/import_repository.dart`
- Create: `lib/src/features/importing/data/drift_import_repository.dart`
- Create: `test/src/features/importing/data/drift_import_repository_test.dart`

**Interfaces:**

- Produces: `ImportRepository.commitSuccessfulImport`, `recordFailure`, `findCompletedByFingerprint`.
- Consumes: Task 1 models and Task 2 database.

- [ ] **Step 1: Write failing atomicity tests**

Use this interface:

```dart
abstract interface class ImportRepository {
  Future<ImportRecord?> findCompletedByFingerprint(String fingerprint);
  Future<void> commitSuccessfulImport(SuccessfulImport value);
  Future<void> recordFailure(ImportRecord record);
}
```

`SuccessfulImport` contains:

```dart
final MediaItem mediaItem;
final LibraryEntry libraryEntry;
final List<ContentUnit> contentUnits;
final ImportRecord importRecord;
```

Test:

```text
successful commit writes one media item, one library entry, all chapters, and one completed import record
completed fingerprint lookup returns the mapped record
the same fingerprint may exist at two source paths
duplicate chapter order causes the whole successful-import transaction to roll back
recordFailure accepts only status failed and requires a non-empty errorCode
```

- [ ] **Step 2: Run the import repository test and observe failure**

Run:

```powershell
flutter test --no-pub test/src/features/importing/data/drift_import_repository_test.dart
```

Expected: FAIL because the aggregate and repository do not exist.

- [ ] **Step 3: Implement the transaction**

Validate aggregate relationships before opening the transaction:

```text
libraryEntry.mediaItemId equals mediaItem.id
every contentUnit.mediaItemId equals mediaItem.id
importRecord.mediaItemId equals mediaItem.id
importRecord.status equals completed
contentUnits is not empty
```

Then use one `database.transaction` to insert the media row, library row, content rows, and import row. Do not catch and suppress Drift exceptions; rollback must be automatic and the application layer will map the failure.

`recordFailure` writes only an import record associated with an existing media item. It throws `ArgumentError` before database access when status or error code is invalid.

- [ ] **Step 4: Run focused tests and analysis**

Run:

```powershell
dart format lib/src/features/importing test/src/features/importing
flutter test --no-pub test/src/features/importing/data/drift_import_repository_test.dart
flutter analyze --no-pub
```

Expected: transaction and validation tests PASS.

- [ ] **Step 5: Commit**

```powershell
git add lib/src/features/importing test/src/features/importing
git commit -m "新增原子导入数据事务"
```

---

### Task 5: Implement Progress and Preference Repositories

**Files:**

- Create: `lib/src/features/novel/domain/progress_write_result.dart`
- Create: `lib/src/features/novel/domain/reading_progress_repository.dart`
- Create: `lib/src/features/novel/data/drift_reading_progress_repository.dart`
- Create: `lib/src/features/settings/domain/effective_reader_preference.dart`
- Create: `lib/src/features/settings/domain/reader_preference_defaults.dart`
- Create: `lib/src/features/settings/domain/reader_preference_repository.dart`
- Create: `lib/src/features/settings/data/drift_reader_preference_repository.dart`
- Create: `test/src/features/novel/data/drift_reading_progress_repository_test.dart`
- Create: `test/src/features/settings/data/drift_reader_preference_repository_test.dart`

**Interfaces:**

- Produces: optimistic progress writes and resolved reader preferences.
- Consumes: database and Task 1 domain models.

- [ ] **Step 1: Write failing progress tests**

Use:

```dart
enum ProgressWriteResult { inserted, updated, revisionConflict }

abstract interface class ReadingProgressRepository {
  Future<ReadingProgress?> findForMedia(String mediaItemId);
  Future<ProgressWriteResult> save(ReadingProgress progress);
}
```

Test first insert, update from revision 0 to 1, rejection of another revision 0 write, and persistence of the revision 1 locator.

- [ ] **Step 2: Run progress tests and observe failure**

Run:

```powershell
flutter test --no-pub test/src/features/novel/data/drift_reading_progress_repository_test.dart
```

Expected: FAIL because the progress repository does not exist.

- [ ] **Step 3: Implement compare-and-set progress writes**

For an existing row, update only when:

```dart
row.mediaItemId.equals(progress.mediaItemId) &
row.revision.equals(progress.revision - 1)
```

Return `revisionConflict` when the affected-row count is zero. Validate fraction and non-negative revision at the domain boundary as well as in SQLite.

- [ ] **Step 4: Write failing preference-resolution tests**

Use:

```dart
abstract interface class ReaderPreferenceRepository {
  Future<ReaderPreference?> findGlobal();
  Future<ReaderPreference?> findForMedia(String mediaItemId);
  Future<EffectiveReaderPreference> resolveForMedia(String mediaItemId);
  Future<void> save(ReaderPreference preference);
}
```

Program defaults are:

```dart
const ReaderPreferenceDefaults(
  fontSize: 18,
  lineHeight: 1.6,
  themeKey: 'system',
  readingMode: ReadingMode.vertical,
);
```

Test program defaults, global overrides, partial media overrides, and rejection of `fontSize <= 0` or `lineHeight <= 0`.

- [ ] **Step 5: Run preference tests and observe failure**

Run:

```powershell
flutter test --no-pub test/src/features/settings/data/drift_reader_preference_repository_test.dart
```

Expected: FAIL because preference repository types do not exist.

- [ ] **Step 6: Implement preference upsert and fallback**

Resolve each field in this order:

```text
media preference non-null value
global preference non-null value
ReaderPreferenceDefaults value
```

Upsert global preference by the partial global index and media preference by `mediaItemId`. Reject inconsistent scope/media ID combinations before database access.

- [ ] **Step 7: Run focused tests and analysis**

Run:

```powershell
dart format lib/src/features/novel lib/src/features/settings test/src/features/novel test/src/features/settings
flutter test --no-pub test/src/features/novel/data/drift_reading_progress_repository_test.dart test/src/features/settings/data/drift_reader_preference_repository_test.dart
flutter analyze --no-pub
```

Expected: all progress and preference tests PASS.

- [ ] **Step 8: Commit**

```powershell
git add lib/src/features/novel lib/src/features/settings test/src/features/novel test/src/features/settings
git commit -m "新增进度与阅读设置仓库"
```

---

### Task 6: Open and Inject the Production Database Safely

**Files:**

- Create: `lib/src/core/database/database_connection.dart`
- Create: `lib/src/core/database/database_providers.dart`
- Modify: `lib/src/app/bootstrap/bootstrap.dart`
- Modify: `lib/src/app/bootstrap/startup_error_app.dart`
- Modify: `test/src/app/bootstrap/bootstrap_test.dart`
- Create: `test/src/core/database/database_providers_test.dart`

**Interfaces:**

- Produces: `openAppDatabase()`, `appDatabaseProvider`, repository providers, `AppDependencies`.
- Consumes: `driftDatabase`, `getApplicationSupportDirectory`, all repository implementations.

- [ ] **Step 1: Write failing connection and bootstrap tests**

Test:

```text
database provider returns the injected in-memory instance
unmounting ProviderScope closes the injected database
successful buildRootWidget contains MirascopeApp and an AppDatabase override
database factory failure shows StartupErrorApp with database_open_failed
raw exception text and private path are absent from UI and captured LogRecord
```

Use a thrown value containing `C:\Users\private\mirascope.sqlite` to prove redaction.

- [ ] **Step 2: Run tests and observe failure**

Run:

```powershell
flutter test --no-pub test/src/core/database/database_providers_test.dart test/src/app/bootstrap/bootstrap_test.dart
```

Expected: FAIL because providers and database dependencies are not wired.

- [ ] **Step 3: Implement the production connection**

Use:

```dart
AppDatabase openAppDatabase() {
  return AppDatabase(
    driftDatabase(
      name: 'mirascope',
      native: DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    ),
  );
}
```

Force the first connection during bootstrap with a harmless `SELECT 1` so open and migration failures occur before the main app is shown.

- [ ] **Step 4: Implement Riverpod ownership**

Declare:

```dart
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw StateError('AppDatabase has not been initialized');
});
```

Create repository providers that read `appDatabaseProvider` and construct the four Drift implementations.

Define:

```dart
final class AppDependencies {
  const AppDependencies({required this.database});
  final AppDatabase database;
}

typedef AppInitializer = Future<AppDependencies> Function();
```

`buildRootWidget` returns a `ProviderScope` overriding `appDatabaseProvider` with a closure that registers `ref.onDispose(database.close)`.

- [ ] **Step 5: Map startup errors safely**

On database initialization failure:

```dart
appLogger.severe('database_open_failed');
return const StartupErrorApp(code: 'database_open_failed');
```

Do not pass the caught error or stack trace to `LogRecord`. Close a partially created database in the initializer before rethrowing.

- [ ] **Step 6: Run focused and full tests**

Run:

```powershell
dart format lib/src/core/database lib/src/app/bootstrap test/src/core/database test/src/app/bootstrap
flutter test --no-pub test/src/core/database/database_providers_test.dart test/src/app/bootstrap/bootstrap_test.dart
flutter test --no-pub
flutter analyze --no-pub
```

Expected: focused tests and complete suite PASS; analysis reports no issues.

- [ ] **Step 7: Commit**

```powershell
git add lib/src/core/database lib/src/app/bootstrap test/src/core/database test/src/app/bootstrap
git commit -m "接入本地数据库启动流程"
```

---

### Task 7: Export schema v1 and Verify Migration Safety

**Files:**

- Create: `drift_schemas/drift_schema_v1.json`
- Generate: `test/generated_migrations/schema.dart`
- Create: `test/src/core/database/migration_test.dart`

**Interfaces:**

- Produces: immutable v1 schema snapshot and repeatable migration verification.
- Consumes: `AppDatabase` schema version 1.

- [ ] **Step 1: Export schema v1**

Run:

```powershell
dart run drift_dev schema dump lib/src/core/database/app_database.dart drift_schemas
dart run drift_dev schema steps drift_schemas test/generated_migrations/schema.dart
```

Expected: `drift_schema_v1.json` and generated migration helpers are created.

- [ ] **Step 2: Write migration tests**

Use `SchemaVerifier` from `package:drift_dev/api/migrations_native.dart`.

Verify:

```text
the generated v1 schema opens successfully
AppDatabase constructed from the v1 connection validates against current schema
foreign keys and all named indexes exist
```

Add a test-only transaction:

```dart
await expectLater(
  database.transaction(() async {
    await database.customStatement(
      "INSERT INTO media_items (...) VALUES (...)",
    );
    throw StateError('forced_migration_failure');
  }),
  throwsStateError,
);
```

After failure, assert that the inserted ID is absent and a row created before the transaction remains readable. This proves SQLite rollback behavior without inventing a released production v0 schema.

- [ ] **Step 3: Run migration tests**

Run:

```powershell
flutter test --no-pub test/src/core/database/migration_test.dart
```

Expected: schema validation and rollback tests PASS.

- [ ] **Step 4: Prove snapshot reproducibility**

Run the dump command again:

```powershell
git add --intent-to-add drift_schemas/drift_schema_v1.json
dart run drift_dev schema dump lib/src/core/database/app_database.dart drift_schemas
git diff --exit-code -- drift_schemas/drift_schema_v1.json
```

Expected: no diff after regenerating the v1 snapshot.

- [ ] **Step 5: Commit**

```powershell
git add drift_schemas test/generated_migrations test/src/core/database/migration_test.dart
git commit -m "新增数据库迁移验证"
```

---

### Task 8: Final Verification and Task Status

**Files:**

- Modify: `docs/mvp-task-list.md`

**Interfaces:**

- Produces: verified M01-005 status with evidence.
- Consumes: all previous tasks.

- [ ] **Step 1: Regenerate and format**

Run:

```powershell
dart run build_runner build
dart format .
```

Expected: generation exits 0 and formatting produces no unreviewed changes.

- [ ] **Step 2: Run all database and project checks**

Run:

```powershell
flutter analyze --no-pub
flutter test --no-pub
dart run drift_dev schema dump lib/src/core/database/app_database.dart drift_schemas
git diff --exit-code -- drift_schemas/drift_schema_v1.json
```

Expected: analysis has no issues, all tests pass, and the schema snapshot is current.

- [ ] **Step 3: Audit boundaries and sensitive logging**

Run:

```powershell
rg -n "package:drift" lib/src/features/*/domain lib/src/features/*/presentation
rg -n "appLogger\\.(severe|warning|info).*error|stackTrace|sourcePath" lib
rg --files lib/src/core/database lib/src/features
git diff --check
```

Expected:

- no Drift import in domain or presentation files;
- no raw database exception, stack trace, or source path passed to ordinary logs;
- only the approved six schema entities exist;
- documentation and code diffs contain no whitespace errors.

- [ ] **Step 4: Update task status**

Set M01-005 to `done` only when:

```text
empty database initialization passes
v1 schema snapshot validation passes
forced transaction failure rollback passes
all Repository tests pass
full flutter test passes
flutter analyze passes
```

Add evidence with the implementation commit hashes and exact verification commands. Do not mark M01-004, M01-006, or later tasks done.

If Windows Release still fails only because of the already recorded external MSVC HostX86 selection problem, keep that blocker attached to M01-002/M01-003 and report it separately from M01-005.

- [ ] **Step 5: Commit documentation**

```powershell
git add docs/mvp-task-list.md
git commit -m "记录数据库阶段完成情况"
```

- [ ] **Step 6: Verify final repository state**

Run:

```powershell
git status --short
git log -8 --oneline
```

Expected: clean worktree and focused commits matching Tasks 1 through 8.
