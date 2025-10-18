import 'package:flutter/material.dart';
import '../models/planta.dart';

class CategoriaCard extends StatelessWidget {
  final CategoriaPlantas categoria;
  final VoidCallback onTap;

  const CategoriaCard({
    super.key,
    required this.categoria,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getCategoriaColor(categoria.nome).withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                _getCategoriaIcon(categoria.nome),
                color: _getCategoriaColor(categoria.nome),
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                categoria.nome,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF424242),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${categoria.plantas.length} plantas',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoriaColor(String nome) {
    switch (nome) {
      case 'Hortaliças Folhosas':
        return const Color(0xFF4CAF50);
      case 'Legumes de Raiz':
        return const Color(0xFFFF9800);
      case 'Ervas e Temperos':
        return const Color(0xFF9C27B0);
      case 'Frutíferas':
        return const Color(0xFFE91E63);
      case 'Outros':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  IconData _getCategoriaIcon(String nome) {
    switch (nome) {
      case 'Hortaliças Folhosas':
        return Icons.eco;
      case 'Legumes de Raiz':
        return Icons.agriculture;
      case 'Ervas e Temperos':
        return Icons.local_florist;
      case 'Frutíferas':
        return Icons.apple;
      case 'Outros':
        return Icons.grass;
      default:
        return Icons.eco;
    }
  }
}
