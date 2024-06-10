import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:flutter/material.dart';

import 'arrow_clipper.dart';

class CustomizedPopUpMenu {
  GlobalKey buttonKey;
  OverlayEntry? _overlayEntry;
  late Size buttonSize;
  late Offset buttonPosition;
  bool isMenuOpen = false;
  bool isTitleShow = false;
  BuildContext context;
  List<CustomizedPopUpMenuItem> childList = [];
  bool hasIcon;
  Alignment arrowPosition;

  double top;
  double? left;
  double? right;
  double arrowLeftPadding;
  double arrowRightPadding;

  late Function onChange;
  late Function menuState;

  int selectedIndex;

  CustomizedPopUpMenu({
    required this.buttonKey,
    required this.context,
    required this.childList,
    this.right,
    this.left,
    this.arrowPosition = Alignment.topRight,
    this.hasIcon = false,
    this.selectedIndex = 0,
    this.top = 15,
    this.arrowLeftPadding = 6,
    this.arrowRightPadding = 6,
  });

  void findButton() {
    final RenderBox renderBox =
        buttonKey.currentContext!.findRenderObject() as RenderBox;
    buttonSize = renderBox.size;
    buttonPosition = renderBox.localToGlobal(Offset.zero);
  }

  void openMenu() {
    findButton();
    _overlayEntry = _overlayEntryBuilder();
    Overlay.of(context)?.insert(_overlayEntry!);
    isMenuOpen = !isMenuOpen;
    menuState(isMenuOpen);
  }

  void closeMenu() {
    if (_overlayEntry != null) {
      try {
        _overlayEntry?.remove();
      } catch (e) {
        debugPrint("Error $e");
      }
      isMenuOpen = !isMenuOpen;
      menuState(isMenuOpen);
    }
  }

  OverlayEntry _overlayEntryBuilder() {
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: GestureDetector(
                  onTap: () {
                    closeMenu();
                  },
                ),
              ),
            ),
            Positioned(
              top: buttonPosition.dy + buttonSize.height - top,
              right: right,
              left: left,
              width: 180,
              child: Material(
                color: Colors.transparent,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Card(
                        elevation: 2,
                        margin: EdgeInsets.zero,
                        shadowColor: dividerColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Container(
                          width: 180,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: dividerColor, width: 0.5)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isTitleShow)
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: ListTile(
                                    dense: true,
                                    title: Text(
                                      "Filter",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: blackFont),
                                    ),
                                  ),
                                ),
                              childrenList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          right: arrowRightPadding, left: arrowLeftPadding),
                      child: Align(
                        alignment: arrowPosition,
                        child: ClipPath(
                          clipper: ArrowClipper(),
                          child: Card(
                            elevation: 2,
                            margin: EdgeInsets.zero,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              width: 17,
                              height: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget childrenList() {
    return Column(
      children: List.generate(
        childList.length,
        (index) {
          final bool isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () {
              selectedIndex = index;
              onChange(childList[index].value, index);
              closeMenu();
            },
            child: hasIcon
                ? menuListTileWithIcon(isSelected: isSelected, index: index)
                : menuListTile(
                    index: index,
                    isSelected: isSelected,
                  ),
          );
        },
      ),
    );
  }

  Widget menuListTile({required bool isSelected, required int index}) {
    // if the menu item is lat then we add the circular shape from bottom to menuListTile
    final bool isLast = index == childList.length - 1;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? lightGrey : Colors.white,
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(
                  10.0,
                ),
                bottomRight: Radius.circular(
                  10.0,
                ),
              )
            : null,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: ListTile(
          dense: true,
          title: Text(
            childList[index].title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? navyBlue : blackFont),
          ),
          trailing: isSelected
              ? Icon(
                  SlydoAppIcon.checked,
                  size: 12,
                  color: navyBlue,
                )
              : null,
        ),
      ),
    );
  }

  Widget childrenListWithIcon() {
    return Column(
      children: List.generate(
        childList.length,
        (index) {
          final bool isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () {
              selectedIndex = index;

              onChange(childList[index].value, index);
              closeMenu();
            },
            child: menuListTileWithIcon(
              index: index,
              isSelected: isSelected,
            ),
          );
        },
      ),
    );
  }

  Widget menuListTileWithIcon({required bool isSelected, required int index}) {
    // if the menu item is lat then we add the circular shape from bottom to menuListTile
    final bool isLast = index == childList.length - 1;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? lightGrey : Colors.white,
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(
                  10.0,
                ),
                bottomRight: Radius.circular(
                  10.0,
                ),
              )
            : null,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: ListTile(
          dense: true,
          title: Row(
            children: [
              Icon(
                (childList[index] is CustomizedPopUpMenuItemWithIcon
                    ? (childList[index] as CustomizedPopUpMenuItemWithIcon).icon
                    : Icons.circle),
                size: 16,
                color: isSelected ? navyBlue : Colors.black,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                childList[index].title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? navyBlue : blackFont),
              ),
              const Expanded(
                  child: SizedBox(
                width: 10,
              )),
              if (isSelected)
                Icon(
                  SlydoAppIcon.checked,
                  size: 12,
                  color: navyBlue,
                )
              else
                Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomizedPopUpMenuItem {
  String title;
  String value;

  CustomizedPopUpMenuItem({required this.title, required this.value});
}

class CustomizedPopUpMenuItemWithIcon extends CustomizedPopUpMenuItem {
  IconData icon;

  CustomizedPopUpMenuItemWithIcon(
      {required super.title, required super.value, required this.icon});
}
