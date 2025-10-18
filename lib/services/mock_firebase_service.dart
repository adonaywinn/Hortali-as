import '../models/firestore_models.dart';

class MockFirebaseService {
  static final List<Plantacao> _plantacoes = [];
  static final List<TarefaFirestore> _tarefas = [];
  static final List<AlertaFirestore> _alertas = [];
  static final List<CanteiroFirestore> _canteiros = [];
  
  static String _currentUserId = 'mock-user-123';

  // ========== AUTENTICAÇÃO ==========
  
  static Future<String> getCurrentUserId() async {
    return _currentUserId;
  }

  static Future<bool> signInAnonymously() async {
    _currentUserId = 'mock-user-${DateTime.now().millisecondsSinceEpoch}';
    return true;
  }

  // ========== PLANTACOES ==========

  static Future<String> createPlantacao(Plantacao plantacao) async {
    final id = 'plantacao-${DateTime.now().millisecondsSinceEpoch}';
    final novaPlantacao = Plantacao(
      id: id,
      usuarioId: plantacao.usuarioId,
      canteiroId: plantacao.canteiroId,
      plantaNome: plantacao.plantaNome,
      plantaTipo: plantacao.plantaTipo,
      dataPlantio: plantacao.dataPlantio,
      dataColheita: plantacao.dataColheita,
      status: plantacao.status,
      dadosPlanta: plantacao.dadosPlanta,
      fotos: plantacao.fotos,
      observacoes: plantacao.observacoes,
    );
    
    _plantacoes.add(novaPlantacao);
    return id;
  }

  static Future<List<Plantacao>> getPlantacoesByUsuario(String usuarioId) async {
    return _plantacoes.where((p) => p.usuarioId == usuarioId).toList();
  }

  static Future<Plantacao?> getPlantacao(String plantacaoId) async {
    try {
      return _plantacoes.firstWhere((p) => p.id == plantacaoId);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updatePlantacao(Plantacao plantacao) async {
    final index = _plantacoes.indexWhere((p) => p.id == plantacao.id);
    if (index != -1) {
      _plantacoes[index] = plantacao;
    }
  }

  static Future<void> deletePlantacao(String plantacaoId) async {
    _plantacoes.removeWhere((p) => p.id == plantacaoId);
  }

  // ========== TAREFAS ==========

  static Future<String> createTarefa(TarefaFirestore tarefa) async {
    final id = 'tarefa-${DateTime.now().millisecondsSinceEpoch}';
    final novaTarefa = TarefaFirestore(
      id: id,
      usuarioId: tarefa.usuarioId,
      plantacaoId: tarefa.plantacaoId,
      titulo: tarefa.titulo,
      descricao: tarefa.descricao,
      dataHora: tarefa.dataHora,
      tipo: tarefa.tipo,
      concluida: tarefa.concluida,
      recorrente: tarefa.recorrente,
      dataConclusao: tarefa.dataConclusao,
      prioridade: tarefa.prioridade,
    );
    
    _tarefas.add(novaTarefa);
    return id;
  }

  static Future<List<TarefaFirestore>> getTarefasByUsuario(String usuarioId) async {
    return _tarefas.where((t) => t.usuarioId == usuarioId).toList();
  }

  static Future<List<TarefaFirestore>> getTarefasByPlantacao(String plantacaoId) async {
    return _tarefas.where((t) => t.plantacaoId == plantacaoId).toList();
  }

  static Future<void> updateTarefa(TarefaFirestore tarefa) async {
    final index = _tarefas.indexWhere((t) => t.id == tarefa.id);
    if (index != -1) {
      _tarefas[index] = tarefa;
    }
  }

  static Future<void> deleteTarefa(String tarefaId) async {
    _tarefas.removeWhere((t) => t.id == tarefaId);
  }

  // ========== ALERTAS ==========

  static Future<String> createAlerta(AlertaFirestore alerta) async {
    final id = 'alerta-${DateTime.now().millisecondsSinceEpoch}';
    final novoAlerta = AlertaFirestore(
      id: id,
      usuarioId: alerta.usuarioId,
      plantacaoId: alerta.plantacaoId,
      titulo: alerta.titulo,
      descricao: alerta.descricao,
      dataHora: alerta.dataHora,
      tipo: alerta.tipo,
      prioridade: alerta.prioridade,
      lido: alerta.lido,
      dataLeitura: alerta.dataLeitura,
    );
    
    _alertas.add(novoAlerta);
    return id;
  }

  static Future<List<AlertaFirestore>> getAlertasByUsuario(String usuarioId) async {
    return _alertas.where((a) => a.usuarioId == usuarioId).toList();
  }

  static Future<void> marcarAlertaComoLido(String alertaId) async {
    final index = _alertas.indexWhere((a) => a.id == alertaId);
    if (index != -1) {
      _alertas[index] = AlertaFirestore(
        id: _alertas[index].id,
        usuarioId: _alertas[index].usuarioId,
        plantacaoId: _alertas[index].plantacaoId,
        titulo: _alertas[index].titulo,
        descricao: _alertas[index].descricao,
        dataHora: _alertas[index].dataHora,
        tipo: _alertas[index].tipo,
        prioridade: _alertas[index].prioridade,
        lido: true,
        dataLeitura: DateTime.now(),
      );
    }
  }

  // ========== CANTEIROS ==========

  static Future<String> createCanteiro(CanteiroFirestore canteiro) async {
    final id = 'canteiro-${DateTime.now().millisecondsSinceEpoch}';
    final novoCanteiro = CanteiroFirestore(
      id: id,
      usuarioId: canteiro.usuarioId,
      nome: canteiro.nome,
      tipo: canteiro.tipo,
      humidade: canteiro.humidade,
      temperatura: canteiro.temperatura,
      status: canteiro.status,
      plantacaoIds: canteiro.plantacaoIds,
      localizacao: canteiro.localizacao,
      dataCriacao: canteiro.dataCriacao,
    );
    
    _canteiros.add(novoCanteiro);
    return id;
  }

  static Future<List<CanteiroFirestore>> getCanteirosByUsuario(String usuarioId) async {
    return _canteiros.where((c) => c.usuarioId == usuarioId).toList();
  }

  static Future<void> updateCanteiro(CanteiroFirestore canteiro) async {
    final index = _canteiros.indexWhere((c) => c.id == canteiro.id);
    if (index != -1) {
      _canteiros[index] = canteiro;
    }
  }

  // ========== MÉTODOS DE UTILIDADE ==========

  static Future<List<Plantacao>> getAllPlantacoes() async {
    return List.from(_plantacoes);
  }

  static Future<List<TarefaFirestore>> getAllTarefas() async {
    return List.from(_tarefas);
  }

  static Future<List<AlertaFirestore>> getAllAlertas() async {
    return List.from(_alertas);
  }

  static Future<List<CanteiroFirestore>> getAllCanteiros() async {
    return List.from(_canteiros);
  }

  // Limpar dados (para testes)
  static void clearAllData() {
    _plantacoes.clear();
    _tarefas.clear();
    _alertas.clear();
    _canteiros.clear();
  }
}
