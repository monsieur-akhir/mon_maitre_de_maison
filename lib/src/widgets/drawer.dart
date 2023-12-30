import 'package:flutter/material.dart';

import 'package:mon_maitre_de_maison/src/theme/theme.dart';

import 'package:mon_maitre_de_maison/src/widgets/drawer-tile.dart';

class ArgonDrawer extends StatelessWidget {
  final String? currentPage;

  ArgonDrawer({required this.currentPage});


  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
          color: ArgonColors.white,
          child: Column(children: [
            Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.85,
                child: SafeArea(
                  bottom: false,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: Image.asset("assets/reading.png"),
                    ),
                  ),
                )),
            Expanded(
              flex: 2,
              child: ListView(
                padding: EdgeInsets.only(top: 24, left: 16, right: 16),
                children: [
                  DrawerTile(
                      icon: Icons.home,
                      onTap: () {
                        if (currentPage != "HomePage" && Navigator.canPop(context)) {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      },
                      iconColor: ArgonColors.primary,
                      title: "Home",
                      isSelected: currentPage == "HomePage" ? true : false),
                  DrawerTile(
                      icon: Icons.apps,
                      onTap: () {
                        if (currentPage != "Recherche")
                          Navigator.pushReplacementNamed(context, '/all_annoucements');
                      },
                      iconColor: ArgonColors.primary,
                      title: "Toute les annonces",
                      isSelected: currentPage == "Toute les annonces" ? true : false),
                  DrawerTile(
                      icon: Icons.pie_chart,
                      onTap: () {
                        if (currentPage != "Profile" && Navigator.canPop(context)) {
                          Navigator.pushReplacementNamed(context, '/profile');
                        }
                      },
                      iconColor: ArgonColors.warning,
                      title: "Profile",
                      isSelected: currentPage == "Profile" ? true : false),
                  DrawerTile(
                      icon: Icons.account_circle,
                      onTap: () {
                        if (currentPage != "Account")
                          Navigator.pushReplacementNamed(context, '/account');
                      },
                      iconColor: ArgonColors.info,
                      title: "Account",
                      isSelected: currentPage == "Account" ? true : false),
                  DrawerTile(
                      icon: Icons.settings_input_component,
                      onTap: () {
                        if (currentPage != "Mes Annonces")
                          Navigator.pushReplacementNamed(context, '/annonces');
                      },
                      iconColor: ArgonColors.error,
                      title: "Mes Annonces",
                      isSelected: currentPage == "Mes Annonces" ? true : false),

                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                  padding: EdgeInsets.only(left: 8, right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(height: 4, thickness: 0, color: ArgonColors.muted),
                      Padding(
                        padding:
                        const EdgeInsets.only(top: 16.0, left: 16, bottom: 8),
                        child: Text("DOCUMENTATION",
                            style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 0.5),
                              fontSize: 15,
                            )),
                      ),
                      /**
                      DrawerTile(
                          icon: Icons.airplanemode_active,
                          onTap: _launchURL,
                          iconColor: ArgonColors.muted,
                          title: "Getting Started",
                          isSelected:
                          currentPage == "Getting started" ? true : false), **/
                    ],
                  )),
            ),
          ]),
        ));
  }
}