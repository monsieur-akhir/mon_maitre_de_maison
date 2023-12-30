import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mon_maitre_de_maison/src/theme/theme.dart';
import 'package:mon_maitre_de_maison/src/widgets/drawer.dart';
import 'package:mon_maitre_de_maison/src/widgets/navbar.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
  const Profile({super.key});
}

class FirebaseAuthService {
  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
}

class _ProfileState extends State<Profile> {
  bool isLoggedIn = false; //
  late String _lastName = "";
  String _firstName = "";
  late String _commune = "";
  late String _profileType = "";
  String _profilePhotoPath = "";

  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuthService.getCurrentUser();
      if (user != null) {
        isLoggedIn = true;
        // Utilisez Firestore pour récupérer les données supplémentaires depuis la collection "users"
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        if (userSnapshot.exists) {
          // Adapté à votre structure de données dans Firestore
          _firstName = userSnapshot.get("firstName") ?? "Nom Inconnu";
          _lastName = userSnapshot.get("lastName") ?? "Nom Inconnu";
          _commune = userSnapshot.get("commune") ?? "Commune Inconnue";
          _profileType = userSnapshot.get("profileType") ?? "type Inconnue";
          _profilePhotoPath =
              userSnapshot.get("profilePhotoPath") ?? "photo Inconnue";
          setState(() {
            isLoggedIn = true;
          });
        }
      }
    } catch (e) {
      print("Erreur lors de la récupération des données utilisateur : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      // Si l'utilisateur n'est pas connecté, redirigez-le vers la page de connexion
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context,
            '/login'); // Remplacez '/login' par le nom de votre route de connexion
      });
      return Scaffold(
          body: Center(
              child:
                  CircularProgressIndicator())); // Affichez un indicateur de chargement pendant la redirection
    }
    // Si l'utilisateur est connecté, affichez le contenu du profil
    else {
      return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: Navbar(
            title: "Profile",
            transparent: true,
          ),
          backgroundColor: ArgonColors.bgColorScreen,
          drawer: ArgonDrawer(currentPage: "Profile"),
          body: Stack(children: <Widget>[
            Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        alignment: Alignment.topCenter,
                        image: AssetImage("assets/img/pro-background.png"),
                        fit: BoxFit.fitWidth))),
            SafeArea(
              child: ListView(children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, right: 16.0, top: 74.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Card(
                              semanticContainer: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              elevation: .0,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0))),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 85.0, bottom: 20.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              
                                              Container(
                                                
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    _deconnexion(); // Appeler la fonction de déconnexion
                                                  },
                                                  child: Text("SE DECONNECTER"),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 8.0),
                                              ),
                                              SizedBox(
                                                width: 40.0,
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: ArgonColors.initial,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          3.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      spreadRadius: 1,
                                                      blurRadius: 7,
                                                      offset: Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  "MESSAGE",
                                                  style: TextStyle(
                                                      color: ArgonColors.white,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 8.0),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 40.0),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Column(
                                                children: [
                                                  Text("2K",
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(
                                                              82, 95, 127, 1),
                                                          fontSize: 20.0,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text("Orders",
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(
                                                              50, 50, 93, 1),
                                                          fontSize: 12.0))
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Text("10",
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(
                                                              82, 95, 127, 1),
                                                          fontSize: 20.0,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text("Photos",
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(
                                                              50, 50, 93, 1),
                                                          fontSize: 12.0))
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Text("89",
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(
                                                              82, 95, 127, 1),
                                                          fontSize: 20.0,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text("Comments",
                                                      style: TextStyle(
                                                          color: Color.fromRGBO(
                                                              50, 50, 93, 1),
                                                          fontSize: 12.0))
                                                ],
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 40.0),
                                          Align(
                                            child: Text(
                                                _firstName + ' ' + _lastName ??
                                                    "Utilisateur",
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        50, 50, 93, 1),
                                                    fontSize: 28.0)),
                                          ),
                                          SizedBox(height: 10.0),
                                          Align(
                                            child: Text(
                                                '(' + _profileType + ')' ??
                                                    "Utilisateur",
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        50, 50, 93, 1),
                                                    fontSize: 22.0)),
                                          ),
                                          SizedBox(height: 10.0),
                                          Align(
                                            child: Text(
                                                "Lieu d'habitation " +
                                                        _commune ??
                                                    "Utilisateur",
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        50, 50, 93, 1),
                                                    fontSize: 18.0,
                                                    fontWeight:
                                                        FontWeight.w200)),
                                          ),
                                          Divider(
                                            height: 40.0,
                                            thickness: 1.5,
                                            indent: 32.0,
                                            endIndent: 32.0,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 32.0, right: 32.0),
                                            child: Align(
                                              child: Text(
                                                  "An artist of considerable range, Jessica name taken by Melbourne...",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          82, 95, 127, 1),
                                                      fontSize: 17.0,
                                                      fontWeight:
                                                          FontWeight.w200)),
                                            ),
                                          ),
                                          SizedBox(height: 15.0),
                                          Align(
                                              child: Text("Show more",
                                                  style: TextStyle(
                                                      color:
                                                          ArgonColors.primary,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16.0))),
                                          SizedBox(height: 25.0),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 25.0, left: 25.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Album",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.0,
                                                      color: ArgonColors.text),
                                                ),
                                                Text(
                                                  "View All",
                                                  style: TextStyle(
                                                      color:
                                                          ArgonColors.primary,
                                                      fontSize: 13.0,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 250,
                                            child: GridView.count(
                                                primary: false,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 24.0,
                                                    vertical: 15.0),
                                                crossAxisSpacing: 10,
                                                mainAxisSpacing: 10,
                                                crossAxisCount: 3,
                                                children: <Widget>[
                                                  Container(
                                                      height: 100,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    6.0)),
                                                        image: DecorationImage(
                                                            image: NetworkImage(
                                                                _profilePhotoPath),
                                                            fit: BoxFit.cover),
                                                      )),
                                                  Container(
                                                      decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                6.0)),
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            "https://images.unsplash.com/photo-1543747579-795b9c2c3ada?fit=crop&w=240&q=80hoto-1501601983405-7c7cabaa1581?fit=crop&w=240&q=80"),
                                                        fit: BoxFit.cover),
                                                  )),
                                                  Container(
                                                      decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                6.0)),
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            "https://images.unsplash.com/photo-1551798507-629020c81463?fit=crop&w=240&q=80"),
                                                        fit: BoxFit.cover),
                                                  )),
                                                  Container(
                                                      decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                6.0)),
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?fit=crop&w=240&q=80"),
                                                        fit: BoxFit.cover),
                                                  )),
                                                  Container(
                                                      decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                6.0)),
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            "https://images.unsplash.com/photo-1503642551022-c011aafb3c88?fit=crop&w=240&q=80"),
                                                        fit: BoxFit.cover),
                                                  )),
                                                  Container(
                                                      decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                6.0)),
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            "https://images.unsplash.com/photo-1482686115713-0fbcaced6e28?fit=crop&w=240&q=80"),
                                                        fit: BoxFit.cover),
                                                  )),
                                                ]),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                        FractionalTranslation(
                          translation: Offset(0.0, -0.5),
                          child: Align(
                            alignment: FractionalOffset(0.5, 0.0),
                            child: CircleAvatar(
                              radius: 65.0,
                              backgroundImage: NetworkImage(_profilePhotoPath), // Utilisez NetworkImage pour charger l'image depuis une URL
                            ),
                          ),
                        )

                      ]),
                    ],
                  ),
                ),
              ]),
            )
          ]));
    }
  }
  void _deconnexion() {
    // Ajoutez ici la logique de déconnexion
    // Par exemple, déconnectez l'utilisateur de Firebase
    FirebaseAuth.instance.signOut();

    // Ajoutez également la logique pour rediriger l'utilisateur vers la page de connexion ou une autre page appropriée
    // Utilisez Navigator.pushReplacementNamed pour remplacer l'écran actuel par une nouvelle page
    Navigator.pushReplacementNamed(context, '/login');
  }

}
