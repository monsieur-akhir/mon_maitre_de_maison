import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mon_maitre_de_maison/src/theme/theme.dart';
import 'package:mon_maitre_de_maison/src/widgets/drawer.dart';
import 'package:mon_maitre_de_maison/src/widgets/navbar.dart';
import 'package:mon_maitre_de_maison/src/widgets/input.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(transparent: true, title: ""),
      extendBodyBehindAppBar: true,
      drawer: ArgonDrawer(currentPage: "Account"),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/register-bg.png"), fit: BoxFit.cover)),
          ),
          SafeArea(
            child: Center(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 16, left: 24.0, right: 24.0, bottom: 32),
                    child: Card(
                      elevation: 5,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Input(
                                  placeholder: "Email",
                                  prefixIcon: Icon(Icons.email),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer votre adresse e-mail';
                                    }
                                    // Ajoutez ici la validation de l'adresse e-mail si nécessaire
                                    return null; // Retourne null si la validation réussit
                                  },
                                  onFieldSubmitted: (value) {
                                    _email = value!;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Input(
                                  placeholder: "Password",
                                  prefixIcon: Icon(Icons.lock),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer votre mot de passe';
                                    }
                                    // Ajoutez ici la validation du mot de passe si nécessaire
                                    return null; // Retourne null si la validation réussit
                                  },
                                  onFieldSubmitted: (value) {
                                    _password = value!;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Validez le formulaire avant de procéder
                                      if (_formKey.currentState!.validate()) {
                                        // Sauvegardez les valeurs du formulaire
                                        _formKey.currentState!.save();
                                        // Appelez la fonction de connexion
                                        signInWithEmailAndPassword(_email, _password);

                                      }
                                      Navigator.pushReplacementNamed(context, '/home');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: ArgonColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: 16.0,
                                        right: 16.0,
                                        top: 12,
                                        bottom: 12,
                                      ),
                                      child: Text(
                                        "LOGIN",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: GestureDetector(
                                  onTap: () {
                                    // Lorsque l'utilisateur clique sur le texte, redirigez-le vers la page de création de compte
                                    Navigator.pushNamed(context, '/account');
                                  },
                                  child: Center(
                                    child: Text(
                                      "Si vous n'avez pas de compte, créez un compte",
                                      style: TextStyle(
                                        color: ArgonColors.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ),
        ],
      ),
    );
  }
}
Future<void> signInWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Si la connexion réussit, l'utilisateur est connecté et vous pouvez effectuer des actions supplémentaires ici
    print('Utilisateur connecté: ${userCredential.user!.email}');
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('Aucun utilisateur trouvé pour cet e-mail.');
    } else if (e.code == 'wrong-password') {
      print('Mot de passe incorrect.');
    } else {
      print('Erreur de connexion: ${e.message}');
    }
  } catch (e) {
    print('Erreur inattendue: $e');
  }
}
