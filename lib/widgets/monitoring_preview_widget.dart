import 'package:flutter/material.dart';
import '../models/planta.dart';
import '../services/planta_monitoring_service.dart';

class MonitoringPreviewWidget extends StatelessWidget {
  final Planta planta;
  final DateTime dataPlantio;

  const MonitoringPreviewWidget({
    super.key,
    required this.planta,
    required this.dataPlantio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.green[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Monitoramento Automático',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Para ${planta.nome} (${planta.tipo})',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildMonitoringItems(),
        ],
      ),
    );
  }

  Widget _buildMonitoringItems() {
    final configRega = _getConfiguracaoRega(planta);
    final configAdubacao = _getConfiguracaoAdubacao(planta);
    final pragasComuns = _getPragasComuns(planta);
    final cuidadosEspeciais = _getCuidadosEspeciais(planta);
    
    return Column(
      children: [
        _buildMonitoringItem(
          icon: Icons.water_drop,
          title: 'Rega ${configRega['tipo']}',
          description: 'A cada ${configRega['frequencia']} dia(s) às ${configRega['hora']}h',
          color: Colors.blue,
        ),
        
        const SizedBox(height: 8),
        
        _buildMonitoringItem(
          icon: Icons.eco,
          title: 'Adubação',
          description: '${configAdubacao['tipo']} - ${configAdubacao['quantidade']}',
          color: Colors.brown,
        ),
        
        const SizedBox(height: 8),
        
        _buildMonitoringItem(
          icon: Icons.bug_report,
          title: 'Monitoramento de Pragas',
          description: 'Verificar: ${pragasComuns.join(', ')}',
          color: Colors.red,
        ),
        
        if (cuidadosEspeciais.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildMonitoringItem(
            icon: Icons.health_and_safety,
            title: 'Cuidados Especiais',
            description: '${cuidadosEspeciais.length} tarefa(s) específica(s)',
            color: Colors.orange,
          ),
        ],
        
        const SizedBox(height: 8),
        
        _buildMonitoringItem(
          icon: Icons.agriculture,
          title: 'Colheita',
          description: 'Em ${_extrairDiasColheita(planta.colheita)} dias',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildMonitoringItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Métodos auxiliares (copiados do PlantaMonitoringService para preview)
  Map<String, dynamic> _getConfiguracaoRega(Planta planta) {
    final tipo = planta.tipo.toLowerCase();
    
    switch (tipo) {
      case 'folhosa':
        return {'frequencia': 1, 'hora': 7, 'tipo': 'matinal'};
      case 'raiz':
        return {'frequencia': 2, 'hora': 8, 'tipo': 'moderada'};
      case 'erva':
        return {'frequencia': 1, 'hora': 6, 'tipo': 'suave'};
      case 'fruto':
        return {'frequencia': 1, 'hora': 7, 'tipo': 'abundante'};
      default:
        return {'frequencia': 2, 'hora': 8, 'tipo': 'regular'};
    }
  }

  Map<String, dynamic> _getConfiguracaoAdubacao(Planta planta) {
    final tipo = planta.tipo.toLowerCase();
    
    switch (tipo) {
      case 'folhosa':
        return {'tipo': 'NPK 20-10-10', 'quantidade': '1 colher de sopa'};
      case 'raiz':
        return {'tipo': 'NPK 10-20-10', 'quantidade': '2 colheres de sopa'};
      case 'erva':
        return {'tipo': 'Húmus de minhoca', 'quantidade': '1 punhado'};
      case 'fruto':
        return {'tipo': 'NPK 15-15-15', 'quantidade': '2 colheres de sopa'};
      default:
        return {'tipo': 'NPK 15-15-15', 'quantidade': '1 colher de sopa'};
    }
  }

  List<String> _getPragasComuns(Planta planta) {
    final tipo = planta.tipo.toLowerCase();
    
    switch (tipo) {
      case 'folhosa':
        return ['pulgões', 'lagartas', 'ácaros'];
      case 'raiz':
        return ['nematoides', 'larvas', 'fungos'];
      case 'erva':
        return ['pulgões', 'ácaros', 'fungos'];
      case 'fruto':
        return ['lagartas', 'pulgões', 'ácaros', 'fungos'];
      default:
        return ['pulgões', 'lagartas'];
    }
  }

  List<Map<String, dynamic>> _getCuidadosEspeciais(Planta planta) {
    final tipo = planta.tipo.toLowerCase();
    
    switch (tipo) {
      case 'folhosa':
        return [
          {'titulo': 'Desbaste das folhas'},
          {'titulo': 'Amarração'},
        ];
      case 'raiz':
        return [
          {'titulo': 'Afloramento'},
          {'titulo': 'Verificar crescimento'},
        ];
      case 'erva':
        return [
          {'titulo': 'Poda de crescimento'},
        ];
      case 'fruto':
        return [
          {'titulo': 'Tutoramento'},
          {'titulo': 'Desbaste de frutos'},
        ];
      default:
        return [];
    }
  }

  int _extrairDiasColheita(String colheita) {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(colheita);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 30;
  }
}
