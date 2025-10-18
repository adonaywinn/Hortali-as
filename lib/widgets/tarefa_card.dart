import 'package:flutter/material.dart';
import '../models/horta_data.dart';

class TarefaCard extends StatelessWidget {
  final Tarefa tarefa;
  final VoidCallback onTap;

  const TarefaCard({
    super.key,
    required this.tarefa,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: tarefa.concluida ? Colors.green : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Checkbox(
              value: tarefa.concluida,
              onChanged: (_) => onTap(),
              activeColor: const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tarefa.titulo,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: tarefa.concluida ? Colors.grey[600] : Colors.black87,
                      decoration: tarefa.concluida ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (tarefa.descricao.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      tarefa.descricao,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildTipoIcon(tarefa.tipo),
                const SizedBox(height: 4),
                Text(
                  _formatTime(tarefa.dataHora),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipoIcon(String tipo) {
    IconData icon;
    Color color;
    
    switch (tipo) {
      case 'rega':
        icon = Icons.water_drop;
        color = Colors.blue;
        break;
      case 'adubo':
        icon = Icons.eco;
        color = Colors.green;
        break;
      case 'colheita':
        icon = Icons.agriculture;
        color = Colors.orange;
        break;
      case 'poda':
        icon = Icons.content_cut;
        color = Colors.purple;
        break;
      default:
        icon = Icons.task;
        color = Colors.grey;
    }
    
    return Icon(icon, size: 16, color: color);
  }

  String _formatTime(DateTime dateTime) {
    if (dateTime.hour == 0 && dateTime.minute == 0) {
      return '📅';
    }
    return '⏰ ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
