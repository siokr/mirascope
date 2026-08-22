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
    required this.onDelete,
    this.onOrganize,
    this.onSetFavorite,
    super.key,
  });

  final List<LibraryItem> items;
  final bool archived;
  final Set<String> busyMediaIds;
  final ValueChanged<LibraryItem> onOpen;
  final ValueChanged<LibraryItem> onArchive;
  final ValueChanged<LibraryItem> onRestore;
  final ValueChanged<LibraryItem> onDelete;
  final ValueChanged<LibraryItem>? onOrganize;
  final void Function(LibraryItem, bool)? onSetFavorite;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1560),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = libraryGridColumnCount(constraints.maxWidth);
            final childAspectRatio = libraryGridChildAspectRatio(
              constraints.maxWidth,
            );
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 20,
                mainAxisSpacing: 24,
                childAspectRatio: childAspectRatio,
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
                  onDelete: () => onDelete(item),
                  onOrganize: onOrganize == null
                      ? null
                      : () => onOrganize!(item),
                  onSetFavorite: onSetFavorite == null
                      ? null
                      : (favorite) => onSetFavorite!(item, favorite),
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
  if (width < 520) {
    return 2;
  }
  if (width < 760) {
    return 3;
  }
  if (width < 1000) {
    return 4;
  }
  if (width < 1240) {
    return 5;
  }
  return 6;
}

double libraryGridChildAspectRatio(double width) => width < 760 ? 0.46 : 0.5;
