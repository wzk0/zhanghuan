import 'package:flutter/material.dart';
import 'package:zhanghuan/widgets/schedule.dart';
import '../../models/semester_config.dart';

class Home extends StatelessWidget {
  final List scheduleData;
  final SemesterConfig? currentSemester;
  final TabController tabController;
  const Home({
    super.key,
    required this.scheduleData,
    required this.currentSemester,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    if (currentSemester == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return TabBarView(
      controller: tabController,
      children: List.generate(20, (index) {
        return Schedule(
          data: scheduleData,
          week: index + 1,
          startDate: currentSemester!.startDate,
        );
      }),
    );
  }
}
