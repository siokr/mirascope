import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../domain/library_item.dart';

typedef LibraryClock = DateTime Function();

final libraryClockProvider = Provider<LibraryClock>((ref) {
  return () => DateTime.now().toUtc();
});

final activeLibraryProvider = StreamProvider<List<LibraryItem>>((ref) {
  return ref.watch(mediaLibraryRepositoryProvider).watchActiveLibrary();
});

final archivedLibraryProvider = StreamProvider<List<LibraryItem>>((ref) {
  return ref.watch(mediaLibraryRepositoryProvider).watchArchivedLibrary();
});
