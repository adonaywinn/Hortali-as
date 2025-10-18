import 'package:flutter/material.dart';
import '../models/planta.dart';
import '../services/planta_service.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'search_screen.dart';
import 'adicionar_planta_screen.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> with TickerProviderStateMixin {
  List<CategoriaPlantas> categorias = [];
  List<Map<String, dynamic>> plantasPersonalizadas = [];
  String categoriaSelecionada = 'Todas';
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCategorias();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategorias() async {
    try {
      // Carregar categorias do JSON
      final cats = await PlantaService.getCategorias();
      
      // Carregar plantas personalizadas do Firebase
      final user = FirebaseAuth.instance.currentUser;
      List<Map<String, dynamic>> personalizadas = [];
      if (user != null) {
        personalizadas = await FirebaseService.getPlantasPersonalizadas(user.uid);
      }
      
      setState(() {
        categorias = cats;
        plantasPersonalizadas = personalizadas;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar inventário: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'INVENTÁRIO DE PLANTAS',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Para Plantio', icon: Icon(Icons.eco)),
            Tab(text: 'Plantadas', icon: Icon(Icons.agriculture)),
            Tab(text: 'Colhidas', icon: Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabParaPlantio(),
          _buildTabPlantadas(),
          _buildTabColhidas(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdicionarPlantaScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoriaChip(String nome) {
    final isSelected = categoriaSelecionada == nome;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            categoriaSelecionada = nome;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF2E7D32),
              width: 1,
            ),
          ),
          child: Text(
            nome,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF2E7D32),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListaPlantas() {
    List<Planta> plantasParaMostrar = [];
    List<Map<String, dynamic>> plantasPersonalizadasParaMostrar = [];
    
    if (categoriaSelecionada == 'Todas') {
      // Adicionar plantas do JSON
      for (var categoria in categorias) {
        plantasParaMostrar.addAll(categoria.plantas);
      }
      // Adicionar plantas personalizadas
      plantasPersonalizadasParaMostrar = plantasPersonalizadas;
    } else {
      // Filtrar plantas do JSON por categoria
      final categoria = categorias.firstWhere(
        (cat) => cat.nome == categoriaSelecionada,
        orElse: () => CategoriaPlantas(nome: '', plantas: []),
      );
      plantasParaMostrar = categoria.plantas;
      
      // Filtrar plantas personalizadas por categoria
      plantasPersonalizadasParaMostrar = plantasPersonalizadas.where((planta) {
        return planta['categoria'] == _getCategoriaKey(categoriaSelecionada);
      }).toList();
    }

    if (plantasParaMostrar.isEmpty && plantasPersonalizadasParaMostrar.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma planta encontrada',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente outra categoria ou adicione uma nova planta',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    final totalPlantas = plantasParaMostrar.length + plantasPersonalizadasParaMostrar.length;
    
    return RefreshIndicator(
      onRefresh: _loadCategorias,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: totalPlantas,
        itemBuilder: (context, index) {
          if (index < plantasParaMostrar.length) {
            // Planta do JSON
            final planta = plantasParaMostrar[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPlantaCard(planta),
            );
          } else {
            // Planta personalizada
            final plantaPersonalizada = plantasPersonalizadasParaMostrar[index - plantasParaMostrar.length];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPlantaPersonalizadaCard(plantaPersonalizada),
            );
          }
        },
      ),
    );
  }

  Widget _buildPlantaCard(Planta planta) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planta.nome,
                      style: const TextStyle(
                        fontSize: 18,
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
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _mostrarDetalhes(planta),
                icon: const Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip('🌱 ${planta.germinacao}', Colors.green),
              const SizedBox(width: 8),
              _buildInfoChip('⏰ ${planta.colheita}', Colors.orange),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip('💧 ${planta.rega}', Colors.blue),
              const SizedBox(width: 8),
              _buildInfoChip('☀️ ${planta.luz}', Colors.yellow[700]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
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
      default:
        return Icons.eco;
    }
  }

  void _mostrarDetalhes(Planta planta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(planta.nome),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Tipo', planta.tipo),
              _buildDetailRow('Luz', planta.luz),
              _buildDetailRow('Rega', planta.rega),
              _buildDetailRow('Temperatura', planta.temperatura),
              _buildDetailRow('Solo', planta.soloIdeal),
              _buildDetailRow('Espaçamento', planta.espacamento),
              _buildDetailRow('Germinação', planta.germinacao),
              _buildDetailRow('Colheita', planta.colheita),
              const SizedBox(height: 8),
              Text(
                'Cuidados:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(planta.cuidados),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantaPersonalizadaCard(Map<String, dynamic> plantaPersonalizada) {
    final planta = plantaPersonalizada['planta'] as Map<String, dynamic>;
    final categoria = plantaPersonalizada['categoria'] as String;
    
    return Container(
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
        border: Border.all(
          color: const Color(0xFF2E7D32).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.add_circle,
                  color: Color(0xFF2E7D32),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planta['nome'] ?? 'Planta Personalizada',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCategoriaLabel(categoria),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _mostrarDetalhesPersonalizada(plantaPersonalizada),
                icon: const Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip('🌱 ${planta['germinacao'] ?? 'N/A'}', Colors.green),
              const SizedBox(width: 8),
              _buildInfoChip('⏰ ${planta['colheita'] ?? 'N/A'}', Colors.orange),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip('💧 ${planta['rega'] ?? 'N/A'}', Colors.blue),
              const SizedBox(width: 8),
              _buildInfoChip('☀️ ${planta['luz'] ?? 'N/A'}', Colors.yellow[700]!),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Personalizada',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoriaKey(String categoriaNome) {
    switch (categoriaNome) {
      case 'Hortaliças Folhosas':
        return 'hortalicas';
      case 'Legumes de Raiz':
        return 'legumes_raizes';
      case 'Ervas e Temperos':
        return 'ervas_temperos';
      case 'Frutíferas':
        return 'frutiferas';
      case 'Outros':
        return 'extras';
      default:
        return 'hortalicas';
    }
  }

  String _getCategoriaLabel(String categoriaKey) {
    switch (categoriaKey) {
      case 'hortalicas':
        return 'Hortaliças Folhosas';
      case 'legumes_raizes':
        return 'Legumes de Raiz';
      case 'ervas_temperos':
        return 'Ervas e Temperos';
      case 'frutiferas':
        return 'Frutíferas';
      case 'extras':
        return 'Outros';
      default:
        return 'Personalizada';
    }
  }

  void _mostrarDetalhesPersonalizada(Map<String, dynamic> plantaPersonalizada) {
    final planta = plantaPersonalizada['planta'] as Map<String, dynamic>;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(planta['nome'] ?? 'Planta Personalizada'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Tipo', planta['tipo'] ?? 'N/A'),
              _buildDetailRow('Luz', planta['luz'] ?? 'N/A'),
              _buildDetailRow('Rega', planta['rega'] ?? 'N/A'),
              _buildDetailRow('Temperatura', planta['temperatura'] ?? 'N/A'),
              _buildDetailRow('Solo', planta['soloIdeal'] ?? 'N/A'),
              _buildDetailRow('Espaçamento', planta['espacamento'] ?? 'N/A'),
              _buildDetailRow('Germinação', planta['germinacao'] ?? 'N/A'),
              _buildDetailRow('Colheita', planta['colheita'] ?? 'N/A'),
              const SizedBox(height: 8),
              Text(
                'Cuidados:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(planta['cuidados'] ?? 'Nenhum cuidado especial'),
              if (planta['observacao'] != null && planta['observacao'].isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Observações:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(planta['observacao']),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabParaPlantio() {
    return Column(
      children: [
        // Filtros de categoria
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Categoria: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoriaChip('Todas'),
                      ...categorias.map((cat) => _buildCategoriaChip(cat.nome)),
                      _buildCategoriaChip('Personalizadas'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Lista de plantas disponíveis para plantio
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildListaPlantas(),
        ),
      ],
    );
  }

  Widget _buildTabPlantadas() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Plantas em desenvolvimento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.agriculture,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma planta plantada',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Plante algo para ver suas plantas aqui!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabColhidas() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Plantas já colhidas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma planta colhida',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Colha suas plantas para ver o histórico aqui!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
