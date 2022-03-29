import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';

import '../configs/app_settings.dart';
import '../models/moeda.dart';
import '../repositories/favoritas_repository.dart';
import '../repositories/moeda_repository.dart';
import 'moedas_detalhes_page.dart';

class MoedasPage extends StatefulWidget {
  const MoedasPage({Key? key}) : super(key: key);

  @override
  State<MoedasPage> createState() => _MoedasPageState();
}

class _MoedasPageState extends State<MoedasPage> {
  late List<Moeda> tabela;
  late NumberFormat real;
  late Map<String, String> loc;
  List<Moeda> listSelected = [];
  late FavoritasRepository favoritas;
  late MoedaRepository moedas;

  readNumberFormat() {
    loc = context.watch<AppSettings>().locale;
    real = NumberFormat.currency(locale: loc['locale'], name: loc['name']);
  }

  changeLanguageButton() {
    final locale = loc['locale'] == 'pt_BR' ? 'en_US' : 'pt_BR';
    final name = loc['locale'] == 'pt_BR' ? '\$' : 'R\$';

    return PopupMenuButton(
      icon: const Icon(Icons.language),
      itemBuilder: (context) => [
        PopupMenuItem(
            child: ListTile(
          leading: const Icon(Icons.swap_vert),
          title: Text('Usar $locale'),
          onTap: () {
            context.read<AppSettings>().setLocale(locale, name);
            Navigator.pop(context);
          },
        ))
      ],
    );
  }

  appBarDinamica() {
    if (listSelected.isEmpty) {
      return AppBar(
        centerTitle: true,
        title: const Text('Cipto Moedas'),
        actions: [changeLanguageButton()],
      );
    } else {
      return AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () {
            setState(() {
              listSelected = [];
            });
          },
        ),
        title: Text('${listSelected.length} selecionadas'),
        backgroundColor: Colors.blue[200],
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
            color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
      );
    }
  }

  mostrarDetalhes(Moeda moeda) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoedasDetalhesPage(moeda: moeda),
      ),
    );
  }

  limparSelecionadas() {
    setState(() {
      listSelected = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    favoritas = context.watch<FavoritasRepository>();
    moedas = context.watch<MoedaRepository>();
    tabela = moedas.tabela;
    readNumberFormat();

    return Scaffold(
      appBar: appBarDinamica(),
      body: RefreshIndicator(
        onRefresh: () => moedas.checkPrecos(),
        child: ListView.separated(
          itemBuilder: (BuildContext context, int moeda) {
            return ListTile(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              leading: (listSelected.contains(tabela[moeda]))
                  ? const CircleAvatar(
                      child: Icon(Icons.check),
                    )
                  : SizedBox(
                      child: Image.network(tabela[moeda].icone),
                      width: 40,
                    ),
              title: Row(
                children: [
                  Text(
                    tabela[moeda].nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  if (favoritas.lista
                      .any((fav) => fav.sigla == tabela[moeda].sigla))
                    const Icon(Icons.star, color: Colors.amber, size: 15),
                ],
              ),
              trailing: Text(real.format(tabela[moeda].preco)),
              selected: listSelected.contains(tabela[moeda]),
              selectedTileColor: Colors.blue[100],
              selectedColor: Colors.black,
              onLongPress: () {
                setState(() {
                  (listSelected.contains(tabela[moeda]))
                      ? listSelected.remove(tabela[moeda])
                      : listSelected.add(tabela[moeda]);
                });
              },
              onTap: () {
                setState(() {
                  listSelected.isEmpty
                      ? mostrarDetalhes(tabela[moeda])
                      : listSelected.contains(tabela[moeda])
                          ? listSelected.remove(tabela[moeda])
                          : listSelected.add(tabela[moeda]);
                });
              },
            );
          },
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const Divider(),
          itemCount: tabela.length,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: listSelected.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                favoritas.saveAll(listSelected);
                limparSelecionadas();
              },
              icon: const Icon(Icons.star),
              label: const Text(
                'FAVORITAR',
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
