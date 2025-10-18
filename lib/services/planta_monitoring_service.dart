import '../models/planta.dart';
import '../models/firestore_models.dart';
import 'firebase_service.dart';

class PlantaMonitoringService {
  
  /// Cria monitoramento personalizado baseado no tipo específico da planta
  static Future<void> criarMonitoramentoPersonalizado({
    required String usuarioId,
    required String plantacaoId,
    required Planta planta,
    required DateTime dataPlantio,
  }) async {
    
    // 1. Cronograma de rega personalizado
    await _criarCronogramaRegaPersonalizado(usuarioId, plantacaoId, planta, dataPlantio);
    
    // 2. Lembretes de adubação específicos
    await _criarAdubacaoPersonalizada(usuarioId, plantacaoId, planta, dataPlantio);
    
    // 3. Alertas de colheita inteligentes
    await _criarAlertasColheitaInteligentes(usuarioId, plantacaoId, planta, dataPlantio);
    
    // 4. Monitoramento de pragas específico
    await _criarMonitoramentoPragasEspecifico(usuarioId, plantacaoId, planta, dataPlantio);
    
    // 5. Cuidados especiais por tipo
    await _criarCuidadosEspeciais(usuarioId, plantacaoId, planta, dataPlantio);
    
    // 6. Alertas de temperatura e clima
    await _criarAlertasClimaticos(usuarioId, plantacaoId, planta, dataPlantio);
  }

  /// Cronograma de rega personalizado por tipo de planta
  static Future<void> _criarCronogramaRegaPersonalizado(
    String usuarioId, String plantacaoId, Planta planta, DateTime dataPlantio) async {
    
    final configRega = _getConfiguracaoRega(planta);
    
    final duracao = configRega['duracao'] as int;
    final frequencia = configRega['frequencia'] as int;
    
    for (int i = 0; i < duracao; i += frequencia) {
      final dataRega = dataPlantio.add(Duration(days: i));
      
      final tarefa = TarefaFirestore(
        id: '',
        usuarioId: usuarioId,
        plantacaoId: plantacaoId,
        titulo: "🌱 Regar ${planta.nome}",
        descricao: "Rega ${configRega['tipo'] as String} - ${planta.rega}",
        dataHora: dataRega.copyWith(hour: configRega['hora'] as int, minute: 0),
        tipo: "rega",
        concluida: false,
        recorrente: true,
        prioridade: configRega['prioridade'] as String,
      );
      
      await FirebaseService.createTarefa(tarefa);
    }
  }

  /// Adubação personalizada por tipo de planta
  static Future<void> _criarAdubacaoPersonalizada(
    String usuarioId, String plantacaoId, Planta planta, DateTime dataPlantio) async {
    
    final configAdubacao = _getConfiguracaoAdubacao(planta);
    
    final dias = configAdubacao['dias'] as List<int>;
    
    for (int dia in dias) {
      final dataAdubacao = dataPlantio.add(Duration(days: dia));
      
      final tarefa = TarefaFirestore(
        id: '',
        usuarioId: usuarioId,
        plantacaoId: plantacaoId,
        titulo: "🌿 Adubar ${planta.nome}",
        descricao: "Adubação com ${configAdubacao['tipo'] as String} - ${configAdubacao['quantidade'] as String}",
        dataHora: dataAdubacao.copyWith(hour: 8, minute: 0),
        tipo: "adubacao",
        concluida: false,
        recorrente: false,
        prioridade: "media",
      );
      
      await FirebaseService.createTarefa(tarefa);
    }
  }

  /// Alertas de colheita inteligentes
  static Future<void> _criarAlertasColheitaInteligentes(
    String usuarioId, String plantacaoId, Planta planta, DateTime dataPlantio) async {
    
    final diasColheita = _extrairDiasColheita(planta.colheita);
    final dataColheita = dataPlantio.add(Duration(days: diasColheita));
    
    // Alerta 7 dias antes da colheita
    final dataAlerta = dataColheita.subtract(const Duration(days: 7));
    
    final alerta = AlertaFirestore(
      id: '',
      usuarioId: usuarioId,
      plantacaoId: plantacaoId,
      titulo: "🚨 Colheita próxima: ${planta.nome}",
      descricao: "Sua ${planta.nome} estará pronta para colheita em 7 dias!",
      dataHora: dataAlerta,
      tipo: "colheita",
      prioridade: "alta",
      lido: false,
    );
    
    await FirebaseService.createAlerta(alerta);
    
    // Tarefa de colheita
    final tarefa = TarefaFirestore(
      id: '',
      usuarioId: usuarioId,
      plantacaoId: plantacaoId,
      titulo: "🌾 Colher ${planta.nome}",
      descricao: "Colheita da ${planta.nome} - ${planta.colheita}",
      dataHora: dataColheita.copyWith(hour: 7, minute: 0),
      tipo: "colheita",
      concluida: false,
      recorrente: false,
      prioridade: "alta",
    );
    
    await FirebaseService.createTarefa(tarefa);
  }

