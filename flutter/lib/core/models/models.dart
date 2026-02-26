/// Data models that mirror the backend Prisma schema.
/// All monetary values arrive from the API as `int` centavos and are
/// converted to `double` only for display purposes.
library;

import 'dart:convert';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AUTH / USER
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final UserProfile user;

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    accessToken: json['accessToken'] ?? json['access_token'] ?? '',
    refreshToken: json['refreshToken'] ?? json['refresh_token'],
    user: UserProfile.fromJson(json['user'] ?? json),
  );
}

class UserProfile {
  final String id;
  final String empresaId;
  final String email;
  final String nombre;
  final String estado;
  final List<String> roles;
  final List<Sucursal> sucursales;

  UserProfile({
    required this.id,
    required this.empresaId,
    required this.email,
    required this.nombre,
    required this.estado,
    this.roles = const [],
    this.sucursales = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] ?? json['userId'] ?? '',
    empresaId: json['empresaId'] ?? json['empresa_id'] ?? '',
    email: json['email'] ?? '',
    nombre: json['nombre'] ?? '',
    estado: json['estado'] ?? 'ACTIVO',
    roles:
        (json['roles'] as List<dynamic>?)
            ?.map((r) => r is String ? r : r['nombre']?.toString() ?? '')
            .toList() ??
        [],
    sucursales:
        (json['sucursales'] as List<dynamic>?)
            ?.map((s) => Sucursal.fromJson(s is Map<String, dynamic> ? s : {}))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'empresaId': empresaId,
    'email': email,
    'nombre': nombre,
    'estado': estado,
    'roles': roles,
    'sucursales': sucursales.map((s) => s.toJson()).toList(),
  };

  String toJsonString() => jsonEncode(toJson());

