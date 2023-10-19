import 'package:flutter/material.dart';

import 'package:mon_maitre_de_maison/src/theme/theme.dart';

class DrawerTile extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? iconColor;

  const DrawerTile({
    this.title,
    this.icon,
    this.onTap,
    this.isSelected = false,
    this.iconColor = ArgonColors.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? ArgonColors.primary : ArgonColors.white,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: isSelected ? ArgonColors.white : iconColor),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(title!,
                  style: TextStyle(
                    letterSpacing: 0.3,
                    fontSize: 15,
                    color: isSelected
                        ? ArgonColors.white
                        : Color.fromRGBO(0, 0, 0, 0.7),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
