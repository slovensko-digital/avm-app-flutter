import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../utils.dart' as utils;

/// Holds "Encryption Key" value.
@singleton
class EncryptionKeyRegistry extends ValueNotifier<String> {
  EncryptionKeyRegistry() : super(_newValue());

  /// Sets new [value] value.
  void newValue() {
    value = _newValue();
  }

  static String _newValue() {
    return utils.createCryptoRandomString();
  }
}
