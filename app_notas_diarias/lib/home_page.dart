import 'package:app_notas_diarias/helper/anotacao_helper.dart';
import 'package:flutter/material.dart';
import 'package:app_notas_diarias/model/anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = List<Anotacao>.empty(growable: true);

  _exibirTelaCadastro({Anotacao? anotacao}) {
    String? textoSalvarAtualizar = "";
    if (anotacao == null) {
      //Salvando...
      _tituloController.text = "";
      _descricaoController.text = "";
      textoSalvarAtualizar = "Salvar";
    } else {
      //Atualizar...
      _tituloController.text = anotacao.titulo!;
      _descricaoController.text = anotacao.descricao!;
      textoSalvarAtualizar = "Atualizar";
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$textoSalvarAtualizar anotação'),
          content: Column(
            // Ocupa o espaço minimo dos widgets do dialog, não ocupando a tela toda!
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tituloController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Título',
                  hintText: 'Digite o título...',
                ),
              ),
              TextField(
                controller: _descricaoController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Digite uma descrição...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                Navigator.pop(context);
              },
              child: Text(textoSalvarAtualizar.toString()),
            ),
          ],
        );
      },
    );
  }

  _recuperarAnotacoes() async {
    List anotacoesRecuperadas = await _db.recuperarAnotacoe();

    List<Anotacao> listaTemporaria = List<Anotacao>.empty(growable: true);
    for (var item in anotacoesRecuperadas) {
      Anotacao anotacao = Anotacao.fromMap(item);
      listaTemporaria.add(anotacao);
    }
    setState(() {
      _anotacoes = listaTemporaria;
    });
    listaTemporaria = [];
    print('Lista anotações: ' + anotacoesRecuperadas.toString());
  }

  _salvarAtualizarAnotacao({Anotacao? anotacaoSelecionada}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    if (anotacaoSelecionada == null) {
      //Salvar
      Anotacao anotacao =
          Anotacao(titulo, descricao, DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);
    } else {
      //Atualizar
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      int resultado = await _db.atualizarAnotacao(anotacaoSelecionada);
    }

    _tituloController.clear(); //Limpa campo de texto do formulario
    _descricaoController.clear();
    _recuperarAnotacoes();
  }

  _formatarData(String data) {
    initializeDateFormatting("pt_BR");
    //d => day, dia; M => Mouth, Mês; y => Year, Ano
    //H => Horas; m = > Minutos; s => Segundos
    //var formatador = DateFormat("d/MM/y H:m:s");
    var formatador = DateFormat.yMd("pt_BR");

    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConvertida);

    return dataFormatada;
  }

  _removerAnotacao(int id) async {
    await _db.removerAnotacao(id);
    _recuperarAnotacoes();
  }

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minhas anotações'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: _anotacoes.length,
                  itemBuilder: (context, index) {
                    final anotacao = _anotacoes[index];
                    return Card(
                      child: ListTile(
                        title: Text(anotacao.titulo!),
                        subtitle: Text(
                            "${_formatarData(anotacao.data!)} - ${anotacao.descricao}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _exibirTelaCadastro(anotacao: anotacao);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _removerAnotacao(anotacao.id!);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 0),
                                child: Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: () {
          _exibirTelaCadastro();
        },
      ),
    );
  }
}
