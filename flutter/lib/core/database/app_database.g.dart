// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ClientesTable extends Clientes with TableInfo<$ClientesTable, Cliente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _empresaIdMeta = const VerificationMeta(
    'empresaId',
  );
  @override
  late final GeneratedColumn<String> empresaId = GeneratedColumn<String>(
    'empresa_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _telefonoMeta = const VerificationMeta(
    'telefono',
  );
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
    'telefono',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _documentoMeta = const VerificationMeta(
    'documento',
  );
  @override
  late final GeneratedColumn<String> documento = GeneratedColumn<String>(
    'documento',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoUrlMeta = const VerificationMeta(
    'fotoUrl',
  );
  @override
  late final GeneratedColumn<String> fotoUrl = GeneratedColumn<String>(
    'foto_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ACTIVO'),
  );
  static const VerificationMeta _creadoAtMeta = const VerificationMeta(
    'creadoAt',
  );
  @override
  late final GeneratedColumn<DateTime> creadoAt = GeneratedColumn<DateTime>(
    'creado_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastSyncedMeta = const VerificationMeta(
    'lastSynced',
  );
  @override
  late final GeneratedColumn<DateTime> lastSynced = GeneratedColumn<DateTime>(
    'last_synced',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    empresaId,
    nombre,
    telefono,
    email,
    documento,
    fotoUrl,
    estado,
    creadoAt,
    isDirty,
    lastSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clientes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cliente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('empresa_id')) {
      context.handle(
        _empresaIdMeta,
        empresaId.isAcceptableOrUnknown(data['empresa_id']!, _empresaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_empresaIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('documento')) {
      context.handle(
        _documentoMeta,
        documento.isAcceptableOrUnknown(data['documento']!, _documentoMeta),
      );
    }
    if (data.containsKey('foto_url')) {
      context.handle(
        _fotoUrlMeta,
        fotoUrl.isAcceptableOrUnknown(data['foto_url']!, _fotoUrlMeta),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('creado_at')) {
      context.handle(
        _creadoAtMeta,
        creadoAt.isAcceptableOrUnknown(data['creado_at']!, _creadoAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('last_synced')) {
      context.handle(
        _lastSyncedMeta,
        lastSynced.isAcceptableOrUnknown(data['last_synced']!, _lastSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cliente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cliente(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      empresaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}empresa_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      documento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}documento'],
      ),
      fotoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_url'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      creadoAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
      lastSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced'],
      ),
    );
  }

  @override
  $ClientesTable createAlias(String alias) {
    return $ClientesTable(attachedDatabase, alias);
  }
}

class Cliente extends DataClass implements Insertable<Cliente> {
  final String id;
  final String empresaId;
  final String nombre;
  final String? telefono;
  final String? email;
  final String? documento;
  final String? fotoUrl;
  final String estado;
  final DateTime? creadoAt;
  final bool isDirty;
  final DateTime? lastSynced;
  const Cliente({
    required this.id,
    required this.empresaId,
    required this.nombre,
    this.telefono,
    this.email,
    this.documento,
    this.fotoUrl,
    required this.estado,
    this.creadoAt,
    required this.isDirty,
    this.lastSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['empresa_id'] = Variable<String>(empresaId);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || documento != null) {
      map['documento'] = Variable<String>(documento);
    }
    if (!nullToAbsent || fotoUrl != null) {
      map['foto_url'] = Variable<String>(fotoUrl);
    }
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || creadoAt != null) {
      map['creado_at'] = Variable<DateTime>(creadoAt);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    if (!nullToAbsent || lastSynced != null) {
      map['last_synced'] = Variable<DateTime>(lastSynced);
    }
    return map;
  }

  ClientesCompanion toCompanion(bool nullToAbsent) {
    return ClientesCompanion(
      id: Value(id),
      empresaId: Value(empresaId),
      nombre: Value(nombre),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      documento: documento == null && nullToAbsent
          ? const Value.absent()
          : Value(documento),
      fotoUrl: fotoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoUrl),
      estado: Value(estado),
      creadoAt: creadoAt == null && nullToAbsent
          ? const Value.absent()
          : Value(creadoAt),
      isDirty: Value(isDirty),
      lastSynced: lastSynced == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSynced),
    );
  }

  factory Cliente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cliente(
      id: serializer.fromJson<String>(json['id']),
      empresaId: serializer.fromJson<String>(json['empresaId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      email: serializer.fromJson<String?>(json['email']),
      documento: serializer.fromJson<String?>(json['documento']),
      fotoUrl: serializer.fromJson<String?>(json['fotoUrl']),
      estado: serializer.fromJson<String>(json['estado']),
      creadoAt: serializer.fromJson<DateTime?>(json['creadoAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      lastSynced: serializer.fromJson<DateTime?>(json['lastSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'empresaId': serializer.toJson<String>(empresaId),
      'nombre': serializer.toJson<String>(nombre),
      'telefono': serializer.toJson<String?>(telefono),
      'email': serializer.toJson<String?>(email),
      'documento': serializer.toJson<String?>(documento),
      'fotoUrl': serializer.toJson<String?>(fotoUrl),
      'estado': serializer.toJson<String>(estado),
      'creadoAt': serializer.toJson<DateTime?>(creadoAt),
      'isDirty': serializer.toJson<bool>(isDirty),
      'lastSynced': serializer.toJson<DateTime?>(lastSynced),
    };
  }

  Cliente copyWith({
    String? id,
    String? empresaId,
    String? nombre,
    Value<String?> telefono = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> documento = const Value.absent(),
    Value<String?> fotoUrl = const Value.absent(),
    String? estado,
    Value<DateTime?> creadoAt = const Value.absent(),
    bool? isDirty,
    Value<DateTime?> lastSynced = const Value.absent(),
  }) => Cliente(
    id: id ?? this.id,
    empresaId: empresaId ?? this.empresaId,
    nombre: nombre ?? this.nombre,
    telefono: telefono.present ? telefono.value : this.telefono,
    email: email.present ? email.value : this.email,
    documento: documento.present ? documento.value : this.documento,
    fotoUrl: fotoUrl.present ? fotoUrl.value : this.fotoUrl,
    estado: estado ?? this.estado,
    creadoAt: creadoAt.present ? creadoAt.value : this.creadoAt,
    isDirty: isDirty ?? this.isDirty,
    lastSynced: lastSynced.present ? lastSynced.value : this.lastSynced,
  );
  Cliente copyWithCompanion(ClientesCompanion data) {
    return Cliente(
      id: data.id.present ? data.id.value : this.id,
      empresaId: data.empresaId.present ? data.empresaId.value : this.empresaId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      email: data.email.present ? data.email.value : this.email,
      documento: data.documento.present ? data.documento.value : this.documento,
      fotoUrl: data.fotoUrl.present ? data.fotoUrl.value : this.fotoUrl,
      estado: data.estado.present ? data.estado.value : this.estado,
      creadoAt: data.creadoAt.present ? data.creadoAt.value : this.creadoAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      lastSynced: data.lastSynced.present
          ? data.lastSynced.value
          : this.lastSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cliente(')
          ..write('id: $id, ')
          ..write('empresaId: $empresaId, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('email: $email, ')
          ..write('documento: $documento, ')
          ..write('fotoUrl: $fotoUrl, ')
          ..write('estado: $estado, ')
          ..write('creadoAt: $creadoAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('lastSynced: $lastSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    empresaId,
    nombre,
    telefono,
    email,
    documento,
    fotoUrl,
    estado,
    creadoAt,
    isDirty,
    lastSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cliente &&
          other.id == this.id &&
          other.empresaId == this.empresaId &&
          other.nombre == this.nombre &&
          other.telefono == this.telefono &&
          other.email == this.email &&
          other.documento == this.documento &&
          other.fotoUrl == this.fotoUrl &&
          other.estado == this.estado &&
          other.creadoAt == this.creadoAt &&
          other.isDirty == this.isDirty &&
          other.lastSynced == this.lastSynced);
}

class ClientesCompanion extends UpdateCompanion<Cliente> {
  final Value<String> id;
  final Value<String> empresaId;
  final Value<String> nombre;
  final Value<String?> telefono;
  final Value<String?> email;
  final Value<String?> documento;
  final Value<String?> fotoUrl;
  final Value<String> estado;
  final Value<DateTime?> creadoAt;
  final Value<bool> isDirty;
  final Value<DateTime?> lastSynced;
  final Value<int> rowid;
  const ClientesCompanion({
    this.id = const Value.absent(),
    this.empresaId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.telefono = const Value.absent(),
    this.email = const Value.absent(),
    this.documento = const Value.absent(),
    this.fotoUrl = const Value.absent(),
    this.estado = const Value.absent(),
    this.creadoAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.lastSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientesCompanion.insert({
    required String id,
    required String empresaId,
    required String nombre,
    this.telefono = const Value.absent(),
    this.email = const Value.absent(),
    this.documento = const Value.absent(),
    this.fotoUrl = const Value.absent(),
    this.estado = const Value.absent(),
    this.creadoAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.lastSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       empresaId = Value(empresaId),
       nombre = Value(nombre);
  static Insertable<Cliente> custom({
    Expression<String>? id,
    Expression<String>? empresaId,
    Expression<String>? nombre,
    Expression<String>? telefono,
    Expression<String>? email,
    Expression<String>? documento,
    Expression<String>? fotoUrl,
    Expression<String>? estado,
    Expression<DateTime>? creadoAt,
    Expression<bool>? isDirty,
    Expression<DateTime>? lastSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (empresaId != null) 'empresa_id': empresaId,
      if (nombre != null) 'nombre': nombre,
      if (telefono != null) 'telefono': telefono,
      if (email != null) 'email': email,
      if (documento != null) 'documento': documento,
      if (fotoUrl != null) 'foto_url': fotoUrl,
      if (estado != null) 'estado': estado,
      if (creadoAt != null) 'creado_at': creadoAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (lastSynced != null) 'last_synced': lastSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientesCompanion copyWith({
    Value<String>? id,
    Value<String>? empresaId,
    Value<String>? nombre,
    Value<String?>? telefono,
    Value<String?>? email,
    Value<String?>? documento,
    Value<String?>? fotoUrl,
    Value<String>? estado,
    Value<DateTime?>? creadoAt,
    Value<bool>? isDirty,
    Value<DateTime?>? lastSynced,
    Value<int>? rowid,
  }) {
    return ClientesCompanion(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      documento: documento ?? this.documento,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      estado: estado ?? this.estado,
      creadoAt: creadoAt ?? this.creadoAt,
      isDirty: isDirty ?? this.isDirty,
      lastSynced: lastSynced ?? this.lastSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (empresaId.present) {
      map['empresa_id'] = Variable<String>(empresaId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (documento.present) {
      map['documento'] = Variable<String>(documento.value);
    }
    if (fotoUrl.present) {
      map['foto_url'] = Variable<String>(fotoUrl.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (creadoAt.present) {
      map['creado_at'] = Variable<DateTime>(creadoAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (lastSynced.present) {
      map['last_synced'] = Variable<DateTime>(lastSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientesCompanion(')
          ..write('id: $id, ')
          ..write('empresaId: $empresaId, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('email: $email, ')
          ..write('documento: $documento, ')
          ..write('fotoUrl: $fotoUrl, ')
          ..write('estado: $estado, ')
          ..write('creadoAt: $creadoAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('lastSynced: $lastSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembresiasTable extends Membresias
    with TableInfo<$MembresiasTable, Membresia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembresiasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<String> clienteId = GeneratedColumn<String>(
    'cliente_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sucursalIdMeta = const VerificationMeta(
    'sucursalId',
  );
  @override
  late final GeneratedColumn<String> sucursalId = GeneratedColumn<String>(
    'sucursal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inicioMeta = const VerificationMeta('inicio');
  @override
  late final GeneratedColumn<DateTime> inicio = GeneratedColumn<DateTime>(
    'inicio',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finMeta = const VerificationMeta('fin');
  @override
  late final GeneratedColumn<DateTime> fin = GeneratedColumn<DateTime>(
    'fin',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ACTIVA'),
  );
  static const VerificationMeta _visitasRestantesMeta = const VerificationMeta(
    'visitasRestantes',
  );
  @override
  late final GeneratedColumn<int> visitasRestantes = GeneratedColumn<int>(
    'visitas_restantes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observacionesMeta = const VerificationMeta(
    'observaciones',
  );
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
    'observaciones',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clienteId,
    sucursalId,
    planId,
    inicio,
    fin,
    estado,
    visitasRestantes,
    observaciones,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'membresias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Membresia> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clienteIdMeta);
    }
    if (data.containsKey('sucursal_id')) {
      context.handle(
        _sucursalIdMeta,
        sucursalId.isAcceptableOrUnknown(data['sucursal_id']!, _sucursalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sucursalIdMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('inicio')) {
      context.handle(
        _inicioMeta,
        inicio.isAcceptableOrUnknown(data['inicio']!, _inicioMeta),
      );
    } else if (isInserting) {
      context.missing(_inicioMeta);
    }
    if (data.containsKey('fin')) {
      context.handle(
        _finMeta,
        fin.isAcceptableOrUnknown(data['fin']!, _finMeta),
      );
    } else if (isInserting) {
      context.missing(_finMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('visitas_restantes')) {
      context.handle(
        _visitasRestantesMeta,
        visitasRestantes.isAcceptableOrUnknown(
          data['visitas_restantes']!,
          _visitasRestantesMeta,
        ),
      );
    }
    if (data.containsKey('observaciones')) {
      context.handle(
        _observacionesMeta,
        observaciones.isAcceptableOrUnknown(
          data['observaciones']!,
          _observacionesMeta,
        ),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Membresia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Membresia(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cliente_id'],
      )!,
      sucursalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sucursal_id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      )!,
      inicio: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}inicio'],
      )!,
      fin: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fin'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      visitasRestantes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}visitas_restantes'],
      ),
      observaciones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observaciones'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_dirty'],
      )!,
    );
  }

  @override
  $MembresiasTable createAlias(String alias) {
    return $MembresiasTable(attachedDatabase, alias);
  }
}

class Membresia extends DataClass implements Insertable<Membresia> {
  final String id;
  final String clienteId;
  final String sucursalId;
  final String planId;
  final DateTime inicio;
  final DateTime fin;
  final String estado;
  final int? visitasRestantes;
  final String? observaciones;
  final bool isDirty;
  const Membresia({
    required this.id,
    required this.clienteId,
    required this.sucursalId,
    required this.planId,
    required this.inicio,
    required this.fin,
    required this.estado,
    this.visitasRestantes,
    this.observaciones,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cliente_id'] = Variable<String>(clienteId);
    map['sucursal_id'] = Variable<String>(sucursalId);
    map['plan_id'] = Variable<String>(planId);
    map['inicio'] = Variable<DateTime>(inicio);
    map['fin'] = Variable<DateTime>(fin);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || visitasRestantes != null) {
      map['visitas_restantes'] = Variable<int>(visitasRestantes);
    }
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  MembresiasCompanion toCompanion(bool nullToAbsent) {
    return MembresiasCompanion(
      id: Value(id),
      clienteId: Value(clienteId),
      sucursalId: Value(sucursalId),
      planId: Value(planId),
      inicio: Value(inicio),
      fin: Value(fin),
      estado: Value(estado),
      visitasRestantes: visitasRestantes == null && nullToAbsent
          ? const Value.absent()
          : Value(visitasRestantes),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      isDirty: Value(isDirty),
    );
  }

  factory Membresia.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Membresia(
      id: serializer.fromJson<String>(json['id']),
      clienteId: serializer.fromJson<String>(json['clienteId']),
      sucursalId: serializer.fromJson<String>(json['sucursalId']),
      planId: serializer.fromJson<String>(json['planId']),
      inicio: serializer.fromJson<DateTime>(json['inicio']),
      fin: serializer.fromJson<DateTime>(json['fin']),
      estado: serializer.fromJson<String>(json['estado']),
      visitasRestantes: serializer.fromJson<int?>(json['visitasRestantes']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clienteId': serializer.toJson<String>(clienteId),
      'sucursalId': serializer.toJson<String>(sucursalId),
      'planId': serializer.toJson<String>(planId),
      'inicio': serializer.toJson<DateTime>(inicio),
      'fin': serializer.toJson<DateTime>(fin),
      'estado': serializer.toJson<String>(estado),
      'visitasRestantes': serializer.toJson<int?>(visitasRestantes),
      'observaciones': serializer.toJson<String?>(observaciones),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  Membresia copyWith({
    String? id,
    String? clienteId,
    String? sucursalId,
    String? planId,
    DateTime? inicio,
    DateTime? fin,
    String? estado,
    Value<int?> visitasRestantes = const Value.absent(),
    Value<String?> observaciones = const Value.absent(),
    bool? isDirty,
  }) => Membresia(
    id: id ?? this.id,
    clienteId: clienteId ?? this.clienteId,
    sucursalId: sucursalId ?? this.sucursalId,
    planId: planId ?? this.planId,
    inicio: inicio ?? this.inicio,
    fin: fin ?? this.fin,
    estado: estado ?? this.estado,
    visitasRestantes: visitasRestantes.present
        ? visitasRestantes.value
        : this.visitasRestantes,
    observaciones: observaciones.present
        ? observaciones.value
        : this.observaciones,
    isDirty: isDirty ?? this.isDirty,
  );
  Membresia copyWithCompanion(MembresiasCompanion data) {
    return Membresia(
      id: data.id.present ? data.id.value : this.id,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      sucursalId: data.sucursalId.present
          ? data.sucursalId.value
          : this.sucursalId,
      planId: data.planId.present ? data.planId.value : this.planId,
      inicio: data.inicio.present ? data.inicio.value : this.inicio,
      fin: data.fin.present ? data.fin.value : this.fin,
      estado: data.estado.present ? data.estado.value : this.estado,
      visitasRestantes: data.visitasRestantes.present
          ? data.visitasRestantes.value
          : this.visitasRestantes,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Membresia(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('sucursalId: $sucursalId, ')
          ..write('planId: $planId, ')
          ..write('inicio: $inicio, ')
          ..write('fin: $fin, ')
          ..write('estado: $estado, ')
          ..write('visitasRestantes: $visitasRestantes, ')
          ..write('observaciones: $observaciones, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clienteId,
    sucursalId,
    planId,
    inicio,
    fin,
    estado,
    visitasRestantes,
    observaciones,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Membresia &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.sucursalId == this.sucursalId &&
          other.planId == this.planId &&
          other.inicio == this.inicio &&
          other.fin == this.fin &&
          other.estado == this.estado &&
          other.visitasRestantes == this.visitasRestantes &&
          other.observaciones == this.observaciones &&
          other.isDirty == this.isDirty);
}

class MembresiasCompanion extends UpdateCompanion<Membresia> {
  final Value<String> id;
  final Value<String> clienteId;
  final Value<String> sucursalId;
  final Value<String> planId;
  final Value<DateTime> inicio;
  final Value<DateTime> fin;
  final Value<String> estado;
  final Value<int?> visitasRestantes;
  final Value<String?> observaciones;
  final Value<bool> isDirty;
  final Value<int> rowid;
  const MembresiasCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.sucursalId = const Value.absent(),
    this.planId = const Value.absent(),
    this.inicio = const Value.absent(),
    this.fin = const Value.absent(),
    this.estado = const Value.absent(),
    this.visitasRestantes = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembresiasCompanion.insert({
    required String id,
    required String clienteId,
    required String sucursalId,
    required String planId,
    required DateTime inicio,
    required DateTime fin,
    this.estado = const Value.absent(),
    this.visitasRestantes = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       clienteId = Value(clienteId),
       sucursalId = Value(sucursalId),
       planId = Value(planId),
       inicio = Value(inicio),
       fin = Value(fin);
  static Insertable<Membresia> custom({
    Expression<String>? id,
    Expression<String>? clienteId,
    Expression<String>? sucursalId,
    Expression<String>? planId,
    Expression<DateTime>? inicio,
    Expression<DateTime>? fin,
    Expression<String>? estado,
    Expression<int>? visitasRestantes,
    Expression<String>? observaciones,
    Expression<bool>? isDirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (sucursalId != null) 'sucursal_id': sucursalId,
      if (planId != null) 'plan_id': planId,
      if (inicio != null) 'inicio': inicio,
      if (fin != null) 'fin': fin,
      if (estado != null) 'estado': estado,
      if (visitasRestantes != null) 'visitas_restantes': visitasRestantes,
      if (observaciones != null) 'observaciones': observaciones,
      if (isDirty != null) 'is_dirty': isDirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembresiasCompanion copyWith({
    Value<String>? id,
    Value<String>? clienteId,
    Value<String>? sucursalId,
    Value<String>? planId,
    Value<DateTime>? inicio,
    Value<DateTime>? fin,
    Value<String>? estado,
    Value<int?>? visitasRestantes,
    Value<String?>? observaciones,
    Value<bool>? isDirty,
    Value<int>? rowid,
  }) {
    return MembresiasCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      sucursalId: sucursalId ?? this.sucursalId,
      planId: planId ?? this.planId,
      inicio: inicio ?? this.inicio,
      fin: fin ?? this.fin,
      estado: estado ?? this.estado,
      visitasRestantes: visitasRestantes ?? this.visitasRestantes,
      observaciones: observaciones ?? this.observaciones,
      isDirty: isDirty ?? this.isDirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<String>(clienteId.value);
    }
    if (sucursalId.present) {
      map['sucursal_id'] = Variable<String>(sucursalId.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (inicio.present) {
      map['inicio'] = Variable<DateTime>(inicio.value);
    }
    if (fin.present) {
      map['fin'] = Variable<DateTime>(fin.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (visitasRestantes.present) {
      map['visitas_restantes'] = Variable<int>(visitasRestantes.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembresiasCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('sucursalId: $sucursalId, ')
          ..write('planId: $planId, ')
          ..write('inicio: $inicio, ')
          ..write('fin: $fin, ')
          ..write('estado: $estado, ')
          ..write('visitasRestantes: $visitasRestantes, ')
          ..write('observaciones: $observaciones, ')
          ..write('isDirty: $isDirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductosTable extends Productos
    with TableInfo<$ProductosTable, Producto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _empresaIdMeta = const VerificationMeta(
    'empresaId',
  );
  @override
  late final GeneratedColumn<String> empresaId = GeneratedColumn<String>(
    'empresa_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _precioCentavosMeta = const VerificationMeta(
    'precioCentavos',
  );
  @override
  late final GeneratedColumn<int> precioCentavos = GeneratedColumn<int>(
    'precio_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costoCentavosMeta = const VerificationMeta(
    'costoCentavos',
  );
  @override
  late final GeneratedColumn<int> costoCentavos = GeneratedColumn<int>(
    'costo_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ACTIVO'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    empresaId,
    nombre,
    categoria,
    precioCentavos,
    costoCentavos,
    estado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'productos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Producto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('empresa_id')) {
      context.handle(
        _empresaIdMeta,
        empresaId.isAcceptableOrUnknown(data['empresa_id']!, _empresaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_empresaIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    }
    if (data.containsKey('precio_centavos')) {
      context.handle(
        _precioCentavosMeta,
        precioCentavos.isAcceptableOrUnknown(
          data['precio_centavos']!,
          _precioCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioCentavosMeta);
    }
    if (data.containsKey('costo_centavos')) {
      context.handle(
        _costoCentavosMeta,
        costoCentavos.isAcceptableOrUnknown(
          data['costo_centavos']!,
          _costoCentavosMeta,
        ),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Producto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Producto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      empresaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}empresa_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      ),
      precioCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precio_centavos'],
      )!,
      costoCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}costo_centavos'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
    );
  }

  @override
  $ProductosTable createAlias(String alias) {
    return $ProductosTable(attachedDatabase, alias);
  }
}

class Producto extends DataClass implements Insertable<Producto> {
  final String id;
  final String empresaId;
  final String nombre;
  final String? categoria;
  final int precioCentavos;
  final int costoCentavos;
  final String estado;
  const Producto({
    required this.id,
    required this.empresaId,
    required this.nombre,
    this.categoria,
    required this.precioCentavos,
    required this.costoCentavos,
    required this.estado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['empresa_id'] = Variable<String>(empresaId);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || categoria != null) {
      map['categoria'] = Variable<String>(categoria);
    }
    map['precio_centavos'] = Variable<int>(precioCentavos);
    map['costo_centavos'] = Variable<int>(costoCentavos);
    map['estado'] = Variable<String>(estado);
    return map;
  }

  ProductosCompanion toCompanion(bool nullToAbsent) {
    return ProductosCompanion(
      id: Value(id),
      empresaId: Value(empresaId),
      nombre: Value(nombre),
      categoria: categoria == null && nullToAbsent
          ? const Value.absent()
          : Value(categoria),
      precioCentavos: Value(precioCentavos),
      costoCentavos: Value(costoCentavos),
      estado: Value(estado),
    );
  }

  factory Producto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Producto(
      id: serializer.fromJson<String>(json['id']),
      empresaId: serializer.fromJson<String>(json['empresaId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      categoria: serializer.fromJson<String?>(json['categoria']),
      precioCentavos: serializer.fromJson<int>(json['precioCentavos']),
      costoCentavos: serializer.fromJson<int>(json['costoCentavos']),
      estado: serializer.fromJson<String>(json['estado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'empresaId': serializer.toJson<String>(empresaId),
      'nombre': serializer.toJson<String>(nombre),
      'categoria': serializer.toJson<String?>(categoria),
      'precioCentavos': serializer.toJson<int>(precioCentavos),
      'costoCentavos': serializer.toJson<int>(costoCentavos),
      'estado': serializer.toJson<String>(estado),
    };
  }

  Producto copyWith({
    String? id,
    String? empresaId,
    String? nombre,
    Value<String?> categoria = const Value.absent(),
    int? precioCentavos,
    int? costoCentavos,
    String? estado,
  }) => Producto(
    id: id ?? this.id,
    empresaId: empresaId ?? this.empresaId,
    nombre: nombre ?? this.nombre,
    categoria: categoria.present ? categoria.value : this.categoria,
    precioCentavos: precioCentavos ?? this.precioCentavos,
    costoCentavos: costoCentavos ?? this.costoCentavos,
    estado: estado ?? this.estado,
  );
  Producto copyWithCompanion(ProductosCompanion data) {
    return Producto(
      id: data.id.present ? data.id.value : this.id,
      empresaId: data.empresaId.present ? data.empresaId.value : this.empresaId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      precioCentavos: data.precioCentavos.present
          ? data.precioCentavos.value
          : this.precioCentavos,
      costoCentavos: data.costoCentavos.present
          ? data.costoCentavos.value
          : this.costoCentavos,
      estado: data.estado.present ? data.estado.value : this.estado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Producto(')
          ..write('id: $id, ')
          ..write('empresaId: $empresaId, ')
          ..write('nombre: $nombre, ')
          ..write('categoria: $categoria, ')
          ..write('precioCentavos: $precioCentavos, ')
          ..write('costoCentavos: $costoCentavos, ')
          ..write('estado: $estado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    empresaId,
    nombre,
    categoria,
    precioCentavos,
    costoCentavos,
    estado,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Producto &&
          other.id == this.id &&
          other.empresaId == this.empresaId &&
          other.nombre == this.nombre &&
          other.categoria == this.categoria &&
          other.precioCentavos == this.precioCentavos &&
          other.costoCentavos == this.costoCentavos &&
          other.estado == this.estado);
}

class ProductosCompanion extends UpdateCompanion<Producto> {
  final Value<String> id;
  final Value<String> empresaId;
  final Value<String> nombre;
  final Value<String?> categoria;
  final Value<int> precioCentavos;
  final Value<int> costoCentavos;
  final Value<String> estado;
  final Value<int> rowid;
  const ProductosCompanion({
    this.id = const Value.absent(),
    this.empresaId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.categoria = const Value.absent(),
    this.precioCentavos = const Value.absent(),
    this.costoCentavos = const Value.absent(),
    this.estado = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductosCompanion.insert({
    required String id,
    required String empresaId,
    required String nombre,
    this.categoria = const Value.absent(),
    required int precioCentavos,
    this.costoCentavos = const Value.absent(),
    this.estado = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       empresaId = Value(empresaId),
       nombre = Value(nombre),
       precioCentavos = Value(precioCentavos);
  static Insertable<Producto> custom({
    Expression<String>? id,
    Expression<String>? empresaId,
    Expression<String>? nombre,
    Expression<String>? categoria,
    Expression<int>? precioCentavos,
    Expression<int>? costoCentavos,
    Expression<String>? estado,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (empresaId != null) 'empresa_id': empresaId,
      if (nombre != null) 'nombre': nombre,
      if (categoria != null) 'categoria': categoria,
      if (precioCentavos != null) 'precio_centavos': precioCentavos,
      if (costoCentavos != null) 'costo_centavos': costoCentavos,
      if (estado != null) 'estado': estado,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductosCompanion copyWith({
    Value<String>? id,
    Value<String>? empresaId,
    Value<String>? nombre,
    Value<String?>? categoria,
    Value<int>? precioCentavos,
    Value<int>? costoCentavos,
    Value<String>? estado,
    Value<int>? rowid,
  }) {
    return ProductosCompanion(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      precioCentavos: precioCentavos ?? this.precioCentavos,
      costoCentavos: costoCentavos ?? this.costoCentavos,
      estado: estado ?? this.estado,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (empresaId.present) {
      map['empresa_id'] = Variable<String>(empresaId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (precioCentavos.present) {
      map['precio_centavos'] = Variable<int>(precioCentavos.value);
    }
    if (costoCentavos.present) {
      map['costo_centavos'] = Variable<int>(costoCentavos.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductosCompanion(')
          ..write('id: $id, ')
          ..write('empresaId: $empresaId, ')
          ..write('nombre: $nombre, ')
          ..write('categoria: $categoria, ')
          ..write('precioCentavos: $precioCentavos, ')
          ..write('costoCentavos: $costoCentavos, ')
          ..write('estado: $estado, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventariosTable extends Inventarios
    with TableInfo<$InventariosTable, Inventario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sucursalIdMeta = const VerificationMeta(
    'sucursalId',
  );
  @override
  late final GeneratedColumn<String> sucursalId = GeneratedColumn<String>(
    'sucursal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<String> productoId = GeneratedColumn<String>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _existenciaMeta = const VerificationMeta(
    'existencia',
  );
  @override
  late final GeneratedColumn<double> existencia = GeneratedColumn<double>(
    'existencia',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [sucursalId, productoId, existencia];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventarios';
  @override
  VerificationContext validateIntegrity(
    Insertable<Inventario> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sucursal_id')) {
      context.handle(
        _sucursalIdMeta,
        sucursalId.isAcceptableOrUnknown(data['sucursal_id']!, _sucursalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sucursalIdMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('existencia')) {
      context.handle(
        _existenciaMeta,
        existencia.isAcceptableOrUnknown(data['existencia']!, _existenciaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sucursalId, productoId};
  @override
  Inventario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Inventario(
      sucursalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sucursal_id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto_id'],
      )!,
      existencia: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}existencia'],
      )!,
    );
  }

  @override
  $InventariosTable createAlias(String alias) {
    return $InventariosTable(attachedDatabase, alias);
  }
}

class Inventario extends DataClass implements Insertable<Inventario> {
  final String sucursalId;
  final String productoId;
  final double existencia;
  const Inventario({
    required this.sucursalId,
    required this.productoId,
    required this.existencia,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sucursal_id'] = Variable<String>(sucursalId);
    map['producto_id'] = Variable<String>(productoId);
    map['existencia'] = Variable<double>(existencia);
    return map;
  }

  InventariosCompanion toCompanion(bool nullToAbsent) {
    return InventariosCompanion(
      sucursalId: Value(sucursalId),
      productoId: Value(productoId),
      existencia: Value(existencia),
    );
  }

  factory Inventario.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Inventario(
      sucursalId: serializer.fromJson<String>(json['sucursalId']),
      productoId: serializer.fromJson<String>(json['productoId']),
      existencia: serializer.fromJson<double>(json['existencia']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sucursalId': serializer.toJson<String>(sucursalId),
      'productoId': serializer.toJson<String>(productoId),
      'existencia': serializer.toJson<double>(existencia),
    };
  }

  Inventario copyWith({
    String? sucursalId,
    String? productoId,
    double? existencia,
  }) => Inventario(
    sucursalId: sucursalId ?? this.sucursalId,
    productoId: productoId ?? this.productoId,
    existencia: existencia ?? this.existencia,
  );
  Inventario copyWithCompanion(InventariosCompanion data) {
    return Inventario(
      sucursalId: data.sucursalId.present
          ? data.sucursalId.value
          : this.sucursalId,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      existencia: data.existencia.present
          ? data.existencia.value
          : this.existencia,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Inventario(')
          ..write('sucursalId: $sucursalId, ')
          ..write('productoId: $productoId, ')
          ..write('existencia: $existencia')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sucursalId, productoId, existencia);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Inventario &&
          other.sucursalId == this.sucursalId &&
          other.productoId == this.productoId &&
          other.existencia == this.existencia);
}

class InventariosCompanion extends UpdateCompanion<Inventario> {
  final Value<String> sucursalId;
  final Value<String> productoId;
  final Value<double> existencia;
  final Value<int> rowid;
  const InventariosCompanion({
    this.sucursalId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.existencia = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventariosCompanion.insert({
    required String sucursalId,
    required String productoId,
    this.existencia = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sucursalId = Value(sucursalId),
       productoId = Value(productoId);
  static Insertable<Inventario> custom({
    Expression<String>? sucursalId,
    Expression<String>? productoId,
    Expression<double>? existencia,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sucursalId != null) 'sucursal_id': sucursalId,
      if (productoId != null) 'producto_id': productoId,
      if (existencia != null) 'existencia': existencia,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventariosCompanion copyWith({
    Value<String>? sucursalId,
    Value<String>? productoId,
    Value<double>? existencia,
    Value<int>? rowid,
  }) {
    return InventariosCompanion(
      sucursalId: sucursalId ?? this.sucursalId,
      productoId: productoId ?? this.productoId,
      existencia: existencia ?? this.existencia,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sucursalId.present) {
      map['sucursal_id'] = Variable<String>(sucursalId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<String>(productoId.value);
    }
    if (existencia.present) {
      map['existencia'] = Variable<double>(existencia.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventariosCompanion(')
          ..write('sucursalId: $sucursalId, ')
          ..write('productoId: $productoId, ')
          ..write('existencia: $existencia, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncLogTable extends SyncLog with TableInfo<$SyncLogTable, SyncLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    action,
    entity,
    entityId,
    payload,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncLogTable createAlias(String alias) {
    return $SyncLogTable(attachedDatabase, alias);
  }
}

class SyncLogData extends DataClass implements Insertable<SyncLogData> {
  final int id;
  final String action;
  final String entity;
  final String entityId;
  final String payload;
  final DateTime createdAt;
  const SyncLogData({
    required this.id,
    required this.action,
    required this.entity,
    required this.entityId,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action'] = Variable<String>(action);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncLogCompanion toCompanion(bool nullToAbsent) {
    return SyncLogCompanion(
      id: Value(id),
      action: Value(action),
      entity: Value(entity),
      entityId: Value(entityId),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory SyncLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncLogData(
      id: serializer.fromJson<int>(json['id']),
      action: serializer.fromJson<String>(json['action']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'action': serializer.toJson<String>(action),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncLogData copyWith({
    int? id,
    String? action,
    String? entity,
    String? entityId,
    String? payload,
    DateTime? createdAt,
  }) => SyncLogData(
    id: id ?? this.id,
    action: action ?? this.action,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncLogData copyWithCompanion(SyncLogCompanion data) {
    return SyncLogData(
      id: data.id.present ? data.id.value : this.id,
      action: data.action.present ? data.action.value : this.action,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogData(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, action, entity, entityId, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncLogData &&
          other.id == this.id &&
          other.action == this.action &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class SyncLogCompanion extends UpdateCompanion<SyncLogData> {
  final Value<int> id;
  final Value<String> action;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  const SyncLogCompanion({
    this.id = const Value.absent(),
    this.action = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncLogCompanion.insert({
    this.id = const Value.absent(),
    required String action,
    required String entity,
    required String entityId,
    required String payload,
    this.createdAt = const Value.absent(),
  }) : action = Value(action),
       entity = Value(entity),
       entityId = Value(entityId),
       payload = Value(payload);
  static Insertable<SyncLogData> custom({
    Expression<int>? id,
    Expression<String>? action,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (action != null) 'action': action,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncLogCompanion copyWith({
    Value<int>? id,
    Value<String>? action,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? payload,
    Value<DateTime>? createdAt,
  }) {
    return SyncLogCompanion(
      id: id ?? this.id,
      action: action ?? this.action,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogCompanion(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientesTable clientes = $ClientesTable(this);
  late final $MembresiasTable membresias = $MembresiasTable(this);
  late final $ProductosTable productos = $ProductosTable(this);
  late final $InventariosTable inventarios = $InventariosTable(this);
  late final $SyncLogTable syncLog = $SyncLogTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    clientes,
    membresias,
    productos,
    inventarios,
    syncLog,
  ];
}

typedef $$ClientesTableCreateCompanionBuilder =
    ClientesCompanion Function({
      required String id,
      required String empresaId,
      required String nombre,
      Value<String?> telefono,
      Value<String?> email,
      Value<String?> documento,
      Value<String?> fotoUrl,
      Value<String> estado,
      Value<DateTime?> creadoAt,
      Value<bool> isDirty,
      Value<DateTime?> lastSynced,
      Value<int> rowid,
    });
typedef $$ClientesTableUpdateCompanionBuilder =
    ClientesCompanion Function({
      Value<String> id,
      Value<String> empresaId,
      Value<String> nombre,
      Value<String?> telefono,
      Value<String?> email,
      Value<String?> documento,
      Value<String?> fotoUrl,
      Value<String> estado,
      Value<DateTime?> creadoAt,
      Value<bool> isDirty,
      Value<DateTime?> lastSynced,
      Value<int> rowid,
    });

class $$ClientesTableFilterComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get empresaId => $composableBuilder(
    column: $table.empresaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documento => $composableBuilder(
    column: $table.documento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoUrl => $composableBuilder(
    column: $table.fotoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoAt => $composableBuilder(
    column: $table.creadoAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClientesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get empresaId => $composableBuilder(
    column: $table.empresaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documento => $composableBuilder(
    column: $table.documento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoUrl => $composableBuilder(
    column: $table.fotoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoAt => $composableBuilder(
    column: $table.creadoAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get empresaId =>
      $composableBuilder(column: $table.empresaId, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get documento =>
      $composableBuilder(column: $table.documento, builder: (column) => column);

  GeneratedColumn<String> get fotoUrl =>
      $composableBuilder(column: $table.fotoUrl, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoAt =>
      $composableBuilder(column: $table.creadoAt, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => column,
  );
}

class $$ClientesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientesTable,
          Cliente,
          $$ClientesTableFilterComposer,
          $$ClientesTableOrderingComposer,
          $$ClientesTableAnnotationComposer,
          $$ClientesTableCreateCompanionBuilder,
          $$ClientesTableUpdateCompanionBuilder,
          (Cliente, BaseReferences<_$AppDatabase, $ClientesTable, Cliente>),
          Cliente,
          PrefetchHooks Function()
        > {
  $$ClientesTableTableManager(_$AppDatabase db, $ClientesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> empresaId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> documento = const Value.absent(),
                Value<String?> fotoUrl = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<DateTime?> creadoAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<DateTime?> lastSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientesCompanion(
                id: id,
                empresaId: empresaId,
                nombre: nombre,
                telefono: telefono,
                email: email,
                documento: documento,
                fotoUrl: fotoUrl,
                estado: estado,
                creadoAt: creadoAt,
                isDirty: isDirty,
                lastSynced: lastSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String empresaId,
                required String nombre,
                Value<String?> telefono = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> documento = const Value.absent(),
                Value<String?> fotoUrl = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<DateTime?> creadoAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<DateTime?> lastSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientesCompanion.insert(
                id: id,
                empresaId: empresaId,
                nombre: nombre,
                telefono: telefono,
                email: email,
                documento: documento,
                fotoUrl: fotoUrl,
                estado: estado,
                creadoAt: creadoAt,
                isDirty: isDirty,
                lastSynced: lastSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClientesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientesTable,
      Cliente,
      $$ClientesTableFilterComposer,
      $$ClientesTableOrderingComposer,
      $$ClientesTableAnnotationComposer,
      $$ClientesTableCreateCompanionBuilder,
      $$ClientesTableUpdateCompanionBuilder,
      (Cliente, BaseReferences<_$AppDatabase, $ClientesTable, Cliente>),
      Cliente,
      PrefetchHooks Function()
    >;
typedef $$MembresiasTableCreateCompanionBuilder =
    MembresiasCompanion Function({
      required String id,
      required String clienteId,
      required String sucursalId,
      required String planId,
      required DateTime inicio,
      required DateTime fin,
      Value<String> estado,
      Value<int?> visitasRestantes,
      Value<String?> observaciones,
      Value<bool> isDirty,
      Value<int> rowid,
    });
typedef $$MembresiasTableUpdateCompanionBuilder =
    MembresiasCompanion Function({
      Value<String> id,
      Value<String> clienteId,
      Value<String> sucursalId,
      Value<String> planId,
      Value<DateTime> inicio,
      Value<DateTime> fin,
      Value<String> estado,
      Value<int?> visitasRestantes,
      Value<String?> observaciones,
      Value<bool> isDirty,
      Value<int> rowid,
    });

class $$MembresiasTableFilterComposer
    extends Composer<_$AppDatabase, $MembresiasTable> {
  $$MembresiasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sucursalId => $composableBuilder(
    column: $table.sucursalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fin => $composableBuilder(
    column: $table.fin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get visitasRestantes => $composableBuilder(
    column: $table.visitasRestantes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MembresiasTableOrderingComposer
    extends Composer<_$AppDatabase, $MembresiasTable> {
  $$MembresiasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sucursalId => $composableBuilder(
    column: $table.sucursalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fin => $composableBuilder(
    column: $table.fin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visitasRestantes => $composableBuilder(
    column: $table.visitasRestantes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MembresiasTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembresiasTable> {
  $$MembresiasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clienteId =>
      $composableBuilder(column: $table.clienteId, builder: (column) => column);

  GeneratedColumn<String> get sucursalId => $composableBuilder(
    column: $table.sucursalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<DateTime> get inicio =>
      $composableBuilder(column: $table.inicio, builder: (column) => column);

  GeneratedColumn<DateTime> get fin =>
      $composableBuilder(column: $table.fin, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<int> get visitasRestantes => $composableBuilder(
    column: $table.visitasRestantes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$MembresiasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MembresiasTable,
          Membresia,
          $$MembresiasTableFilterComposer,
          $$MembresiasTableOrderingComposer,
          $$MembresiasTableAnnotationComposer,
          $$MembresiasTableCreateCompanionBuilder,
          $$MembresiasTableUpdateCompanionBuilder,
          (
            Membresia,
            BaseReferences<_$AppDatabase, $MembresiasTable, Membresia>,
          ),
          Membresia,
          PrefetchHooks Function()
        > {
  $$MembresiasTableTableManager(_$AppDatabase db, $MembresiasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembresiasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembresiasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembresiasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clienteId = const Value.absent(),
                Value<String> sucursalId = const Value.absent(),
                Value<String> planId = const Value.absent(),
                Value<DateTime> inicio = const Value.absent(),
                Value<DateTime> fin = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<int?> visitasRestantes = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembresiasCompanion(
                id: id,
                clienteId: clienteId,
                sucursalId: sucursalId,
                planId: planId,
                inicio: inicio,
                fin: fin,
                estado: estado,
                visitasRestantes: visitasRestantes,
                observaciones: observaciones,
                isDirty: isDirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String clienteId,
                required String sucursalId,
                required String planId,
                required DateTime inicio,
                required DateTime fin,
                Value<String> estado = const Value.absent(),
                Value<int?> visitasRestantes = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembresiasCompanion.insert(
                id: id,
                clienteId: clienteId,
                sucursalId: sucursalId,
                planId: planId,
                inicio: inicio,
                fin: fin,
                estado: estado,
                visitasRestantes: visitasRestantes,
                observaciones: observaciones,
                isDirty: isDirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MembresiasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MembresiasTable,
      Membresia,
      $$MembresiasTableFilterComposer,
      $$MembresiasTableOrderingComposer,
      $$MembresiasTableAnnotationComposer,
      $$MembresiasTableCreateCompanionBuilder,
      $$MembresiasTableUpdateCompanionBuilder,
      (Membresia, BaseReferences<_$AppDatabase, $MembresiasTable, Membresia>),
      Membresia,
      PrefetchHooks Function()
    >;
typedef $$ProductosTableCreateCompanionBuilder =
    ProductosCompanion Function({
      required String id,
      required String empresaId,
      required String nombre,
      Value<String?> categoria,
      required int precioCentavos,
      Value<int> costoCentavos,
      Value<String> estado,
      Value<int> rowid,
    });
typedef $$ProductosTableUpdateCompanionBuilder =
    ProductosCompanion Function({
      Value<String> id,
      Value<String> empresaId,
      Value<String> nombre,
      Value<String?> categoria,
      Value<int> precioCentavos,
      Value<int> costoCentavos,
      Value<String> estado,
      Value<int> rowid,
    });

class $$ProductosTableFilterComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get empresaId => $composableBuilder(
    column: $table.empresaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precioCentavos => $composableBuilder(
    column: $table.precioCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costoCentavos => $composableBuilder(
    column: $table.costoCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductosTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get empresaId => $composableBuilder(
    column: $table.empresaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precioCentavos => $composableBuilder(
    column: $table.precioCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costoCentavos => $composableBuilder(
    column: $table.costoCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get empresaId =>
      $composableBuilder(column: $table.empresaId, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<int> get precioCentavos => $composableBuilder(
    column: $table.precioCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get costoCentavos => $composableBuilder(
    column: $table.costoCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);
}

class $$ProductosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductosTable,
          Producto,
          $$ProductosTableFilterComposer,
          $$ProductosTableOrderingComposer,
          $$ProductosTableAnnotationComposer,
          $$ProductosTableCreateCompanionBuilder,
          $$ProductosTableUpdateCompanionBuilder,
          (Producto, BaseReferences<_$AppDatabase, $ProductosTable, Producto>),
          Producto,
          PrefetchHooks Function()
        > {
  $$ProductosTableTableManager(_$AppDatabase db, $ProductosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> empresaId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> categoria = const Value.absent(),
                Value<int> precioCentavos = const Value.absent(),
                Value<int> costoCentavos = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductosCompanion(
                id: id,
                empresaId: empresaId,
                nombre: nombre,
                categoria: categoria,
                precioCentavos: precioCentavos,
                costoCentavos: costoCentavos,
                estado: estado,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String empresaId,
                required String nombre,
                Value<String?> categoria = const Value.absent(),
                required int precioCentavos,
                Value<int> costoCentavos = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductosCompanion.insert(
                id: id,
                empresaId: empresaId,
                nombre: nombre,
                categoria: categoria,
                precioCentavos: precioCentavos,
                costoCentavos: costoCentavos,
                estado: estado,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductosTable,
      Producto,
      $$ProductosTableFilterComposer,
      $$ProductosTableOrderingComposer,
      $$ProductosTableAnnotationComposer,
      $$ProductosTableCreateCompanionBuilder,
      $$ProductosTableUpdateCompanionBuilder,
      (Producto, BaseReferences<_$AppDatabase, $ProductosTable, Producto>),
      Producto,
      PrefetchHooks Function()
    >;
typedef $$InventariosTableCreateCompanionBuilder =
    InventariosCompanion Function({
      required String sucursalId,
      required String productoId,
      Value<double> existencia,
      Value<int> rowid,
    });
typedef $$InventariosTableUpdateCompanionBuilder =
    InventariosCompanion Function({
      Value<String> sucursalId,
      Value<String> productoId,
      Value<double> existencia,
      Value<int> rowid,
    });

class $$InventariosTableFilterComposer
    extends Composer<_$AppDatabase, $InventariosTable> {
  $$InventariosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sucursalId => $composableBuilder(
    column: $table.sucursalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get existencia => $composableBuilder(
    column: $table.existencia,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InventariosTableOrderingComposer
    extends Composer<_$AppDatabase, $InventariosTable> {
  $$InventariosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sucursalId => $composableBuilder(
    column: $table.sucursalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get existencia => $composableBuilder(
    column: $table.existencia,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InventariosTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventariosTable> {
  $$InventariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sucursalId => $composableBuilder(
    column: $table.sucursalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get existencia => $composableBuilder(
    column: $table.existencia,
    builder: (column) => column,
  );
}

class $$InventariosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventariosTable,
          Inventario,
          $$InventariosTableFilterComposer,
          $$InventariosTableOrderingComposer,
          $$InventariosTableAnnotationComposer,
          $$InventariosTableCreateCompanionBuilder,
          $$InventariosTableUpdateCompanionBuilder,
          (
            Inventario,
            BaseReferences<_$AppDatabase, $InventariosTable, Inventario>,
          ),
          Inventario,
          PrefetchHooks Function()
        > {
  $$InventariosTableTableManager(_$AppDatabase db, $InventariosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sucursalId = const Value.absent(),
                Value<String> productoId = const Value.absent(),
                Value<double> existencia = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventariosCompanion(
                sucursalId: sucursalId,
                productoId: productoId,
                existencia: existencia,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sucursalId,
                required String productoId,
                Value<double> existencia = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventariosCompanion.insert(
                sucursalId: sucursalId,
                productoId: productoId,
                existencia: existencia,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InventariosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventariosTable,
      Inventario,
      $$InventariosTableFilterComposer,
      $$InventariosTableOrderingComposer,
      $$InventariosTableAnnotationComposer,
      $$InventariosTableCreateCompanionBuilder,
      $$InventariosTableUpdateCompanionBuilder,
      (
        Inventario,
        BaseReferences<_$AppDatabase, $InventariosTable, Inventario>,
      ),
      Inventario,
      PrefetchHooks Function()
    >;
typedef $$SyncLogTableCreateCompanionBuilder =
    SyncLogCompanion Function({
      Value<int> id,
      required String action,
      required String entity,
      required String entityId,
      required String payload,
      Value<DateTime> createdAt,
    });
typedef $$SyncLogTableUpdateCompanionBuilder =
    SyncLogCompanion Function({
      Value<int> id,
      Value<String> action,
      Value<String> entity,
      Value<String> entityId,
      Value<String> payload,
      Value<DateTime> createdAt,
    });

class $$SyncLogTableFilterComposer
    extends Composer<_$AppDatabase, $SyncLogTable> {
  $$SyncLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncLogTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncLogTable> {
  $$SyncLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncLogTable> {
  $$SyncLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncLogTable,
          SyncLogData,
          $$SyncLogTableFilterComposer,
          $$SyncLogTableOrderingComposer,
          $$SyncLogTableAnnotationComposer,
          $$SyncLogTableCreateCompanionBuilder,
          $$SyncLogTableUpdateCompanionBuilder,
          (
            SyncLogData,
            BaseReferences<_$AppDatabase, $SyncLogTable, SyncLogData>,
          ),
          SyncLogData,
          PrefetchHooks Function()
        > {
  $$SyncLogTableTableManager(_$AppDatabase db, $SyncLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncLogCompanion(
                id: id,
                action: action,
                entity: entity,
                entityId: entityId,
                payload: payload,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String action,
                required String entity,
                required String entityId,
                required String payload,
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncLogCompanion.insert(
                id: id,
                action: action,
                entity: entity,
                entityId: entityId,
                payload: payload,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncLogTable,
      SyncLogData,
      $$SyncLogTableFilterComposer,
      $$SyncLogTableOrderingComposer,
      $$SyncLogTableAnnotationComposer,
      $$SyncLogTableCreateCompanionBuilder,
      $$SyncLogTableUpdateCompanionBuilder,
      (SyncLogData, BaseReferences<_$AppDatabase, $SyncLogTable, SyncLogData>),
      SyncLogData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientesTableTableManager get clientes =>
      $$ClientesTableTableManager(_db, _db.clientes);
  $$MembresiasTableTableManager get membresias =>
      $$MembresiasTableTableManager(_db, _db.membresias);
  $$ProductosTableTableManager get productos =>
      $$ProductosTableTableManager(_db, _db.productos);
  $$InventariosTableTableManager get inventarios =>
      $$InventariosTableTableManager(_db, _db.inventarios);
  $$SyncLogTableTableManager get syncLog =>
      $$SyncLogTableTableManager(_db, _db.syncLog);
}
