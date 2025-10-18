import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String id;
  final String nome;
  final String email;
  final DateTime dataCriacao;
  final String localizacao;
  final Map<String, dynamic> configuracoes;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.dataCriacao,
    required this.localizacao,
    required this.configuracoes,
  });

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Usuario(
      id: doc.id,
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      dataCriacao: (data['dataCriacao'] as Timestamp).toDate(),
      localizacao: data['localizacao'] ?? '',
      configuracoes: data['configuracoes'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'email': email,
      'dataCriacao': Timestamp.fromDate(dataCriacao),
      'localizacao': localizacao,
      'configuracoes': configuracoes,
    };
  }
}

class Plantacao {
  final String id;
  final String usuarioId;
  final String canteiroId;
  final String plantaNome;
  final String plantaTipo;
  final DateTime dataPlantio;
  final DateTime? dataColheita;
  final int quantidade;
  final String tipoQuantidade;
  final double estimativaColheita;
  final String status; // "plantada", "germinando", "crescendo", "colhida"
  final Map<String, dynamic> dadosPlanta;
  final List<String> fotos;
  final String observacoes;

  Plantacao({
    required this.id,
    required this.usuarioId,
    required this.canteiroId,
    required this.plantaNome,
    required this.plantaTipo,
    required this.dataPlantio,
    this.dataColheita,
    required this.quantidade,
    required this.tipoQuantidade,
    required this.estimativaColheita,
    required this.status,
    required this.dadosPlanta,
    required this.fotos,
    required this.observacoes,
  });

  factory Plantacao.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Plantacao(
      id: doc.id,
      usuarioId: data['usuarioId'] ?? '',
      canteiroId: data['canteiroId'] ?? '',
      plantaNome: data['plantaNome'] ?? '',
      plantaTipo: data['plantaTipo'] ?? '',
      dataPlantio: (data['dataPlantio'] as Timestamp).toDate(),
      dataColheita: data['dataColheita'] != null 
          ? (data['dataColheita'] as Timestamp).toDate() 
          : null,
      quantidade: data['quantidade'] ?? 1,
      tipoQuantidade: data['tipoQuantidade'] ?? 'sementes',
      estimativaColheita: (data['estimativaColheita'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'plantada',
      dadosPlanta: data['dadosPlanta'] ?? {},
      fotos: List<String>.from(data['fotos'] ?? []),
      observacoes: data['observacoes'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'usuarioId': usuarioId,
      'canteiroId': canteiroId,
      'plantaNome': plantaNome,
      'plantaTipo': plantaTipo,
      'dataPlantio': Timestamp.fromDate(dataPlantio),
      'dataColheita': dataColheita != null 
          ? Timestamp.fromDate(dataColheita!) 
          : null,
      'quantidade': quantidade,
      'tipoQuantidade': tipoQuantidade,
      'estimativaColheita': estimativaColheita,
      'status': status,
      'dadosPlanta': dadosPlanta,
      'fotos': fotos,
      'observacoes': observacoes,
    };
  }
}

class TarefaFirestore {
  final String id;
  final String usuarioId;
  final String plantacaoId;
  final String titulo;
  final String descricao;
  final DateTime dataHora;
  final String tipo; // "rega", "adubo", "colheita", "poda", "monitoramento"
  final bool concluida;
  final bool recorrente;
  final DateTime? dataConclusao;
  final String prioridade; // "baixa", "media", "alta"

  TarefaFirestore({
    required this.id,
    required this.usuarioId,
    required this.plantacaoId,
    required this.titulo,
    required this.descricao,
    required this.dataHora,
    required this.tipo,
    required this.concluida,
    required this.recorrente,
    this.dataConclusao,
    required this.prioridade,
  });

  factory TarefaFirestore.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TarefaFirestore(
      id: doc.id,
      usuarioId: data['usuarioId'] ?? '',
      plantacaoId: data['plantacaoId'] ?? '',
      titulo: data['titulo'] ?? '',
      descricao: data['descricao'] ?? '',
      dataHora: (data['dataHora'] as Timestamp).toDate(),
      tipo: data['tipo'] ?? '',
      concluida: data['concluida'] ?? false,
      recorrente: data['recorrente'] ?? false,
      dataConclusao: data['dataConclusao'] != null 
          ? (data['dataConclusao'] as Timestamp).toDate() 
          : null,
      prioridade: data['prioridade'] ?? 'media',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'usuarioId': usuarioId,
      'plantacaoId': plantacaoId,
      'titulo': titulo,
      'descricao': descricao,
      'dataHora': Timestamp.fromDate(dataHora),
      'tipo': tipo,
      'concluida': concluida,
      'recorrente': recorrente,
      'dataConclusao': dataConclusao != null 
          ? Timestamp.fromDate(dataConclusao!) 
          : null,
      'prioridade': prioridade,
    };
  }
}

class AlertaFirestore {
  final String id;
  final String usuarioId;
  final String plantacaoId;
  final String titulo;
  final String descricao;
  final DateTime dataHora;
  final String tipo; // "praga", "rega", "colheita", "adubo", "clima"
  final String prioridade; // "baixa", "media", "alta"
  final bool lido;
  final DateTime? dataLeitura;

