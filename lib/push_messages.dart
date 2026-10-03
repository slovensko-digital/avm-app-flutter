import 'dart:convert' show base64, json, utf8;
import 'dart:typed_data' show Uint8List;

import 'package:pointycastle/export.dart'
    show AEADParameters, AESEngine, GCMBlockCipher, KeyParameter;

/// Key of the FCM `data` payload value with sign request message.
const signRequestMessageKey = "encrypted_message";

/// Parses sign request from the FCM `data` payload [message] value.
///
/// Server sends JSON `{"document_guid": ..., "documentEncryptionKey": ...}`
/// either as is, or encrypted by Rails `ActiveSupport::MessageEncryptor`
/// (AES-256-GCM) using device [pushkey] - see
/// https://github.com/slovensko-digital/avm-server/blob/main/app/models/device.rb
///
/// Throws [FormatException] in case of invalid [message].
SignRequestMessage parseSignRequestMessage(String message, String? pushkey) {
  final trimmed = message.trim();
  final decoded = trimmed.startsWith("{")
      ? json.decode(trimmed)
      : _decryptMessage(trimmed, pushkey);

  return SignRequestMessage._fromJson(decoded);
}

Object? _decryptMessage(String message, String? pushkey) {
  if (pushkey == null) {
    throw const FormatException("Missing pushkey to decrypt message.");
  }

  // Format: "<data>--<iv>--<auth_tag>"; all in Base64
  final parts = message.split("--");

  if (parts.length != 3) {
    throw const FormatException("Invalid encrypted message format.");
  }

  final [data, iv, authTag] = parts.map(base64.decode).toList();
  final cipher = GCMBlockCipher(AESEngine())
    ..init(
      false,
      AEADParameters(
        KeyParameter(base64.decode(pushkey)),
        authTag.length * 8,
        iv,
        Uint8List(0),
      ),
    );
  final plainText = cipher.process(Uint8List.fromList([...data, ...authTag]));
  final decoded = json.decode(utf8.decode(plainText));

  // Rails JSON serializer encodes our JSON String once more
  return decoded is String ? json.decode(decoded) : decoded;
}

/// Sign request received through push notification.
class SignRequestMessage {
  final String documentGuid;
  final String documentEncryptionKey;

  const SignRequestMessage({
    required this.documentGuid,
    required this.documentEncryptionKey,
  });

  factory SignRequestMessage._fromJson(Object? value) {
    if (value is! Map) {
      throw const FormatException("Message is not JSON object.");
    }

    final guid = value["documentGuid"] ?? value["document_guid"];
    final key =
        value["documentEncryptionKey"] ?? value["document_encryption_key"];

    if (guid is! String || guid.isEmpty || key is! String || key.isEmpty) {
      throw const FormatException("Message is missing guid or key.");
    }

    return SignRequestMessage(documentGuid: guid, documentEncryptionKey: key);
  }

  /// Returns "QR code" URL that is handled same way as scanned QR code.
  Uri toUri() {
    return Uri.https(
      "autogram.slovensko.digital",
      "/api/v1/qr-code",
      {"guid": documentGuid, "key": documentEncryptionKey},
    );
  }

  @override
  String toString() {
    return "$runtimeType(documentGuid: $documentGuid)";
  }
}
