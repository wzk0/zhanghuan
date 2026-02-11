import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Schedule extends StatefulWidget {
  final List data;
  final int week;
  final String startDate;
  const Schedule({
    super.key,
    required this.data,
    required this.week,
    required this.startDate,
  });

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  static const int totalUnits = 12;
  bool _showSunday = false;
  final Map<String, bool> _tooltipSettings = {
    '授课老师': true,
    '上课时间': true,
    '上课节数': true,
    '课程学时': true,
    '课程学分': true,
  };
  final List<String> weekDay = [
    'Mon.',
    'Tue.',
    'Wed.',
    'Thu.',
    'Fri.',
    'Sat.',
    'Sun.',
  ];
  final List<String> timeTab = [
    '8:00',
    '9:25',
    '9:50',
    '11:15',
    '12:00',
    '13:30',
    '14:55',
    '15:05',
    '16:30',
    '17:15',
    '18:00',
    '19:25',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _showSunday = prefs.getBool('show_sunday') ?? false;
      for (var key in _tooltipSettings.keys) {
        _tooltipSettings[key] = prefs.getBool('tooltip_$key') ?? true;
      }
    });
  }

  DateTime _parseStartDate(String dateStr) {
    return DateTime.parse(dateStr);
  }

  @override
  Widget build(BuildContext context) {
    _loadSettings();
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final semesterStart = _parseStartDate(widget.startDate);
    final mondayOfTargetWeek = semesterStart.add(
      Duration(days: (widget.week - 1) * 7),
    );
    int columnCount = _showSunday ? 7 : 6;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: Row(
        children: [
          _buildTimeColumn(),
          const SizedBox(width: 4),
          ...List.generate(columnCount, (i) {
            final date = mondayOfTargetWeek.add(Duration(days: i));
            final isTargetWeekday = (i + 1) == currentWeekday;
            return Expanded(
              child: Column(
                children: [
                  _buildDateHeader(i, date, isTargetWeekday),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Column(
                      children: _buildCourseCells(i + 1, isTargetWeekday),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDateHeader(int index, DateTime date, bool isTargetWeekday) {
    final color = isTargetWeekday
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        Text(
          weekDay[index],
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: isTargetWeekday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          "${date.month}/${date.day}",
          style: TextStyle(color: color, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildTimeColumn() {
    return Column(
      children: [
        const SizedBox(height: 28),
        Expanded(
          child: Column(
            children: List.generate(
              totalUnits,
              (i) => Expanded(
                child: Center(
                  child: Text(
                    "${i + 1}\n${timeTab[i]}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCourseCells(int weekday, bool isTargetWeekday) {
    List<Widget> cells = [];
    List rawDayData = widget.data
        .where(
          (d) =>
              d['weekday'] == weekday && d['weekIndexes'].contains(widget.week),
        )
        .toList();
    rawDayData.sort(
      (a, b) => (a['startUnit'] as int).compareTo(b['startUnit'] as int),
    );

    List mergedDayData = [];
    for (var item in rawDayData) {
      if (mergedDayData.isNotEmpty) {
        var last = mergedDayData.last;
        bool shouldBreak = (last['endUnit'] == 5 && item['startUnit'] == 6);
        if (!shouldBreak &&
            last['courseName'] == item['courseName'] &&
            last['room'] == item['room'] &&
            last['endUnit'] == item['startUnit'] - 1) {
          last['endUnit'] = item['endUnit'];
          continue;
        }
      }
      mergedDayData.add(Map.from(item));
    }

    int currentUnit = 1;
    for (var course in mergedDayData) {
      int start = course['startUnit'];
      int end = course['endUnit'];
      if (start > totalUnits) break;
      if (end > totalUnits) end = totalUnits;
      int duration = end - start + 1;
      if (start > currentUnit) {
        cells.add(Expanded(flex: start - currentUnit, child: const SizedBox()));
      }
      cells.add(
        Expanded(
          flex: duration,
          child: _buildCourseItem(course, isTargetWeekday),
        ),
      );
      currentUnit = end + 1;
    }
    if (currentUnit <= totalUnits) {
      cells.add(
        Expanded(flex: totalUnits - currentUnit + 1, child: const SizedBox()),
      );
    }
    return cells;
  }

  Widget _buildCourseItem(Map data, bool isTargetWeekday) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = isTargetWeekday
        ? colorScheme.tertiaryContainer
        : colorScheme.primaryContainer;
    final borderColor = isTargetWeekday
        ? colorScheme.tertiary
        : colorScheme.primary;
    return GestureDetector(
      onTap: () {
        List<String> info = [];
        if (_tooltipSettings['授课老师'] == true) {
          info.add(
            "授课教师: ${data['teachers']?.isNotEmpty == true ? data['teachers'][0] : '未知'}",
          );
        }
        if (_tooltipSettings['上课时间'] == true) {
          info.add("上课时间: ${data['startTime']}~${data['endTime']}");
        }
        if (_tooltipSettings['上课节数'] == true) {
          info.add("上课节数: ${data['startUnit']}-${data['endUnit']}节");
        }
        if (_tooltipSettings['课程学时'] == true) {
          info.add("课程学时: ${data['periodInfo']['total'] ?? '未知'}");
        }
        if (_tooltipSettings['课程学分'] == true) {
          info.add("课程学分: ${data['credits'] ?? '未知'}");
        }
        Fluttertoast.showToast(msg: info.join("\n"));
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              data['courseName'] ?? '',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: borderColor,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            Text(
              data['room'] ?? '',
              style: TextStyle(fontSize: 10, color: borderColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
