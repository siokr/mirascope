import 'package:flutter/material.dart';

import '../../domain/library_item.dart';

enum LibraryCardAction { archive, restore, delete }

class LibraryCard extends StatelessWidget {
  const LibraryCard({
    required this.item,
    required this.archived,
    required this.busy,
    required this.onOpen,
    required this.onArchive,
    required this.onRestore,
    required this.onDelete,
    super.key,
  });

  final LibraryItem item;
  final bool archived;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onArchive;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final media = item.mediaItem;
    final metadata = media.creator ?? media.subtitle ?? 'TXT 小说';

    return Semantics(
      button: !busy && !archived,
      label: archived ? '《${media.title}》，已归档' : '打开《${media.title}》',
      child: Card(
        key: Key('library-card-${media.id}'),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: InkWell(
          onTap: busy || archived ? null : onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 2 / 3,
                child: ColoredBox(
                  key: ValueKey('library-cover-${media.id}'),
                  color: _placeholderColor(context, media.id),
                  child: Center(
                    child: Text(
                      _firstCharacter(media.title),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              media.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              metadata,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              _lastOpenedLabel(item.libraryEntry.lastOpenedAt),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<LibraryCardAction>(
                        key: Key('library-menu-${media.id}'),
                        enabled: !busy,
                        tooltip: '更多操作',
                        onSelected: (action) {
                          switch (action) {
                            case LibraryCardAction.archive:
                              onArchive();
                            case LibraryCardAction.restore:
                              onRestore();
                            case LibraryCardAction.delete:
                              onDelete();
                          }
                        },
                        itemBuilder: (context) => [
                          if (archived) ...const [
                            PopupMenuItem(
                              value: LibraryCardAction.restore,
                              child: Text('恢复到媒体库'),
                            ),
                            PopupMenuItem(
                              value: LibraryCardAction.delete,
                              child: Text('永久删除'),
                            ),
                          ] else ...const [
                            PopupMenuItem(
                              value: LibraryCardAction.archive,
                              child: Text('移入归档'),
                            ),
                          ],
                        ],
                        icon: busy
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _placeholderColor(BuildContext context, String mediaId) {
  const seeds = [
    Color(0xFF526A78),
    Color(0xFF6D5D72),
    Color(0xFF4F6B5B),
    Color(0xFF755E50),
    Color(0xFF5C647A),
    Color(0xFF6E6650),
  ];
  var value = 2166136261;
  for (final codeUnit in mediaId.codeUnits) {
    value = ((value ^ codeUnit) * 16777619) & 0x7fffffff;
  }
  final seed = seeds[value % seeds.length];
  return ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Theme.of(context).brightness,
  ).primaryContainer;
}

String _firstCharacter(String title) {
  final trimmed = title.trim();
  if (trimmed.isEmpty) {
    return '书';
  }
  return String.fromCharCode(trimmed.runes.first);
}

String _lastOpenedLabel(DateTime? value) {
  if (value == null) {
    return '尚未阅读';
  }
  final utc = value.toUtc();
  final month = utc.month.toString().padLeft(2, '0');
  final day = utc.day.toString().padLeft(2, '0');
  return '最近阅读 ${utc.year}/$month/$day';
}
