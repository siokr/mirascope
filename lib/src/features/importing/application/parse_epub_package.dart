import 'dart:convert';

import 'package:html/dom.dart' as html_dom;
import 'package:html/parser.dart' as html_parser;
import 'package:xml/xml.dart';

import '../../../core/errors/app_error_code.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/epub_container.dart';
import '../domain/parsed_epub.dart';

final class ParseEpubPackage {
  const ParseEpubPackage({this.maximumSpineItems = 5000});

  final int maximumSpineItems;

  Future<ParsedEpub> call(EpubContainer container) async {
    try {
      const containerPath = 'META-INF/container.xml';
      if (!container.contains(containerPath)) {
        throw AppFailure.fromCode(AppErrorCode.epubInvalidContainer);
      }
      final containerXml = _parseXml(
        await container.readBytes(containerPath),
        AppErrorCode.epubInvalidContainer,
      );
      final rootfiles = _elements(containerXml, 'rootfile').where(
        (element) =>
            element.getAttribute('media-type') ==
            'application/oebps-package+xml',
      );
      if (rootfiles.length != 1) {
        throw AppFailure.fromCode(AppErrorCode.epubPackageMissing);
      }
      final packagePath = rootfiles.single.getAttribute('full-path');
      if (packagePath == null || !container.contains(packagePath)) {
        throw AppFailure.fromCode(AppErrorCode.epubPackageMissing);
      }

      final package = _parseXml(
        await container.readBytes(packagePath),
        AppErrorCode.epubManifestInvalid,
      );
      final packageElement = _elements(package, 'package').firstOrNull;
      final version = packageElement?.getAttribute('version')?.trim();
      if (packageElement == null || version == null || version.isEmpty) {
        throw AppFailure.fromCode(AppErrorCode.epubManifestInvalid);
      }

      final title = _firstText(package, 'title');
      if (title == null) {
        throw AppFailure.fromCode(AppErrorCode.epubManifestInvalid);
      }
      final authors = _elements(package, 'creator')
          .map((element) => element.innerText.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
      final manifest = _parseManifest(container, package, packagePath);
      final spineElement = _elements(package, 'spine').firstOrNull;
      if (spineElement == null) {
        throw AppFailure.fromCode(AppErrorCode.epubSpineEmpty);
      }
      final itemRefs = _childElements(spineElement, 'itemref').toList();
      if (itemRefs.isEmpty || itemRefs.length > maximumSpineItems) {
        throw AppFailure.fromCode(
          itemRefs.length > maximumSpineItems
              ? AppErrorCode.epubResourceLimit
              : AppErrorCode.epubSpineEmpty,
        );
      }
      final spine = <EpubSpineItem>[];
      for (final itemRef in itemRefs) {
        final idref = itemRef.getAttribute('idref');
        final item = manifest[idref];
        if (idref == null || item == null || !container.contains(item.path)) {
          throw AppFailure.fromCode(AppErrorCode.epubResourceMissing);
        }
        spine.add(
          EpubSpineItem(
            item: item,
            linear: itemRef.getAttribute('linear')?.toLowerCase() != 'no',
          ),
        );
      }

      await _rejectEncryptedReadingResources(container, manifest);
      final navigation = await _parseNavigation(container, package, manifest);
      return ParsedEpub(
        version: version,
        packagePath: packagePath,
        title: title,
        authors: List.unmodifiable(authors),
        manifest: Map.unmodifiable(manifest),
        spine: List.unmodifiable(spine),
        navigation: List.unmodifiable(navigation),
      );
    } on AppFailure {
      rethrow;
    } on Object {
      throw AppFailure.fromCode(AppErrorCode.epubManifestInvalid);
    }
  }

  Map<String, EpubManifestItem> _parseManifest(
    EpubContainer container,
    XmlDocument package,
    String packagePath,
  ) {
    final result = <String, EpubManifestItem>{};
    final manifestElement = _elements(package, 'manifest').firstOrNull;
    if (manifestElement == null) {
      throw AppFailure.fromCode(AppErrorCode.epubManifestInvalid);
    }
    for (final element in _childElements(manifestElement, 'item')) {
      final id = element.getAttribute('id')?.trim();
      final href = element.getAttribute('href')?.trim();
      final mediaType = element.getAttribute('media-type')?.trim();
      if (id == null ||
          id.isEmpty ||
          href == null ||
          href.isEmpty ||
          mediaType == null ||
          mediaType.isEmpty ||
          result.containsKey(id)) {
        throw AppFailure.fromCode(AppErrorCode.epubManifestInvalid);
      }
      result[id] = EpubManifestItem(
        id: id,
        path: container.resolvePath(packagePath, href),
        mediaType: mediaType,
        properties: Set.unmodifiable(
          (element.getAttribute('properties') ?? '')
              .split(RegExp(r'\s+'))
              .where((value) => value.isNotEmpty),
        ),
      );
    }
    if (result.isEmpty) {
      throw AppFailure.fromCode(AppErrorCode.epubManifestInvalid);
    }
    return result;
  }

  Future<List<EpubNavigationItem>> _parseNavigation(
    EpubContainer container,
    XmlDocument package,
    Map<String, EpubManifestItem> manifest,
  ) async {
    final navItem = manifest.values
        .where((item) => item.properties.contains('nav'))
        .firstOrNull;
    if (navItem != null) {
      if (!container.contains(navItem.path)) {
        throw AppFailure.fromCode(AppErrorCode.epubResourceMissing);
      }
      final document = html_parser.parse(
        _decodeMarkup(await container.readBytes(navItem.path)),
      );
      final nav = document.querySelectorAll('nav').where((element) {
        final type = element.attributes.entries
            .where((entry) {
              final name = entry.key.toString();
              return name == 'type' || name.endsWith(':type');
            })
            .map((entry) => entry.value)
            .firstOrNull;
        return type?.split(RegExp(r'\s+')).contains('toc') ?? false;
      }).firstOrNull;
      if (nav == null) {
        return const <EpubNavigationItem>[];
      }
      final list = nav.children
          .where((element) => element.localName == 'ol')
          .firstOrNull;
      return list == null
          ? const <EpubNavigationItem>[]
          : _parseHtmlList(container, navItem.path, list);
    }

    final spine = _elements(package, 'spine').firstOrNull;
    final ncxId = spine?.getAttribute('toc');
    final ncx = manifest[ncxId];
    if (ncx == null) {
      return const <EpubNavigationItem>[];
    }
    if (!container.contains(ncx.path)) {
      throw AppFailure.fromCode(AppErrorCode.epubResourceMissing);
    }
    final document = _parseXml(
      await container.readBytes(ncx.path),
      AppErrorCode.epubManifestInvalid,
    );
    final navMap = _elements(document, 'navMap').firstOrNull;
    return navMap == null
        ? const <EpubNavigationItem>[]
        : _parseNcxPoints(container, ncx.path, navMap);
  }

  List<EpubNavigationItem> _parseHtmlList(
    EpubContainer container,
    String navigationPath,
    html_dom.Element list,
  ) {
    final result = <EpubNavigationItem>[];
    for (final li in list.children.where(
      (element) => element.localName == 'li',
    )) {
      final anchor = li.children
          .where((element) => element.localName == 'a')
          .firstOrNull;
      final href = anchor?.attributes['href'];
      final title = anchor?.text.trim();
      if (href == null || title == null || title.isEmpty) {
        continue;
      }
      final target = _resolveTarget(container, navigationPath, href);
      final nested = li.children
          .where((element) => element.localName == 'ol')
          .firstOrNull;
      result.add(
        EpubNavigationItem(
          title: title,
          targetPath: target.path,
          fragment: target.fragment,
          children: nested == null
              ? const <EpubNavigationItem>[]
              : List.unmodifiable(
                  _parseHtmlList(container, navigationPath, nested),
                ),
        ),
      );
    }
    return result;
  }

  List<EpubNavigationItem> _parseNcxPoints(
    EpubContainer container,
    String ncxPath,
    XmlElement parent,
  ) {
    final result = <EpubNavigationItem>[];
    for (final point in _childElements(parent, 'navPoint')) {
      final title = _elements(point, 'text').firstOrNull?.innerText.trim();
      final source = _childElements(
        point,
        'content',
      ).firstOrNull?.getAttribute('src');
      if (title == null || title.isEmpty || source == null || source.isEmpty) {
        continue;
      }
      final target = _resolveTarget(container, ncxPath, source);
      result.add(
        EpubNavigationItem(
          title: title,
          targetPath: target.path,
          fragment: target.fragment,
          children: List.unmodifiable(
            _parseNcxPoints(container, ncxPath, point),
          ),
        ),
      );
    }
    return result;
  }

  _EpubTarget _resolveTarget(
    EpubContainer container,
    String base,
    String href,
  ) {
    final hash = href.indexOf('#');
    final resource = hash < 0 ? href : href.substring(0, hash);
    final fragment = hash < 0
        ? null
        : Uri.decodeComponent(href.substring(hash + 1));
    final path = container.resolvePath(base, resource);
    if (!container.contains(path)) {
      throw AppFailure.fromCode(AppErrorCode.epubResourceMissing);
    }
    return _EpubTarget(path, fragment?.isEmpty ?? true ? null : fragment);
  }

  Future<void> _rejectEncryptedReadingResources(
    EpubContainer container,
    Map<String, EpubManifestItem> manifest,
  ) async {
    const encryptionPath = 'META-INF/encryption.xml';
    if (!container.contains(encryptionPath)) {
      return;
    }
    final encryption = _parseXml(
      await container.readBytes(encryptionPath),
      AppErrorCode.epubManifestInvalid,
    );
    final protectedPaths = manifest.values
        .where(
          (item) =>
              item.mediaType == 'application/xhtml+xml' ||
              item.mediaType.startsWith('image/'),
        )
        .map((item) => item.path)
        .toSet();
    for (final reference in _elements(encryption, 'CipherReference')) {
      final uri = reference.getAttribute('URI');
      if (uri != null &&
          protectedPaths.contains(container.resolvePath(encryptionPath, uri))) {
        throw AppFailure.fromCode(AppErrorCode.epubDrmUnsupported);
      }
    }
  }
}

XmlDocument _parseXml(List<int> bytes, AppErrorCode failureCode) {
  try {
    return XmlDocument.parse(_decodeMarkup(bytes));
  } on Object {
    throw AppFailure.fromCode(failureCode);
  }
}

String _decodeMarkup(List<int> bytes) {
  if (bytes.length >= 2) {
    final littleEndian =
        (bytes[0] == 0xff && bytes[1] == 0xfe) ||
        (bytes[0] == 0x3c && bytes[1] == 0x00);
    final bigEndian =
        (bytes[0] == 0xfe && bytes[1] == 0xff) ||
        (bytes[0] == 0x00 && bytes[1] == 0x3c);
    if (littleEndian || bigEndian) {
      final start = (bytes[0] == 0xff || bytes[0] == 0xfe) ? 2 : 0;
      if ((bytes.length - start).isOdd) {
        throw const FormatException('Invalid UTF-16 byte length');
      }
      final codeUnits = <int>[];
      for (var index = start; index < bytes.length; index += 2) {
        codeUnits.add(
          littleEndian
              ? bytes[index] | (bytes[index + 1] << 8)
              : (bytes[index] << 8) | bytes[index + 1],
        );
      }
      return String.fromCharCodes(codeUnits);
    }
  }
  return utf8.decode(bytes, allowMalformed: false);
}

Iterable<XmlElement> _elements(XmlNode node, String localName) => node
    .descendants
    .whereType<XmlElement>()
    .where((element) => element.name.local == localName);

Iterable<XmlElement> _childElements(XmlElement node, String localName) => node
    .children
    .whereType<XmlElement>()
    .where((element) => element.name.local == localName);

String? _firstText(XmlNode node, String localName) {
  final value = _elements(node, localName).firstOrNull?.innerText.trim();
  return value == null || value.isEmpty ? null : value;
}

final class _EpubTarget {
  const _EpubTarget(this.path, this.fragment);
  final String path;
  final String? fragment;
}
