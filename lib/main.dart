import 'package:flutter/material.dart';
import 'package:mon_maitre_de_maison/src/model/dactor_model.dart';
import 'package:mon_maitre_de_maison/src/pages/detail_page.dart';
import 'package:mon_maitre_de_maison/src/pages/home_page.dart';
import 'package:mon_maitre_de_maison/src/pages/profile.dart';
import 'package:mon_maitre_de_maison/src/pages/register.dart';
import 'package:mon_maitre_de_maison/src/pages/splash_page.dart';
import 'package:mon_maitre_de_maison/src/theme/theme.dart';
import 'package:mon_maitre_de_maison/src/widgets/coustom_route.dart';
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
