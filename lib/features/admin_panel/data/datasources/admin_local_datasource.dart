import 'package:hive/hive.dart';
import '../models/admin_stats_model.dart';
import '../models/user_admin_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';

abstract class AdminLocalDatasource {
  Future<void> cacheUsers(List<UserAdminModel> users);
  Future<List<UserAdminModel>> getCachedUsers();
  Future<void> cacheAdminStats(AdminStatsModel stats);
  Future<AdminStatsModel?> getCachedAdminStats();
  Future<void> clearCache();
}

class AdminLocalDatasourceImpl implements AdminLocalDatasource {
  static const String _usersBoxName = 'admin_users';
  static const String _statsBoxName = 'admin_stats';
  static const String _statsKey = 'stats';

  late Box<Map> _usersBox;
  late Box<Map> _statsBox;

  AdminLocalDatasourceImpl();

  Future<void> init() async {
    _usersBox = await Hive.openBox<Map>(_usersBoxName);
    _statsBox = await Hive.openBox<Map>(_statsBoxName);
  }

  @override
  Future<void> cacheUsers(List<UserAdminModel> users) async {
    try {
      await _usersBox.clear();
      for (var user in users) {
        await _usersBox.put(user.id, user.toJson());
      }
      AppLogger.d('Cached ${users.length} users locally');
    } catch (e) {
      throw CacheException('Failed to cache users: $e');
    }
  }

  @override
  Future<List<UserAdminModel>> getCachedUsers() async {
    try {
      final values = _usersBox.values;
      final users = values
          .map((v) => UserAdminModel.fromJson(Map<String, dynamic>.from(v)))
          .toList();
      AppLogger.d('Retrieved ${users.length} users from cache');
      return users;
    } catch (e) {
      throw CacheException('Failed to get cached users: $e');
    }
  }

  @override
  Future<void> cacheAdminStats(AdminStatsModel stats) async {
    try {
      await _statsBox.put(_statsKey, stats.toJson());
      AppLogger.d('Cached admin stats locally');
    } catch (e) {
      throw CacheException('Failed to cache admin stats: $e');
    }
  }

  @override
  Future<AdminStatsModel?> getCachedAdminStats() async {
    try {
      final data = _statsBox.get(_statsKey);
      if (data == null) return null;
      return AdminStatsModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw CacheException('Failed to get cached admin stats: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _usersBox.clear();
      await _statsBox.clear();
      AppLogger.d('Admin cache cleared');
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }
}
