import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mon_maitre_de_maison/src/model/dactor_model.dart';
import 'package:mon_maitre_de_maison/src/pages/AllAnnouncementsPage.dart';
import 'package:mon_maitre_de_maison/src/pages/JobsScreen.dart';
import 'package:mon_maitre_de_maison/src/pages/ManageCourseAnnouncementsPage.dart';
import 'package:mon_maitre_de_maison/src/pages/course_announcement_form.dart';
import 'package:mon_maitre_de_maison/src/pages/detail_page.dart';
import 'package:mon_maitre_de_maison/src/pages/home_page.dart';
import 'package:mon_maitre_de_maison/src/pages/login.dart';
import 'package:mon_maitre_de_maison/src/pages/profile.dart';
import 'package:mon_maitre_de_maison/src/pages/register.dart';
import 'package:mon_maitre_de_maison/src/pages/registerPage.dart';
import 'package:mon_maitre_de_maison/src/pages/splash_page.dart';
import 'package:mon_maitre_de_maison/src/theme/theme.dart';
import 'package:mon_maitre_de_maison/src/widgets/coustom_route.dart';
import 'package:mon_maitre_de_maison/src/pages/annonces.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Maitre de Maison',
      theme: AppTheme.lightTheme,
      routes: <String, WidgetBuilder>{
        '/': (_) => SplashPage(),
        '/home': (_) => HomePage(),
        "/profile": (BuildContext context) => new Profile(),
        "/account": (BuildContext context) => Register(),
        "/create_compte": (BuildContext context) => RegisterPage(),
        "/login": (BuildContext context) => Login(),
        "/annonces": (BuildContext context) => Annonces(),
        "/form_cours": (BuildContext context) => CourseAnnouncementForm(),
        '/manage_course_announcements': (context) => ManageCourseAnnouncementsPage(),
        '/all_annoucements': (context) => AllAnnouncementsPage(),
        '/jobs': (context) => JobsScreen(),
      },
      onGenerateRoute: (settings) {
        final List<String> pathElements = settings.name!.split('/');
        if (pathElements[0] != '' || pathElements.length == 1) {
          return null;
        }
        switch (pathElements[1]) {
          case 'DetailPage':
            return CustomRoute<bool>(
              builder: (BuildContext context) =>
                  DetailPage(model: settings.arguments as DoctorModel),
            );
        }
      },
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
    );
  }
}
