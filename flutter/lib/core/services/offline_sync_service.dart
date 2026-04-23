import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' as drift;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart' hide Cliente;
import 'api_service.dart';

class OfflineSyncService {
  final AppDatabase _db;
  final ApiService _api = ApiService();
  static const String _lastSeqKey = 'sync_last_seq';

  OfflineSyncService(this._db);

  // ── Sync Incoming (Pull) ───────────────────────────────────

  /// Realiza un Pull incremental desde el servidor.
  Future<void> performPull(String sucursalId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSeq = prefs.getInt(_lastSeqKey) ?? 0;

      final result = await _api.get(
        '/sync/pull',
        query: {'desdeSeq': lastSeq.toString(), 'sucursalId': sucursalId},
      );

      final List<dynamic> cambios = result['cambios'] ?? [];
      final int hastaSeq = result['hastaSeq'] ?? lastSeq;

      if (cambios.isEmpty) {
        // Update seq even if empty to keep in track
        await prefs.setInt(_lastSeqKey, hastaSeq);
        return;
      }

      await _db.batch((batch) {
        for (final cambio in cambios) {
          final String tabla = cambio['tabla'];
          final String operacion = cambio['op'];
          final Map<String, dynamic> data = cambio['data'];

          if (operacion == 'DELETE') {
            _handleIncomingDelete(batch, tabla, data);
          } else {
            _handleIncomingUpsert(batch, tabla, data);
          }
        }
      });

      await prefs.setInt(_lastSeqKey, hastaSeq);
      debugPrint('Sync Pull completed. New Seq: $hastaSeq');
    } catch (e) {
      debugPrint('Sync Pull error: $e');
    }
  }

  void _handleIncomingUpsert(
    drift.Batch batch,
    String tabla,
    Map<String, dynamic> data,
  ) {
    switch (tabla) {
      case 'cliente':
        batch.insert(
          _db.clientes,
          ClientesCompanion.insert(
            id: data['id'],
            empresaId: data['empresa_id'],
            nombre: data['nombre'],
            telefono: drift.Value(data['telefono']),
            email: drift.Value(data['email']),
            documento: drift.Value(data['documento']),
            fotoUrl: drift.Value(data['foto_url']),
            estado: drift.Value(data['estado']),
            creadoAt: drift.Value(
              data['creado_at'] != null
                  ? DateTime.parse(data['creado_at'])
                  : null,
            ),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
        break;
      case 'membresia_cliente':
        batch.insert(
          _db.membresias,
          MembresiasCompanion.insert(
            id: data['id'],
            clienteId: data['cliente_id'],
            sucursalId: data['sucursal_id'],
            planId: data['plan_id'],
            inicio: DateTime.parse(data['inicio']),
            fin: DateTime.parse(data['fin']),
            estado: drift.Value(data['estado']),
            visitasRestantes: drift.Value(data['visitas_restantes']),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
        break;
      case 'producto':
        batch.insert(
          _db.productos,
          ProductosCompanion.insert(
            id: data['id'],
            empresaId: data['empresa_id'],
            nombre: data['nombre'],
            categoria: drift.Value(data['categoria']),
            precioCentavos: _parseToInt(data['precio_centavos']),
            costoCentavos: drift.Value(_parseToInt(data['costo_centavos'])),
            estado: drift.Value(data['estado']),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
        break;
      case 'inventario_sucursal':
        batch.insert(
          _db.inventarios,
          InventariosCompanion.insert(
            sucursalId: data['sucursal_id'],
            productoId: data['producto_id'],
            existencia: drift.Value(_parseToDouble(data['existencia'])),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
        break;
    }
  }

  int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return double.tryParse(value)?.toInt() ?? 0;
    return 0;
  }

  double _parseToDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  void _handleIncomingDelete(
    drift.Batch batch,
    String tabla,
    Map<String, dynamic> data,
  ) {
    switch (tabla) {
      case 'cliente':
        final id = data['id']?.toString();
        if (id != null && id.isNotEmpty) {
          batch.deleteWhere(_db.clientes, (t) => t.id.equals(id));
        }
        break;
      case 'membresia_cliente':
        final id = data['id']?.toString();
        if (id != null && id.isNotEmpty) {
          batch.deleteWhere(_db.membresias, (t) => t.id.equals(id));
        }
        break;
      case 'producto':
        final id = data['id']?.toString();
        if (id != null && id.isNotEmpty) {
          batch.deleteWhere(_db.productos, (t) => t.id.equals(id));
        }
        break;
      case 'inventario_sucursal':
        final sucursalId = data['sucursal_id']?.toString();
        final productoId = data['producto_id']?.toString();
        if ((sucursalId ?? '').isNotEmpty && (productoId ?? '').isNotEmpty) {
          batch.deleteWhere(
            _db.inventarios,
            (t) => t.sucursalId.equals(sucursalId!) & t.productoId.equals(productoId!),
          );
        }
        break;
    }
  }

  // ── Sync Outgoing (Push) ───────────────────────────────────

  /// Sube los cambios locales pendientes al servidor usando /sync/push.
  Future<void> performPush(String deviceId) async {
    final logEntries =
        await (_db.select(_db.syncLog)
              ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt)])
              ..limit(50))
            .get();

    if (logEntries.isEmpty) return;

    final requestId = const Uuid().v4();
    final eventos = logEntries.map((e) {
      return {
        'eventId': const Uuid().v4(),
        'tipo': e.entity, // VENTA, CLIENTE, ASISTENCIA, CAJA, INVENTARIO
        'accion': e.action, // CREAR, UPSERT, ABRIR, CERRAR, ENTRADA
        'payload': jsonDecode(e.payload),
        'idLocal': e.id.toString(),
      };
    }).toList();

    try {
      final result = await _api.post(
        '/sync/push',
        body: {
          'deviceId': deviceId,
          'requestId': requestId,
          'eventos': eventos,
        },
      );

      if (result['status'] == 'OK' || result['status'] == 'PARTIAL_OK') {
        final List<dynamic> results = result['results'] ?? [];
        for (var res in results) {
          if (res['status'] == 'OK') {
            final idLocal = int.parse(res['idLocal']);
            await (_db.delete(
              _db.syncLog,
            )..where((t) => t.id.equals(idLocal))).go();
          }
        }
      }
    } catch (e) {
      debugPrint('Sync Push error: $e');
    }
  }
}