  factory UserProfile.fromJsonString(String s) =>
      UserProfile.fromJson(jsonDecode(s));
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUCURSAL
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class Sucursal {
  final String id;
  final String empresaId;
  final String nombre;
  final String? direccion;
  final String estado;

  Sucursal({
    required this.id,
    required this.empresaId,
    required this.nombre,
    this.direccion,
    this.estado = 'ACTIVO',
  });

  factory Sucursal.fromJson(Map<String, dynamic> json) => Sucursal(
    id: json['id'] ?? '',
    empresaId: json['empresaId'] ?? json['empresa_id'] ?? '',
    nombre: json['nombre'] ?? '',
    direccion: json['direccion'],
    estado: json['estado'] ?? 'ACTIVO',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'empresaId': empresaId,
    'nombre': nombre,
    'direccion': direccion,
    'estado': estado,
  };
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CLIENTE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class Cliente {
  final String id;
  final String empresaId;
  final String nombre;
  final String? telefono;
  final String? email;
  final String? documento;
  final String? fotoUrl;
  final String estado;
  final DateTime? creadoAt;

  Cliente({
    required this.id,
    required this.empresaId,
    required this.nombre,
    this.telefono,
    this.email,
    this.documento,
    this.fotoUrl,
    this.estado = 'ACTIVO',
    this.creadoAt,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
    id: json['id'] ?? '',
    empresaId: json['empresa_id'] ?? '',
    nombre: json['nombre'] ?? '',
    telefono: json['telefono'],
    email: json['email'],
    documento: json['documento'],
    fotoUrl: json['foto_url'],
    estado: json['estado'] ?? 'ACTIVO',
    creadoAt: json['creado_at'] != null
        ? DateTime.tryParse(json['creado_at'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'empresa_id': empresaId,
    'nombre': nombre,
    'telefono': telefono,
    'email': email,
    'documento': documento,
    'foto_url': fotoUrl,
    'estado': estado,
  };

  Cliente copyWith({
    String? nombre,
    String? telefono,
    String? email,
    String? fotoUrl,
    String? estado,
  }) => Cliente(
    id: id,
    empresaId: empresaId,
    nombre: nombre ?? this.nombre,
    telefono: telefono ?? this.telefono,
    email: email ?? this.email,
    documento: documento,
    fotoUrl: fotoUrl ?? this.fotoUrl,
    estado: estado ?? this.estado,
    creadoAt: creadoAt,
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLAN DE MEMBRESÍA
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class PlanMembresia {
  final String id;
  final String empresaId;
  final String? sucursalId;
  final String nombre;
  final String tipo; // DIAS | VISITAS
  final int? dias;
  final int? visitas;
  final int precioCentavos;
  final String? descripcion;
  final bool multisede;
  final String estado;

  PlanMembresia({
    required this.id,
    required this.empresaId,
    this.sucursalId,
    required this.nombre,
    required this.tipo,
    this.dias,
    this.visitas,
    required this.precioCentavos,
    this.descripcion,
    this.multisede = false,
    this.estado = 'ACTIVO',
  });

  double get precioDisplay => precioCentavos / 100;

  factory PlanMembresia.fromJson(Map<String, dynamic> json) => PlanMembresia(
    id: json['id'] ?? '',
    empresaId: json['empresa_id'] ?? '',
    sucursalId: json['sucursal_id'],
    nombre: json['nombre'] ?? '',
    tipo: json['tipo'] ?? 'DIAS',
    dias: json['dias'],
    visitas: json['visitas'],
    precioCentavos: _toBigIntSafe(json['precio_centavos']),
    descripcion: json['descripcion'],
    multisede: json['multisede'] ?? false,
    estado: json['estado'] ?? 'ACTIVO',
  );

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'tipo': tipo,
    'dias': dias,
    'visitas': visitas,
    'precio_centavos': precioCentavos,
    'descripcion': descripcion,
    'multisede': multisede,
    'estado': estado,
    'sucursal_id': sucursalId,
  };

  PlanMembresia copyWith({
    String? nombre,
    String? tipo,
    int? dias,
    int? visitas,
    int? precioCentavos,
    String? descripcion,
    bool? multisede,
    String? estado,
  }) => PlanMembresia(
    id: id,
    empresaId: empresaId,
    sucursalId: sucursalId,
    nombre: nombre ?? this.nombre,
    tipo: tipo ?? this.tipo,
    dias: dias ?? this.dias,
    visitas: visitas ?? this.visitas,
    precioCentavos: precioCentavos ?? this.precioCentavos,
    descripcion: descripcion ?? this.descripcion,
    multisede: multisede ?? this.multisede,
    estado: estado ?? this.estado,
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MEMBRESÍA CLIENTE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class MembresiaCliente {
  final String id;
  final String clienteId;
  final String sucursalId;
  final String planId;
  final DateTime inicio;
  final DateTime fin;
  final String estado;
  final int? visitasRestantes;
  final String? observaciones;
  // Nested
  final String? clienteNombre;
  final String? clienteFotoUrl;
  final String? planNombre;

  MembresiaCliente({
    required this.id,
    required this.clienteId,
    required this.sucursalId,
    required this.planId,
    required this.inicio,
    required this.fin,
    required this.estado,
    this.visitasRestantes,
    this.observaciones,
    this.clienteNombre,
    this.clienteFotoUrl,
    this.planNombre,
  });

  factory MembresiaCliente.fromJson(Map<String, dynamic> json) =>
      MembresiaCliente(
        id: json['id'] ?? '',
        clienteId: json['cliente_id'] ?? '',
        sucursalId: json['sucursal_id'] ?? '',
        planId: json['plan_id'] ?? '',
        inicio: DateTime.parse(json['inicio']),
        fin: DateTime.parse(json['fin']),
        estado: json['estado'] ?? 'ACTIVA',
        visitasRestantes: json['visitas_restantes'],
        observaciones: json['observaciones'],
        clienteNombre: json['cliente']?['nombre'],
        clienteFotoUrl: json['cliente']?['foto_url'],
        planNombre: json['plan']?['nombre'],
      );

  MembresiaCliente copyWith({
    String? estado,
    DateTime? fin,
    int? visitasRestantes,
  }) => MembresiaCliente(
    id: id,
    clienteId: clienteId,
    sucursalId: sucursalId,
    planId: planId,
    inicio: inicio,
    fin: fin ?? this.fin,
    estado: estado ?? this.estado,
    visitasRestantes: visitasRestantes ?? this.visitasRestantes,
    observaciones: observaciones,
    clienteNombre: clienteNombre,
    clienteFotoUrl: clienteFotoUrl,
    planNombre: planNombre,
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ASISTENCIA
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class Asistencia {
  final String id;
  final String clienteId;
  final String sucursalId;
  final DateTime fechaHora;
  final String resultado; // PERMITIDO | DENEGADO
  final String? nota;
  // Nested
  final String? clienteNombre;
  final String? clienteFotoUrl;

  Asistencia({
    required this.id,
    required this.clienteId,
    required this.sucursalId,
    required this.fechaHora,
    required this.resultado,
    this.nota,
    this.clienteNombre,
    this.clienteFotoUrl,
  });

  factory Asistencia.fromJson(Map<String, dynamic> json) => Asistencia(
    id: json['id'] ?? '',
    clienteId: json['cliente_id'] ?? '',
    sucursalId: json['sucursal_id'] ?? '',
    fechaHora: DateTime.parse(json['fecha_hora']),
    resultado: json['resultado'] ?? '',
    nota: json['nota'],
    clienteNombre: json['cliente']?['nombre'],
    clienteFotoUrl: json['cliente']?['foto_url'],
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CAJA
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRODUCTO
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class Producto {
  final String id;
  final String empresaId;
  final String nombre;
  final String? categoria;
  final int precioCentavos;
  final int costoCentavos;
  final String estado;
  final String? fotoUrl;
  final int? existencia; // Populated when queried with stock

  Producto({
    required this.id,
    required this.empresaId,
    required this.nombre,
    this.categoria,
    required this.precioCentavos,
    this.costoCentavos = 0,
    this.estado = 'ACTIVO',
    this.fotoUrl,
    this.existencia,
  });

  double get precioDisplay => precioCentavos / 100;
  double get costoDisplay => costoCentavos / 100;

  factory Producto.fromJson(Map<String, dynamic> json) {
    // Stock may come from inventarios relation
    int? stock;
    if (json['inventarios'] is List &&
        (json['inventarios'] as List).isNotEmpty) {
      final inv = (json['inventarios'] as List).first;
      stock = _parseDecimalToInt(inv['existencia']);
    }
    if (json['existencia'] != null) {
      stock = _parseDecimalToInt(json['existencia']);
    }

    return Producto(
      id: json['id'] ?? '',
      empresaId: json['empresa_id'] ?? '',
      nombre: json['nombre'] ?? '',
      categoria: json['categoria'],
      precioCentavos: _toBigIntSafe(json['precio_centavos']),
      costoCentavos: _toBigIntSafe(json['costo_centavos']),
      estado: json['estado'] ?? 'ACTIVO',
      fotoUrl: json['foto_url'],
      existencia: stock,
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'categoria': categoria,
    'precio': precioDisplay,
    'costo': costoDisplay,
    'foto_url': fotoUrl,
  };
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VENTA & DETALLE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class Venta {
  final String id;
  final String sucursalId;
  final String cajaId;
  final String? clienteId;
  final int totalCentavos;
  final String estado;
  final DateTime creadoAt;
  // Nested
  final String? clienteNombre;
  final List<VentaDetalle> detalles;

  Venta({
    required this.id,
    required this.sucursalId,
    required this.cajaId,
    this.clienteId,
    required this.totalCentavos,
    this.estado = 'APLICADA',
    required this.creadoAt,
    this.clienteNombre,
    this.detalles = const [],
  });

  double get totalDisplay => totalCentavos / 100;

  factory Venta.fromJson(Map<String, dynamic> json) => Venta(
    id: json['id'] ?? '',
    sucursalId: json['sucursal_id'] ?? '',
    cajaId: json['caja_id'] ?? '',
    clienteId: json['cliente_id'],
    totalCentavos: _toBigIntSafe(json['total_centavos']),
    estado: json['estado'] ?? 'APLICADA',
    creadoAt: DateTime.parse(json['creado_at']),
    clienteNombre: json['cliente']?['nombre'],
    detalles:
        (json['detalles'] as List<dynamic>?)
            ?.map((d) => VentaDetalle.fromJson(d))
            .toList() ??
        [],
  );
}

class VentaDetalle {
  final String id;
  final String productoId;
  final double cantidad;
  final int precioUnitCentavos;
  final int subtotalCentavos;
  final String? productoNombre;

  VentaDetalle({
    required this.id,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitCentavos,
    required this.subtotalCentavos,
    this.productoNombre,
  });

  factory VentaDetalle.fromJson(Map<String, dynamic> json) => VentaDetalle(
    id: json['id'] ?? '',
    productoId: json['producto_id'] ?? '',
    cantidad: (json['cantidad'] is String)
        ? double.parse(json['cantidad'])
        : (json['cantidad'] as num).toDouble(),
    precioUnitCentavos: _toBigIntSafe(json['precio_unit_centavos']),
    subtotalCentavos: _toBigIntSafe(json['subtotal_centavos']),
    productoNombre: json['producto']?['nombre'],
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PAGO
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class Pago {
  final String id;
  final String cajaId;
  final String? clienteId;
  final String tipo; // MEMBRESIA | PRODUCTO | OTRO
  final int montoCentavos;
  final String metodo; // EFECTIVO | TARJETA | TRANSFERENCIA
  final String estado;
  final String? descripcion;
  final DateTime creadoAt;

  Pago({
    required this.id,
    required this.cajaId,
    this.clienteId,
    required this.tipo,
    required this.montoCentavos,
    required this.metodo,
    this.estado = 'APLICADO',
    this.descripcion,
    required this.creadoAt,
  });

  double get montoDisplay => montoCentavos / 100;

  factory Pago.fromJson(Map<String, dynamic> json) => Pago(
    id: json['id'] ?? '',
    cajaId: json['caja_id'] ?? '',
    clienteId: json['cliente_id'],
    tipo: json['tipo'] ?? '',
    montoCentavos: _toBigIntSafe(json['monto_centavos']),
    metodo: json['metodo'] ?? '',
    estado: json['estado'] ?? 'APLICADO',
    descripcion: json['descripcion'] ?? json['referencia'],
    creadoAt: DateTime.parse(
      json['creado_at'] ?? DateTime.now().toIso8601String(),
    ),
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REPORTES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ResumenDia {
  final int asistencias;
  final int ventasCantidad;
  final double ventasTotal;
  final double ingresos;
  final int nuevosClientes;

  ResumenDia({
    required this.asistencias,
    required this.ventasCantidad,
    required this.ventasTotal,
    required this.ingresos,
    required this.nuevosClientes,
  });

  factory ResumenDia.fromJson(Map<String, dynamic> json) => ResumenDia(
    asistencias: json['asistencias'] ?? 0,
    ventasCantidad: json['ventas']?['cantidad'] ?? 0,
    ventasTotal: (json['ventas']?['total'] ?? 0).toDouble(),
    ingresos: (json['ingresos'] ?? 0).toDouble(),
    nuevosClientes: json['nuevosClientes'] ?? 0,
  );
}

class AsistenciaPorHora {
  final int hora;
  final int cantidad;

  AsistenciaPorHora({required this.hora, required this.cantidad});

  factory AsistenciaPorHora.fromJson(Map<String, dynamic> json) =>
      AsistenciaPorHora(
        hora: json['hora'] ?? 0,
        cantidad: json['cantidad'] ?? 0,
      );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Safely converts BigInt/String/int from JSON to int.
int _toBigIntSafe(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// Parses a Prisma Decimal (returned as String) into int.
int? _parseDecimalToInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return double.tryParse(value)?.toInt();
  return null;
}

//
// CAJA
// ?

class CajaModel {
  final String id;
  final String sucursalId;
  final String? usuarioAperturaId;
  final String? usuarioCierreId;
  final DateTime fechaApertura;
  final DateTime? fechaCierre;
  final int montoAperturaCentavos;
  final int? montoCierreCentavos;
  final String estado;

  CajaModel({
    required this.id,
    required this.sucursalId,
    this.usuarioAperturaId,
    this.usuarioCierreId,
    required this.fechaApertura,
    this.fechaCierre,
    required this.montoAperturaCentavos,
    this.montoCierreCentavos,
    required this.estado,
  });

  factory CajaModel.fromJson(Map<String, dynamic> json) => CajaModel(
    id: json['id'] ?? '',
    sucursalId: json['sucursal_id'] ?? '',
    usuarioAperturaId: json['usuario_id'],
    usuarioCierreId: json['usuario_cierre_id'],
    fechaApertura: DateTime.parse(
      json['apertura_at'] ??
          json['fecha_apertura'] ??
          DateTime.now().toIso8601String(),
    ),
    fechaCierre: json['cierre_at'] != null
        ? DateTime.parse(json['cierre_at'])
        : json['fecha_cierre'] != null
        ? DateTime.parse(json['fecha_cierre'])
        : null,
    montoAperturaCentavos: _toBigIntSafe(json['monto_apertura_centavos']),
    montoCierreCentavos: _toBigIntSafe(json['monto_cierre_centavos']),
    estado: json['estado'] ?? 'CERRADA',
  );
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRASLADOS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class TrasladoInventario {
  final String id;
  final String sucursalOrigenId;
  final String sucursalDestinoId;
  final String estado;
  final String creadoPor;
  final DateTime creadoAt;
  final String? recibidoPor;
  final DateTime? recibidoAt;
  final List<TrasladoDetalle> detalles;
  // Extra Info
  final String? sucursalOrigenNombre;
  final String? sucursalDestinoNombre;
  final String? usuarioCreaNombre;

  TrasladoInventario({
    required this.id,
    required this.sucursalOrigenId,
    required this.sucursalDestinoId,
    required this.estado,
    required this.creadoPor,
    required this.creadoAt,
    this.recibidoPor,
    this.recibidoAt,
    this.detalles = const [],
    this.sucursalOrigenNombre,
    this.sucursalDestinoNombre,
    this.usuarioCreaNombre,
  });

  factory TrasladoInventario.fromJson(Map<String, dynamic> json) =>
      TrasladoInventario(
        id: json['id'] ?? '',
        sucursalOrigenId: json['sucursal_origen_id'] ?? '',
        sucursalDestinoId: json['sucursal_destino_id'] ?? '',
        estado: json['estado'] ?? 'CREADO',
        creadoPor: json['creado_por'] ?? '',
        creadoAt: DateTime.parse(json['creado_at']),
        recibidoPor: json['recibido_por'],
        recibidoAt: json['recibido_at'] != null
            ? DateTime.parse(json['recibido_at'])
            : null,
        detalles:
            (json['detalles'] as List<dynamic>?)
                ?.map((d) => TrasladoDetalle.fromJson(d))
                .toList() ??
            [],
        sucursalOrigenNombre: json['sucursal_origen']?['nombre'],
        sucursalDestinoNombre: json['sucursal_destino']?['nombre'],
        usuarioCreaNombre: json['usuario_crea']?['nombre'],
      );
}

class TrasladoDetalle {
  final String id;
  final String productoId;
  final double cantidad;
  final String? productoNombre;

  TrasladoDetalle({
    required this.id,
    required this.productoId,
    required this.cantidad,
    this.productoNombre,
  });

  factory TrasladoDetalle.fromJson(Map<String, dynamic> json) =>
      TrasladoDetalle(
        id: json['id'] ?? '',
        productoId: json['producto_id'] ?? '',
        cantidad: (json['cantidad'] is String)
            ? double.parse(json['cantidad'])
            : (json['cantidad'] as num).toDouble(),
        productoNombre: json['producto']?['nombre'],
      );
}
