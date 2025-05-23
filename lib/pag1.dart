import 'package:dbestudante/cursando.dart';
import 'package:dbestudante/cursando_dao.dart';
import 'package:dbestudante/disciplina.dart';
import 'package:dbestudante/disciplina_dao.dart';
import 'package:dbestudante/estudante.dart';
import 'package:dbestudante/estudante_dao.dart';
import 'package:flutter/material.dart';

class pag1 extends StatefulWidget {
  const pag1({super.key});

  @override
  State<pag1> createState() => _pag1State();
}

class _pag1State extends State<pag1> {
  final _estudanteDAO = EstudanteDao();
  final _disciplinaDAO = DisciplinaDao();
  final _cursandoDAO = CursandoDao();

  final _controllerNome = TextEditingController();
  final _controllerMatricula = TextEditingController();
  final _controllerNomeDisciplina = TextEditingController();

  Estudante? _estudanteAtual;

  List<Estudante> _listaEstudantes = [];
  List<Disciplina> _listaDisciplinas = [];
  List<Disciplina> _disciplinasDoEstudante = [];

  @override
  void initState() {
    super.initState();
    _loadEstudantes();
    _loadDisciplinas();
  }

  Future<void> _loadEstudantes() async {
    List<Estudante> temp = await _estudanteDAO.listarEstudantes();
    setState(() {
      _listaEstudantes = temp;
    });
  }

  Future<void> _loadDisciplinas() async {
    List<Disciplina> temp = await _disciplinaDAO.listarDisciplinas();
    setState(() {
      _listaDisciplinas = temp;
    });
  }

  Future<void> _loadDisciplinasDoEstudante(int idEstudante) async {
    List<Disciplina> temp =
        await _cursandoDAO.listarDisciplinasPorEstudante(idEstudante);
    setState(() {
      _disciplinasDoEstudante = temp;
    });
  }

  Future<void> _salvarOUEditarEstudante() async {
    if (_estudanteAtual == null) {
      await _estudanteDAO.incluirEstudante(Estudante(
        nome: _controllerNome.text,
        matricula: _controllerMatricula.text,
      ));
    } else {
      _estudanteAtual!.nome = _controllerNome.text;
      _estudanteAtual!.matricula = _controllerMatricula.text;
      await _estudanteDAO.editarEstudante(_estudanteAtual!);
    }
    _controllerNome.clear();
    _controllerMatricula.clear();
    setState(() {
      _estudanteAtual = null;
    });
    _loadEstudantes();
  }

  Future<void> _apagarEstudante(int id) async {
    await _estudanteDAO.deleteEstudante(id);
    _loadEstudantes();
    setState(() {
      if (_estudanteAtual?.id == id) {
        _estudanteAtual = null;
        _disciplinasDoEstudante.clear();
      }
    });
  }

  Future<void> _salvarDisciplina() async {
    if (_controllerNomeDisciplina.text.isNotEmpty) {
      await _disciplinaDAO.incluirDisciplina(
        Disciplina(nome: _controllerNomeDisciplina.text, codigo: ''),
      );
      _controllerNomeDisciplina.clear();
      _loadDisciplinas();
    }
  }

  Future<void> _vincularDisciplina(int idDisciplina) async {
    if (_estudanteAtual != null) {
      await _cursandoDAO.incluirCursando(Cursando(
        idEstudante: _estudanteAtual!.id!,
        idDisciplina: idDisciplina,
      ));
      _loadDisciplinasDoEstudante(_estudanteAtual!.id!);
    }
  }

  Future<void> _desvincularDisciplina(int idDisciplina) async {
    if (_estudanteAtual != null) {
      await _cursandoDAO.deleteCursando(_estudanteAtual!.id!, idDisciplina);
      _loadDisciplinasDoEstudante(_estudanteAtual!.id!);
    }
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gerenciador de Estudantes"),
        backgroundColor: Color.fromARGB(255, 132, 109, 233),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildSectionTitle("Cadastro de Estudante"),
                    _buildTextField(_controllerNome, "Nome"),
                    _buildTextField(_controllerMatricula, "Matrícula"),
                    ElevatedButton.icon(
                      onPressed: _salvarOUEditarEstudante,
                      icon: Icon(Icons.save),
                      label: Text(
                          _estudanteAtual == null ? "Salvar" : "Atualizar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 132, 109, 233),
                        minimumSize: Size(double.infinity, 40),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Lista de Estudantes"),
                    ..._listaEstudantes.map((e) => ListTile(
                          title: Text(e.nome),
                          subtitle: Text("Matrícula: ${e.matricula}"),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.deepPurple),
                            onPressed: () => _apagarEstudante(e.id!),
                          ),
                          onTap: () {
                            setState(() {
                              _estudanteAtual = e;
                              _controllerNome.text = e.nome;
                              _controllerMatricula.text = e.matricula;
                            });
                            _loadDisciplinasDoEstudante(e.id!);
                          },
                        )),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildSectionTitle("Gerenciar Disciplinas"),
                    _buildTextField(
                        _controllerNomeDisciplina, "Nova Disciplina"),
                    ElevatedButton.icon(
                      onPressed: _salvarDisciplina,
                      icon: Icon(Icons.add),
                      label: Text("Adicionar Disciplina"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 132, 109, 233),
                        minimumSize: Size(double.infinity, 40),
                      ),
                    ),
                    Divider(),
                    _buildSectionTitle("Todas as Disciplinas"),
                    ..._listaDisciplinas.map((d) => ListTile(
                          title: Text(d.nome),
                          trailing: IconButton(
                            icon: Icon(Icons.link, color: Colors.green),
                            onPressed: _estudanteAtual == null
                                ? null
                                : () => _vincularDisciplina(d.id!),
                          ),
                        )),
                  ],
                ),
              ),
            ),
            if (_estudanteAtual != null)
              Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(
                          "Disciplinas de ${_estudanteAtual!.nome}"),
                      ..._disciplinasDoEstudante.map((d) => ListTile(
                            title: Text(d.nome),
                            trailing: IconButton(
                              icon: Icon(Icons.link_off,
                                  color: const Color.fromARGB(255, 84, 7, 146)),
                              onPressed: () => _desvincularDisciplina(d.id!),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
