abstract class StorageService {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveStringList(String key, List<String> values);
  Future<List<String>> getStringList(String key);
  Future<void> remove(String key);
  Future<void> clear();
}

