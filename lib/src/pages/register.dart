import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:mon_maitre_de_maison/firebase_access.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mon_maitre_de_maison/src/theme/theme.dart';
import 'package:mon_maitre_de_maison/src/widgets/drawer.dart';
import 'package:mon_maitre_de_maison/src/widgets/navbar.dart';
import 'package:mon_maitre_de_maison/src/widgets/input.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _checkboxValue = false;
  bool _isFileUploading =
      false; // Indicateur pour montrer si le téléchargement est en cours
  double _uploadProgress = 0.0;

  final double height = window.physicalSize.height;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phoneNumber = '';
  String _address = '';
  String? _password;
  String _confirmPassword = '';
  String _selectedProfileType = 'Elève';
  bool _isTeacher = false;
  bool _hasError = false;
  File? _diplomaFile;
  File? _profileImage;
  String? _profilePhotoPath;
  String? _diplomaPath;
  String? _selectedRegion;
  String? _selectedCommune;
  String? _quartier;

  // Listes pour stocker les données des régions et des communes depuis Firestore
  List<String> _regions = [];
  Map<String, List<String>> _communes = {};

  firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Chargez les données depuis Firestore au moment de l'initialisation de la page
    loadFirebaseData();
  }

  void loadFirebaseData() async {
    Map<String, List<String>> data =
        await FirebaseAccess.loadRegionsAndCommunes();

    setState(() {
      _regions = data.keys.toList();
      _communes = data;
    });
  }

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
                      image: AssetImage("assets/register-bg.png"),
                      fit: BoxFit.cover)),
            ),
            SafeArea(
              child: ListView(children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 16, left: 24.0, right: 24.0, bottom: 32),
                  child: Card(
                      elevation: 5,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                              height: MediaQuery.of(context).size.height * 0.15,
                              decoration: BoxDecoration(
                                  color: ArgonColors.white,
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 0.5,
                                          color: ArgonColors.muted))),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Center(
                                      child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text("Sign up with",
                                        style: TextStyle(
                                            color: ArgonColors.text,
                                            fontSize: 16.0)),
                                  )),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            primary: ArgonColors.secondary,
                                            onPrimary: ArgonColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.only(
                                              bottom: 10,
                                              top: 10,
                                              left: 14,
                                              right: 14,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.github,
                                                  size: 13,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "GITHUB",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            primary: ArgonColors.secondary,
                                            onPrimary: ArgonColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.only(
                                              bottom: 10,
                                              top: 10,
                                              left: 8,
                                              right: 8,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.facebook,
                                                  size: 13,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "FACEBOOK",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Divider()
                                ],
                              )), //height: MediaQuery.of(context).size.height * 0.63,
                          Container(
                            color: Color.fromRGBO(244, 245, 247, 1),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            top: 24.0, bottom: 24.0),
                                        child: Center(
                                          child: Text(
                                            "Or sign up with the classic way",
                                            style: TextStyle(
                                              color: ArgonColors.text,
                                              fontWeight: FontWeight.w200,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: GestureDetector(
                                              onTap: () async {
                                                FilePickerResult? result =
                                                    await FilePicker.platform
                                                        .pickFiles(
                                                  type: FileType
                                                      .image, // Limitez le choix aux fichiers image
                                                );

                                                if (result != null) {
                                                  PlatformFile file =
                                                      result.files.first;
                                                  if (file.path != null) {
                                                    setState(() {
                                                      _profileImage =
                                                          File(file.path!);
                                                    });
                                                  } else {
                                                    // Gérez le cas où file.path est nul, par exemple en affichant un message d'erreur à l'utilisateur.
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              'Erreur de sélection de fichier'),
                                                          content: Text(
                                                              'La sélection de fichier a échoué. Veuillez réessayer.'),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(); // Fermez la boîte de dialogue
                                                              },
                                                              child: Text('OK'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                }
                                              },
                                              child: CircleAvatar(
                                                radius: 60,
                                                backgroundImage: _profileImage !=
                                                        null
                                                    ? FileImage(_profileImage!)
                                                    : null, // Utilisez la photo de profil sélectionnée ou une icône par défaut
                                                child: _profileImage == null
                                                    ? Icon(Icons.add_a_photo)
                                                    : null, // Affichez une icône pour ajouter une photo de profil si elle est vide
                                              ),
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Input(
                                              placeholder: "Name",
                                              prefixIcon: Icon(Icons.person),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Veuillez entrer votre nom';
                                                }
                                                return null; // Retourne null si la validation réussit
                                              },
                                              onFieldSubmitted: (value) {
                                                _firstName = value!;
                                                ;
                                              },
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Input(
                                              placeholder: "Prenoms",
                                              prefixIcon: Icon(Icons.person),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Veuillez entrer votre nom';
                                                }
                                                return null; // Retourne null si la validation réussit
                                              },
                                              onFieldSubmitted: (value) {
                                                _lastName = value!;
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Input(
                                              placeholder: "Email",
                                              prefixIcon: Icon(Icons.email),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Veuillez entrer votre adresse e-mail';
                                                }

                                                // Expression régulière pour valider une adresse e-mail
                                                final emailRegExp = RegExp(
                                                    r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

                                                if (!emailRegExp
                                                    .hasMatch(value)) {
                                                  return 'Veuillez entrer une adresse e-mail valide';
                                                }

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
                                              placeholder:
                                                  "Numero de téléphone",
                                              prefixIcon: Icon(Icons.phone),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Veuillez entrer votre nom';
                                                }
                                                return null; // Retourne null si la validation réussit
                                              },
                                              onFieldSubmitted: (value) {
                                                _phoneNumber = value!;
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
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Veuillez entrer votre mot de passe';
                                                }
                                                // Vous pouvez ajouter une validation de mot de passe supplémentaire ici
                                                return null; // Retourne null si la validation réussit
                                              },
                                              onFieldSubmitted: (value) {
                                                // Le code à exécuter lorsque ce champ est soumis
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 24.0),
                                            child: RichText(
                                              text: TextSpan(
                                                text:
                                                    "force du mot de passe : ",
                                                style: TextStyle(
                                                  color: ArgonColors.muted,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: "forte",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          ArgonColors.success,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Dropdown pour sélectionner la région
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                DropdownButtonFormField<String>(
                                              decoration: InputDecoration(
                                                labelText:
                                                    'Sélectionnez une région',
                                                prefixIcon:
                                                    Icon(Icons.location_on),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                              ),
                                              value: _selectedRegion,
                                              items: _regions.map((region) {
                                                return DropdownMenuItem<String>(
                                                  value: region,
                                                  child: Text(region),
                                                );
                                              }).toList(),
                                              onChanged: (region) {
                                                setState(() {
                                                  _selectedRegion = region;
                                                  _selectedCommune = null;
                                                  _quartier =
                                                      null; // Réinitialisez la commune et le quartier
                                                });
                                              },
                                            ),
                                          ),

                                          // Dropdown pour sélectionner la commune
                                          if (_selectedRegion != null)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: DropdownButtonFormField<
                                                  String>(
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Sélectionnez une commune',
                                                  prefixIcon:
                                                      Icon(Icons.map_sharp),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                ),
                                                value: _selectedCommune,
                                                items:
                                                    _communes[_selectedRegion!]!
                                                        .map((commune) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: commune,
                                                    child: Text(commune),
                                                  );
                                                }).toList(),
                                                onChanged: (commune) {
                                                  setState(() {
                                                    _selectedCommune = commune;
                                                    _quartier =
                                                        null; // Réinitialisez le quartier
                                                  });
                                                },
                                              ),
                                            ),

                                          // Champ de saisie pour préciser le quartier
                                          if (_selectedCommune != null)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                decoration: InputDecoration(
                                                  labelText: 'Quartier',
                                                  prefixIcon: Icon(Icons
                                                      .location_city_outlined),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (_selectedCommune !=
                                                          null &&
                                                      (value == null ||
                                                          value.isEmpty)) {
                                                    return 'Veuillez entrer le quartier';
                                                  }
                                                  return null; // Retourne null si la validation réussit
                                                },
                                                onChanged: (value) {
                                                  setState(() {
                                                    _quartier = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          // Dropdown pour sélectionner le profil
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                DropdownButtonFormField<String>(
                                              decoration: InputDecoration(
                                                labelText:
                                                    'Sélectionnez un profil',
                                                prefixIcon: Icon(Icons.person),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                              ),
                                              value: _selectedProfileType,
                                              items: [
                                                'Elève',
                                                'Parent d\'élève',
                                                'Enseignant'
                                              ].map((profileType) {
                                                return DropdownMenuItem<String>(
                                                  value: profileType,
                                                  child: Text(profileType),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedProfileType = value!;
                                                  if (value == 'Enseignant') {
                                                    _isTeacher = true;
                                                  } else {
                                                    _isTeacher = false;
                                                  }
                                                });
                                              },
                                            ),
                                          ),

                                          // Si le profil "Enseignant" est sélectionné, demandez un diplôme
                                          if (_isTeacher)
                                            Column(
                                              children: [
                                                SizedBox(height: 10.0),
                                                Text(
                                                    'Sélectionnez votre diplôme'),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      _uploadProgress =
                                                          0.0; // Réinitialisez la progression du téléchargement
                                                    });

                                                    FilePickerResult? result =
                                                        await FilePicker
                                                            .platform
                                                            .pickFiles(
                                                      type: FileType.custom,
                                                      allowedExtensions: [
                                                        'pdf',
                                                        'jpeg',
                                                        'jpg',
                                                        'png'
                                                      ],
                                                    );

                                                    if (result != null) {
                                                      PlatformFile file =
                                                          result.files.first;

                                                      // Le code de téléchargement du fichier va ici
                                                      // Vous devrez probablement utiliser un package comme http ou firebase_storage pour le téléchargement

                                                      // Exemple hypothétique de progression (à adapter à votre utilisation réelle)
                                                      for (int i = 0;
                                                          i <= 100;
                                                          i++) {
                                                        await Future.delayed(
                                                            Duration(
                                                                milliseconds:
                                                                    100));
                                                        setState(() {
                                                          _uploadProgress = i /
                                                              100; // Mettez à jour la progression
                                                        });
                                                      }

                                                      // Téléchargement terminé
                                                    }
                                                  },
                                                  child: Text(
                                                      'Télécharger un fichier'),
                                                ),
                                                LinearProgressIndicator(
                                                  value:
                                                      _uploadProgress, // La valeur doit être comprise entre 0.0 et 1.0
                                                  minHeight:
                                                      10, // Hauteur minimale de la barre de progression
                                                  backgroundColor: Colors.grey[
                                                      300], // Couleur de fond de la barre de progression
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Colors
                                                              .blue), // Couleur de remplissage de la barre de progression
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, top: 0, bottom: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Checkbox(
                                              activeColor: ArgonColors.primary,
                                              onChanged: (bool? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    _checkboxValue = newValue;
                                                  });
                                                }
                                              },
                                              value: _checkboxValue,
                                            ),
                                            Text(
                                              "I agree with the",
                                              style: TextStyle(
                                                color: ArgonColors.muted,
                                                fontWeight: FontWeight.w200,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, '/pro');
                                              },
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(left: 5),
                                                child: Text(
                                                  "Privacy Policy",
                                                  style: TextStyle(
                                                    color: ArgonColors.primary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Center(
                                          child: TextButton(
                                            onPressed: () {
                                              // Réagir lorsque le bouton est pressé
                                              Navigator.pushNamed(
                                                  context, '/home');
                                            },
                                            style: TextButton.styleFrom(
                                              primary: ArgonColors.white,
                                              backgroundColor:
                                                  ArgonColors.primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
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
                                                "REGISTER",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
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
                          )
                        ],
                      )),
                ),
              ]),
            )
          ],
        ));
  }
}
