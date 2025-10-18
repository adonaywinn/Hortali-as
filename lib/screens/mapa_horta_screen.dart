import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import 'adicionar_canteiro_screen.dart';

class MapaHortaScreen extends StatefulWidget {
  const MapaHortaScreen({super.key});

  @override
  State<MapaHortaScreen> createState() => _MapaHortaScreenState();
}

class _MapaHortaScreenState extends State<MapaHortaScreen> {
  List<Map<String, dynamic>> canteiros = [];
  String? canteiroSelecionado;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCanteiros();
  }

  Future<void> _loadCanteiros() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          canteiros = [];
          isLoading = false;
        });
        return;
      }

      // Carregar canteiros do Firebase
      final canteirosFirebase = await FirebaseService.getCanteirosPorUsuario(user.uid);
      
      setState(() {
        canteiros = canteirosFirebase;
        isLoading = false;
      });

      print('✅ Canteiros carregados: ${canteiros.length}');
    } catch (e) {
      print('❌ Erro ao carregar canteiros: $e');
      setState(() {
        canteiros = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'MAPA DA HORTA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Vista aérea esquemática
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: canteiros.isEmpty
                        ? _buildEmptyState()
                        : _buildVistaAerea(),
                  ),
                ),
                // Informações do canteiro selecionado
                if (canteiroSelecionado != null)
                  Expanded(
                    flex: 1,
                    child: _buildInfoCanteiro(),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarPlanta,
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildVistaAerea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vista aérea (esquemático)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'N ↑',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Mapa
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: canteiros.length,
                itemBuilder: (context, index) {
                  final canteiro = canteiros[index];
                  final isSelected = canteiroSelecionado == canteiro['id'];
                  
                  return GestureDetector(
                    onTap: () => _selecionarCanteiro(canteiro['id']),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getCanteiroColor(canteiro['status'] ?? 'Disponível'),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[300]!,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getCanteiroIcon(canteiro['tipo'] ?? 'Geral'),
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            canteiro['nome'] ?? 'Canteiro',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            canteiro['tipo'] ?? 'Geral',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCanteiro() {
    if (canteiroSelecionado == null) return const SizedBox();
    
    final canteiro = canteiros.firstWhere((c) => c['id'] == canteiroSelecionado);
    
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'INFO → ${canteiro['nome'] ?? 'Canteiro'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => canteiroSelecionado = null),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            (canteiro['tipo'] ?? 'Geral') == 'Disponível' 
                ? 'Canteiro disponível para plantio'
                : '${canteiro['tipo'] ?? 'Geral'} x12 | Humidade ${(canteiro['humidade'] ?? 0.0).toInt()}%',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip('Temp', '${(canteiro['temperatura'] ?? 0.0).toInt()}°C'),
              const SizedBox(width: 8),
              _buildInfoChip('Status', canteiro['status'] ?? 'Disponível'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF2E7D32),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getCanteiroColor(String status) {
    switch (status) {
      case 'Saudável':
        return Colors.green;
      case 'Precisa regar':
        return Colors.orange;
      case 'Praga detectada':
        return Colors.red;
      case 'Disponível':
        return Colors.grey[300]!;
      default:
        return Colors.grey;
    }
  }

  IconData _getCanteiroIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'alface':
        return Icons.eco;
      case 'tomate':
        return Icons.apple;
      case 'maracujá':
        return Icons.local_florist;
      case 'batata-doce':
        return Icons.agriculture;
      case 'disponível':
        return Icons.add_circle_outline;
      default:
        return Icons.add_circle_outline;
    }
  }

  void _selecionarCanteiro(String canteiroId) {
    setState(() {
      canteiroSelecionado = canteiroId;
    });
  }

  Widget _buildEmptyState() {
    return Container(
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum canteiro criado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Crie seu primeiro canteiro para começar!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _adicionarPlanta,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Criar Primeiro Canteiro',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _adicionarPlanta() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdicionarCanteiroScreen(),
      ),
    );
    
    // Recarregar canteiros após criar um novo
    if (result == true) {
      await _loadCanteiros();
    }
  }
}
