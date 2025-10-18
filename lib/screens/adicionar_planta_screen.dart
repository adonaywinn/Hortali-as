import 'package:flutter/material.dart';
import '../models/planta.dart';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdicionarPlantaScreen extends StatefulWidget {
  const AdicionarPlantaScreen({super.key});

  @override
  State<AdicionarPlantaScreen> createState() => _AdicionarPlantaScreenState();
}

class _AdicionarPlantaScreenState extends State<AdicionarPlantaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _tipoController = TextEditingController();
  final _luzController = TextEditingController();
  final _regaController = TextEditingController();
  final _temperaturaController = TextEditingController();
  final _soloController = TextEditingController();
  final _espacamentoController = TextEditingController();
  final _germinacaoController = TextEditingController();
  final _colheitaController = TextEditingController();
  final _cuidadosController = TextEditingController();
  final _observacaoController = TextEditingController();

  String _categoriaSelecionada = 'hortalicas';
  bool _isLoading = false;

  final List<Map<String, String>> _categorias = [
    {'value': 'hortalicas', 'label': 'Hortaliças Folhosas'},
    {'value': 'legumes_raizes', 'label': 'Legumes de Raiz'},
    {'value': 'ervas_temperos', 'label': 'Ervas e Temperos'},
    {'value': 'frutiferas', 'label': 'Frutíferas'},
    {'value': 'extras', 'label': 'Outros'},
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _tipoController.dispose();
    _luzController.dispose();
    _regaController.dispose();
    _temperaturaController.dispose();
    _soloController.dispose();
    _espacamentoController.dispose();
    _germinacaoController.dispose();
    _colheitaController.dispose();
    _cuidadosController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'ADICIONAR PLANTA',
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
              _buildSectionTitle('Informações Básicas'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nomeController,
                label: 'Nome da Planta',
                hint: 'Ex: Alface Americana',
                validator: (value) => value?.isEmpty == true ? 'Nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Categoria',
                value: _categoriaSelecionada,
                items: _categorias,
                onChanged: (value) => setState(() => _categoriaSelecionada = value!),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _tipoController,
                label: 'Tipo',
                hint: 'Ex: folhosa, raiz, erva, fruto',
                validator: (value) => value?.isEmpty == true ? 'Tipo é obrigatório' : null,
              ),
              const SizedBox(height: 24),

              // Condições de Cultivo
              _buildSectionTitle('Condições de Cultivo'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _luzController,
                label: 'Luz',
                hint: 'Ex: Sol pleno, Meia-sombra, Sombra',
                validator: (value) => value?.isEmpty == true ? 'Luz é obrigatória' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _regaController,
                label: 'Rega',
                hint: 'Ex: Diária, A cada 2 dias, Semanal',
                validator: (value) => value?.isEmpty == true ? 'Rega é obrigatória' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _temperaturaController,
                label: 'Temperatura',
                hint: 'Ex: 15-25°C, 20-30°C',
                validator: (value) => value?.isEmpty == true ? 'Temperatura é obrigatória' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _soloController,
                label: 'Solo Ideal',
                hint: 'Ex: Bem drenado, Rico em matéria orgânica',
                validator: (value) => value?.isEmpty == true ? 'Solo é obrigatório' : null,
              ),
              const SizedBox(height: 24),

              // Espaçamento e Ciclo
              _buildSectionTitle('Espaçamento e Ciclo'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _espacamentoController,
                label: 'Espaçamento',
                hint: 'Ex: 30cm entre plantas, 50cm entre linhas',
                validator: (value) => value?.isEmpty == true ? 'Espaçamento é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _germinacaoController,
                label: 'Germinação',
                hint: 'Ex: 7-14 dias, 5-10 dias',
                validator: (value) => value?.isEmpty == true ? 'Germinação é obrigatória' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _colheitaController,
                label: 'Colheita',
                hint: 'Ex: 45-60 dias, 30-45 dias',
                validator: (value) => value?.isEmpty == true ? 'Colheita é obrigatória' : null,
              ),
              const SizedBox(height: 24),

              // Cuidados e Observações
              _buildSectionTitle('Cuidados e Observações'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _cuidadosController,
                label: 'Cuidados Especiais',
                hint: 'Ex: Proteger do frio, Podar regularmente',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _observacaoController,
                label: 'Observações Adicionais',
                hint: 'Ex: Planta sensível ao excesso de água',
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvarPlanta,
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
                          'SALVAR PLANTA',
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

  Future<void> _salvarPlanta() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Obter usuário atual
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Criar objeto Planta
      final planta = Planta(
        nome: _nomeController.text.trim(),
        tipo: _tipoController.text.trim(),
        luz: _luzController.text.trim(),
        rega: _regaController.text.trim(),
        temperatura: _temperaturaController.text.trim(),
        soloIdeal: _soloController.text.trim(),
        espacamento: _espacamentoController.text.trim(),
        germinacao: _germinacaoController.text.trim(),
        colheita: _colheitaController.text.trim(),
        cuidados: _cuidadosController.text.trim(),
        observacao: _observacaoController.text.trim(),
      );

      // Salvar no Firebase
      await FirebaseService.createPlantaPersonalizada(
        usuarioId: user.uid,
        categoria: _categoriaSelecionada,
        planta: planta.toJson(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Planta adicionada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar planta: $e'),
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
