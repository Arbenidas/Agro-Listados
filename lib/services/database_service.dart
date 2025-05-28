import 'dart:async';
import 'package:logitruck_app/model/driver.dart';
import 'package:logitruck_app/model/list_item.dart';
import 'package:logitruck_app/model/point.dart';
import 'package:logitruck_app/model/product.dart';
import 'package:logitruck_app/model/shipping_list.dart';
import 'package:logitruck_app/model/transport_info.dart';
import 'package:logitruck_app/model/truck.dart';
import 'package:logitruck_app/model/user.dart';
import 'package:logitruck_app/model/user_point.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

// Actualizar la versión de la base de datos
  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'logitruck.db');
      return await openDatabase(
        path,
        version: 3, // Incrementar la versión para la migración
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
        onOpen: (db) {},
      );
    } catch (e) {
      rethrow;
    }
  }

// Actualizar el método de actualización de la base de datos
  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS user_points (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        point_id INTEGER NOT NULL,
        assigned_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (point_id) REFERENCES points (id),
        UNIQUE(user_id, point_id)
      )
    ''');

      await _assignPointsToExistingUsers(db);
    }

    if (oldVersion < 3) {
      // Crear tabla de conductores
      await db.execute('''
      CREATE TABLE IF NOT EXISTS drivers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        driver_id TEXT NOT NULL,
        phone TEXT NOT NULL,
        license_type TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

      // Crear tabla de camiones
      await db.execute('''
      CREATE TABLE IF NOT EXISTS trucks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plate TEXT NOT NULL UNIQUE,
        model TEXT NOT NULL,
        brand TEXT NOT NULL,
        year INTEGER NOT NULL,
        capacity REAL NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

      // Verificar si las columnas ya existen antes de agregarlas
      final tableInfo = await db.rawQuery("PRAGMA table_info(transport_info)");
      final columnNames =
          tableInfo.map((column) => column['name'] as String).toList();

      // Solo agregar driver_id si no existe
      if (!columnNames.contains('driver_id')) {
        await db.execute('''
        ALTER TABLE transport_info ADD COLUMN driver_id INTEGER
      ''');
      }

      // Solo agregar truck_id si no existe
      if (!columnNames.contains('truck_id')) {
        await db.execute('''
        ALTER TABLE transport_info ADD COLUMN truck_id INTEGER
      ''');
      }

      // Insertar datos de ejemplo
      await _insertSampleDriversAndTrucks(db);
    }
  }

// Agregar método para insertar datos de ejemplo
  Future<void> _insertSampleDriversAndTrucks(Database db) async {
    try {
      final now = DateTime.now().toIso8601String();

      // Insertar más conductores de ejemplo
      final drivers = [
        {
          'name': 'Juan Pérez',
          'driver_id': 'DL12345',
          'phone': '7771234567',
          'license_type': 'A'
        },
        {
          'name': 'María López',
          'driver_id': 'DL67890',
          'phone': '7779876543',
          'license_type': 'B'
        },
        {
          'name': 'Carlos Rodríguez',
          'driver_id': 'DL11111',
          'phone': '7775551234',
          'license_type': 'C'
        },
        {
          'name': 'Ana García',
          'driver_id': 'DL22222',
          'phone': '7775559876',
          'license_type': 'A'
        },
        {
          'name': 'Luis Martínez',
          'driver_id': 'DL33333',
          'phone': '7775555555',
          'license_type': 'B'
        },
        {
          'name': 'Sofia Hernández',
          'driver_id': 'DL44444',
          'phone': '7775556666',
          'license_type': 'C'
        },
        {
          'name': 'Roberto Silva',
          'driver_id': 'DL55555',
          'phone': '7775557777',
          'license_type': 'A'
        },
        {
          'name': 'Patricia Morales',
          'driver_id': 'DL66666',
          'phone': '7775558888',
          'license_type': 'B'
        },
        {
          'name': 'Diego Vargas',
          'driver_id': 'DL77777',
          'phone': '7775559999',
          'license_type': 'C'
        },
        {
          'name': 'Elena Ramírez',
          'driver_id': 'DL88888',
          'phone': '7775550000',
          'license_type': 'A'
        },
        {
          'name': 'Fernando Castro',
          'driver_id': 'DL99999',
          'phone': '7775551111',
          'license_type': 'B'
        },
        {
          'name': 'Gabriela Torres',
          'driver_id': 'DL00000',
          'phone': '7775552222',
          'license_type': 'C'
        },
      ];

      for (var driver in drivers) {
        await db.insert('drivers', {
          'name': driver['name'],
          'driver_id': driver['driver_id'],
          'phone': driver['phone'],
          'license_type': driver['license_type'],
          'is_active': 1,
          'created_at': now,
        });
      }

      // Insertar más camiones de ejemplo
      final trucks = [
        {
          'plate': 'ABC123',
          'model': 'Cargo 1000',
          'brand': 'Ford',
          'year': 2020,
          'capacity': 10.5
        },
        {
          'plate': 'XYZ789',
          'model': 'Master',
          'brand': 'Renault',
          'year': 2019,
          'capacity': 8.0
        },
        {
          'plate': 'DEF456',
          'model': 'Actros',
          'brand': 'Mercedes-Benz',
          'year': 2021,
          'capacity': 15.0
        },
        {
          'plate': 'GHI789',
          'model': 'FH',
          'brand': 'Volvo',
          'year': 2020,
          'capacity': 12.5
        },
        {
          'plate': 'JKL012',
          'model': 'TGX',
          'brand': 'MAN',
          'year': 2018,
          'capacity': 14.0
        },
        {
          'plate': 'MNO345',
          'model': 'Stralis',
          'brand': 'Iveco',
          'year': 2019,
          'capacity': 11.0
        },
        {
          'plate': 'PQR678',
          'model': 'Atego',
          'brand': 'Mercedes-Benz',
          'year': 2022,
          'capacity': 9.5
        },
        {
          'plate': 'STU901',
          'model': 'Daily',
          'brand': 'Iveco',
          'year': 2021,
          'capacity': 7.0
        },
        {
          'plate': 'VWX234',
          'model': 'Cascadia',
          'brand': 'Freightliner',
          'year': 2020,
          'capacity': 16.0
        },
        {
          'plate': 'HIJ567',
          'model': 'Sprinter',
          'brand': 'Mercedes-Benz',
          'year': 2023,
          'capacity': 6.5
        },
        {
          'plate': 'KLM890',
          'model': 'Transit',
          'brand': 'Ford',
          'year': 2022,
          'capacity': 5.0
        },
        {
          'plate': 'NOP123',
          'model': 'Boxer',
          'brand': 'Peugeot',
          'year': 2021,
          'capacity': 4.5
        },
      ];

      for (var truck in trucks) {
        await db.insert('trucks', {
          'plate': truck['plate'],
          'model': truck['model'],
          'brand': truck['brand'],
          'year': truck['year'],
          'capacity': truck['capacity'],
          'is_active': 1,
          'created_at': now,
        });
      }
    } catch (e) {
      print('Error inserting sample drivers and trucks: $e');
    }
  }

// Actualizar el método de creación de la base de datos
  Future<void> _createDatabase(Database db, int version) async {
    try {
      await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE points (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE user_points (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        point_id INTEGER NOT NULL,
        assigned_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (point_id) REFERENCES points (id),
        UNIQUE(user_id, point_id)
      )
    ''');

      await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        unit TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE shipping_lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        point_id INTEGER NOT NULL,
        shipping_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pendiente',
        total REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (point_id) REFERENCES points (id)
      )
    ''');

      await db.execute('''
      CREATE TABLE list_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (list_id) REFERENCES shipping_lists (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

      await db.execute('''
      CREATE TABLE drivers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        driver_id TEXT NOT NULL,
        phone TEXT NOT NULL,
        license_type TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE trucks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plate TEXT NOT NULL UNIQUE,
        model TEXT NOT NULL,
        brand TEXT NOT NULL,
        year INTEGER NOT NULL,
        capacity REAL NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE transport_info (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        driver_name TEXT NOT NULL,
        driver_id_text TEXT NOT NULL,
        truck_plate TEXT NOT NULL,
        truck_model TEXT NOT NULL,
        entry_time TEXT NOT NULL,
        exit_time TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        driver_id INTEGER,
        truck_id INTEGER,
        FOREIGN KEY (list_id) REFERENCES shipping_lists (id),
        FOREIGN KEY (driver_id) REFERENCES drivers (id),
        FOREIGN KEY (truck_id) REFERENCES trucks (id)
      )
    ''');

      await _insertInitialData(db);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _insertInitialData(Database db) async {
    try {
      final now = DateTime.now().toIso8601String();

      // Usar una contraseña simple para pruebas
      final plainPassword = '123456';
      final hashedPassword = _hashPassword(plainPassword);

      final proveedorId = await db.insert('users', {
        'email': 'proveedor@test.com',
        'password': hashedPassword,
        'name': 'Juan Pérez',
        'role': 'proveedor',
        'created_at': now,
      });

      final proveedor2Id = await db.insert('users', {
        'email': 'proveedor2@test.com',
        'password': hashedPassword,
        'name': 'Carlos López',
        'role': 'proveedor',
        'created_at': now,
      });

      await db.insert('users', {
        'email': 'supervisor@test.com',
        'password': hashedPassword,
        'name': 'María García',
        'role': 'supervisor',
        'created_at': now,
      });

      // Los 14 departamentos de El Salvador
      final pointsData = [
        {
          'name': 'Ahuachapán',
          'address': 'Departamento de Ahuachapán, El Salvador'
        },
        {
          'name': 'Santa Ana',
          'address': 'Departamento de Santa Ana, El Salvador'
        },
        {
          'name': 'Sonsonate',
          'address': 'Departamento de Sonsonate, El Salvador'
        },
        {
          'name': 'Chalatenango',
          'address': 'Departamento de Chalatenango, El Salvador'
        },
        {
          'name': 'La Libertad',
          'address': 'Departamento de La Libertad, El Salvador'
        },
        {
          'name': 'San Salvador',
          'address': 'Departamento de San Salvador, El Salvador'
        },
        {
          'name': 'Cuscatlán',
          'address': 'Departamento de Cuscatlán, El Salvador'
        },
        {'name': 'La Paz', 'address': 'Departamento de La Paz, El Salvador'},
        {'name': 'Cabañas', 'address': 'Departamento de Cabañas, El Salvador'},
        {
          'name': 'San Vicente',
          'address': 'Departamento de San Vicente, El Salvador'
        },
        {
          'name': 'Usulután',
          'address': 'Departamento de Usulután, El Salvador'
        },
        {
          'name': 'San Miguel',
          'address': 'Departamento de San Miguel, El Salvador'
        },
        {'name': 'Morazán', 'address': 'Departamento de Morazán, El Salvador'},
        {
          'name': 'La Unión',
          'address': 'Departamento de La Unión, El Salvador'
        },
      ];

      List<int> pointIds = [];
      for (var pointData in pointsData) {
        final pointId = await db.insert('points', {
          'name': pointData['name'],
          'address': pointData['address'],
          'is_active': 1,
          'created_at': now,
        });
        pointIds.add(pointId);
      }

      // Asignar puntos a los proveedores (distribuir equitativamente)
      // Proveedor 1 obtiene los primeros 7 departamentos
      for (int i = 0; i < 7; i++) {
        await db.insert('user_points', {
          'user_id': proveedorId,
          'point_id': pointIds[i],
          'assigned_at': now,
        });
      }

      // Proveedor 2 obtiene los últimos 7 departamentos
      for (int i = 7; i < pointIds.length; i++) {
        await db.insert('user_points', {
          'user_id': proveedor2Id,
          'point_id': pointIds[i],
          'assigned_at': now,
        });
      }

      final products = [
        {'name': 'Maíz', 'unit': 'Quintal'},
        {'name': 'Frijol', 'unit': 'Quintal'},
        {'name': 'Arroz', 'unit': 'Quintal'},
        {'name': 'Café', 'unit': 'Saco'},
        {'name': 'Azúcar', 'unit': 'Saco'},
        {'name': 'Trigo', 'unit': 'Quintal'},
        {'name': 'Sorgo', 'unit': 'Quintal'},
        {'name': 'Cebada', 'unit': 'Quintal'},
        {'name': 'Soya', 'unit': 'Quintal'},
        {'name': 'Algodón', 'unit': 'Kilogramo'},
      ];

      Map<String, int> productIds = {};
      for (Map<String, String> product in products) {
        final productId = await db.insert('products', {
          'name': product['name'],
          'unit': product['unit'],
          'is_active': 1,
          'created_at': now,
        });
        productIds[product['name']!] = productId;
      }

      // Insertar conductores
      final drivers = [
        {
          'name': 'Juan Pérez',
          'driver_id': 'DL12345',
          'phone': '7771234567',
          'license_type': 'A'
        },
        {
          'name': 'María López',
          'driver_id': 'DL67890',
          'phone': '7779876543',
          'license_type': 'B'
        },
        {
          'name': 'Carlos Rodríguez',
          'driver_id': 'DL11111',
          'phone': '7775551234',
          'license_type': 'C'
        },
        {
          'name': 'Ana García',
          'driver_id': 'DL22222',
          'phone': '7775559876',
          'license_type': 'A'
        },
        {
          'name': 'Luis Martínez',
          'driver_id': 'DL33333',
          'phone': '7775555555',
          'license_type': 'B'
        },
        {
          'name': 'Sofia Hernández',
          'driver_id': 'DL44444',
          'phone': '7775556666',
          'license_type': 'C'
        },
        {
          'name': 'Roberto Silva',
          'driver_id': 'DL55555',
          'phone': '7775557777',
          'license_type': 'A'
        },
        {
          'name': 'Patricia Morales',
          'driver_id': 'DL66666',
          'phone': '7775558888',
          'license_type': 'B'
        },
        {
          'name': 'Diego Vargas',
          'driver_id': 'DL77777',
          'phone': '7775559999',
          'license_type': 'C'
        },
        {
          'name': 'Elena Ramírez',
          'driver_id': 'DL88888',
          'phone': '7775550000',
          'license_type': 'A'
        },
        {
          'name': 'Fernando Castro',
          'driver_id': 'DL99999',
          'phone': '7775551111',
          'license_type': 'B'
        },
        {
          'name': 'Gabriela Torres',
          'driver_id': 'DL00000',
          'phone': '7775552222',
          'license_type': 'C'
        },
      ];

      for (var driver in drivers) {
        await db.insert('drivers', {
          'name': driver['name'],
          'driver_id': driver['driver_id'],
          'phone': driver['phone'],
          'license_type': driver['license_type'],
          'is_active': 1,
          'created_at': now,
        });
      }

      // Insertar camiones
      final trucks = [
        {
          'plate': 'ABC123',
          'model': 'Cargo 1000',
          'brand': 'Ford',
          'year': 2020,
          'capacity': 10.5
        },
        {
          'plate': 'XYZ789',
          'model': 'Master',
          'brand': 'Renault',
          'year': 2019,
          'capacity': 8.0
        },
        {
          'plate': 'DEF456',
          'model': 'Actros',
          'brand': 'Mercedes-Benz',
          'year': 2021,
          'capacity': 15.0
        },
        {
          'plate': 'GHI789',
          'model': 'FH',
          'brand': 'Volvo',
          'year': 2020,
          'capacity': 12.5
        },
        {
          'plate': 'JKL012',
          'model': 'TGX',
          'brand': 'MAN',
          'year': 2018,
          'capacity': 14.0
        },
        {
          'plate': 'MNO345',
          'model': 'Stralis',
          'brand': 'Iveco',
          'year': 2019,
          'capacity': 11.0
        },
        {
          'plate': 'PQR678',
          'model': 'Atego',
          'brand': 'Mercedes-Benz',
          'year': 2022,
          'capacity': 9.5
        },
        {
          'plate': 'STU901',
          'model': 'Daily',
          'brand': 'Iveco',
          'year': 2021,
          'capacity': 7.0
        },
        {
          'plate': 'VWX234',
          'model': 'Cascadia',
          'brand': 'Freightliner',
          'year': 2020,
          'capacity': 16.0
        },
        {
          'plate': 'HIJ567',
          'model': 'Sprinter',
          'brand': 'Mercedes-Benz',
          'year': 2023,
          'capacity': 6.5
        },
        {
          'plate': 'KLM890',
          'model': 'Transit',
          'brand': 'Ford',
          'year': 2022,
          'capacity': 5.0
        },
        {
          'plate': 'NOP123',
          'model': 'Boxer',
          'brand': 'Peugeot',
          'year': 2021,
          'capacity': 4.5
        },
      ];

      for (var truck in trucks) {
        await db.insert('trucks', {
          'plate': truck['plate'],
          'model': truck['model'],
          'brand': truck['brand'],
          'year': truck['year'],
          'capacity': truck['capacity'],
          'is_active': 1,
          'created_at': now,
        });
      }

      // Crear dos listas precargadas

      // Lista 1 - Para el proveedor 1 en Ahuachapán
      final shippingDate1 = DateTime.now().add(const Duration(days: 3));
      final list1Id = await db.insert('shipping_lists', {
        'user_id': proveedorId,
        'point_id': pointIds[0], // Ahuachapán
        'shipping_date': shippingDate1.toIso8601String(),
        'status': 'pendiente',
        'total': 0.0, // Se actualizará después
        'created_at': now,
      });

      // Productos para la lista 1
      final list1Items = [
        {'product': 'Maíz', 'price': 25.50, 'quantity': 10},
        {'product': 'Frijol', 'price': 45.75, 'quantity': 5},
        {'product': 'Arroz', 'price': 30.00, 'quantity': 8},
      ];

      double total1 = 0.0;
      for (var item in list1Items) {
        final productId = productIds[item['product']];
        final price = item['price'] as double;
        final quantity = item['quantity'] as int;
        final subtotal = price * quantity;
        total1 += subtotal;

        await db.insert('list_items', {
          'list_id': list1Id,
          'product_id': productId,
          'price': price,
          'quantity': quantity,
          'subtotal': subtotal,
        });
      }

      // Actualizar el total de la lista 1
      await db.update(
        'shipping_lists',
        {'total': total1},
        where: 'id = ?',
        whereArgs: [list1Id],
      );

      // Lista 2 - Para el proveedor 2 en San Miguel
      final shippingDate2 = DateTime.now().add(const Duration(days: 5));
      final list2Id = await db.insert('shipping_lists', {
        'user_id': proveedor2Id,
        'point_id': pointIds[11], // San Miguel
        'shipping_date': shippingDate2.toIso8601String(),
        'status': 'en_proceso',
        'total': 0.0, // Se actualizará después
        'created_at': now,
      });

      // Productos para la lista 2
      final list2Items = [
        {'product': 'Café', 'price': 120.00, 'quantity': 3},
        {'product': 'Azúcar', 'price': 35.50, 'quantity': 7},
        {'product': 'Trigo', 'price': 28.75, 'quantity': 12},
        {'product': 'Soya', 'price': 42.25, 'quantity': 4},
      ];

      double total2 = 0.0;
      for (var item in list2Items) {
        final productId = productIds[item['product']];
        final price = item['price'] as double;
        final quantity = item['quantity'] as int;
        final subtotal = price * quantity;
        total2 += subtotal;

        await db.insert('list_items', {
          'list_id': list2Id,
          'product_id': productId,
          'price': price,
          'quantity': quantity,
          'subtotal': subtotal,
        });
      }

      // Actualizar el total de la lista 2
      await db.update(
        'shipping_lists',
        {'total': total2},
        where: 'id = ?',
        whereArgs: [list2Id],
      );

      // Asignar transporte a la lista 2
      await db.insert('transport_info', {
        'list_id': list2Id,
        'driver_name': 'Juan Pérez',
        'driver_id_text': 'DL12345',
        'truck_plate': 'ABC123',
        'truck_model': 'Ford Cargo 1000',
        'entry_time': '08:30',
        'created_at': now,
        'driver_id': 1,
        'truck_id': 1,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _assignPointsToExistingUsers(Database db) async {
    try {
      final now = DateTime.now().toIso8601String();

      final users =
          await db.query('users', where: 'role = ?', whereArgs: ['proveedor']);
      final points =
          await db.query('points', where: 'is_active = ?', whereArgs: [1]);

      if (users.isNotEmpty && points.isNotEmpty) {
        for (int i = 0; i < users.length; i++) {
          final userId = users[i]['id'] as int;
          final pointsPerUser = (points.length / users.length).ceil();
          final startIndex = i * pointsPerUser;
          final endIndex = ((i + 1) * pointsPerUser).clamp(0, points.length);

          for (int j = startIndex; j < endIndex; j++) {
            final pointId = points[j]['id'] as int;
            try {
              await db.insert('user_points', {
                'user_id': userId,
                'point_id': pointId,
                'assigned_at': now,
              });
            } catch (e) {
              print('Point already assigned: $e');
            }
          }
        }
      }
    } catch (e) {
      print('Error assigning points to existing users: $e');
    }
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Métodos para usuarios
  Future<User?> authenticateUser(String email, String password) async {
    try {
      final db = await database;
      final hashedPassword = _hashPassword(password);

      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, hashedPassword],
      );

      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error authenticating user: $e');
      return null;
    }
  }

  Future<int> insertUser(User user) async {
    try {
      final db = await database;
      final userMap = user.toMap();
      userMap['password'] = _hashPassword(userMap['password']);
      return await db.insert('users', userMap);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('users');
      return List.generate(maps.length, (i) => User.fromMap(maps[i]));
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  // Métodos para puntos
  Future<List<Point>> getAllPoints() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'points',
        where: 'is_active = ?',
        whereArgs: [1],
      );
      return List.generate(maps.length, (i) => Point.fromMap(maps[i]));
    } catch (e) {
      print('Error getting all points: $e');
      return [];
    }
  }

  Future<List<Point>> getPointsByUserId(int userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT p.* FROM points p
        INNER JOIN user_points up ON p.id = up.point_id
        WHERE up.user_id = ? AND p.is_active = 1
        ORDER BY p.name
      ''', [userId]);

      return List.generate(maps.length, (i) => Point.fromMap(maps[i]));
    } catch (e) {
      print('Error getting points by user id: $e');
      return [];
    }
  }

  Future<Point?> getPointById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'points',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Point.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<int> insertPoint(Point point) async {
    try {
      final db = await database;
      return await db.insert('points', point.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Métodos para asignación de puntos a usuarios
  Future<void> assignPointToUser(int userId, int pointId) async {
    try {
      final db = await database;
      await db.insert('user_points', {
        'user_id': userId,
        'point_id': pointId,
        'assigned_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removePointFromUser(int userId, int pointId) async {
    try {
      final db = await database;
      await db.delete(
        'user_points',
        where: 'user_id = ? AND point_id = ?',
        whereArgs: [userId, pointId],
      );
    } catch (e) {
      rethrow;
    }
  }

  // Métodos para productos
  Future<List<Product>> getAllProducts() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: 'name',
      );
      return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
    } catch (e) {
      print('Error getting all products: $e');
      return [];
    }
  }

  Future<Product?> getProductByName(String name) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'name = ? AND is_active = ?',
        whereArgs: [name, 1],
      );

      if (maps.isNotEmpty) {
        return Product.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting product by name: $e');
      return null;
    }
  }

  // Métodos para listas de envío
  Future<List<Map<String, dynamic>>> getAllShippingListsWithDetails() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT
          sl.*,
          u.name as user_name,
          u.email as user_email,
          p.name as point_name,
          p.address as point_address,
          COUNT(li.id) as items_count
        FROM shipping_lists sl
        LEFT JOIN users u ON sl.user_id = u.id
        LEFT JOIN points p ON sl.point_id = p.id
        LEFT JOIN list_items li ON sl.id = li.list_id
        GROUP BY sl.id
        ORDER BY sl.created_at DESC
      ''');
      return maps;
    } catch (e) {
      print('Error getting all shipping lists: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getShippingListsByUser(int userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT
          sl.*,
          p.name as point_name,
          p.address as point_address,
          COUNT(li.id) as items_count
        FROM shipping_lists sl
        LEFT JOIN points p ON sl.point_id = p.id
        LEFT JOIN list_items li ON sl.id = li.list_id
        WHERE sl.user_id = ?
        GROUP BY sl.id
        ORDER BY sl.created_at DESC
      ''', [userId]);
      return maps;
    } catch (e) {
      print('Error getting shipping lists by user: $e');
      return [];
    }
  }

  Future<int> insertShippingList(ShippingList shippingList) async {
    try {
      final db = await database;
      return await db.insert('shipping_lists', shippingList.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateShippingListTotal(int listId, double total) async {
    try {
      final db = await database;
      await db.update(
        'shipping_lists',
        {'total': total},
        where: 'id = ?',
        whereArgs: [listId],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateShippingListStatus(int listId, String status) async {
    try {
      final db = await database;
      await db.update(
        'shipping_lists',
        {'status': status},
        where: 'id = ?',
        whereArgs: [listId],
      );
    } catch (e) {
      rethrow;
    }
  }

  // Métodos para items de lista
  Future<List<Map<String, dynamic>>> getListItemsWithProductDetails(
      int listId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT
          li.*,
          p.name as product_name,
          p.unit as product_unit
        FROM list_items li
        LEFT JOIN products p ON li.product_id = p.id
        WHERE li.list_id = ?
        ORDER BY li.id
      ''', [listId]);
      return maps;
    } catch (e) {
      print('Error getting list items: $e');
      return [];
    }
  }

  Future<int> insertListItem(ListItem listItem) async {
    try {
      final db = await database;
      final itemId = await db.insert('list_items', listItem.toMap());

      // Actualizar el total de la lista
      await _updateListTotal(listItem.listId);

      return itemId;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteListItem(int id) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query(
        'list_items',
        columns: ['list_id'],
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final listId = maps.first['list_id'] as int;

        await db.delete('list_items', where: 'id = ?', whereArgs: [id]);

        await _updateListTotal(listId);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _updateListTotal(int listId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT SUM(subtotal) as total
      FROM list_items
      WHERE list_id = ?
    ''', [listId]);

      final total = maps.first['total'] ?? 0.0;
      await db.update(
        'shipping_lists',
        {'total': total.toDouble()},
        where: 'id = ?',
        whereArgs: [listId],
      );
    } catch (e) {
      print('Error updating list total: $e');
    }
  }

// Método público para recalcular el total de una lista
  Future<void> recalculateListTotal(int listId) async {
    await _updateListTotal(listId);
  }

// Agregar métodos para conductores
  Future<List<Driver>> getAllDrivers() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'drivers',
        orderBy: 'name',
      );
      return List.generate(maps.length, (i) => Driver.fromMap(maps[i]));
    } catch (e) {
      print('Error getting all drivers: $e');
      return [];
    }
  }

  Future<Driver?> getDriverById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'drivers',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Driver.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting driver by id: $e');
      return null;
    }
  }

  Future<int> insertDriver(Driver driver) async {
    try {
      final db = await database;
      return await db.insert('drivers', driver.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateDriver(Driver driver) async {
    try {
      final db = await database;
      return await db.update(
        'drivers',
        driver.toMap(),
        where: 'id = ?',
        whereArgs: [driver.id],
      );
    } catch (e) {
      rethrow;
    }
  }

// Agregar métodos para camiones
  Future<List<Truck>> getAllTrucks() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'trucks',
        orderBy: 'plate',
      );
      return List.generate(maps.length, (i) => Truck.fromMap(maps[i]));
    } catch (e) {
      print('Error getting all trucks: $e');
      return [];
    }
  }

  Future<Truck?> getTruckById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'trucks',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Truck.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting truck by id: $e');
      return null;
    }
  }

  Future<int> insertTruck(Truck truck) async {
    try {
      final db = await database;
      return await db.insert('trucks', truck.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateTruck(Truck truck) async {
    try {
      final db = await database;
      return await db.update(
        'trucks',
        truck.toMap(),
        where: 'id = ?',
        whereArgs: [truck.id],
      );
    } catch (e) {
      rethrow;
    }
  }

// Actualizar métodos para información de transporte
  Future<int> insertTransportInfo(TransportInfo transportInfo) async {
    try {
      final db = await database;
      return await db.insert('transport_info', transportInfo.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<TransportInfo?> getTransportInfoByListId(int listId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transport_info',
        where: 'list_id = ?',
        whereArgs: [listId],
      );

      if (maps.isNotEmpty) {
        return TransportInfo.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting transport info by list id: $e');
      return null;
    }
  }

  Future<int> updateTransportInfo(TransportInfo transportInfo) async {
    try {
      final db = await database;
      return await db.update(
        'transport_info',
        transportInfo.toMap(),
        where: 'id = ?',
        whereArgs: [transportInfo.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  // Método para reiniciar la base de datos (solo para desarrollo)
  Future<void> resetDatabase() async {
    try {
      // Cerrar la conexión actual si existe
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Eliminar el archivo de la base de datos
      String path = join(await getDatabasesPath(), 'logitruck.db');
      await deleteDatabase(path);

      // Recrear la base de datos
      _database = await _initDatabase();

      print('Base de datos reiniciada correctamente');
    } catch (e) {
      print('Error al reiniciar la base de datos: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
