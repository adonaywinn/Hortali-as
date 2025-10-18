import '../models/planta.dart';
import '../models/firestore_models.dart';
import 'firebase_service.dart';
import 'planta_monitoring_service.dart';

class ControleAutomaticoService {

  static Future<void> criarControleAutomatico({
    required String usuarioId,
    required String canteiroId,
    required Planta planta,
    required DateTime dataPlantio,
  }) async {
    // Criar plantação no Firebase
    final plantacao = Plantacao(
      id: '', // Será definido pelo Firebase
      usuarioId: usuarioId,
      canteiroId: canteiroId,
      plantaNome: planta.nome,
      plantaTipo: planta.tipo,
      dataPlantio: dataPlantio,
      quantidade: 1, // Valor padrão
      tipoQuantidade: 'sementes', // Valor padrão
      estimativaColheita: 0.75, // Valor padrão
      status: 'plantada',
      dadosPlanta: planta.toJson(),
      fotos: [],
      observacoes: '',
    );

    final plantacaoId = await FirebaseService.createPlantacao(plantacao);

    // Criar monitoramento personalizado baseado no tipo específico da planta
    await PlantaMonitoringService.criarMonitoramentoPersonalizado(
      usuarioId: usuarioId,
      plantacaoId: plantacaoId,
      planta: planta,
      dataPlantio: dataPlantio,
    );
  }

  static Future<void> _criarCronogramaRega(String usuarioId, String plantacaoId, Planta planta, DateTime dataPlantio) async {
    // Regar baseado no tipo de rega da planta
    final frequenciaRega = _getFrequenciaRega(planta.rega);
    
    for (int i = 0; i < 30; i += frequenciaRega) { // 30 dias de rega
      final dataRega = dataPlantio.add(Duration(days: i));
      
      final tarefa = TarefaFirestore(
        id: '', // Será definido pelo Firebase
        usuarioId: usuarioId,
        plantacaoId: plantacaoId,
        titulo: "Regar ${planta.nome}",
        descricao: "Rega automática - ${planta.rega}",
        dataHora: dataRega.copyWith(hour: 7, minute: 0),
        tipo: "rega",
        concluida: false,
        recorrente: true,
        prioridade: "media",
      );
      
      await FirebaseService.createTarefa(tarefa);
    }
  }

  static Future<void> _criarLembretesAdubacao(String usuarioId, String plantacaoId, Planta planta, DateTime dataPlantio) async {
    // Adubação baseada no tipo de planta
    final diasAdubacao = _getDiasAdubacao(planta.tipo);
    
    for (int adubacao in diasAdubacao) {
      final dataAdubacao = dataPlantio.add(Duration(days: adubacao));
      
      final tarefa = TarefaFirestore(
        id: '', // Será definido pelo Firebase
        usuarioId: usuarioId,
        plantacaoId: plantacaoId,
        titulo: "Adubar ${planta.nome}",
        descricao: "Adubação com ${_getTipoAdubo(planta.tipo)}",
        dataHora: dataAdubacao.copyWith(hour: 9, minute: 0),
        tipo: "adubo",
        concluida: false,
        recorrente: false,
        prioridade: "media",
      );
      
      await FirebaseService.createTarefa(tarefa);
    }
  }

  static Future<void> _criarAlertasColheita(String usuarioId, String plantacaoId, Planta planta, DateTime dataPlantio) async {
    // Calcular data de colheita baseada na planta
    final diasColheita = _getDiasColheita(planta.colheita);
    final dataColheita = dataPlantio.add(Duration(days: diasColheita));
    
    // Alerta 3 dias antes da colheita
    final dataAlerta = dataColheita.subtract(const Duration(days: 3));
    
    final alerta = AlertaFirestore(
      id: '', // Será definido pelo Firebase
      usuarioId: usuarioId,
      plantacaoId: plantacaoId,
      titulo: "Colheita próxima!",
      descricao: "${planta.nome} estará pronta em 3 dias",
      dataHora: dataAlerta,
      tipo: "colheita",
      prioridade: "alta",
      lido: false,
    );
    
    await FirebaseService.createAlerta(alerta);

    // Tarefa de colheita
    final tarefa = TarefaFirestore(
      id: '', // Será definido pelo Firebase
      usuarioId: usuarioId,
      plantacaoId: plantacaoId,
      titulo: "Colher ${planta.nome}",
      descricao: "Primeira colheita - ${planta.cuidados}",
      dataHora: dataColheita,
      tipo: "colheita",
      concluida: false,
      recorrente: false,
      prioridade: "alta",
    );
    
    await FirebaseService.createTarefa(tarefa);
  }

  static Future<void> _criarMonitoramentoPragas(String usuarioId, String plantacaoId, Planta planta, DateTime dataPlantio) async {
    // Monitoramento semanal
    for (int semana = 1; semana <= 12; semana++) {
      final dataMonitoramento = dataPlantio.add(Duration(days: semana * 7));
      
      final tarefa = TarefaFirestore(
        id: '', // Será definido pelo Firebase
        usuarioId: usuarioId,
        plantacaoId: plantacaoId,
        titulo: "Monitorar pragas - ${planta.nome}",
        descricao: "Inspeção semanal para lagartas e pulgões",
        dataHora: dataMonitoramento.copyWith(hour: 16, minute: 0),
        tipo: "poda",
        concluida: false,
        recorrente: true,
        prioridade: "baixa",
      );
      
      await FirebaseService.createTarefa(tarefa);
    }
  }

  static int _getFrequenciaRega(String rega) {
    if (rega.toLowerCase().contains('diária')) return 1;
    if (rega.toLowerCase().contains('regular')) return 2;
    if (rega.toLowerCase().contains('moderada')) return 3;
    if (rega.toLowerCase().contains('baixa')) return 5;
    return 2; // padrão
  }

  static List<int> _getDiasAdubacao(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'folhosa':
        return [7, 21, 35]; // Adubação a cada 2 semanas
      case 'raiz':
        return [14, 28, 42]; // Adubação a cada 2 semanas
      case 'erva':
        return [10, 25, 40]; // Adubação a cada 2 semanas
      case 'fruto':
        return [7, 21, 35, 49]; // Adubação mais frequente
      default:
        return [14, 28]; // Padrão
    }
  }

  static String _getTipoAdubo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'folhosa':
        return 'NPK 20-10-10';
      case 'raiz':
        return 'NPK 10-20-10';
      case 'erva':
        return 'Húmus de minhoca';
      case 'fruto':
        return 'NPK 15-15-15';
      default:
        return 'NPK 15-15-15';
    }
  }

  static int _getDiasColheita(String colheita) {
    // Extrair número de dias da string (ex: "30–45 dias" -> 30)
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(colheita);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 30; // padrão
  }

  // Métodos para buscar dados do Firebase
  static Future<List<TarefaFirestore>> getTarefasPorUsuario(String usuarioId) async {
    return await FirebaseService.getTarefasByUsuario(usuarioId);
  }
  
  static Future<List<AlertaFirestore>> getAlertasPorUsuario(String usuarioId) async {
    return await FirebaseService.getAlertasByUsuario(usuarioId);
  }
  
  static Future<List<Plantacao>> getPlantacoesPorUsuario(String usuarioId) async {
    return await FirebaseService.getPlantacoesByUsuario(usuarioId);
  }
}