  /// Monitoramento de pragas específico
  static Future<void> _criarMonitoramentoPragasEspecifico(
    String usuarioId, String plantacaoId, Planta planta, DateTime dataPlantio) async {
    
    final pragasComuns = _getPragasComuns(planta);
    
    for (String praga in pragasComuns) {
      final dataMonitoramento = dataPlantio.add(Duration(days: 7));
      
      final tarefa = TarefaFirestore(
        id: '',
        usuarioId: usuarioId,
        plantacaoId: plantacaoId,
        titulo: "🔍 Verificar ${planta.nome} - ${praga}",
        descricao: "Monitorar presença de ${praga} na ${planta.nome}",
        dataHora: dataMonitoramento.copyWith(hour: 10, minute: 0),
        tipo: "monitoramento",
        concluida: false,
        recorrente: true,
        prioridade: "media",
      );
      
      await FirebaseService.createTarefa(tarefa);
    }
  }

  /// Cuidados especiais por tipo de planta
  static Future<void> _criarCuidadosEspeciais(
    String usuarioId, String plantacaoId, Planta planta, DateTime dataPlantio) async {
    
    final cuidadosEspeciais = _getCuidadosEspeciais(planta);
    
    for (var cuidado in cuidadosEspeciais) {
      final dataCuidado = dataPlantio.add(Duration(days: cuidado['dia']));
      
      final tarefa = TarefaFirestore(
        id: '',
        usuarioId: usuarioId,
        plantacaoId: plantacaoId,
        titulo: "🌱 ${cuidado['titulo']}",
        descricao: cuidado['descricao'],
        dataHora: dataCuidado.copyWith(hour: 9, minute: 0),
        tipo: "cuidado",
        concluida: false,
        recorrente: cuidado['recorrente'],
        prioridade: cuidado['prioridade'],
      );
      
      await FirebaseService.createTarefa(tarefa);
    }
  }

  /// Alertas climáticos personalizados
  static Future<void> _criarAlertasClimaticos(
    String usuarioId, String plantacaoId, Planta planta, DateTime dataPlantio) async {
    
    final configClima = _getConfiguracaoClima(planta);
    
    // Alerta de temperatura
    if (configClima['tempMin'] != null) {
      final alerta = AlertaFirestore(
        id: '',
        usuarioId: usuarioId,
        plantacaoId: plantacaoId,
        titulo: "🌡️ Atenção à temperatura",
        descricao: "${planta.nome} precisa de temperatura mínima de ${configClima['tempMin']}°C",
        dataHora: dataPlantio.add(const Duration(days: 1)),
        tipo: "clima",
        prioridade: "media",
        lido: false,
      );
      
      await FirebaseService.createAlerta(alerta);
    }
  }

  /// Configuração de rega por tipo de planta
  static Map<String, dynamic> _getConfiguracaoRega(Planta planta) {
    final tipo = planta.tipo.toLowerCase();
    
    switch (tipo) {
      case 'folhosa':
        return <String, dynamic>{
          'frequencia': 1, // Diária
          'duracao': 45,
          'hora': 7,
          'tipo': 'matinal',
          'prioridade': 'alta',
        };
      case 'raiz':
        return <String, dynamic>{
          'frequencia': 2, // A cada 2 dias
          'duracao': 90,
          'hora': 8,
          'tipo': 'moderada',
          'prioridade': 'media',
        };
      case 'erva':
        return <String, dynamic>{
          'frequencia': 1, // Diária
          'duracao': 30,
          'hora': 6,
          'tipo': 'suave',
          'prioridade': 'alta',
        };
      case 'fruto':
        return <String, dynamic>{
          'frequencia': 1, // Diária
          'duracao': 120,
          'hora': 7,
          'tipo': 'abundante',
          'prioridade': 'alta',
        };
      default:
        return <String, dynamic>{
          'frequencia': 2,
          'duracao': 60,
          'hora': 8,
          'tipo': 'regular',
          'prioridade': 'media',
        };
    }
  }

