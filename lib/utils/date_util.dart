class DateUtil {
  static int getCurrentWeek(String startDateStr) {
    if (startDateStr.isEmpty) return 1;

    try {
      DateTime now = DateTime.now();
      DateTime startDate = DateTime.parse(startDateStr);

      DateTime startMonday = startDate.subtract(
        Duration(days: startDate.weekday - 1),
      );

      startMonday = DateTime(
        startMonday.year,
        startMonday.month,
        startMonday.day,
      );
      DateTime today = DateTime(now.year, now.month, now.day);

      final difference = today.difference(startMonday).inDays;

      int currentWeek = (difference / 7).floor() + 1;

      if (currentWeek < 1) return 1;
      return currentWeek;
    } catch (e) {
      return 1;
    }
  }

  static bool isInSemester(int currentWeek) {
    return currentWeek >= 1 && currentWeek <= 20;
  }
}
