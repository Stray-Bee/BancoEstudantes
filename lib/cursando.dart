class Cursando {
  int idEstudante;
  int idDisciplina;

  Cursando({required this.idEstudante, required this.idDisciplina});

  Map<String, dynamic> toMap() {
    return {
      'id_estudante': idEstudante,
      'id_disciplina': idDisciplina,
    };
  }

  factory Cursando.fromMap(Map<String, dynamic> map) {
    return Cursando(
      idEstudante: map['id_estudante'],
      idDisciplina: map['id_disciplina'],
    );
  }
}
