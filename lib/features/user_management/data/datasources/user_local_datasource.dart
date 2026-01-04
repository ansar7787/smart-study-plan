import 'package:hive/hive.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';

abstract class UserLocalDatasource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser(String userId);
  Future<UserModel?> getUserByEmail(String email);
  Future<List<UserModel>> getAllUsers();
  Future<void> deleteUser(String userId);
  Future<void> clearAllUsers();
}

class UserLocalDatasourceImpl implements UserLocalDatasource {
  static const String _boxName = 'users';
  late Box<Map> _box;

  UserLocalDatasourceImpl();

  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await _box.put(user.id, user.toJson());
      AppLogger.d('User saved locally: ${user.email}');
    } catch (e) {
      throw CacheException('Failed to save user: $e');
    }
  }

  @override
  Future<UserModel?> getUser(String userId) async {
    try {
      final data = _box.get(userId);
      if (data == null) return null;
      return UserModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw CacheException('Failed to get user: $e');
    }
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final values = _box.values;
      for (var value in values) {
        final user = UserModel.fromJson(Map<String, dynamic>.from(value));
        if (user.email == email) {
          return user;
        }
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get user by email: $e');
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final values = _box.values;
      return values
          .map((v) => UserModel.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get all users: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _box.delete(userId);
      AppLogger.d('User deleted locally: $userId');
    } catch (e) {
      throw CacheException('Failed to delete user: $e');
    }
  }

  @override
  Future<void> clearAllUsers() async {
    try {
      await _box.clear();
      AppLogger.d('All users cleared from local storage');
    } catch (e) {
      throw CacheException('Failed to clear users: $e');
    }
  }
}
