import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../domain/manga_page_cache.dart';

final class DartIoMangaPageCache implements MangaPageCache {
  DartIoMangaPageCache(this.root, {this.budget = const MangaPageCacheBudget()});
  final Directory root;
  final MangaPageCacheBudget budget;
  final LinkedHashMap<String, Uint8List> _memory = LinkedHashMap();
  var _memoryBytes = 0;

  @override
  Future<Uint8List?> get(MangaPageCacheKey key) async {
    final token = _token(key);
    final memory = _memory.remove(token);
    if (memory != null) {
      _memory[token] = memory;
      return Uint8List.fromList(memory);
    }
    final file = File('${root.path}${Platform.pathSeparator}$token.page');
    if (!await file.exists()) return null;
    try {
      final bytes = await file.readAsBytes();
      if (!_valid(key, bytes)) {
        await file.delete();
        return null;
      }
      await file.setLastModified(DateTime.now().toUtc());
      _remember(token, bytes);
      return bytes;
    } on FileSystemException {
      return null;
    }
  }

  @override
  Future<void> put(MangaPageCacheKey key, Uint8List bytes) async {
    if (!_valid(key, bytes)) {
      throw ArgumentError('Page bytes do not match cache key');
    }
    final token = _token(key);
    _remember(token, bytes);
    if (bytes.length > budget.maximumDiskBytes) return;
    await root.create(recursive: true);
    final target = File('${root.path}${Platform.pathSeparator}$token.page');
    final temporary = File('${target.path}.tmp');
    await temporary.writeAsBytes(bytes, flush: true);
    if (await target.exists()) await target.delete();
    await temporary.rename(target.path);
    await _trimDisk();
  }

  @override
  Future<void> clear() async {
    _memory.clear();
    _memoryBytes = 0;
    if (await root.exists()) await root.delete(recursive: true);
  }

  void _remember(String token, Uint8List bytes) {
    if (bytes.length > budget.maximumMemoryBytes) return;
    final previous = _memory.remove(token);
    if (previous != null) _memoryBytes -= previous.length;
    final copy = Uint8List.fromList(bytes);
    _memory[token] = copy;
    _memoryBytes += copy.length;
    while (_memoryBytes > budget.maximumMemoryBytes && _memory.isNotEmpty) {
      final oldest = _memory.keys.first;
      _memoryBytes -= _memory.remove(oldest)!.length;
    }
  }

  Future<void> _trimDisk() async {
    final files = await root
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.page'))
        .cast<File>()
        .toList();
    final stats = <({File file, FileStat stat})>[];
    var total = 0;
    for (final file in files) {
      final stat = await file.stat();
      total += stat.size;
      stats.add((file: file, stat: stat));
    }
    stats.sort((a, b) => a.stat.modified.compareTo(b.stat.modified));
    for (final entry in stats) {
      if (total <= budget.maximumDiskBytes) break;
      await entry.file.delete();
      total -= entry.stat.size;
    }
  }

  String _token(MangaPageCacheKey key) =>
      sha256.convert(key.stableValue.codeUnits).toString();
  bool _valid(MangaPageCacheKey key, Uint8List bytes) =>
      bytes.length == key.byteLength &&
      key.contentHash == 'sha256:${sha256.convert(bytes)}';
}
