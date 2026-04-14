class FirebaseUtils {
  const FirebaseUtils._();

  static String extractFirebaseStoragePath(String downloadUrl) {
    final uri = Uri.parse(downloadUrl);
    final segments = uri.pathSegments;

    final oIndex = segments.indexOf('o');
    if (oIndex == -1 || oIndex + 1 >= segments.length) {
      throw FormatException('Invalid Firebase Storage URL');
    }

    final encodedPath = segments[oIndex + 1];
    return Uri.decodeComponent(encodedPath);
  }
}
