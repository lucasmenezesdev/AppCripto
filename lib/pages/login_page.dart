import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final senha = TextEditingController();

  bool isLogin = true;
  late String title;
  late String actionButton;
  late String toggleButton;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    setFormAction(true);
  }

  setFormAction(bool action) {
    setState(() {
      isLogin = action;
      if (isLogin) {
        title = 'Bem vindo';
        actionButton = 'Login';
        toggleButton = 'Ainda não tem conta? Cadastre-se agora.';
      } else {
        title = 'Crie sua conta';
        actionButton = 'Cadastrar';
        toggleButton = 'Voltar ao Login.';
      }
    });
  }

  login() async {
    setState(() => loading = true);
    try {
      await context.read<AuthService>().login(email.text, senha.text);
    } on AuthException catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
      ));
    }
  }

  loginGoogle() async {
    setState(() => loading = true);
    try {
      await context.read<AuthService>().loginWithGoogle();
    } on AuthException catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
      ));
    }
  }

  register() async {
    setState(() => loading = true);
    try {
      await context.read<AuthService>().register(email.text, senha.text);
    } on AuthException catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.5,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(24),
                  child: TextFormField(
                    controller: email,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'E-mail',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Informe o e-mail coretamente';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(24),
                  child: TextFormField(
                    obscureText: true,
                    controller: senha,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Senha',
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Informe sua senha!';
                      } else if (value.length < 6) {
                        return 'Sua senha deve ter no mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (isLogin) {
                            login();
                          } else {
                            register();
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: (loading)
                            ? [
                                Padding(
                                    padding: EdgeInsets.all(16),
                                    child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            color: Colors.white)))
                              ]
                            : [
                                Icon(Icons.check),
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    actionButton,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                )
                              ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        loginGoogle();
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 35,
                              child: Image.asset('images/icongoogle.png'),
                            ),
                            Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('Google',
                                    style: TextStyle(fontSize: 24)))
                          ]),
                    ),
                  ),
                ),
                TextButton(
                    onPressed: () => setFormAction(!isLogin),
                    child: Text(toggleButton)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
