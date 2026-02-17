import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart' hide Cliente;
import '../models/models.dart';
import 'api_service.dart';

class OfflineSyncService {
  final AppDatabase _db;
  final ApiService _api = ApiService();

  OfflineSyncService(this._db);

  // ── Sync Incoming ──────────────────────────────────────────

  Future<void> syncClientes() async {
    try {
      final json = await _api.get('/clientes');
      final List<Cliente> remote = (json as List)
          .map((j) => Cliente.fromJson(j))
          .toList();

      await _db.batch((batch) {
        for (final c in remote) {
          batch.insert(
            _db.clientes,
            ClientesCompanion.insert(
              id: c.id,
              empresaId: c.empresaId,
              nombre: c.nombre,
              telefono: drift.Value(c.telefono),
              email: drift.Value(c.email),
              documento: drift.Value(c.documento),
              fotoUrl: drift.Value(c.fotoUrl),
              estado: drift.Value(c.estado),
              creadoAt: drift.Value(c.creadoAt),
              isDirty: const drift.Value(false),
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
        }
      });
    } catch (e) {
      debugPrint('Sync error (clientes): $e');
    }
  }

  Future<void> syncMembresias() async {
    try {
      final json = await _api.get('/membresias');
      final List<MembresiaCliente> remote = (json as List)
          .map((j) => MembresiaCliente.fromJson(j))
          .toList();

      await _db.batch((batch) {
        for (final m in remote) {
          batch.insert(
            _db.membresias,
            MembresiasCompanion.insert(
              id: m.id,
              clienteId: m.clienteId,
              sucursalId: m.sucursalId,
              planId: m.planId,
              inicio: m.inicio,
              fin: m.fin,
              estado: drift.Value(m.estado),
              visitasRestantes: drift.Value(m.visitasRestantes),
              observaciones: drift.Value(m.observaciones),
              isDirty: const drift.Value(false),
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
        }
      });
    } catch (e) {
      debugPrint('Sync error (membresias): $e');
    }
  }

  // ── Sync Outgoing ──────────────────────────────────────────

  Future<void> pushLocalChanges() async {
    final logEntries = await (_db.select(
      _db.syncLog,
    )..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt)])).get();

    for (final entry in logEntries) {
      try {
        final payload = jsonDecode(entry.payload);

        switch (entry.action) {
          case 'CREATE':
            if (entry.entity == 'CLIENTE') {
              await _api.post('/clientes', body: payload);
            }
            break;
          case 'UPDATE':
            if (entry.entity == 'CLIENTE') {
              await _api.patch('/clientes/${entry.entityId}', body: payload);
            }
            break;
        }

        // Remove from log if successful
        await (_db.delete(
          _db.syncLog,
        )..where((t) => t.id.equals(entry.id))).go();
      } catch (e) {
        debugPrint('Push error for entry ${entry.id}: $e');
        // Stop pushing and retry later to maintain order
        break;
      }
    }
  }
}
