import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/horta_data.dart';
import '../widgets/status_card.dart';
import '../widgets/tarefa_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/sync_status_widget.dart';
import '../services/data_sync_service.dart';
import '../services/firebase_service.dart';
import 'mapa_horta_screen.dart';
import 'plantas_screen.dart';
import 'inventario_screen.dart';
import 'agenda_screen.dart';
import 'plantio_screen.dart';
import 'auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late StatusGeral statusGeral;
  List<Map<String, dynamic>> tarefasHoje = [];
  List<Map<String, dynamic>> alertas = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _syncDataOnLogin();
  }

  Future<void> _loadDashboardData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Usuário não logado - dados zerados
        statusGeral = StatusGeral(
          totalCanteiros: 0,
          alertasPragas: 0,
          proximaColheita: "Nenhuma",
          diasProximaColheita: 0,
          nivelAgua: 0.0,
          clima: "☀️",
          temperatura: 25.0,
        );
        tarefasHoje = [];
        alertas = [];
        return;
      }

      // Carregar dados reais do Firebase
      final plantacoes = await FirebaseService.getPlantacoesPorUsuario(user.uid);
      final canteiros = await FirebaseService.getCanteirosPorUsuario(user.uid);
      final tarefas = await FirebaseService.getTarefasPorUsuario(user.uid);
      final alertasFirebase = await FirebaseService.getAlertasPorUsuario(user.uid);

      // Agrupar plantações por canteiro (apenas 1 entrada por canteiro)
      final plantacoesAgrupadas = _agruparPlantacoesPorCanteiro(plantacoes);

      // Calcular estatísticas
      final totalCanteiros = canteiros.length;
      final alertasPragas = alertasFirebase.where((a) => a['tipo'] == 'praga').length;
      
      // Encontrar próxima colheita
      String proximaColheita = "Nenhuma";
      int diasProximaColheita = 0;
      
      if (plantacoesAgrupadas.isNotEmpty) {
        // Ordenar por data de plantio e calcular colheita
        plantacoesAgrupadas.sort((a, b) {
          final dataA = (a['dataPlantio'] as Timestamp).toDate();
          final dataB = (b['dataPlantio'] as Timestamp).toDate();
          return dataA.compareTo(dataB);
        });
        
        final primeiraPlantacao = plantacoesAgrupadas.first;
        final dadosPlanta = primeiraPlantacao['dadosPlanta'] as Map<String, dynamic>;
        proximaColheita = dadosPlanta['nome'] ?? 'Planta';
        
        // Calcular dias para colheita (assumindo 30 dias como padrão)
        final dataPlantio = (primeiraPlantacao['dataPlantio'] as Timestamp).toDate();
        final diasPlantados = DateTime.now().difference(dataPlantio).inDays;
        diasProximaColheita = 30 - diasPlantados; // Assumindo 30 dias para colheita
      }

      // Filtrar tarefas de hoje
      final hoje = DateTime.now();
      final tarefasHojeFiltradas = tarefas.where((tarefa) {
        final dataTarefa = (tarefa['dataHora'] as Timestamp).toDate();
        return dataTarefa.year == hoje.year && 
               dataTarefa.month == hoje.month && 
               dataTarefa.day == hoje.day;
      }).toList();

      setState(() {
        statusGeral = StatusGeral(
          totalCanteiros: totalCanteiros,
          alertasPragas: alertasPragas,
          proximaColheita: proximaColheita,
          diasProximaColheita: diasProximaColheita,
          nivelAgua: 75.0, // Valor padrão
          clima: "☀️",
          temperatura: 25.0,
        );

        tarefasHoje = tarefasHojeFiltradas;
        alertas = alertasFirebase;
      });

      print('✅ Dashboard carregado com dados reais:');
      print('   - Canteiros: $totalCanteiros');
      print('   - Plantações agrupadas: ${plantacoesAgrupadas.length}');
      print('   - Tarefas hoje: ${tarefasHojeFiltradas.length}');
      print('   - Alertas: ${alertasFirebase.length}');

    } catch (e) {
      print('❌ Erro ao carregar dados do dashboard: $e');
      // Em caso de erro, usar dados zerados
      statusGeral = StatusGeral(
        totalCanteiros: 0,
        alertasPragas: 0,
        proximaColheita: "Nenhuma",
        diasProximaColheita: 0,
        nivelAgua: 0.0,
        clima: "☀️",
        temperatura: 25.0,
      );
      tarefasHoje = [];
      alertas = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HORTAPP',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            Text(
              '🌿 Machuca — Aquiraz',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () => _showAlertas(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.account_circle, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status de Sincronização
              const SyncStatusWidget(),
              
              // Header com data e clima
              _buildHeader(),
              const SizedBox(height: 20),
              
              // Status Geral
              _buildStatusGeral(),
              const SizedBox(height: 20),
              
              // Botão Principal - Plantar
              _buildBotaoPlantar(),
              const SizedBox(height: 20),
              
              // Ações Rápidas
              _buildAcoesRapidas(),
              const SizedBox(height: 20),
              
              // Tarefas do Dia
              _buildTarefasHoje(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final dataFormatada = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    
    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hoje: $dataFormatada',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Clima: ${statusGeral.clima} ${statusGeral.temperatura.toInt()}°C',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${statusGeral.temperatura.toInt()}°C',
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGeral() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'STATUS GERAL:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatusCard(
                titulo: 'Canteiros',
                valor: '${statusGeral.totalCanteiros}',
                icone: Icons.eco,
                cor: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatusCard(
                titulo: 'Pragas',
                valor: '${statusGeral.alertasPragas} alerta',
                icone: Icons.warning,
                cor: statusGeral.alertasPragas > 0 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatusCard(
                titulo: 'Próx. colheita',
                valor: '${statusGeral.proximaColheita} (${statusGeral.diasProximaColheita}d)',
                icone: Icons.agriculture,
                cor: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatusCard(
                titulo: 'Água',
                valor: 'Caixa ${statusGeral.nivelAgua.toInt()}%',
                icone: Icons.water_drop,
                cor: statusGeral.nivelAgua < 30 ? Colors.red : Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBotaoPlantar() {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _iniciarPlantio,
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 32,
                ),
                SizedBox(width: 12),
                Text(
                  'PLANTAR AGORA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAcoesRapidas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ações Rápidas:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionButton(
                titulo: 'Mapear Horta',
                icone: Icons.map,
                cor: Colors.blue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapaHortaScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionButton(
                titulo: 'Minhas Plantas',
                icone: Icons.eco,
                cor: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlantasScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionButton(
                titulo: 'Agenda',
                icone: Icons.calendar_today,
                cor: Colors.purple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AgendaScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTarefasHoje() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tarefas rápidas:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 12),
        if (tarefasHoje.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.grey[400]),
                const SizedBox(width: 12),
                Text(
                  'Nenhuma tarefa para hoje',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          ...tarefasHoje.map((tarefaMap) {
            final tarefa = Tarefa(
              id: tarefaMap['id'] ?? '',
              titulo: tarefaMap['titulo'] ?? '',
              descricao: tarefaMap['descricao'] ?? '',
              dataHora: (tarefaMap['dataHora'] as Timestamp).toDate(),
              tipo: tarefaMap['tipo'] ?? '',
              canteiroId: tarefaMap['plantacaoId'] ?? '',
              concluida: tarefaMap['concluida'] ?? false,
              recorrente: tarefaMap['recorrente'] ?? false,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TarefaCard(
                tarefa: tarefa,
                onTap: () => _mostrarMenuAcoesRapidas(tarefaMap),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF2E7D32),
      unselectedItemColor: Colors.grey[600],
      currentIndex: 0,
      onTap: (index) => _navigateToTab(index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Mapa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.eco),
          label: 'Plantas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Agenda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Inventário',
        ),
      ],
    );
  }

  void _navigateToTab(int index) {
    switch (index) {
      case 0:
        // Já estamos na home
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MapaHortaScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PlantasScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AgendaScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InventarioScreen()),
        );
        break;
    }
  }


  void _showAlertas() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Alertas Recentes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
              Expanded(
                child: alertas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum alerta',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tudo em ordem!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: alertas.length,
                        itemBuilder: (context, index) {
                          final alertaMap = alertas[index];
                          final dataHora = (alertaMap['dataHora'] as Timestamp).toDate();
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                Icons.warning,
                                color: alertaMap['prioridade'] == 'alta' ? Colors.red : Colors.orange,
                              ),
                              title: Text(alertaMap['titulo'] ?? ''),
                              subtitle: Text(alertaMap['descricao'] ?? ''),
                              trailing: Text(
                                '${dataHora.hour.toString().padLeft(2, '0')}:${dataHora.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _iniciarPlantio() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlantioScreen(),
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao sair: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    // Simular carregamento
    await Future.delayed(const Duration(seconds: 1));
    _loadDashboardData();
    setState(() {});
  }

  List<Map<String, dynamic>> _agruparPlantacoesPorCanteiro(List<Map<String, dynamic>> plantacoes) {
    // Agrupar por canteiro (apenas 1 entrada por canteiro)
    final Map<String, Map<String, dynamic>> grupos = {};
    
    for (var plantacao in plantacoes) {
      final canteiroId = plantacao['canteiroId'] ?? '';
      
      if (!grupos.containsKey(canteiroId)) {
        // Primeira plantação deste canteiro
        grupos[canteiroId] = plantacao;
      } else {
        // Já existe uma plantação neste canteiro, manter a mais antiga
        final plantacaoExistente = grupos[canteiroId]!;
        final dataExistente = (plantacaoExistente['dataPlantio'] as Timestamp).toDate();
        final dataAtual = (plantacao['dataPlantio'] as Timestamp).toDate();
        
        if (dataAtual.isBefore(dataExistente)) {
          grupos[canteiroId] = plantacao;
        }
      }
    }
    
    return grupos.values.toList();
  }

  void _mostrarMenuAcoesRapidas(Map<String, dynamic> tarefa) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações Rápidas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha uma ação para ${tarefa['titulo']}:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            _buildAcaoRapida(
              '✅ Marcar como Concluída',
              Icons.check_circle,
              Colors.green,
              () => _executarAcaoRapida(tarefa, 'concluir'),
            ),
            _buildAcaoRapida(
              '⏰ Adiar para Amanhã',
              Icons.schedule,
              Colors.orange,
              () => _executarAcaoRapida(tarefa, 'adiar'),
            ),
            _buildAcaoRapida(
              '📝 Adicionar Nota',
              Icons.note_add,
              Colors.blue,
              () => _executarAcaoRapida(tarefa, 'nota'),
            ),
            _buildAcaoRapida(
              '🔄 Repetir Tarefa',
              Icons.repeat,
              Colors.purple,
              () => _executarAcaoRapida(tarefa, 'repetir'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcaoRapida(String titulo, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          titulo,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          onPressed();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: color.withOpacity(0.1),
      ),
    );
  }

  Future<void> _executarAcaoRapida(Map<String, dynamic> tarefa, String acao) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      switch (acao) {
        case 'concluir':
          // Marcar tarefa como concluída
          await FirebaseFirestore.instance
              .collection('tarefas')
              .doc(tarefa['id'])
              .update({'concluida': true});
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${tarefa['titulo']} marcada como concluída!'),
              backgroundColor: Colors.green,
            ),
          );
          break;
          
        case 'adiar':
          // Adiar para amanhã
          final amanha = DateTime.now().add(const Duration(days: 1));
          await FirebaseFirestore.instance
              .collection('tarefas')
              .doc(tarefa['id'])
              .update({
            'dataHora': Timestamp.fromDate(amanha),
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⏰ ${tarefa['titulo']} adiada para amanhã!'),
              backgroundColor: Colors.orange,
            ),
          );
          break;
          
        case 'nota':
          // Mostrar dialog para adicionar nota
          _mostrarDialogNota(tarefa);
          break;
          
        case 'repetir':
          // Criar nova tarefa repetida
          final novaTarefa = {
            'usuarioId': user.uid,
            'plantacaoId': tarefa['plantacaoId'],
            'titulo': tarefa['titulo'],
            'descricao': tarefa['descricao'],
            'dataHora': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
            'tipo': tarefa['tipo'],
            'concluida': false,
            'recorrente': false,
            'prioridade': tarefa['prioridade'],
          };
          
          await FirebaseFirestore.instance.collection('tarefas').add(novaTarefa);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🔄 Nova ${tarefa['titulo']} criada para amanhã!'),
              backgroundColor: Colors.purple,
            ),
          );
          break;
      }
      
      // Recarregar dados
      await _loadDashboardData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao executar ação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarDialogNota(Map<String, dynamic> tarefa) {
    final TextEditingController notaController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Nota'),
        content: TextField(
          controller: notaController,
          decoration: const InputDecoration(
            hintText: 'Digite sua nota sobre esta tarefa...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (notaController.text.isNotEmpty) {
                // Aqui você pode salvar a nota no Firebase
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('📝 Nota adicionada: ${notaController.text}'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _syncDataOnLogin() async {
    try {
      // Sincronizar dados das plantas com Firestore
      await DataSyncService.syncPlantDataToFirestore();
      print('✅ Dados sincronizados com sucesso!');
      
      // Recarregar dados do dashboard após sincronização
      await _loadDashboardData();
    } catch (e) {
      print('❌ Erro ao sincronizar dados: $e');
    }
  }
}
