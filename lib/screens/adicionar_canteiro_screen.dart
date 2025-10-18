import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../models/firestore_models.dart';

class AdicionarCanteiroScreen extends StatefulWidget {
  const AdicionarCanteiroScreen({super.key});

  @override
  State<AdicionarCanteiroScreen> createState() => _AdicionarCanteiroScreenState();
}

class _AdicionarCanteiroScreenState extends State<AdicionarCanteiroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _observacoesController = TextEditingController();
  
  String _tipoSelecionado = 'retangular';
  double _largura = 2.0;
  double _comprimento = 3.0;
  bool _isLoading = false;

  final List<Map<String, String>> _tipos = [
    {'value': 'retangular', 'label': 'Retangular'},
    {'value': 'circular', 'label': 'Circular'},
    {'value': 'quadrado', 'label': 'Quadrado'},
    {'value': 'outro', 'label': 'Outro'},
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'NOVO CANTEIRO',
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
              _buildSectionTitle('Informações do Canteiro'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nomeController,
                label: 'Nome do Canteiro',
                hint: 'Ex: Canteiro Principal',
                validator: (value) => value?.isEmpty == true ? 'Nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Tipo',
                value: _tipoSelecionado,
                items: _tipos,
                onChanged: (value) => setState(() => _tipoSelecionado = value!),
              ),
              const SizedBox(height: 24),

              // Dimensões
              _buildSectionTitle('Dimensões'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSliderField(
                      label: 'Largura (m)',
                      value: _largura,
                      min: 0.5,
                      max: 5.0,
                      onChanged: (value) => setState(() => _largura = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSliderField(
                      label: 'Comprimento (m)',
                      value: _comprimento,
                      min: 0.5,
                      max: 10.0,
                      onChanged: (value) => setState(() => _comprimento = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2E7D32).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Área: ${(_largura * _comprimento).toStringAsFixed(1)} m²',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Observações
              _buildSectionTitle('Observações'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _observacoesController,
                label: 'Observações Adicionais',
                hint: 'Ex: Localização, características especiais, etc.',
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvarCanteiro,
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
                          'CRIAR CANTEIRO',
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

  Widget _buildSliderField({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(1)}m',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) * 10).round(),
          activeColor: const Color(0xFF2E7D32),
          inactiveColor: const Color(0xFF2E7D32).withOpacity(0.3),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _salvarCanteiro() async {
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

      // Criar canteiro no Firebase
      final canteiro = CanteiroFirestore(
        id: '',
        usuarioId: user.uid,
        nome: _nomeController.text.trim(),
        tipo: _tipoSelecionado,
        humidade: 50.0, // Valor padrão
        temperatura: 25.0, // Valor padrão
        status: 'Disponível',
        plantacaoIds: [],
        localizacao: {
          'largura': _largura,
          'comprimento': _comprimento,
          'observacoes': _observacoesController.text.trim(),
        },
        dataCriacao: DateTime.now(),
      );
      
      await FirebaseService.createCanteiro(canteiro);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Canteiro criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retorna true para indicar sucesso
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar canteiro: $e'),
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
