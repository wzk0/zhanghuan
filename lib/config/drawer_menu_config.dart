import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:zhanghuan/pages/library/library.dart';
import 'package:zhanghuan/pages/plan/plan.dart';
import 'package:zhanghuan/pages/comment/comment.dart';
import 'package:zhanghuan/pages/select/select.dart';
import 'package:zhanghuan/pages/vocation/vocation.dart';
import '../models/drawer_item.dart';

final List<dynamic> drawerMenuConfig = [
  const DrawerDestinationModel(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: '首页│课表',
  ),
  const DrawerDestinationModel(icon: Icons.hdr_weak, label: '空教室查询'),
  const DrawerDestinationModel(icon: MdiIcons.textSearch, label: '成绩查询'),
  const DrawerDestinationModel(
    icon: MdiIcons.calendarSearchOutline,
    selectedIcon: MdiIcons.calendarSearch,
    label: '考试查询',
  ),
  const DrawerDestinationModel(
    icon: MdiIcons.calendarSearchOutline,
    selectedIcon: MdiIcons.calendarSearch,
    label: '校历',
  ),
  "divider",
  DrawerDestinationModel(
    icon: MdiIcons.humanMaleBoardPoll,
    label: '培养方案',
    type: DrawerItemType.page,
    targetPage: Plan(),
  ),

  DrawerDestinationModel(
    icon: MdiIcons.libraryOutline,
    selectedIcon: MdiIcons.library,
    label: '图书馆',
    type: DrawerItemType.page,
    targetPage: Library(),
  ),
  const DrawerDestinationModel(
    icon: Icons.class_outlined,
    label: '选课',
    type: DrawerItemType.page,
    targetPage: Select(),
  ),
  const DrawerDestinationModel(
    icon: MdiIcons.commentEditOutline,
    label: '评教',
    type: DrawerItemType.page,
    targetPage: Comment(),
  ),
  const DrawerDestinationModel(
    icon: Icons.directions_car_filled_outlined,
    label: '请假',
    type: DrawerItemType.page,
    targetPage: Vocation(),
  ),
  "divider",
  const DrawerDestinationModel(icon: Icons.settings_outlined, label: '设置'),
];
