import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class Database {
  static final Database _instance = Database._internal();
  late final FlutterSecureStorage _storage;
  final Uuid _uuid = Uuid();

  AndroidOptions get _androidOptions =>
      const AndroidOptions(encryptedSharedPreferences: true);

  IOSOptions get _iosOptions =>
      const IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  WebOptions get _webOptions =>
      WebOptions(dbName: 'secureStorage', publicKey: 'thoughts_key');

  factory Database() => _instance;

  Database._internal() {
    _storage = const FlutterSecureStorage();
  }

  Future<void> writeString(String key, String value) async {
    if (kIsWeb) {
      await _storage.write(key: key, value: value, webOptions: _webOptions);
    } else {
      await _storage.write(
        key: key,
        value: value,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    }
  }

  Future<String?> readString(String key) async {
    if (kIsWeb) {
      return await _storage.read(key: key, webOptions: _webOptions);
    } else {
      return await _storage.read(
        key: key,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    }
  }

  Future<void> deleteKey(String key) async {
    if (kIsWeb) {
      await _storage.delete(key: key, webOptions: _webOptions);
    } else {
      await _storage.delete(
        key: key,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    }
  }

  Future<void> deleteAll() async {
    if (kIsWeb) {
      await _storage.deleteAll(webOptions: _webOptions);
    } else {
      await _storage.deleteAll(
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getCollection(String collectionKey) async {
    final String? data = await readString(collectionKey);
    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      throw Exception("Failed to parse collection data: $e");
    }
  }

  Future<void> saveCollection(
    String collectionKey,
    List<Map<String, dynamic>> collection,
  ) async {
    final String jsonData = jsonEncode(collection);
    await writeString(collectionKey, jsonData);
  }

  Future<Map<String, dynamic>> create(
    String collectionKey,
    Map<String, dynamic> data,
  ) async {
    final String id = _uuid.v4();

    final DateTime now = DateTime.now();
    final int timestamp = now.millisecondsSinceEpoch;

    final Map<String, dynamic> fullData = {
      ...data,
      'id': id,
      'created_at': timestamp,
      'updated_at': timestamp,
    };

    final List<Map<String, dynamic>> collection = await getCollection(
      collectionKey,
    );
    collection.add(fullData);
    await saveCollection(collectionKey, collection);

    return fullData;
  }

  Future<Map<String, dynamic>?> find(String collectionKey, String id) async {
    final List<Map<String, dynamic>> collection = await getCollection(
      collectionKey,
    );
    try {
      return collection.firstWhere((item) => item['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> readAll(String collectionKey) async {
    return await getCollection(collectionKey);
  }

  Future<bool> update(
    String collectionKey,
    String id,
    Map<String, dynamic> data,
  ) async {
    final List<Map<String, dynamic>> collection = await getCollection(
      collectionKey,
    );
    final int index = collection.indexWhere((item) => item['id'] == id);

    if (index == -1) {
      return false;
    }

    final int timestamp = DateTime.now().millisecondsSinceEpoch;

    collection[index] = {
      ...collection[index],
      ...data,
      'id': id,
      'created_at': collection[index]['created_at'],
      'updated_at': timestamp,
    };

    await saveCollection(collectionKey, collection);
    return true;
  }

  Future<bool> delete(String collectionKey, String id) async {
    final List<Map<String, dynamic>> collection = await getCollection(
      collectionKey,
    );
    final int initialLength = collection.length;

    collection.removeWhere((item) => item['id'] == id);

    if (collection.length == initialLength) {
      return false;
    }

    await saveCollection(collectionKey, collection);
    return true;
  }

  Future<List<Map<String, dynamic>>> query(
    String collectionKey,
    bool Function(Map<String, dynamic>) filter,
  ) async {
    final List<Map<String, dynamic>> collection = await getCollection(
      collectionKey,
    );
    return collection.where(filter).toList();
  }

  Future<List<Map<String, dynamic>>> where(
    String collectionKey,
    String field,
    dynamic value, {
    String? operator,
  }) async {
    final List<Map<String, dynamic>> collection = await getCollection(
      collectionKey,
    );

    return collection.where((item) {
      if (!item.containsKey(field)) {
        return false;
      }

      final dynamic itemValue = item[field];

      if (operator == null) {
        return itemValue == value;
      }

      switch (operator) {
        case '=':
        case '==':
          return itemValue == value;
        case '!=':
        case '<>':
          return itemValue != value;
        case '>':
          if (itemValue is num && value is num) {
            return itemValue > value;
          } else if (itemValue is String && value is String) {
            return itemValue.compareTo(value) > 0;
          }
          return false;
        case '>=':
          if (itemValue is num && value is num) {
            return itemValue >= value;
          } else if (itemValue is String && value is String) {
            return itemValue.compareTo(value) >= 0;
          }
          return false;
        case '<':
          if (itemValue is num && value is num) {
            return itemValue < value;
          } else if (itemValue is String && value is String) {
            return itemValue.compareTo(value) < 0;
          }
          return false;
        case '<=':
          if (itemValue is num && value is num) {
            return itemValue <= value;
          } else if (itemValue is String && value is String) {
            return itemValue.compareTo(value) <= 0;
          }
          return false;
        case 'like':
        case 'LIKE':
          if (itemValue is String && value is String) {
            String pattern = value.replaceAll('%', '.*');
            RegExp regExp = RegExp('^$pattern\$', caseSensitive: false);
            return regExp.hasMatch(itemValue);
          }
          return false;
        case 'in':
        case 'IN':
          if (value is List) {
            return value.contains(itemValue);
          }
          return false;
        case 'not in':
        case 'NOT IN':
          if (value is List) {
            return !value.contains(itemValue);
          }
          return false;
        default:
          throw ArgumentError('Unsupported operator: $operator');
      }
    }).toList();
  }
}
