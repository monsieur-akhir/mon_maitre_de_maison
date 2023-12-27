import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import '../theme/theme.dart';
import '../widgets/drawer.dart';
import '../widgets/input.dart';
import '../widgets/navbar.dart';

class Annonces extends StatefulWidget {
  @override
  _AnnoncesState createState() => _AnnoncesState();
}

class _AnnoncesState extends State<Annonces> {
  File? _diplomaFile;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _tarifController = TextEditingController();
  TextEditingController _localisationController = TextEditingController();
  TextEditingController _langueController = TextEditingController();
  TextEditingController _accesVisioController = TextEditingController();
  String _titre = '';
  String _description= '';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: Navbar(transparent: true, title: ""),
        extendBodyBehindAppBar: true,
        drawer: ArgonDrawer(currentPage: "Annonces"),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/register-bg.png"),
                      fit: BoxFit.cover)),
            ),
            Container(
              color: Color.fromRGBO(244, 245, 247, 1),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 80.0, bottom: 24.0),
                          child: Center(
                            child: Text(
                              "Create an Announcement",
                              style: TextStyle(
                                color: ArgonColors.text,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ... (Autres champs d'entrée)

                            // Champ d'entrée pour le titre de l'annonce
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Input(
                                placeholder: "Titre",
                                prefixIcon: Icon(Icons.title),
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty) {
                                    return 'Veuillez entrer un titre';
                                  }
                                  return null; // Retourne null si la validation réussit
                                },
                                onFieldSubmitted: (value) {
                                  _titre = value!;
                                },
                              ),
                            ),

                            // Champ d'entrée pour la description de l'annonce
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Input(
                                placeholder: "Description",
                                prefixIcon: Icon(Icons.description_sharp),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer une description';
                                  }
                                  return null; // Retourne null si la validation réussit
                                },
                                onFieldSubmitted: (value) {
                                  _description= value!;
                                },
                                maxLines: null, // Permet plusieurs lignes pour la description
                              ),
                            ),


                            // Champ d'entrée pour d'autres caractéristiques de l'annonce
                            // ...

                            ElevatedButton(
                              onPressed: () {
                                // Ajoutez le code pour soumettre l'annonce à Firestore
                                // Utilisez les informations nécessaires pour créer une annonce
                                // Vous pouvez accéder aux valeurs des champs avec les contrôleurs ou directement depuis l'état du widget
                              },
                              child: Text('Publish Announcement'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )


          ],
        ));
  }
}
