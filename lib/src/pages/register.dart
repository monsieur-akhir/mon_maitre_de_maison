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
  bool _isRegistering = false;
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
  String? _profileImagePath;
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
                        children: [ //height: MediaQuery.of(context).size.height * 0.63,
                          Container(
                            key: _formKey,
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
                                              placeholder: "Nom",
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
                                                  return 'Veuillez entrer votre prénom';
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
                                                  return 'Veuillez entrer votre numéro de téléphone';
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
                                              placeholder: "Mot de passe",
                                              prefixIcon: Icon(Icons.lock),
                                              obscureText: true,
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Veuillez entrer votre mot de passe';
                                                }
                                                if (value.length < 8) {
                                                  return 'Le mot de passe doit contenir au moins 8 caractères';
                                                }
                                                return null;
                                              },
                                              onFieldSubmitted: (value) {
                                                _password = value!;
                                              },
                                            ),
                                          ),
                                          // Dropdown pour sélectionner la région
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                DropdownButtonFormField<String>(
                                              decoration: InputDecoration(
                                                labelText:
                                                    'Sélectionnez votre région',
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
                                                      'Sélectionnez votre commune ou ville',
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
                                                  onPressed: _selectDiploma,
                                                  child: Text(
                                                      'Télécharger un fichier'),
                                                ),
                                                if (_diplomaFile != null)
                                                  LinearProgressIndicator(
                                                    value: _uploadProgress,
                                                    minHeight: 10,
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(Colors.blue),
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
                                            onPressed:
                                                _submitForm, // déplacez l'appel de la fonction onPressed en dehors de l'accolade de l'enfant
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
                                                "Enregistrer",
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

  void _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  void _selectDiploma() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        _diplomaFile = File(file.path!);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Définissez `_isRegistering` sur true pour afficher l'animation
      setState(() {
        _isRegistering = true;
      });
      bool isEmailExists = await checkIfEmailExists(_email);

      if (isEmailExists) {
        // L'adresse e-mail existe déjà, affichez un message d'erreur
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Erreur de création de compte'),
              content: Text('L\'adresse e-mail existe déjà.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermez la boîte de dialogue
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        try {
          // Create the user account using Firebase Authentication
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: _email, password: _password!);

          // Get the UID of the newly created user
          String userId = userCredential.user!.uid;

          // Upload profile photo to Firebase Storage
          if (_profileImage != null) {
            final profilePhotoRef =
                _storage.ref().child('profilePhotos/$userId');
            await profilePhotoRef.putFile(_profileImage!);
            final profilePhotoUrl = await profilePhotoRef.getDownloadURL();
            _profileImagePath = profilePhotoUrl;
          }

          // Upload diploma to Firebase Storage if the user is a teacher
          if (_isTeacher && _diplomaFile != null) {
            final diplomaRef = _storage.ref().child('diplomas/$userId');
            await diplomaRef.putFile(_diplomaFile!);
            final diplomaUrl = await diplomaRef.getDownloadURL();
            _diplomaPath = diplomaUrl;
          }

          // Add user data to Firestore
          await _firestore.collection('users').doc(userId).set({
            'firstName': _firstName,
            'lastName': _lastName,
            'email': _email,
            'phoneNumber': _phoneNumber,
            'address': _address,
            'profileType': _selectedProfileType,
            'profilePhotoPath': _profileImagePath,
            'diplomaPath': _diplomaPath,
            'region': _selectedRegion,
            'commune': _selectedCommune,
            'quartier': _quartier
          });
          setState(() {
            _isRegistering = false;
          });
          // Reset the form

          // Show a success dialog and navigate to the main page
          _showSuccessDialog();
        } catch (e) {
          if (e is FirebaseAuthException) {
            if (e.code == 'email-already-in-use') {
              // L'adresse e-mail est déjà utilisée, affichez un message d'erreur
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Erreur d\'inscription'),
                    content: Text(
                        'Cette adresse e-mail est déjà associée à un compte.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            } else {
              // Gérez d'autres erreurs Firebase ici si nécessaire
              setState(() {
                _isRegistering = false;
              });
              print('Erreur Firebase: ${e.code}');
            }
          } else {
            setState(() {
              _isRegistering = false;
            });
            // Gérez d'autres erreurs inattendues ici si nécessaire
            print('Erreur inattendue: $e');
          }
        }
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Compte créé avec succès'),
          content: Text('Votre compte a été créé avec succès.'),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
                // Navigate to the main page or perform other actions as needed
                Navigator.pushNamed(context, '/');
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<String> uploadDiploma(File diplomaFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    firebase_storage.Reference ref = _storage.ref().child('diplomas/$fileName');
    firebase_storage.UploadTask uploadTask = ref.putFile(diplomaFile);
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadProfilePhoto(File profilePhoto) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    firebase_storage.Reference ref =
        _storage.ref().child('profilePhotos/$fileName');
    firebase_storage.UploadTask uploadTask = ref.putFile(profilePhoto);
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<bool> checkIfEmailExists(String email) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}
