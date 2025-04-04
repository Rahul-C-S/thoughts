import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class Database {
  static final Database _instance = Database._internal();
  late final FlutterSecureStorage _storage;
  final Uuid _uuid = Uuid();

  // Platform-specific options
  AndroidOptions get _androidOptions =>
      const AndroidOptions(encryptedSharedPreferences: true);

  IOSOptions get _iosOptions =>
      const IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  // Web options
  WebOptions get _webOptions =>
      WebOptions(dbName: 'secureStorage', publicKey: 'thoughts_key');

  // Singleton pattern
  factory Database() => _instance;

  Database._internal() {
    // Initialize the storage with appropriate settings
    _storage = const FlutterSecureStorage();
  }

  // Basic storage methods
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

  // Collection methods
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

  // Model CRUD Operations with metadata handling

  // Create operation
  Future<Map<String, dynamic>> create(
    String collectionKey,
    Map<String, dynamic> data,
  ) async {
    // Generate a unique UUID for the primary key
    final String id = _uuid.v4();

    // Add metadata - ID and timestamps
    final DateTime now = DateTime.now();
    final int timestamp = now.millisecondsSinceEpoch;

    // Create a new map with all the required fields
    final Map<String, dynamic> fullData = {
      ...data,
      'id': id,
      'created_at': timestamp,
      'updated_at': timestamp,
    };

    // Get collection and add item
    final List<Map<String, dynamic>> collection = await getCollection(
      collectionKey,
    );
    collection.add(fullData);
    await saveCollection(collectionKey, collection);

    return fullData;
  }

  // Read operation - get by ID
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

  // Read all operation
  Future<List<Map<String, dynamic>>> readAll(String collectionKey) async {
    return await getCollection(collectionKey);
  }

  // Update operation
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

    // Update with new data and timestamp
    final int timestamp = DateTime.now().millisecondsSinceEpoch;

    // Create updated item preserving id and created_at
    collection[index] = {
      ...collection[index],
      ...data,
      'id': id, // Ensure ID stays the same
      'created_at':
          collection[index]['created_at'], // Preserve original creation time
      'updated_at': timestamp, // Update the modification time
    };

    await saveCollection(collectionKey, collection);
    return true;
  }

  // Delete operation
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

  // Query collection with filter function
  Future<List<Map<String, dynamic>>> query(
    String collectionKey,
    bool Function(Map<String, dynamic>) filter,
  ) async {
    final List<Map<String, dynamic>> collection = await getCollection(
      collectionKey,
    );
    return collection.where(filter).toList();
  }

  // Where function for querying collections
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

      // If no operator is provided, default to equality check
      if (operator == null) {
        return itemValue == value;
      }

      // Handle different operators
      switch (operator) {
        case '=':
        case '==':
          return itemValue == value;
        case '!=':
        case '<>':
          return itemValue != value;
        case '>':
          // Parse values to num if comparing numbers
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
            // Convert the 'like' pattern to a RegExp
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
