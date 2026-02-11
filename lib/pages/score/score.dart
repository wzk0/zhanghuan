import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/network_service.dart';

class Score extends StatefulWidget {
  final int semesterId;
  const Score({super.key, required this.semesterId});

  @override
  State<Score> createState() => _ScoreState();
}

class _ScoreState extends State<Score> {
  List _scores = [];
  Map<String, double> _summary = {'GPA': 0, 'credits': 0, 'averageScore': 0};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(Score oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.semesterId != widget.semesterId) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final String? businessId = await _getStudentBusinessId();
      if (businessId == null) {
        throw "无法获取业务ID，请尝试重新登录";
      }
      final String url =
          "https://eams.tjzhic.edu.cn/student/for-std/grade/sheet/info/$businessId";
      final response = await NetworkService().request(
        url,
        queryParameters: {'semester': widget.semesterId},
      );
      if (response != null && response['semesterId2studentGrades'] != null) {
        final semesterKey = widget.semesterId.toString();
        final List data =
            response['semesterId2studentGrades'][semesterKey] ?? [];
        if (mounted) {
          setState(() {
            _scores = data;
            _summary = _calculateSummary(data);
            _isLoading = false;
          });
        }
      } else {
        throw "该学期暂无成绩记录";
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<String?> _getStudentBusinessId() async {
    const String url =
        'https://eams.tjzhic.edu.cn/student/for-std/grade/sheet/';
    final prefs = await SharedPreferences.getInstance();
    final String? cookies = prefs.getString('cookies')?.replaceAll('"', '');
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url))
        ..followRedirects = false
        ..headers['Cookie'] = cookies ?? '';
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      String? location = response.headers['location'];
      if (location != null) {
        return _extractId(location);
      }
      final finalUrl = response.request?.url.toString() ?? '';
      return _extractId(finalUrl);
    } catch (e) {
      return null;
    } finally {
      client.close();
    }
  }

  String? _extractId(String url) {
    final RegExp regExp = RegExp(r'/(\d+)$|/(\d+)\?');
    final match = regExp.firstMatch(url);
    String? id = match?.group(1) ?? match?.group(2);
    return id;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        _buildSummaryCard(colorScheme),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: colorScheme.tertiary),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: _scores.isEmpty
                      ? const Center(child: Text("暂无数据"))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _scores.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) =>
                              _buildScoreTile(_scores[index], colorScheme),
                        ),
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem("平均分", _summary['averageScore']!.toStringAsFixed(1)),
          _summaryItem("总学分", _summary['credits']!.toStringAsFixed(1)),
          _summaryItem("GPA", _summary['GPA']!.toStringAsFixed(2)),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 22,
            fontWeight: .bold,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreTile(Map data, ColorScheme colorScheme) {
    final bool isPassed = data['passed'] ?? true;
    final String grade = data['gaGrade']?.toString() ?? '-';
    return Card(
      elevation: 0,
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          backgroundColor: isPassed
              ? colorScheme.primaryContainer
              : colorScheme.tertiaryContainer,
          child: Text(
            grade,
            style: TextStyle(
              color: isPassed ? colorScheme.primary : colorScheme.tertiary,
              fontWeight: .bold,
            ),
          ),
        ),
        title: Text(
          data['courseName'] ?? '未知课程',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${data['courseProperty']} · ${data['courseCode']}',
          style: TextStyle(fontSize: 11, color: colorScheme.outline),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              textAlign: .center,
              '学分: ${data['credits']}\n绩点: ${data['gp']}',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateSummary(List courses) {
    double totalGpWeight = 0.0;
    double totalScoreWeight = 0.0;
    double totalCredits = 0.0;
    for (final course in courses) {
      if (course['passed'] != true) continue;
      final credits = (course['credits'] as num?)?.toDouble() ?? 0.0;
      if (credits <= 0) continue;
      final gp = (course['gp'] as num?)?.toDouble() ?? 0.0;
      final grade = double.tryParse(course['gaGrade']?.toString() ?? '') ?? 0.0;
      totalGpWeight += gp * credits;
      totalScoreWeight += grade * credits;
      totalCredits += credits;
    }
    return {
      'GPA': totalCredits > 0 ? (totalGpWeight / totalCredits) : 0.0,
      'credits': totalCredits,
      'averageScore': totalCredits > 0
          ? (totalScoreWeight / totalCredits)
          : 0.0,
    };
  }
}
