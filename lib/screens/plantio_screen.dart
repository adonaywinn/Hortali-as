import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/planta.dart';
import '../models/firestore_models.dart';
import '../services/planta_service.dart';
import '../services/controle_automatico_service.dart';
import '../services/firebase_service.dart';
import '../widgets/monitoring_preview_widget.dart';
import 'adicionar_canteiro_screen.dart';

class PlantioScreen extends StatefulWidget {
  const PlantioScreen({super.key});

  @override
  State<PlantioScreen> createState() => _PlantioScreenState();
}

class _PlantioScreenState extends State<PlantioScreen> {
  int _etapaAtual = 0;
  String? _canteiroSelecionado;
  Planta? _plantaSelecionada;
  List<Planta> _plantasDisponiveis = [];
  List<Map<String, dynamic>> _canteiros = [];
  bool _isLoading = true;
  
  // Campos de quantidade
  final TextEditingController _quantidadeController = TextEditingController();
  String _tipoQuantidade = 'sementes';
  int _quantidade = 1;
  double _estimativaColheita = 0.0;
  bool _isPlanting = false; // Estado de carregamento

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _quantidadeController.text = '1';
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    await Future.wait([
      _carregarPlantas(),
      _carregarCanteiros(),
    ]);
  }

  Future<void> _carregarCanteiros() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Carregar canteiros do Firebase
      final canteiros = await FirebaseService.getCanteirosPorUsuario(user.uid);
      
      setState(() {
        _canteiros = canteiros;
      });
    } catch (e) {
      print('Erro ao carregar canteiros: $e');
      setState(() {
        _canteiros = [];
      });
    }
  }

  void _calcularEstimativaColheita() {
    if (_plantaSelecionada == null || _quantidade == 0) {
      _estimativaColheita = 0.0;
      return;
    }

    // Fatores de estimativa baseados no tipo de planta
    double fatorEstimativa = _getFatorEstimativa(_plantaSelecionada!.tipo);
    
    // Calcular estimativa baseada na quantidade plantada
    _estimativaColheita = _quantidade * fatorEstimativa;
    
    setState(() {});
  }

  double _getFatorEstimativa(String tipoPlanta) {
    switch (tipoPlanta.toLowerCase()) {
      case 'folhosa':
        return 0.8; // 80% das sementes viram plantas colhíveis
      case 'raiz':
        return 0.7; // 70% das sementes viram raízes colhíveis
      case 'erva':
        return 0.9; // 90% das sementes viram ervas colhíveis
      case 'fruto':
        return 0.6; // 60% das sementes viram frutos colhíveis
      default:
        return 0.75; // 75% padrão
    }
  }

  Future<void> _carregarPlantas() async {
    try {
      final plantas = await PlantaService.getAllPlantas();
      setState(() {
        _plantasDisponiveis = plantas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar plantas: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _getTituloEtapa(),
          style: const TextStyle(
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
      body: Column(
        children: [
          // Progresso
          _buildProgresso(),
          
          // Conteúdo da etapa
          Expanded(
            child: _buildConteudoEtapa(),
          ),
          
          // Botões de navegação
          _buildBotoesNavegacao(),
        ],
      ),
    );
  }

  Widget _buildProgresso() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: List.generate(3, (index) {
              final isActive = index <= _etapaAtual;
              final isCompleted = index < _etapaAtual;
              
              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive 
                            ? const Color(0xFF2E7D32)
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive ? Colors.white : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    if (index < 2)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted 
                              ? const Color(0xFF2E7D32)
                              : Colors.grey[300],
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _getDescricaoEtapa(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConteudoEtapa() {
    switch (_etapaAtual) {
      case 0:
        return _buildSelecaoCanteiro();
      case 1:
        return _buildSelecaoPlanta();
      case 2:
        return _buildConfirmacaoPlantio();
      default:
        return const SizedBox();
    }
  }

  Widget _buildSelecaoCanteiro() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Escolha o canteiro para plantar:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _canteiros.isEmpty
                ? _buildEmptyCanteiros()
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _canteiros.length,
                    itemBuilder: (context, index) {
                      final canteiro = _canteiros[index];
                      final isSelected = _canteiroSelecionado == canteiro['id'];
                      final isDisponivel = canteiro['status'] == "Disponível";
                      
                      return GestureDetector(
                        onTap: isDisponivel ? () => _selecionarCanteiro(canteiro['id']) : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDisponivel 
                                ? (isSelected ? const Color(0xFF2E7D32) : Colors.white)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected 
                                  ? const Color(0xFF2E7D32)
                                  : Colors.grey[300]!,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isDisponivel ? Icons.eco : Icons.block,
                                color: isDisponivel 
                                    ? (isSelected ? Colors.white : const Color(0xFF2E7D32))
                                    : Colors.grey[400],
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                canteiro['nome'],
                                style: TextStyle(
                                  color: isDisponivel 
                                      ? (isSelected ? Colors.white : const Color(0xFF2E7D32))
                                      : Colors.grey[400],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isDisponivel ? "Disponível" : "Ocupado",
                                style: TextStyle(
                                  color: isDisponivel 
                                      ? (isSelected ? Colors.white70 : Colors.grey[600])
                                      : Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelecaoPlanta() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Escolha a espécie do inventário:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          // Campos de quantidade (só aparecem quando uma planta é selecionada)
          if (_plantaSelecionada != null) ...[
            _buildCamposQuantidade(),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: ListView.builder(
              itemCount: _plantasDisponiveis.length,
              itemBuilder: (context, index) {
                final planta = _plantasDisponiveis[index];
                final isSelected = _plantaSelecionada?.nome == planta.nome;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _selecionarPlanta(planta),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: (isSelected ? Colors.white : const Color(0xFF2E7D32)).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Icon(
                              _getPlantaIcon(planta.tipo),
                              color: isSelected ? Colors.white : const Color(0xFF2E7D32),
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
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  planta.tipo,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected ? Colors.white70 : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Colheita: ${planta.colheita}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white70 : Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmacaoPlantio() {
    if (_plantaSelecionada == null || _canteiroSelecionado == null) {
      return const Center(
        child: Text('Erro: Dados não selecionados'),
      );
    }

    final canteiro = _canteiros.firstWhere((c) => c['id'] == _canteiroSelecionado);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirme o plantio:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 16),
          
          // Card de confirmação
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        _getPlantaIcon(_plantaSelecionada!.tipo),
                        color: const Color(0xFF2E7D32),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _plantaSelecionada!.nome,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          Text(
                            '${canteiro['nome']} • ${_plantaSelecionada!.tipo}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Informações da planta
                _buildInfoPlanta('Germinação', _plantaSelecionada!.germinacao),
                _buildInfoPlanta('Colheita', _plantaSelecionada!.colheita),
                _buildInfoPlanta('Espaçamento', _plantaSelecionada!.espacamento),
                _buildInfoPlanta('Luz', _plantaSelecionada!.luz),
                _buildInfoPlanta('Rega', _plantaSelecionada!.rega),
                
                const SizedBox(height: 20),
                
                // Aviso automático
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF4CAF50),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'O app criará automaticamente todo o controle para esta plantação!',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPlanta(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotoesNavegacao() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_etapaAtual > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _etapaAnterior,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Voltar'),
              ),
            ),
          if (_etapaAtual > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isPlanting ? null : (_podeAvancar() ? _proximaEtapa : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isPlanting
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Plantando...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      _etapaAtual == 2 ? 'PLANTAR!' : 'Continuar',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTituloEtapa() {
    switch (_etapaAtual) {
      case 0:
        return 'Escolher Canteiro';
      case 1:
        return 'Escolher Planta';
      case 2:
        return 'Confirmar Plantio';
      default:
        return 'Plantar';
    }
  }

  String _getDescricaoEtapa() {
    switch (_etapaAtual) {
      case 0:
        return 'Selecione onde você quer plantar';
      case 1:
        return 'Escolha a espécie do seu inventário';
      case 2:
        return 'Confirme e o app cuidará de tudo!';
      default:
        return '';
    }
  }

  bool _podeAvancar() {
    switch (_etapaAtual) {
      case 0:
        return _canteiroSelecionado != null;
      case 1:
        return _plantaSelecionada != null;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _selecionarCanteiro(String canteiroId) {
    setState(() {
      _canteiroSelecionado = canteiroId;
    });
  }

  void _selecionarPlanta(Planta planta) {
    setState(() {
      _plantaSelecionada = planta;
      _calcularEstimativaColheita();
    });
  }

  Widget _buildCamposQuantidade() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2E7D32).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantidade para ${_plantaSelecionada?.nome}:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _tipoQuantidade,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'sementes', child: Text('Sementes')),
                    DropdownMenuItem(value: 'mudas', child: Text('Mudas')),
                    DropdownMenuItem(value: 'bulbos', child: Text('Bulbos')),
                    DropdownMenuItem(value: 'estacas', child: Text('Estacas')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _tipoQuantidade = value!;
                      _calcularEstimativaColheita();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _quantidadeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _quantidade = int.tryParse(value) ?? 1;
                      _calcularEstimativaColheita();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.analytics, color: Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                Text(
                  'Estimativa de colheita: ${_estimativaColheita.toStringAsFixed(0)} unidades',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _etapaAnterior() {
    if (_etapaAtual > 0) {
      setState(() {
        _etapaAtual--;
      });
    }
  }

  void _proximaEtapa() {
    if (_isPlanting) return; // Não executar durante o loading
    
    print('🔄 Próxima etapa chamada. Etapa atual: $_etapaAtual');
    if (_etapaAtual < 2) {
      setState(() {
        _etapaAtual++;
      });
    } else {
      print('🌱 Chamando _confirmarPlantio...');
      _confirmarPlantio();
    }
  }

  void _confirmarPlantio() async {
    if (_isPlanting) return; // Evitar múltiplos cliques
    
    setState(() {
      _isPlanting = true;
    });
    
    try {
      print('🌱 Iniciando processo de plantio...');
      
      // Obter usuário atual ou criar anônimo
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        try {
          final userCredential = await FirebaseAuth.instance.signInAnonymously();
          user = userCredential.user;
        } catch (e) {
          print('❌ Erro ao autenticar: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao autenticar: $e')),
          );
          return;
        }
      }

    // Criar plantação no Firebase
    final plantacao = Plantacao(
      id: '',
      usuarioId: user!.uid,
      canteiroId: _canteiroSelecionado!,
      plantaNome: _plantaSelecionada!.nome,
      plantaTipo: _plantaSelecionada!.tipo,
      dataPlantio: DateTime.now(),
      quantidade: _quantidade,
      tipoQuantidade: _tipoQuantidade,
      estimativaColheita: _estimativaColheita,
      status: 'plantada',
      dadosPlanta: _plantaSelecionada!.toJson(),
      fotos: [],
      observacoes: '',
    );

    print('💾 Salvando plantação no Firebase...');
    await FirebaseService.createPlantacao(plantacao);
    print('✅ Plantação salva com sucesso!');

    print('🤖 Criando controle automático...');
    // Criar controle automático para a plantação
    await ControleAutomaticoService.criarControleAutomatico(
      usuarioId: user.uid,
      canteiroId: _canteiroSelecionado!,
      planta: _plantaSelecionada!,
      dataPlantio: DateTime.now(),
    );
    print('✅ Controle automático criado!');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 32),
            SizedBox(width: 12),
            Text('Plantio Confirmado!'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✅ ${_plantaSelecionada!.nome} plantada em ${_canteiros.firstWhere((c) => c['id'] == _canteiroSelecionado)['nome']}'),
              const SizedBox(height: 8),
              Text('📊 Quantidade: $_quantidade $_tipoQuantidade'),
              Text('📈 Estimativa de colheita: ${_estimativaColheita.toStringAsFixed(0)} unidades'),
              const SizedBox(height: 16),
              
              // Preview do monitoramento
              MonitoringPreviewWidget(
                planta: _plantaSelecionada!,
                dataPlantio: DateTime.now(),
              ),
              
              const SizedBox(height: 16),
              const Text(
                '🎯 O app criou automaticamente todo o monitoramento personalizado para esta planta!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fecha o dialog
              Navigator.pop(context); // Volta para o dashboard
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Perfeito!'),
          ),
        ],
      ),
    );
    } catch (e) {
      print('❌ Erro durante o plantio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao plantar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isPlanting = false;
      });
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

  Widget _buildEmptyCanteiros() {
    return Center(
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
            'Nenhum canteiro disponível',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Você precisa criar um canteiro primeiro',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdicionarCanteiroScreen(),
                ),
              );
              
              // Recarregar canteiros após criar um novo
              if (result == true) {
                _carregarCanteiros();
              }
            },
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
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Voltar',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
