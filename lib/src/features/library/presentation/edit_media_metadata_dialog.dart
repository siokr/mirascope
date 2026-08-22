import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../application/library_providers.dart';
import '../domain/media_item.dart';

Future<bool> showEditMediaMetadataDialog(
  BuildContext context, {
  required MediaItem mediaItem,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => _EditMediaMetadataDialog(mediaItem: mediaItem),
      ) ??
      false;
}

class _EditMediaMetadataDialog extends ConsumerStatefulWidget {
  const _EditMediaMetadataDialog({required this.mediaItem});

  final MediaItem mediaItem;

  @override
  ConsumerState<_EditMediaMetadataDialog> createState() =>
      _EditMediaMetadataDialogState();
}

class _EditMediaMetadataDialogState
    extends ConsumerState<_EditMediaMetadataDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _creatorController;
  late final TextEditingController _descriptionController;
  var _saving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final item = widget.mediaItem;
    _titleController = TextEditingController(text: item.title);
    _subtitleController = TextEditingController(text: item.subtitle);
    _creatorController = TextEditingController(text: item.creator);
    _descriptionController = TextEditingController(text: item.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _creatorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑作品信息'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: const Key('metadata-title-field'),
                  controller: _titleController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: '书名'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? '请输入书名' : null,
                ),
                TextFormField(
                  key: const Key('metadata-subtitle-field'),
                  controller: _subtitleController,
                  decoration: const InputDecoration(labelText: '副标题'),
                ),
                TextFormField(
                  key: const Key('metadata-creator-field'),
                  controller: _creatorController,
                  decoration: const InputDecoration(labelText: '作者'),
                ),
                TextFormField(
                  key: const Key('metadata-description-field'),
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: '简介'),
                  minLines: 3,
                  maxLines: 6,
                ),
                if (_saveError != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _saveError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? '正在保存' : '保存'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await ref
          .read(mediaLibraryRepositoryProvider)
          .updateMetadata(
            mediaItemId: widget.mediaItem.id,
            title: _titleController.text,
            subtitle: _subtitleController.text,
            creator: _creatorController.text,
            description: _descriptionController.text,
            updatedAt: ref.read(libraryClockProvider)(),
          );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError = '保存失败，请重试';
      });
    }
  }
}
