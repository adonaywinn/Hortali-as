import 'package:flutter/material.dart';
import '../models/horta_data.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late List<Tarefa> tarefasHoje;
  late List<Tarefa> tarefasSemana;
  DateTime dataSelecionada = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTarefas();
  }

  void _loadTarefas() {
    // Agenda vazia para novos usuários
    tarefasHoje = [];
    tarefasSemana = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'AGENDA',
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
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _adicionarTarefa,
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendário
          _buildCalendario(),
          const SizedBox(height: 16),
          // Lista de tarefas
          Expanded(
            child: _buildListaTarefas(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendario() {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AGENDA — ${_getMesAno()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _mesAnterior,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _proximoMes,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCalendarioGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarioGrid() {
    final diasSemana = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    final hoje = DateTime.now();
    final primeiroDia = DateTime(dataSelecionada.year, dataSelecionada.month, 1);
    final ultimoDia = DateTime(dataSelecionada.year, dataSelecionada.month + 1, 0);
    final diasNoMes = ultimoDia.day;
    final primeiroDiaSemana = primeiroDia.weekday % 7;

    return Column(
      children: [
        // Cabeçalho dos dias da semana
        Row(
          children: diasSemana.map((dia) => Expanded(
            child: Center(
              child: Text(
                dia,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),
        // Grid do calendário
        ...List.generate(6, (semana) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: List.generate(7, (dia) {
                final diaNumero = semana * 7 + dia - primeiroDiaSemana + 1;
                final isDiaValido = diaNumero > 0 && diaNumero <= diasNoMes;
                final isHoje = isDiaValido && 
                    diaNumero == hoje.day && 
                    dataSelecionada.month == hoje.month && 
                    dataSelecionada.year == hoje.year;
                final temTarefa = _temTarefaNoDia(diaNumero);

                return Expanded(
                  child: GestureDetector(
                    onTap: isDiaValido ? () => _selecionarDia(diaNumero) : null,
                    child: Container(
                      height: 32,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: isHoje 
                            ? const Color(0xFF2E7D32)
                            : temTarefa 
                                ? Colors.orange.withOpacity(0.3)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: isDiaValido 
                            ? Border.all(color: Colors.grey[300]!)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          isDiaValido ? diaNumero.toString() : '',
                          style: TextStyle(
                            color: isHoje 
                                ? Colors.white
                                : temTarefa 
                                    ? Colors.orange[800]
                                    : Colors.black87,
                            fontWeight: isHoje ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildListaTarefas() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          const Text(
            'Lista de tarefas (hoje):',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: tarefasHoje.isEmpty
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
                          'Nenhuma tarefa para hoje',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Plante algo para ver suas tarefas aqui!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: tarefasHoje.length,
                    itemBuilder: (context, index) {
                      final tarefa = tarefasHoje[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildTarefaItem(tarefa),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarefaItem(Tarefa tarefa) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tarefa.concluida ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: tarefa.concluida ? Colors.green : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: tarefa.concluida,
            onChanged: (value) => _marcarTarefa(tarefa),
            activeColor: const Color(0xFF2E7D32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatTime(tarefa.dataHora)} — ${tarefa.titulo}',
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
          if (tarefa.concluida)
            const Text(
              '[Feito]',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.add_alert, size: 16),
              onPressed: () => _adicionarLembrete(tarefa),
            ),
        ],
      ),
    );
  }

  String _getMesAno() {
    final meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return '${meses[dataSelecionada.month - 1]} ${dataSelecionada.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  bool _temTarefaNoDia(int dia) {
    return tarefasHoje.any((tarefa) => 
        tarefa.dataHora.day == dia && 
        tarefa.dataHora.month == dataSelecionada.month);
  }

  void _selecionarDia(int dia) {
    // TODO: Implementar seleção de dia
  }

  void _mesAnterior() {
    setState(() {
      dataSelecionada = DateTime(dataSelecionada.year, dataSelecionada.month - 1);
    });
  }

  void _proximoMes() {
    setState(() {
      dataSelecionada = DateTime(dataSelecionada.year, dataSelecionada.month + 1);
    });
  }

  void _marcarTarefa(Tarefa tarefa) {
    setState(() {
      final index = tarefasHoje.indexWhere((t) => t.id == tarefa.id);
      if (index != -1) {
        tarefasHoje[index] = Tarefa(
          id: tarefa.id,
          titulo: tarefa.titulo,
          descricao: tarefa.descricao,
          dataHora: tarefa.dataHora,
          tipo: tarefa.tipo,
          canteiroId: tarefa.canteiroId,
          concluida: !tarefa.concluida,
          recorrente: tarefa.recorrente,
        );
      }
    });
  }

  void _adicionarTarefa() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Tarefa'),
        content: const Text('Funcionalidade em desenvolvimento...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _adicionarLembrete(Tarefa tarefa) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lembrete adicionado para ${tarefa.titulo}'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }
}
