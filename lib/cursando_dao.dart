import 'package:dbestudante/DatabaseHelper.dart';
import 'package:dbestudante/cursando.dart';
import 'package:dbestudante/disciplina.dart';
import 'package:sqflite/sqflite.dart';

class CursandoDao {
  final Databasehelper _dbHelper = Databasehelper();

  // Incluir vínculo no banco
  Future<void> incluirCursando(Cursando c) async {
    final db = await _dbHelper.database;
    await db.insert(
      "cursando",
      c.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Excluir vínculo do banco
  Future<void> deleteCursando(int idEstudante, int idDisciplina) async {
    final db = await _dbHelper.database;
    await db.delete(
      "cursando",
      where: "id_estudante = ? AND id_disciplina = ?",
      whereArgs: [idEstudante, idDisciplina],
    );
  }

  // Listar disciplinas vinculadas a um estudante (com JOIN)
  Future<List<Disciplina>> listarDisciplinasPorEstudante(
      int idEstudante) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT d.* FROM disciplina d
      INNER JOIN cursando c ON c.id_disciplina = d.id
      WHERE c.id_estudante = ?
    ''', [idEstudante]);

    return List.generate(maps.length, (index) {
      return Disciplina.fromMap(maps[index]);
    });
  }
}
