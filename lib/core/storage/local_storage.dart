import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

class StorageServiceImpl implements StorageService {
  final SharedPreferences _prefs;

  StorageServiceImpl(this._prefs);

  @override
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> saveStringList(String key, List<String> values) async {
    await _prefs.setStringList(key, values);
  }

  @override
  Future<List<String>> getStringList(String key) async {
    return _prefs.getStringList(key) ?? [];
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}

