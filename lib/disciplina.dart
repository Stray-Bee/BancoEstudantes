class Disciplina {
  int? id;
  String nome;
  String codigo;

  Disciplina({this.id, required this.nome, required this.codigo});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'codigo': codigo,
    };
  }

  factory Disciplina.fromMap(Map<String, dynamic> map) {
    return Disciplina(
      id: map['id'],
      nome: map['nome'],
      codigo: map['codigo'],
    );
  }
}
