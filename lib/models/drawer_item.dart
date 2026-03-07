import 'package:flutter/material.dart';

enum DrawerItemType { navigation, page }

class DrawerDestinationModel {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final DrawerItemType type;
  final Widget? targetPage;

  const DrawerDestinationModel({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.type = DrawerItemType.navigation,
    this.targetPage,
  });
}
