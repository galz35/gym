import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/logger.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  @override
  Widget build(BuildContext context) {
    final logs = Logger.logs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs de Sistema'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Limpiar logs',
            onPressed: () {
              setState(() {
                Logger.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: logs.isEmpty
          ? const Center(child: Text('No hay logs registrados'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              separatorBuilder: (_, index) => const Divider(),
              itemBuilder: (context, index) {
                final log = logs[index];
                final isError = log.contains('ERROR:');
                final isWarn = log.contains('WARN:');

                return SelectableText(
                  log,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: isError
                        ? AppColors.error
                        : isWarn
                        ? AppColors.warning
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                );
              },
            ),
    );
  }
}
