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

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}
// bool _isRegistering = false; // Un indicateur pour savoir si l'enregistrement est en cours
class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isRegistering = false;
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
  File? _profilePhoto;
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
    Map<String, List<String>> data = await FirebaseAccess.loadRegionsAndCommunes();

    setState(() {
      _regions = data.keys.toList();
      _communes = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un compte'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Ajoutez la logique pour revenir en arrière ici
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                if (_isRegistering)
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/img/loading2.gif",
                          width: 100, // Ajustez la largeur de l'image selon vos besoins
                          height: 100, // Ajustez la hauteur de l'image selon vos besoins
                        ),
                        SizedBox(height: 10.0),
                        Text('Enregistrement en cours...'),
                      ],
                    ),
                  )
                else if (_hasError) // Si une erreur s'est produite, masquez l'image
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 100.0,
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'Une erreur s\'est produite. Veuillez réessayer.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  )
                else
                  Center(
                    child: GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _profilePhoto != null
                            ? FileImage(_profilePhoto!)
                            : null,
                        child: _profilePhoto == null
                            ? Icon(Icons.add_a_photo)
                            : null,
                      ),
                    ),
                  ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Prénom',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Veuillez entrer votre prénom';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _firstName = value!;
                  },
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _lastName = value!;
                  },
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value!;
                  },
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Numéro de téléphone',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Veuillez entrer votre numéro de téléphone';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _phoneNumber = value!;
                  },
                ),
                SizedBox(height: 10.0),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Sélectionnez une commune',
                    prefixIcon: Icon(Icons.add_location_alt_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
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
                      _selectedCommune = null; // Réinitialisez la commune sélectionnée
                    });
                  },
                ),
                SizedBox(height: 16.0),
                if (_selectedRegion != null)
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Sélectionnez une commune',
                      prefixIcon: Icon(Icons.map_sharp),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    value: _selectedCommune,
                    items: _communes[_selectedRegion!]!.map((commune) {
                      return DropdownMenuItem<String>(
                        value: commune,
                        child: Text(commune),
                      );
                    }).toList(),
                    onChanged: (commune) {
                      setState(() {
                        _selectedCommune = commune;
                      });
                    },
                  ),
                SizedBox(height: 10.0),
                if (_selectedCommune != null)
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Quartier',
                      prefixIcon: Icon(Icons.location_city_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _quartier = value;
                      });
                    },
                  ),
                SizedBox(height: 10.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
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
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
                SizedBox(height: 10.0),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Type de profil',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  value: _selectedProfileType,
                  items: ['Elève', 'Parent d\'élève', 'Enseignant']
                      .map((String profileType) {
                    return DropdownMenuItem<String>(
                      value: profileType,
                      child: Text(profileType),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProfileType = value!;
                      if (_selectedProfileType == 'Enseignant') {
                        _isTeacher = true;
                      } else {
                        _isTeacher = false;
                      }
                    });
                  },
                ),
                if (_isTeacher)
                  Column(
                    children: [
                      SizedBox(height: 10.0),
                      Text('Sélectionnez votre diplôme'),
                      _diplomaFile != null
                          ? Text(_diplomaFile!.path)
                          : Text('Aucun fichier sélectionné'),
                    ],
                  ),
                SizedBox(height: 20.0),
                //if (_isRegistering)
                // CircularProgressIndicator()
                // else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_selectedProfileType == 'Enseignant')
                      ElevatedButton(
                        child: Text('Sélectionner le diplôme'),
                        onPressed: _selectDiploma,
                      ),
                    ElevatedButton(
                      child: Text('Créer un compte'),
                      onPressed: _submitForm,
                    ),
                  ],
                ),
              ],
            ),



          ),






// Utilisez la propriété Visibility pour afficher ou masquer l'image pendant l'enregistrement
        ),

      ),


    );


  }


  void _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _profilePhoto = File(pickedImage.path);
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
      }else{

        try {
          // Create the user account using Firebase Authentication
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
              email: _email, password: _password!);

          // Get the UID of the newly created user
          String userId = userCredential.user!.uid;

          // Upload profile photo to Firebase Storage
          if (_profilePhoto != null) {
            final profilePhotoRef = _storage.ref().child('profilePhotos/$userId');
            await profilePhotoRef.putFile(_profilePhoto!);
            final profilePhotoUrl = await profilePhotoRef.getDownloadURL();
            _profilePhotoPath = profilePhotoUrl;
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
            'profilePhotoPath': _profilePhotoPath,
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
                    content: Text('Cette adresse e-mail est déjà associée à un compte.'),
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
                Navigator.pushNamed(context, '/home');
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