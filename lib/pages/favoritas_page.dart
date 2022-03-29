import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/favoritas_repository.dart';
import '../widgets/moedas_card.dart';

class FavoritasPage extends StatefulWidget {
  const FavoritasPage({Key? key}) : super(key: key);

  @override
  _FavoritasPageState createState() => _FavoritasPageState();
}

class _FavoritasPageState extends State<FavoritasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Moedas Favoritas'),
      ),
      body: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(12),
          child: Consumer<FavoritasRepository>(
              builder: (context, favoritas, child) {
            return favoritas.lista.isEmpty
                ? const ListTile(
                    leading: Icon(Icons.star),
                    title: Text('Ainda não há favoritas'),
                  )
                : ListView.builder(
                    itemCount: favoritas.lista.length,
                    itemBuilder: (_, index) {
                      return MoedaCard(moeda: favoritas.lista[index]);
                    },
                  );
          })),
    );
  }
}
