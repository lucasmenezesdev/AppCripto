import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthException implements Exception {
  String message;

  AuthException(this.message);
}

class AuthService extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? usuario;
  bool isLoading = true;

  AuthService() {
    _authCheck();
  }

  //Verifica se tem um usuário logado
  _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      usuario = (user == null) ? null : user;
      isLoading = false;
      notifyListeners();
    });
  }

  _getUser() {
    usuario = _auth.currentUser;
    notifyListeners();
  }

  register(String email, String senha) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: senha);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException('Senha muito curta! Mínimo de 6 caracteres.');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('Este e-mail já está cadastrado.');
      }
    }
  }

  login(String email, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException('E-mail não encontrado!');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Senha incorreta!');
      }
    }
  }

  loginWithGoogle() async {
    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
            await _auth.signInWithPopup(authProvider);

        usuario = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await _auth.signInWithCredential(credential);

          usuario = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            print('The account already exists with a different credential.');
          } else if (e.code == 'invalid-credential') {
            print('Error occurred while accessing credentials. Try again.');
          }
        } catch (e) {
          print(e);
        }
      }
    }
  }

  logout() async {
    await _auth.signOut();
    _getUser();
  }
}