  AlertaFirestore({
    required this.id,
    required this.usuarioId,
    required this.plantacaoId,
    required this.titulo,
    required this.descricao,
    required this.dataHora,
    required this.tipo,
    required this.prioridade,
    required this.lido,
    this.dataLeitura,
  });

  factory AlertaFirestore.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AlertaFirestore(
      id: doc.id,
      usuarioId: data['usuarioId'] ?? '',
      plantacaoId: data['plantacaoId'] ?? '',
      titulo: data['titulo'] ?? '',
      descricao: data['descricao'] ?? '',
      dataHora: (data['dataHora'] as Timestamp).toDate(),
      tipo: data['tipo'] ?? '',
      prioridade: data['prioridade'] ?? 'media',
      lido: data['lido'] ?? false,
      dataLeitura: data['dataLeitura'] != null 
          ? (data['dataLeitura'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'usuarioId': usuarioId,
      'plantacaoId': plantacaoId,
      'titulo': titulo,
      'descricao': descricao,
      'dataHora': Timestamp.fromDate(dataHora),
      'tipo': tipo,
      'prioridade': prioridade,
      'lido': lido,
      'dataLeitura': dataLeitura != null 
          ? Timestamp.fromDate(dataLeitura!) 
          : null,
    };
  }
}

class CanteiroFirestore {
  final String id;
  final String usuarioId;
  final String nome;
  final String tipo;
  final double humidade;
  final double temperatura;
  final String status;
  final List<String> plantacaoIds;
  final Map<String, dynamic> localizacao;
  final DateTime dataCriacao;

  CanteiroFirestore({
    required this.id,
    required this.usuarioId,
    required this.nome,
    required this.tipo,
    required this.humidade,
    required this.temperatura,
    required this.status,
    required this.plantacaoIds,
    required this.localizacao,
    required this.dataCriacao,
  });

  factory CanteiroFirestore.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CanteiroFirestore(
      id: doc.id,
      usuarioId: data['usuarioId'] ?? '',
      nome: data['nome'] ?? '',
      tipo: data['tipo'] ?? '',
      humidade: (data['humidade'] ?? 0.0).toDouble(),
      temperatura: (data['temperatura'] ?? 0.0).toDouble(),
      status: data['status'] ?? '',
      plantacaoIds: List<String>.from(data['plantacaoIds'] ?? []),
      localizacao: data['localizacao'] ?? {},
      dataCriacao: (data['dataCriacao'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'usuarioId': usuarioId,
      'nome': nome,
      'tipo': tipo,
      'humidade': humidade,
      'temperatura': temperatura,
      'status': status,
      'plantacaoIds': plantacaoIds,
      'localizacao': localizacao,
      'dataCriacao': Timestamp.fromDate(dataCriacao),
    };
  }
}
