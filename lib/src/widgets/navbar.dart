import 'package:flutter/material.dart';
import 'package:mon_maitre_de_maison/src/theme/extention.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:mon_maitre_de_maison/src/theme/theme.dart';
import 'package:mon_maitre_de_maison/src/widgets/input.dart';

import '../theme/light_color.dart';
import '../theme/text_styles.dart';


class Navbar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String categoryOne;
  final String categoryTwo;
  final bool searchBar;
  final bool backButton;
  final bool transparent;
  final bool rightOptions;
  final List<String>? tags;
  final Function? getCurrentPage;
  final bool isOnSearch;
  final TextEditingController? searchController;
  final Function? searchOnChanged;
  final bool searchAutofocus;
  final bool noShadow;
  final Color bgColor;

  Navbar({
    this.title = "Home",
    this.categoryOne = "",
    this.categoryTwo = "",
    this.tags,
    this.transparent = false,
    this.rightOptions = true,
    this.getCurrentPage,
    this.searchController,
    this.isOnSearch = false,
    this.searchOnChanged,
    this.searchAutofocus = false,
    this.backButton = false,
    this.noShadow = false,
    this.bgColor = ArgonColors.white,
    this.searchBar = false,
  });

  final double _preferredHeight = 150.0;

  @override
  _NavbarState createState() => _NavbarState();

  @override
  Size get preferredSize => Size.fromHeight(_preferredHeight);
}

class _NavbarState extends State<Navbar> {
  String? activeTag;

  ItemScrollController _scrollController = ItemScrollController();

  void initState() {
    if (widget.tags != null && widget.tags!.length != 0) {
      activeTag = widget.tags![0];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool categories =
        widget.categoryOne!.isNotEmpty && widget.categoryTwo!.isNotEmpty;
    final bool tagsExist =
    widget.tags == null ? false : (widget.tags!.length == 0 ? false : true);

    return Container(
      height: widget.searchBar
          ? (!categories
          ? (tagsExist ? 211.0 : 178.0)
          : (tagsExist ? 262.0 : 210.0))
          : (!categories
          ? (tagsExist ? 162.0 : 102.0)
          : (tagsExist ? 200.0 : 150.0)),
    /**  decoration: BoxDecoration(
        color: !widget.transparent ? widget.bgColor : Colors.transparent,
      ),**/
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          !widget.backButton
                              ? Icons.short_text
                              : Icons.arrow_back_ios,
                          color: !widget.transparent
                              ? (widget.bgColor == ArgonColors.white
                              ? ArgonColors.initial
                              : ArgonColors.white)
                              : ArgonColors.white,
                          size: 24.0,
                        ),
                        onPressed: () {
                          if (!widget.backButton)
                            Scaffold.of(context).openDrawer();
                          else
                            Navigator.pop(context);
                        },
                      ),
                      Text(
                        widget.title,

                        style: TextStyle(
                          color: !widget.transparent
                              ? (widget.bgColor == ArgonColors.white
                              ? ArgonColors.initial
                              : ArgonColors.white)
                              : ArgonColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                  if (widget.rightOptions)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                              //  Navigator.pushNamed(context, '/pro');
                              },
                              child: IconButton(
                                icon: Icon(
                                  Icons.notifications_none,
                                  size: 30,
                                  color: LightColor.grey,
                                ),
                                onPressed: null,
                              ),
                            ),
                            CircleAvatar(
                              radius: 25, // Ajustez le rayon selon vos besoins
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Image.asset(
                                "assets/user.png",
                                fit: BoxFit.cover,
                                height: 50, // Ajustez la taille de l'image à l'intérieur du cercle
                                width: 50,
                              ),
                            ).p(10)
                          ],
                        ),

                      ],
                    ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              if (categories)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                       // Navigator.pushNamed(context, '/pro');
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.camera,
                            color: ArgonColors.initial,
                            size: 22.0,
                          ),
                          SizedBox(width: 10),
                          Text(
                            widget.categoryOne,
                            style: TextStyle(
                              color: ArgonColors.initial,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 30),
                    Container(
                      color: ArgonColors.initial,
                      height: 25,
                      width: 1,
                    ),
                    SizedBox(width: 30),
                    GestureDetector(
                      onTap: () {
                      //  Navigator.pushNamed(context, '/pro');
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            color: ArgonColors.initial,
                            size: 22.0,
                          ),
                          SizedBox(width: 10),
                          Text(
                            widget.categoryTwo,
                            style: TextStyle(
                              color: ArgonColors.initial,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              if (tagsExist)
                Container(
                  height: 40,
                  child: ScrollablePositionedList.builder(
                    itemScrollController: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.tags!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          if (activeTag != widget.tags![index]) {
                            setState(() => activeTag = widget.tags![index]);
                            _scrollController.scrollTo(
                              index: index == widget.tags!.length - 1 ? 1 : 0,
                              duration: Duration(milliseconds: 420),
                              curve: Curves.easeIn,
                            );
                            if (widget.getCurrentPage != null)
                              widget.getCurrentPage!(activeTag);
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            left: index == 0 ? 46 : 8,
                            right: 8,
                          ),
                          padding: EdgeInsets.only(
                            top: 4,
                            bottom: 4,
                            left: 20,
                            right: 20,
                          ),
                          decoration: BoxDecoration(
                            color: activeTag == widget.tags![index]
                                ? ArgonColors.primary
                                : ArgonColors.secondary,
                            borderRadius: BorderRadius.all(
                              Radius.circular(4.0),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              widget.tags![index],
                              style: TextStyle(
                                color: activeTag == widget.tags![index]
                                    ? ArgonColors.white
                                    : ArgonColors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
