import 'dart:io' show Directory, File;

import 'package:path/path.dart' as path;

/// Set of extensions on [Directory] type.
extension DirectoryExtensions on Directory {
  /// Returns flag indicating whether can write into this [Directory].
  Future<bool> canWrite() async {
    final tempFile = File(path.join(this.path, ".can_write"));

    try {
      await tempFile.writeAsBytes(const [], flush: true);

      return true;
    } catch (error) {
      return false;
    }
  }
}
