import 'package:flutter/material.dart';

import '../../domain/library_item.dart';
import 'library_card.dart';

class LibraryGrid extends StatelessWidget {
  const LibraryGrid({
    required this.items,
    required this.archived,
    required this.busyMediaIds,
    required this.onOpen,
    required this.onArchive,
    required this.onRestore,
    super.key,
  });

  final List<LibraryItem> items;
  final bool archived;
  final Set<String> busyMediaIds;
  final ValueChanged<LibraryItem> onOpen;
  final ValueChanged<LibraryItem> onArchive;
  final ValueChanged<LibraryItem> onRestore;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1560),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = libraryGridColumnCount(constraints.maxWidth);
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 20,
                mainAxisSpacing: 24,
                childAspectRatio: 0.5,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final mediaId = item.mediaItem.id;
                return LibraryCard(
                  item: item,
                  archived: archived,
                  busy: busyMediaIds.contains(mediaId),
                  onOpen: () => onOpen(item),
                  onArchive: () => onArchive(item),
                  onRestore: () => onRestore(item),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

int libraryGridColumnCount(double width) {
  if (width < 700) {
    return 2;
  }
  if (width < 1000) {
    return 3;
  }
  if (width < 1280) {
    return 4;
  }
  if (width < 1500) {
    return 5;
  }
  return 6;
}
