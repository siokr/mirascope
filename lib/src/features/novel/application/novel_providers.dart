import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../domain/novel_details.dart';

final novelDetailsProvider = FutureProvider.autoDispose
    .family<NovelDetails?, String>((ref, mediaItemId) {
      return ref.watch(novelDetailsRepositoryProvider).findDetails(mediaItemId);
    });
