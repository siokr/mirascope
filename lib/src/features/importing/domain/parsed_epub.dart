final class ParsedEpub {
  const ParsedEpub({
    required this.version,
    required this.packagePath,
    required this.title,
    required this.authors,
    required this.manifest,
    required this.spine,
    required this.navigation,
  });

  final String version;
  final String packagePath;
  final String title;
  final List<String> authors;
  final Map<String, EpubManifestItem> manifest;
  final List<EpubSpineItem> spine;
  final List<EpubNavigationItem> navigation;
}

final class EpubManifestItem {
  const EpubManifestItem({
    required this.id,
    required this.path,
    required this.mediaType,
    required this.properties,
  });

  final String id;
  final String path;
  final String mediaType;
  final Set<String> properties;
}

final class EpubSpineItem {
  const EpubSpineItem({required this.item, required this.linear});

  final EpubManifestItem item;
  final bool linear;
}

final class EpubNavigationItem {
  const EpubNavigationItem({
    required this.title,
    required this.targetPath,
    this.fragment,
    this.children = const <EpubNavigationItem>[],
  });

  final String title;
  final String targetPath;
  final String? fragment;
  final List<EpubNavigationItem> children;
}
