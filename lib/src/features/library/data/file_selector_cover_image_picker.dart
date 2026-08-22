import 'package:file_selector/file_selector.dart';

import '../domain/cover_image_picker.dart';

final class FileSelectorCoverImagePicker implements CoverImagePicker {
  const FileSelectorCoverImagePicker();

  static const _imageTypes = XTypeGroup(
    label: '封面图片',
    extensions: ['jpg', 'jpeg', 'png', 'webp'],
  );

  @override
  Future<String?> pickImage() async {
    final file = await openFile(
      acceptedTypeGroups: const [_imageTypes],
      confirmButtonText: '选择封面',
    );
    return file?.path;
  }
}
