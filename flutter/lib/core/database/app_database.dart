import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ── Tables ──────────────────────────────────────────────────

class Clientes extends Table {
  TextColumn get id => text()();
  TextColumn get empresaId => text()();
  TextColumn get nombre => text()();
  TextColumn get telefono => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get documento => text().nullable()();
  TextColumn get fotoUrl => text().nullable()();
  TextColumn get estado => text().withDefault(const Constant('ACTIVO'))();
  DateTimeColumn get creadoAt => dateTime().nullable()();

  // Offline sync metadata
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSynced => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Membresias extends Table {
  TextColumn get id => text()();
  TextColumn get clienteId => text()();
  TextColumn get sucursalId => text()();
  TextColumn get planId => text()();
  DateTimeColumn get inicio => dateTime()();
  DateTimeColumn get fin => dateTime()();
  TextColumn get estado => text().withDefault(const Constant('ACTIVA'))();
  IntColumn get visitasRestantes => integer().nullable()();
  TextColumn get observaciones => text().nullable()();

  // Offline sync metadata
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Productos extends Table {
  TextColumn get id => text()();
  TextColumn get empresaId => text()();
  TextColumn get nombre => text()();
  TextColumn get categoria => text().nullable()();
  IntColumn get precioCentavos => integer()();
  IntColumn get costoCentavos => integer().withDefault(const Constant(0))();
  TextColumn get estado => text().withDefault(const Constant('ACTIVO'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Inventarios extends Table {
  TextColumn get sucursalId => text()();
  TextColumn get productoId => text()();
  RealColumn get existencia => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {sucursalId, productoId};
}

class SyncLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get action => text()(); // CREATE, UPDATE, DELETE
  TextColumn get entity => text()(); // CLIENTE, MEMBRESIA, etc.
  TextColumn get entityId => text()();
  TextColumn get payload => text()(); // JSON string of the change
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ── Database ────────────────────────────────────────────────

@DriftDatabase(tables: [Clientes, Membresias, Productos, Inventarios, SyncLog])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'gym_pro.sqlite'));
      return NativeDatabase(file);
    });
  }
}
