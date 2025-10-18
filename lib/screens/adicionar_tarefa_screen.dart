import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AdicionarTarefaScreen extends StatefulWidget {
  const AdicionarTarefaScreen({super.key});

  @override
  State<AdicionarTarefaScreen> createState() => _AdicionarTarefaScreenState();
}

class _AdicionarTarefaScreenState extends State<AdicionarTarefaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaSelecionada = TimeOfDay.now();
  String _tipoSelecionado = 'geral';
  String _prioridadeSelecionada = 'media';
  bool _recorrente = false;
  bool _isLoading = false;

  final List<Map<String, String>> _tipos = [
    {'value': 'geral', 'label': 'Geral'},
    {'value': 'preparacao', 'label': 'Preparação de Canteiro'},
    {'value': 'manutencao', 'label': 'Manutenção'},
    {'value': 'limpeza', 'label': 'Limpeza'},
    {'value': 'organizacao', 'label': 'Organização'},
    {'value': 'compra', 'label': 'Compra de Insumos'},
    {'value': 'outro', 'label': 'Outro'},
  ];

  final List<Map<String, String>> _prioridades = [
    {'value': 'baixa', 'label': 'Baixa'},
    {'value': 'media', 'label': 'Média'},
    {'value': 'alta', 'label': 'Alta'},
    {'value': 'urgente', 'label': 'Urgente'},
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'NOVA TAREFA',
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informações Básicas
              _buildSectionTitle('Informações da Tarefa'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _tituloController,
                label: 'Título da Tarefa',
                hint: 'Ex: Preparar novo canteiro',
                validator: (value) => value?.isEmpty == true ? 'Título é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descricaoController,
                label: 'Descrição',
                hint: 'Ex: Limpar área, adicionar composto, marcar espaçamento',
                maxLines: 3,
                validator: (value) => value?.isEmpty == true ? 'Descrição é obrigatória' : null,
              ),
              const SizedBox(height: 24),

              // Data e Hora
              _buildSectionTitle('Data e Hora'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeField(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tipo e Prioridade
              _buildSectionTitle('Classificação'),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Tipo',
                value: _tipoSelecionado,
                items: _tipos,
                onChanged: (value) => setState(() => _tipoSelecionado = value!),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Prioridade',
                value: _prioridadeSelecionada,
                items: _prioridades,
                onChanged: (value) => setState(() => _prioridadeSelecionada = value!),
              ),
              const SizedBox(height: 16),

              // Opções
              _buildSectionTitle('Opções'),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Tarefa Recorrente'),
                subtitle: const Text('Repetir esta tarefa'),
                value: _recorrente,
                onChanged: (value) => setState(() => _recorrente = value),
                activeColor: const Color(0xFF2E7D32),
              ),
              const SizedBox(height: 32),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvarTarefa,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'CRIAR TAREFA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2E7D32),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selecionarData,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF2E7D32)),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            Text(
              '${_dataSelecionada.day.toString().padLeft(2, '0')}/${_dataSelecionada.month.toString().padLeft(2, '0')}/${_dataSelecionada.year}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return InkWell(
      onTap: _selecionarHora,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF2E7D32)),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            Text(
              _horaSelecionada.format(context),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child: Text(item['label']!),
        );
      }).toList(),
    );
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (data != null) {
      setState(() {
        _dataSelecionada = data;
      });
    }
  }

  Future<void> _selecionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada,
    );
    if (hora != null) {
      setState(() {
        _horaSelecionada = hora;
      });
    }
  }

  Future<void> _salvarTarefa() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final dataHora = DateTime(
        _dataSelecionada.year,
        _dataSelecionada.month,
        _dataSelecionada.day,
        _horaSelecionada.hour,
        _horaSelecionada.minute,
      );

      final tarefa = TarefaFirestore(
        id: '',
        usuarioId: user.uid,
        plantacaoId: '', // Tarefa manual não tem plantação
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        dataHora: dataHora,
        tipo: _tipoSelecionado,
        concluida: false,
        recorrente: _recorrente,
        prioridade: _prioridadeSelecionada,
      );

      await FirebaseService.createTarefa(tarefa);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarefa criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar tarefa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
