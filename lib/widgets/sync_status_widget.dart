import 'package:flutter/material.dart';
import '../services/data_sync_service.dart';

class SyncStatusWidget extends StatefulWidget {
  const SyncStatusWidget({super.key});

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  bool _isSyncing = false;
  bool _isSynced = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _checkSyncStatus();
  }

  Future<void> _checkSyncStatus() async {
    setState(() {
      _isSyncing = true;
      _statusMessage = 'Verificando dados...';
    });

    try {
      final bool synced = await DataSyncService.isDataSynced();
      setState(() {
        _isSynced = synced;
        _isSyncing = false;
        _statusMessage = synced 
            ? '✅ Dados sincronizados' 
            : '⚠️ Dados não sincronizados';
      });
    } catch (e) {
      setState(() {
        _isSyncing = false;
        _statusMessage = '❌ Erro ao verificar';
      });
    }
  }

  Future<void> _forceSync() async {
    setState(() {
      _isSyncing = true;
      _statusMessage = 'Sincronizando...';
    });

    try {
      await DataSyncService.forceSync();
      setState(() {
        _isSynced = true;
        _isSyncing = false;
        _statusMessage = '✅ Sincronização concluída!';
      });
    } catch (e) {
      setState(() {
        _isSyncing = false;
        _statusMessage = '❌ Erro na sincronização';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Só mostrar o widget se não estiver sincronizado
    if (_isSynced && !_isSyncing) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isSynced ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isSynced ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isSynced ? Icons.cloud_done : Icons.cloud_sync,
            color: _isSynced ? Colors.green[600] : Colors.orange[600],
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: _isSynced ? Colors.green[700] : Colors.orange[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!_isSynced && !_isSyncing)
            TextButton(
              onPressed: _forceSync,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Sincronizar',
                style: TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
