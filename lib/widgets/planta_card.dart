import 'package:flutter/material.dart';
import '../models/planta.dart';

class PlantaCard extends StatelessWidget {
  final Planta planta;
  final VoidCallback onTap;

  const PlantaCard({
    super.key,
    required this.planta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone da planta
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getPlantaColor(planta.tipo).withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                _getPlantaIcon(planta.tipo),
                color: _getPlantaColor(planta.tipo),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Informações da planta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    planta.nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    planta.tipo,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(Icons.wb_sunny, planta.luz),
                      const SizedBox(width: 8),
                      _buildInfoChip(Icons.water_drop, planta.rega),
                    ],
                  ),
                ],
              ),
            ),
            // Seta de navegação
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPlantaColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'folhosa':
        return const Color(0xFF4CAF50);
      case 'raiz':
        return const Color(0xFFFF9800);
      case 'erva':
        return const Color(0xFF9C27B0);
      case 'fruto':
        return const Color(0xFFE91E63);
      case 'grão':
        return const Color(0xFF795548);
      case 'leguminosa':
        return const Color(0xFF8BC34A);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  IconData _getPlantaIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'folhosa':
        return Icons.eco;
      case 'raiz':
        return Icons.agriculture;
      case 'erva':
        return Icons.local_florist;
      case 'fruto':
        return Icons.apple;
      case 'grão':
        return Icons.grain;
      case 'leguminosa':
        return Icons.grass;
      default:
        return Icons.eco;
    }
  }
}
