import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CredentialService {
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const _keyEmail = 'saved_email';
  static const _keyPassword = 'saved_password';
  static const _keyRemember = 'remember_me';

  Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
    await _storage.write(key: _keyRemember, value: 'true');
  }

  Future<({String? email, String? password})?> loadCredentials() async {
    final remember = await _storage.read(key: _keyRemember);
    if (remember != 'true') return null;
    final email = await _storage.read(key: _keyEmail);
    final password = await _storage.read(key: _keyPassword);
    return (email: email, password: password);
  }

  Future<void> clearCredentials() async {
    await _storage.deleteAll();
  }

  Future<bool> hasSavedCredentials() async {
    final remember = await _storage.read(key: _keyRemember);
    return remember == 'true';
  }
}

final credentialServiceProvider =
    Provider<CredentialService>((_) => CredentialService());
