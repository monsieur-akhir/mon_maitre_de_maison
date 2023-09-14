import 'package:flutter/material.dart';
import 'package:mon_maitre_de_maison/src/pages/detail_page.dart';
import 'package:mon_maitre_de_maison/src/pages/home_page.dart';
import 'package:mon_maitre_de_maison/src/pages/splash_page.dart';
import 'package:mon_maitre_de_maison/src/widgets/coustom_route.dart';

import '../model/dactor_model.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoute() {
    return <String, WidgetBuilder>{
      '/': (_) => SplashPage(),
      '/HomePage': (_) => HomePage(),
    };
  }

  static Route? onGenerateRoute(RouteSettings settings) {
    final List<String> pathElements = settings.name!.split('/');
    if (pathElements[0] != '' || pathElements.length == 1) {
      return null;
    }
    switch (pathElements[1]) {
      case "DetailPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => DetailPage(model: settings.arguments as DoctorModel),
        );
    }
  }
}
