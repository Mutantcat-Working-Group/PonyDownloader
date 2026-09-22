import 'package:flutter_test/flutter_test.dart';
import 'package:ponydownloader/core/utils/content_uri_resolver.dart';

void main() {
  test('rejects non-content URIs', () async {
    expect(() => ContentUriResolver.copyToCache(Uri.parse('file:///tmp/example.torrent')), throwsArgumentError);
  });
}
