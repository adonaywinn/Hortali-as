class Planta {
  final String nome;
  final String tipo;
  final String luz;
  final String rega;
  final String temperatura;
  final String soloIdeal;
  final String espacamento;
  final String germinacao;
  final String colheita;
  final String cuidados;
  final String? observacao;

  Planta({
    required this.nome,
    required this.tipo,
    required this.luz,
    required this.rega,
    required this.temperatura,
    required this.soloIdeal,
    required this.espacamento,
    required this.germinacao,
    required this.colheita,
    required this.cuidados,
    this.observacao,
  });

  factory Planta.fromJson(Map<String, dynamic> json) {
    return Planta(
      nome: json['nome'] ?? '',
      tipo: json['tipo'] ?? '',
      luz: json['luz'] ?? '',
      rega: json['rega'] ?? '',
      temperatura: json['temperatura'] ?? '',
      soloIdeal: json['solo_ideal'] ?? '',
      espacamento: json['espacamento'] ?? '',
      germinacao: json['germinacao'] ?? '',
      colheita: json['colheita'] ?? '',
      cuidados: json['cuidados'] ?? '',
      observacao: json['observacao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'tipo': tipo,
      'luz': luz,
      'rega': rega,
      'temperatura': temperatura,
      'solo_ideal': soloIdeal,
      'espacamento': espacamento,
      'germinacao': germinacao,
      'colheita': colheita,
      'cuidados': cuidados,
      'observacao': observacao,
    };
  }
}

class CategoriaPlantas {
  final String nome;
  final List<Planta> plantas;

  CategoriaPlantas({
    required this.nome,
    required this.plantas,
  });

  factory CategoriaPlantas.fromJson(String nome, List<dynamic> json) {
    return CategoriaPlantas(
      nome: nome,
      plantas: json.map((planta) => Planta.fromJson(planta)).toList(),
    );
  }
}
