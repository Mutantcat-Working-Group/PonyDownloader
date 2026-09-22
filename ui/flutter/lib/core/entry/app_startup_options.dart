class AppStartupOptions {
  const AppStartupOptions({required this.hidden});

  factory AppStartupOptions.fromArgs(List<String> args) {
    return AppStartupOptions(
      hidden: args.contains('--hidden') || args.map(Uri.tryParse).whereType<Uri>().any(isSilentPonyDownloaderWakeUri),
    );
  }

  final bool hidden;

  AppStartupOptions withInitialUri(Uri? uri) {
    return AppStartupOptions(hidden: hidden || (uri != null && isSilentPonyDownloaderWakeUri(uri)));
  }
}

bool isSilentPonyDownloaderWakeUri(Uri uri) {
  if (uri.scheme.toLowerCase() != 'ponydownloader' || uri.queryParameters['hidden'] != 'true') {
    return false;
  }
  return uri.path.isEmpty || uri.path == '/';
}
