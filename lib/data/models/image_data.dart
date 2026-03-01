import 'dart:typed_data';

enum AppImageSource {
  asset,
  network,
  file,
  memory,
}

class AppImageData {
  final AppImageSource source;
  final String? path;           // asset / network / file
  final Uint8List? bytes;       // memory
  final Map<String, String>? headers;

  const AppImageData.asset(this.path)
      : source = AppImageSource.asset,
        bytes = null,
        headers = null;

  const AppImageData.network(this.path, {this.headers})
      : source = AppImageSource.network,
        bytes = null;

  const AppImageData.file(this.path)
      : source = AppImageSource.file,
        bytes = null,
        headers = null;

  const AppImageData.memory(this.bytes)
      : source = AppImageSource.memory,
        path = null,
        headers = null;
}
