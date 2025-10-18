import 'planta.dart';

class Canteiro {
  final String id;
  final String nome;
  final String tipo;
  final List<Planta> plantas;
  final double humidade;
  final double temperatura;
  final String status; // "Saudável", "Precisa regar", "Praga detectada"
  final double largura; // em metros
  final double comprimento; // em metros
  final String? observacoes;

  Canteiro({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.plantas,
    required this.humidade,
    required this.temperatura,
    required this.status,
    required this.largura,
    required this.comprimento,
    this.observacoes,
  });
}

class Tarefa {
  final String id;
  final String titulo;
  final String descricao;
  final DateTime dataHora;
  final String tipo; // "rega", "adubo", "colheita", "poda"
  final String canteiroId;
  final bool concluida;
  final bool recorrente;

  Tarefa({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataHora,
    required this.tipo,
    required this.canteiroId,
    required this.concluida,
    required this.recorrente,
  });
}

class Alerta {
  final String id;
  final String titulo;
  final String descricao;
  final DateTime dataHora;
  final String tipo; // "praga", "rega", "colheita", "adubo"
  final String canteiroId;
  final String prioridade; // "baixa", "media", "alta"

  Alerta({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataHora,
    required this.tipo,
    required this.canteiroId,
    required this.prioridade,
  });
}

class Insumo {
  final String id;
  final String nome;
  final String tipo; // "semente", "adubo", "ferramenta"
  final int quantidade;
  final int usado;
  final String unidade; // "un", "kg", "L"
  final DateTime? validade;

  Insumo({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.quantidade,
    required this.usado,
    required this.unidade,
    this.validade,
  });
}

class Producao {
  final String id;
  final String plantaNome;
  final String canteiroId;
  final double quantidade;
  final String unidade;
  final DateTime dataColheita;
  final String observacoes;

  Producao({
    required this.id,
    required this.plantaNome,
    required this.canteiroId,
    required this.quantidade,
    required this.unidade,
    required this.dataColheita,
    required this.observacoes,
  });
}

class StatusGeral {
  final int totalCanteiros;
  final int alertasPragas;
  final String proximaColheita;
  final int diasProximaColheita;
  final double nivelAgua;
  final String clima;
  final double temperatura;

  StatusGeral({
    required this.totalCanteiros,
    required this.alertasPragas,
    required this.proximaColheita,
    required this.diasProximaColheita,
    required this.nivelAgua,
    required this.clima,
    required this.temperatura,
  });
}
