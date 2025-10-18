import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore_models.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'search_screen.dart';
import 'plantio_screen.dart';

class PlantasScreen extends StatefulWidget {
  const PlantasScreen({super.key});

  @override
  State<PlantasScreen> createState() => _PlantasScreenState();
}

class _PlantasScreenState extends State<PlantasScreen> {
  List<Map<String, dynamic>> plantasPlantadas = [];
  List<Map<String, dynamic>> plantasFiltradas = [];
  String filtroAtual = 'Todas';
  bool isLoading = true;
  bool isProcessing = false; // Estado de loading para ações
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey<AnimatedListState>();

  final List<String> filtros = ['Todas', 'Hortaliças', 'Frutas', 'Ervas'];

  @override
  void initState() {
    super.initState();
    _loadPlantas();
  }

  Future<void> _loadPlantas() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          plantasPlantadas = [];
          plantasFiltradas = [];
          isLoading = false;
        });
        return;
      }

      // Carregar plantações do Firebase (apenas as não colhidas)
      final todasPlantacoes = await FirebaseService.getPlantacoesPorUsuario(user.uid);
      final plantacoesNaoColhidas = todasPlantacoes.where((p) => p['status'] != 'colhida').toList();
      
      // Agrupar plantações por canteiro e tipo de planta
      final plantacoesAgrupadas = _agruparPlantacoes(plantacoesNaoColhidas);
      
      setState(() {
        plantasPlantadas = plantacoesAgrupadas;
        plantasFiltradas = plantacoesAgrupadas;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar plantas: $e')),
      );
    }
  }

  List<Map<String, dynamic>> _agruparPlantacoes(List<Map<String, dynamic>> plantacoes) {
    // Agrupar por canteiro + tipo de planta
    final Map<String, List<Map<String, dynamic>>> grupos = {};
    
    for (var plantacao in plantacoes) {
      final canteiroId = plantacao['canteiroId'] ?? '';
      final dadosPlanta = plantacao['dadosPlanta'] as Map<String, dynamic>;
      final nomePlanta = dadosPlanta['nome'] ?? '';
      final chave = '$canteiroId-$nomePlanta';
      
      if (!grupos.containsKey(chave)) {
        grupos[chave] = [];
      }
      grupos[chave]!.add(plantacao);
    }
    
    // Criar entradas agrupadas
    final List<Map<String, dynamic>> plantacoesAgrupadas = [];
    
    for (var grupo in grupos.values) {
      if (grupo.isEmpty) continue;
      
      // Usar a primeira plantação como base
      final primeiraPlantacao = grupo.first;
      final dadosPlanta = primeiraPlantacao['dadosPlanta'] as Map<String, dynamic>;
      
      // Calcular totais
      int quantidadeTotal = 0;
      double estimativaTotal = 0.0;
      DateTime dataPlantioMaisAntiga = DateTime.now();
      
      for (var p in grupo) {
        quantidadeTotal += (p['quantidade'] ?? 1) as int;
        estimativaTotal += (p['estimativaColheita'] ?? 0.0) as double;
        
        final dataPlantio = (p['dataPlantio'] as Timestamp).toDate();
        if (dataPlantio.isBefore(dataPlantioMaisAntiga)) {
          dataPlantioMaisAntiga = dataPlantio;
        }
      }
      
      // Criar plantação agrupada
      final plantacaoAgrupada = {
        'id': primeiraPlantacao['id'], // ID da primeira plantação
        'canteiroId': primeiraPlantacao['canteiroId'],
        'dadosPlanta': dadosPlanta,
        'dataPlantio': Timestamp.fromDate(dataPlantioMaisAntiga),
        'quantidade': quantidadeTotal,
        'tipoQuantidade': primeiraPlantacao['tipoQuantidade'] ?? 'sementes',
        'estimativaColheita': estimativaTotal,
        'status': primeiraPlantacao['status'],
        'fotos': primeiraPlantacao['fotos'] ?? [],
        'observacoes': primeiraPlantacao['observacoes'] ?? '',
        'plantacoesOriginais': grupo, // Lista das plantações originais
      };
      
      plantacoesAgrupadas.add(plantacaoAgrupada);
    }
    
    return plantacoesAgrupadas;
  }

  void _aplicarFiltro(String filtro) {
    setState(() {
      filtroAtual = filtro;
      
      switch (filtro) {
        case 'Hortaliças':
          plantasFiltradas = plantasPlantadas.where((p) {
            final dadosPlanta = p['dadosPlanta'] as Map<String, dynamic>;
            final tipo = dadosPlanta['tipo']?.toString().toLowerCase() ?? '';
            return tipo.contains('folhosa') || tipo.contains('raiz');
          }).toList();
          break;
        case 'Frutas':
          plantasFiltradas = plantasPlantadas.where((p) {
            final dadosPlanta = p['dadosPlanta'] as Map<String, dynamic>;
            final tipo = dadosPlanta['tipo']?.toString().toLowerCase() ?? '';
            return tipo.contains('fruto');
          }).toList();
          break;
        case 'Ervas':
          plantasFiltradas = plantasPlantadas.where((p) {
            final dadosPlanta = p['dadosPlanta'] as Map<String, dynamic>;
            final tipo = dadosPlanta['tipo']?.toString().toLowerCase() ?? '';
            return tipo.contains('erva');
          }).toList();
          break;
        default:
          plantasFiltradas = plantasPlantadas;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'MINHAS PLANTAS',
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
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Filtro: ',
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
                      children: filtros.map((filtro) {
                        final isSelected = filtroAtual == filtro;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _aplicarFiltro(filtro),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? const Color(0xFF2E7D32)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF2E7D32),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                filtro,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Lista de plantas
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : plantasFiltradas.isEmpty
                    ? Center(
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
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPlantas,
                        child: AnimatedList(
                          key: _animatedListKey,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          initialItemCount: plantasFiltradas.length,
                          itemBuilder: (context, index, animation) {
                            if (index >= plantasFiltradas.length) return const SizedBox.shrink();
                            
                            final planta = plantasFiltradas[index];
                            return SlideTransition(
                              position: animation.drive(
                                Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).chain(CurveTween(curve: Curves.easeOut)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildPlantaCard(planta),
                              ),
                            );
                          },
                        ),
                      ),
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

  Widget _buildPlantaCard(Map<String, dynamic> plantacao) {
    // Debug: imprimir estrutura dos dados
    print('🔍 Dados da plantação recebidos:');
    print('ID: ${plantacao['id']}');
    print('Estrutura completa: $plantacao');
    
    final dadosPlanta = plantacao['dadosPlanta'] as Map<String, dynamic>;
    final nomePlanta = dadosPlanta['nome'] ?? 'Planta';
    final tipoPlanta = dadosPlanta['tipo'] ?? 'geral';
    final dataPlantio = (plantacao['dataPlantio'] as Timestamp).toDate();
    final diasPlantados = DateTime.now().difference(dataPlantio).inDays;
    
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
                  color: _getPlantaColor(tipoPlanta).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  _getPlantaIcon(tipoPlanta),
                  color: _getPlantaColor(tipoPlanta),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomePlanta,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 4),
                        Text(
                          'Plantada há $diasPlantados dias',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (plantacao['quantidade'] > 1) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${plantacao['quantidade']} ${plantacao['tipoQuantidade']} plantadas',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusChip(_getStatusPlanta(diasPlantados)),
                  const SizedBox(height: 4),
                  Text(
                    'Canteiro ${plantacao['canteiroId']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip('🌱 ${dadosPlanta['germinacao'] ?? 'N/A'}', Colors.green),
                  const SizedBox(width: 8),
                  _buildInfoChip('⏰ ${dadosPlanta['colheita'] ?? 'N/A'}', Colors.orange),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip('💧 ${dadosPlanta['rega'] ?? 'N/A'}', Colors.blue),
                  const SizedBox(width: 8),
                  _buildInfoChip('☀️ ${dadosPlanta['luz'] ?? 'N/A'}', Colors.yellow[700]!),
                ],
              ),
              if (plantacao['estimativaColheita'] > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoChip(
                      '📈 Est. colheita: ${plantacao['estimativaColheita'].toStringAsFixed(0)} unidades', 
                      Colors.purple
                    ),
                  ],
                ),
              ],
          const SizedBox(height: 12),
          // Botões de Ação
          _buildAcoesButtons(plantacao),
        ],
      ),
    );
  }

  String _getStatusPlanta(int diasPlantados) {
    if (diasPlantados < 7) {
      return 'Germinando';
    } else if (diasPlantados < 30) {
      return 'Crescendo';
    } else if (diasPlantados < 60) {
      return 'Florescendo';
    } else {
      return 'Pronta para colher';
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Germinando':
        color = Colors.blue;
        break;
      case 'Crescendo':
        color = Colors.green;
        break;
      case 'Florescendo':
        color = Colors.purple;
        break;
      case 'Pronta para colher':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
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

  void _adicionarPlanta() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlantioScreen(),
      ),
    );
  }

  Widget _buildAcoesButtons(Map<String, dynamic> plantacao) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ações Disponíveis:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildAcaoButton(
              '💧 Regar',
              Colors.blue,
              () => _executarAcao(plantacao, 'rega'),
            ),
            _buildAcaoButton(
              '🌿 Adubar',
              Colors.green,
              () => _executarAcao(plantacao, 'adubacao'),
            ),
            _buildAcaoButton(
              '✂️ Podar',
              Colors.orange,
              () => _executarAcao(plantacao, 'poda'),
            ),
            _buildAcaoButton(
              '🐛 Pragas',
              Colors.red,
              () => _executarAcao(plantacao, 'pragas'),
            ),
            _buildAcaoButton(
              '📸 Foto',
              Colors.purple,
              () => _executarAcao(plantacao, 'foto'),
            ),
            _buildAcaoButton(
              '📝 Nota',
              Colors.grey,
              () => _executarAcao(plantacao, 'nota'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Botões principais: Colher e Deletar
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : () => _colherPlantacao(plantacao),
                icon: isProcessing 
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.agriculture, size: 18),
                label: Text(isProcessing ? 'Colhendo...' : 'Colher'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : () => _deletarPlantacao(plantacao),
                icon: isProcessing 
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.delete, size: 18),
                label: Text(isProcessing ? 'Deletando...' : 'Deletar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAcaoButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _executarAcao(Map<String, dynamic> plantacao, String tipoAcao) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Criar tarefa de execução
      final tarefa = TarefaFirestore(
        id: '',
        usuarioId: user.uid,
        plantacaoId: plantacao['id'],
        titulo: _getTituloAcao(tipoAcao),
        descricao: _getDescricaoAcao(tipoAcao),
        dataHora: DateTime.now(),
        tipo: tipoAcao,
        concluida: true, // Marcar como concluída
        recorrente: false,
        prioridade: 'media',
      );

      await FirebaseService.createTarefa(tarefa);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${_getTituloAcao(tipoAcao)} executada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao executar ação: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getTituloAcao(String tipoAcao) {
    switch (tipoAcao) {
      case 'rega':
        return 'Rega executada';
      case 'adubacao':
        return 'Adubação executada';
      case 'poda':
        return 'Poda executada';
      case 'pragas':
        return 'Controle de pragas executado';
      case 'foto':
        return 'Foto registrada';
      case 'nota':
        return 'Nota adicionada';
      default:
        return 'Ação executada';
    }
  }

      String _getDescricaoAcao(String tipoAcao) {
        switch (tipoAcao) {
          case 'rega':
            return 'Planta regada com sucesso';
          case 'adubacao':
            return 'Adubação aplicada conforme necessário';
          case 'poda':
            return 'Poda realizada para melhor crescimento';
          case 'pragas':
            return 'Verificação e controle de pragas realizado';
          case 'foto':
            return 'Foto do progresso da planta registrada';
          case 'nota':
            return 'Observação adicionada ao registro da planta';
          default:
            return 'Ação realizada com sucesso';
        }
      }

      Future<void> _colherPlantacao(Map<String, dynamic> plantacao) async {
        if (isProcessing) return; // Evitar múltiplos cliques
        
        setState(() {
          isProcessing = true;
        });

        try {
          print('🌾 Iniciando colheita...');
          print('Plantação ID: ${plantacao['id']}');
          print('Dados da plantação: $plantacao');

          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            print('❌ Usuário não logado');
            return;
          }

          // Mostrar diálogo de confirmação
          final confirmar = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirmar Colheita'),
              content: Text(
                'Tem certeza que deseja colher ${plantacao['dadosPlanta']['nome']}? '
                'Esta ação marcará a plantação como colhida e a removerá da lista.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Colher'),
                ),
              ],
            ),
          );

          if (confirmar != true) {
            print('❌ Colheita cancelada pelo usuário');
            return;
          }

          print('✅ Confirmação recebida, atualizando plantação...');

          // Atualizar todas as plantações originais para "colhida"
          final plantacoesOriginais = plantacao['plantacoesOriginais'] as List<Map<String, dynamic>>;
          for (var p in plantacoesOriginais) {
            await FirebaseFirestore.instance
                .collection('plantacoes')
                .doc(p['id'])
                .update({
              'status': 'colhida',
              'dataColheita': FieldValue.serverTimestamp(),
            });
          }

          print('✅ Plantação atualizada no Firebase');

          // Remover com animação da lista local
          final index = plantasFiltradas.indexWhere((p) => p['id'] == plantacao['id']);
          if (index != -1) {
            setState(() {
              plantasPlantadas.removeWhere((p) => p['id'] == plantacao['id']);
              plantasFiltradas.removeAt(index);
            });
            
            // Animar a remoção
            _animatedListKey.currentState?.removeItem(
              index,
              (context, animation) => SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: Offset.zero,
                    end: const Offset(-1, 0),
                  ).chain(CurveTween(curve: Curves.easeIn)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPlantaCard(plantacao),
                ),
              ),
            );
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🌾 ${plantacao['dadosPlanta']['nome']} colhida com sucesso!'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } catch (e) {
          print('❌ Erro ao colher: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao colher: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          setState(() {
            isProcessing = false;
          });
        }
      }

      Future<void> _deletarPlantacao(Map<String, dynamic> plantacao) async {
        if (isProcessing) return; // Evitar múltiplos cliques
        
        setState(() {
          isProcessing = true;
        });

        try {
          print('🗑️ Iniciando exclusão...');
          print('Plantação ID: ${plantacao['id']}');
          print('Dados da plantação: $plantacao');

          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            print('❌ Usuário não logado');
            return;
          }

          // Mostrar diálogo de confirmação
          final confirmar = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirmar Exclusão'),
              content: Text(
                'Tem certeza que deseja deletar ${plantacao['dadosPlanta']['nome']}? '
                'Esta ação é irreversível e removerá todos os dados da plantação.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Deletar'),
                ),
              ],
            ),
          );

          if (confirmar != true) {
            print('❌ Exclusão cancelada pelo usuário');
            return;
          }

          print('✅ Confirmação recebida, deletando plantação...');

          // Deletar todas as plantações originais do Firebase
          final plantacoesOriginais = plantacao['plantacoesOriginais'] as List<Map<String, dynamic>>;
          for (var p in plantacoesOriginais) {
            await FirebaseFirestore.instance
                .collection('plantacoes')
                .doc(p['id'])
                .delete();
          }

          print('✅ Plantações deletadas do Firebase');

          // Deletar tarefas relacionadas
          for (var p in plantacoesOriginais) {
            final tarefasQuery = await FirebaseFirestore.instance
                .collection('tarefas')
                .where('plantacaoId', isEqualTo: p['id'])
                .get();

            for (var doc in tarefasQuery.docs) {
              await doc.reference.delete();
            }
          }

          print('✅ Tarefas relacionadas deletadas');

          // Deletar alertas relacionados
          for (var p in plantacoesOriginais) {
            final alertasQuery = await FirebaseFirestore.instance
                .collection('alertas')
                .where('plantacaoId', isEqualTo: p['id'])
                .get();

            for (var doc in alertasQuery.docs) {
              await doc.reference.delete();
            }
          }

          print('✅ Alertas relacionados deletados');

          // Remover com animação da lista local
          final index = plantasFiltradas.indexWhere((p) => p['id'] == plantacao['id']);
          if (index != -1) {
            setState(() {
              plantasPlantadas.removeWhere((p) => p['id'] == plantacao['id']);
              plantasFiltradas.removeAt(index);
            });
            
            // Animar a remoção
            _animatedListKey.currentState?.removeItem(
              index,
              (context, animation) => SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: Offset.zero,
                    end: const Offset(-1, 0),
                  ).chain(CurveTween(curve: Curves.easeIn)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPlantaCard(plantacao),
                ),
              ),
            );
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🗑️ ${plantacao['dadosPlanta']['nome']} deletada com sucesso!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          print('❌ Erro ao deletar: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao deletar: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          setState(() {
            isProcessing = false;
          });
        }
      }
}
