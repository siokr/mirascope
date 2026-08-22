import 'package:flutter/material.dart';

import '../domain/media_item.dart';

class MediaMetadataSummary extends StatelessWidget {
  const MediaMetadataSummary({required this.mediaItem, super.key});

  final MediaItem mediaItem;

  @override
  Widget build(BuildContext context) {
    final subtitle = mediaItem.subtitle;
    final creator = mediaItem.creator;
    final description = mediaItem.description;
    if (subtitle == null && creator == null && description == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null)
            Text(subtitle, style: Theme.of(context).textTheme.titleMedium),
          if (creator != null) ...[
            const SizedBox(height: 4),
            Text('作者：$creator'),
          ],
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(description),
          ],
        ],
      ),
    );
  }
}
