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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CRUD Estudante & Disciplinas"),
        backgroundColor: Colors.cyan,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Formulário Estudante ---
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controllerNome,
                decoration: InputDecoration(labelText: "Nome"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controllerMatricula,
                decoration: InputDecoration(labelText: "Matrícula"),
              ),
            ),
            ElevatedButton(
              onPressed: _salvarOUEditarEstudante,
              child: Text(_estudanteAtual == null ? "Salvar" : "Atualizar"),
            ),

            // --- Lista de Estudantes ---
            Divider(),
            Text("Lista de Estudantes", style: TextStyle(fontSize: 16)),
            ..._listaEstudantes.map((e) => ListTile(
                  title: Text(e.nome),
                  subtitle: Text(e.matricula),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
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

            // --- Disciplinas ---
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controllerNomeDisciplina,
                decoration: InputDecoration(labelText: "Nova Disciplina"),
              ),
            ),
            ElevatedButton(
              onPressed: _salvarDisciplina,
              child: Text("Adicionar Disciplina"),
            ),

            Text("Todas as Disciplinas", style: TextStyle(fontSize: 16)),
            ..._listaDisciplinas.map((d) => ListTile(
                  title: Text(d.nome),
                  trailing: IconButton(
                    icon: Icon(Icons.link),
                    onPressed: _estudanteAtual == null
                        ? null
                        : () => _vincularDisciplina(d.id!),
                  ),
                )),

            // --- Disciplinas vinculadas ---
            Divider(),
            if (_estudanteAtual != null)
              Column(
                children: [
                  Text("Disciplinas de ${_estudanteAtual!.nome}",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ..._disciplinasDoEstudante.map((d) => ListTile(
                        title: Text(d.nome),
                        trailing: IconButton(
                          icon: Icon(Icons.link_off),
                          onPressed: () => _desvincularDisciplina(d.id!),
                        ),
                      )),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
