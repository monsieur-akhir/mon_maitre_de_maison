import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

import '../theme/theme.dart';
import '../widgets/drawer.dart';
import '../widgets/input.dart';
import '../widgets/navbar.dart';

class Annonces extends StatefulWidget {
  @override
  _AnnoncesState createState() => _AnnoncesState();

}


class _AnnoncesState extends State<Annonces> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: Navbar(transparent: true, title: ""),
        extendBodyBehindAppBar: true,
        drawer: ArgonDrawer(currentPage: "Mes Annonces"),
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
                              "Créer une annonce de cours",
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
                            // Ajoutez d'autres widgets ou fonctionnalités pour gérer les annonces
                            // ...
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to the ManageCourseAnnouncementsPage
                                Navigator.pushReplacementNamed(context, '/manage_course_announcements');
                              },
                              child: Text('Gérer mes annonces de cours'),
                            ),

                            ElevatedButton(
                              onPressed: () {
                                // Navigate to the main page or perform other actions as needed
                                Navigator.pushReplacementNamed(context, '/form_cours');
                              },
                              child: Text('Créer une nouvelle annonce de cours'),
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
