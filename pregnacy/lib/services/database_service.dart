// lib/services/database_service.dart

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class DatabaseService {
  // Singleton pattern - only one instance of DatabaseService
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  
  final _secureStorage = const FlutterSecureStorage();
  
  // Private constructor
  DatabaseService._init();

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mamacare.db');
    return _database!;
  }

  // Initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // Create database tables
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL';

    // Users Table (extended with preferences for privacy controls)
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        email $textType UNIQUE,
        password $textType,
        name $textType,
        role $textType,
        specialization TEXT,
        phone_number TEXT,
        is_active $intType,
        created_at $textType,
        last_login TEXT,
        preferences TEXT
      )
    ''');

    // System Logs Table (Audit Trail)
    await db.execute('''
      CREATE TABLE system_logs (
        id $idType,
        user_id $textType,
        user_role $textType,
        action $textType,
        description $textType,
        timestamp $textType,
        affected_record_id TEXT,
        affected_record_type TEXT,
        previous_value TEXT,
        new_value TEXT
      )
    ''');

    // Doctor-Patient Assignment Table
    await db.execute('''
      CREATE TABLE doctor_patient_assignments (
        id $idType,
        doctor_id $intType,
        doctor_name $textType,
        patient_id $intType,
        patient_name $textType,
        assigned_date $textType,
        notes TEXT
      )
    ''');

    // User Profile Table
    await db.execute('''
      CREATE TABLE user_profile (
        id $idType,
        name $textType,
        due_date $textType,
        last_period_date $textType,
        pregnancy_type TEXT,
        created_at $textType
      )
    ''');

    // Kick Count Table
    await db.execute('''
      CREATE TABLE kick_counts (
        id $idType,
        date $textType,
        count $intType,
        start_time $textType,
        end_time $textType,
        notes TEXT
      )
    ''');

    // Contraction Table
    await db.execute('''
      CREATE TABLE contractions (
        id $idType,
        date $textType,
        start_time $textType,
        duration $intType,
        intensity TEXT,
        notes TEXT
      )
    ''');

    // Vital Signs Table
    await db.execute('''
      CREATE TABLE vital_signs (
        id $idType,
        date $textType,
        weight $realType,
        blood_pressure_systolic $intType,
        blood_pressure_diastolic $intType,
        glucose_level $realType,
        notes TEXT
      )
    ''');

    // Seed default users
    await _seedUsers(db);

    print('✅ Database tables created successfully');
  }

  // Upgrade handler — seeds new demo users when upgrading from v1 → v2
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _seedUsers(db);
      print('✅ Database upgraded to version $newVersion');
    }
  }

  // Insert all demo / seed users
  Future<void> _seedUsers(Database db) async {
    final now = DateTime.now().toIso8601String();

    await db.insert('users', {
      'email': 'admin@mamacare.com',
      'password': 'admin123',
      'name': 'Admin User',
      'role': 'admin',
      'is_active': 1,
      'created_at': now,
      'preferences': null,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.insert('users', {
      'email': 'patient@mamacare.com',
      'password': 'patient123',
      'name': 'Jane Doe',
      'role': 'patient',
      'is_active': 1,
      'created_at': now,
      'preferences': null,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.insert('users', {
      'email': 'doctor@mamacare.com',
      'password': 'doctor123',
      'name': 'Dr. Smith',
      'role': 'doctor',
      'specialization': 'Obstetrics',
      'is_active': 1,
      'created_at': now,
      'preferences': null,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    print('✅ Seed users inserted');
  }

  // Initialize database (call this in main.dart)
  Future<void> initDatabase() async {
    await database;
    print('✅ Database initialized');
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Get encryption key (create if doesn't exist)
  Future<String> _getEncryptionKey() async {
    String? key = await _secureStorage.read(key: 'encryption_key');
    if (key == null) {
      // Generate new encryption key
      key = encrypt.Key.fromSecureRandom(32).base64;
      await _secureStorage.write(key: 'encryption_key', value: key);
      print('✅ New encryption key created');
    }
    return key;
  }

  // Encrypt data
  Future<String> encryptData(String data) async {
    final keyString = await _getEncryptionKey();
    final key = encrypt.Key.fromBase64(keyString);
    final iv = encrypt.IV.fromSecureRandom(16);
    
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(data, iv: iv);
    
    // Return IV + encrypted data
    return '${iv.base64}:${encrypted.base64}';
  }

  // Decrypt data
  Future<String> decryptData(String encryptedData) async {
    final keyString = await _getEncryptionKey();
    final key = encrypt.Key.fromBase64(keyString);
    
    // Split IV and encrypted data
    final parts = encryptedData.split(':');
    final iv = encrypt.IV.fromBase64(parts[0]);
    final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
    
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.decrypt(encrypted, iv: iv);
  }

  // Generic database operations
  
  // Insert data
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  // Export all information related to a single user. This can be
  // serialized and offered for download in the UI as part of a GDPR-style
  // data portability request.
  Future<Map<String, dynamic>> exportUserData(int userId) async {
    final db = await database;
    final result = <String, dynamic>{};

    // basic user record
    final users = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (users.isNotEmpty) {
      result['user'] = users.first;
    }

    // example additional tables; adjust to your schema
    result['doctor_patient_assignments'] =
        await db.query('doctor_patient_assignments', where: 'doctor_id = ? OR patient_id = ?', whereArgs: [userId, userId]);
    result['user_profile'] =
        await db.query('user_profile', where: 'id = ?', whereArgs: [userId]);
    result['kick_counts'] =
        await db.query('kick_counts', where: 'id = ?', whereArgs: [userId]);
    result['contractions'] =
        await db.query('contractions', where: 'id = ?', whereArgs: [userId]);
    result['vital_signs'] =
        await db.query('vital_signs', where: 'id = ?', whereArgs: [userId]);

    return result;
  }

  // Delete all data associated with a user, including the account itself.
  // The caller should ensure proper authorization (e.g. ask for password or
  // confirm via MFA) before invoking this for privacy reasons.
  Future<void> deleteAllUserData(int userId) async {
    final db = await database;

    // remove from dependent tables first to satisfy foreign key constraints if
    // any exist (not defined in current schema)
    await db.delete('doctor_patient_assignments', where: 'doctor_id = ? OR patient_id = ?', whereArgs: [userId, userId]);
    await db.delete('user_profile', where: 'id = ?', whereArgs: [userId]);
    await db.delete('kick_counts', where: 'id = ?', whereArgs: [userId]);
    await db.delete('contractions', where: 'id = ?', whereArgs: [userId]);
    await db.delete('vital_signs', where: 'id = ?', whereArgs: [userId]);

    // finally delete the user record
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  // Query data
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  // Update data
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  // Delete data
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }
}