import 'package:encrypt/encrypt.dart';

class EncryptionHelper {
  static final _key = Key.fromUtf8(
    'my32lengthsupersecretkey12345678',
  ); // In production, derive from user PIN
  static final _iv = IV.fromLength(16);

  static String encrypt(String plainText) {
    final encrypter = Encrypter(AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  static String decrypt(String cipherText) {
    final encrypter = Encrypter(AES(_key));
    final decrypted = encrypter.decrypt(
      Encrypted.fromBase64(cipherText),
      iv: _iv,
    );
    return decrypted;
  }
}