  /// Configuração de adubação por tipo
  static Map<String, dynamic> _getConfiguracaoAdubacao(Planta planta) {
    final tipo = planta.tipo.toLowerCase();
    
    switch (tipo) {
      case 'folhosa':
        return <String, dynamic>{
          'dias': [7, 21, 35],
          'tipo': 'NPK 20-10-10',
          'quantidade': '1 colher de sopa',
        };
      case 'raiz':
        return <String, dynamic>{
          'dias': [14, 28, 42],
          'tipo': 'NPK 10-20-10',
          'quantidade': '2 colheres de sopa',
        };
      case 'erva':
        return <String, dynamic>{
          'dias': [10, 25, 40],
          'tipo': 'Húmus de minhoca',
          'quantidade': '1 punhado',
        };
      case 'fruto':
        return <String, dynamic>{
          'dias': [7, 21, 35, 49],
          'tipo': 'NPK 15-15-15',
          'quantidade': '2 colheres de sopa',
        };
      default:
        return <String, dynamic>{
          'dias': [14, 28],
          'tipo': 'NPK 15-15-15',
          'quantidade': '1 colher de sopa',
        };
    }
  }

  /// Pragas comuns por tipo de planta
  static List<String> _getPragasComuns(Planta planta) {
    final tipo = planta.tipo.toLowerCase();
    
    switch (tipo) {
      case 'folhosa':
        return ['pulgões', 'lagartas', 'ácaros'];
      case 'raiz':
        return ['nematoides', 'larvas', 'fungos'];
      case 'erva':
        return ['pulgões', 'ácaros', 'fungos'];
      case 'fruto':
        return ['lagartas', 'pulgões', 'ácaros', 'fungos'];
      default:
        return ['pulgões', 'lagartas'];
    }
  }

  /// Cuidados especiais por tipo
  static List<Map<String, dynamic>> _getCuidadosEspeciais(Planta planta) {
    final tipo = planta.tipo.toLowerCase();
    
    switch (tipo) {
      case 'folhosa':
        return [
          {
            'dia': 3,
            'titulo': 'Desbaste das folhas',
            'descricao': 'Remover folhas amarelas ou danificadas',
            'recorrente': false,
            'prioridade': 'media',
          },
          {
            'dia': 14,
            'titulo': 'Amarração',
            'descricao': 'Amarar plantas que estão crescendo',
            'recorrente': false,
            'prioridade': 'baixa',
          },
        ];
      case 'raiz':
        return [
          {
            'dia': 7,
            'titulo': 'Afloramento',
            'descricao': 'Remover terra ao redor da raiz',
            'recorrente': false,
            'prioridade': 'alta',
          },
          {
            'dia': 21,
            'titulo': 'Verificar crescimento',
            'descricao': 'Verificar se a raiz está se desenvolvendo',
            'recorrente': true,
            'prioridade': 'media',
          },
        ];
      case 'erva':
        return [
          {
            'dia': 5,
            'titulo': 'Poda de crescimento',
            'descricao': 'Podar para estimular crescimento',
            'recorrente': true,
            'prioridade': 'media',
          },
        ];
      case 'fruto':
        return [
          {
            'dia': 10,
            'titulo': 'Tutoramento',
            'descricao': 'Colocar suporte para a planta',
            'recorrente': false,
            'prioridade': 'alta',
          },
          {
            'dia': 21,
            'titulo': 'Desbaste de frutos',
            'descricao': 'Remover frutos pequenos ou danificados',
            'recorrente': false,
            'prioridade': 'media',
          },
        ];
      default:
        return [];
    }
  }

  /// Configuração climática por tipo
  static Map<String, dynamic> _getConfiguracaoClima(Planta planta) {
    final tipo = planta.tipo.toLowerCase();
    
    switch (tipo) {
      case 'folhosa':
        return <String, dynamic>{'tempMin': 15, 'tempMax': 25, 'umidade': 'alta'};
      case 'raiz':
        return <String, dynamic>{'tempMin': 10, 'tempMax': 30, 'umidade': 'media'};
      case 'erva':
        return <String, dynamic>{'tempMin': 18, 'tempMax': 28, 'umidade': 'media'};
      case 'fruto':
        return <String, dynamic>{'tempMin': 20, 'tempMax': 35, 'umidade': 'media'};
      default:
        return <String, dynamic>{'tempMin': 15, 'tempMax': 30, 'umidade': 'media'};
    }
  }

  /// Extrair dias de colheita da string
  static int _extrairDiasColheita(String colheita) {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(colheita);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 30; // padrão
  }
}
