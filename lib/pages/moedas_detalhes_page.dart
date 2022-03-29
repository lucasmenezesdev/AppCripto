import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';

import '../configs/app_settings.dart';
import '../models/moeda.dart';
import '../repositories/conta_repository.dart';

class MoedasDetalhesPage extends StatefulWidget {
  Moeda moeda;

  MoedasDetalhesPage({Key? key, required this.moeda}) : super(key: key);

  @override
  _MoedasDetalhesPageState createState() => _MoedasDetalhesPageState();
}

class _MoedasDetalhesPageState extends State<MoedasDetalhesPage> {
  late NumberFormat real;
  late Map<String, String> loc;
  final _form = GlobalKey<FormState>();
  final _value = TextEditingController();
  double coin = 0;
  late ContaRepository conta;

  readNumberFormat() {
    loc = context.watch<AppSettings>().locale;
    real = NumberFormat.currency(locale: loc['locale'], name: loc['name']);
  }

  comprar() async {
    if (_form.currentState!.validate()) {
      await conta.comprar(widget.moeda, double.parse(_value.text));
      // Salvar comprar
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Compra realizada com sucesso!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    readNumberFormat();
    conta = Provider.of<ContaRepository>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.moeda.nome),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    child: Image.network(
                      widget.moeda.icone,
                      scale: 2.5,
                    ),
                    width: 45,
                  ),
                  Container(
                    width: 20,
                  ),
                  Text(
                    real.format(widget.moeda.preco),
                    style: TextStyle(
                      fontSize: 25,
                      letterSpacing: -1,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
            (coin > 0)
                ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      child: Text(
                        '$coin ${widget.moeda.sigla}',
                        style: TextStyle(fontSize: 20, color: Colors.teal),
                      ),
                      margin: EdgeInsets.only(bottom: 24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.05),
                      ),
                      padding: EdgeInsets.all(8),
                    ),
                  )
                : Container(
                    margin: EdgeInsets.only(bottom: 20),
                  ),
            Form(
              key: _form,
              child: TextFormField(
                controller: _value,
                style: TextStyle(fontSize: 22),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Valor',
                  prefixIcon: Icon(Icons.monetization_on_rounded),
                  suffix: Text(
                    'reais',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Informe o valor';
                  } else if (double.parse(value) < 50) {
                    return 'Compra mínima é R\$ 50,00';
                  } else if (double.parse(value) > conta.saldo) {
                    return 'Você não tem saldo suficiente!';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    coin = (value.isEmpty)
                        ? 0
                        : double.parse(value) / widget.moeda.preco;
                  });
                },
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.only(top: 24),
              child: ElevatedButton(
                onPressed: () {
                  comprar();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Comprar',
                        style: TextStyle(fontSize: 20),
                      ),
                    )
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
