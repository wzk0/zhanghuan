import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart' show parse;

class Exam extends StatefulWidget {
  final int semesterId;
  const Exam({super.key, required this.semesterId});

  @override
  State<Exam> createState() => _ExamState();
}

class _ExamState extends State<Exam> {
  List<Map<String, dynamic>> _upcomingExams = [];
  List<Map<String, dynamic>> _finishedExams = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchExams();
  }

  @override
  void didUpdateWidget(Exam oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.semesterId != widget.semesterId) {
      _fetchExams();
    }
  }

  String? _extractId(String url) {
    final RegExp regExp = RegExp(r'/(\d+)$|/(\d+)\?');
    final match = regExp.firstMatch(url);
    String? id = match?.group(1) ?? match?.group(2);
    return id;
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
      if (location != null) return _extractId(location);
      final finalUrl = response.request?.url.toString() ?? '';
      return _extractId(finalUrl);
    } catch (e) {
      return null;
    } finally {
      client.close();
    }
  }

  Future<void> _fetchExams() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final id = await _getStudentBusinessId();
      if (id == null) throw "无法获取业务ID，请尝试重新登录";
      final prefs = await SharedPreferences.getInstance();
      final cookies = prefs.getString('cookies')?.replaceAll('"', '');
      final response = await http.get(
        Uri.parse(
          "https://eams.tjzhic.edu.cn/student/for-std/exam-arrange/info/$id?semester=${widget.semesterId}",
        ),
        headers: {'Cookie': cookies ?? ''},
      );
      if (response.statusCode == 200) {
        _parseHtml(response.body);
      } else {
        throw "服务器响应错误: ${response.statusCode}";
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _parseHtml(String htmlBody) {
    final document = parse(htmlBody);
    final List<Map<String, dynamic>> upcoming = [];
    final List<Map<String, dynamic>> finished = [];
    final rows = document
        .querySelectorAll('tbody tr')
        .where((row) => !row.classes.contains('tr-empty'));
    for (var row in rows) {
      final cells = row.querySelectorAll('td');
      if (cells.length < 3) continue;
      final time = cells[0].querySelector('.time')?.text.trim() ?? "";
      final locationNodes = cells[0].querySelectorAll('div:not(.time) span');
      final location = locationNodes.map((e) => e.text.trim()).join(" ");
      final courseName =
          cells[1]
              .querySelector('span[style*="font-weight: bold"]')
              ?.text
              .trim() ??
          "";
      final type = cells[1].querySelector('.tag-span')?.text.trim() ?? "考试";
      final status = cells[2].text.trim();
      final examData = {
        'courseName': courseName,
        'time': time,
        'location': location,
        'type': type,
        'status': status,
        'isFinished': row.classes.contains('finished') || status == "已结束",
      };

      if (examData['isFinished'] == true) {
        finished.add(examData);
      } else {
        upcoming.add(examData);
      }
    }
    if (mounted) {
      setState(() {
        _upcomingExams = upcoming;
        _finishedExams = finished;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchExams,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_upcomingExams.isNotEmpty) ...[
            _buildSectionHeader(
              "进行中 / 未开始",
              Icons.event_available,
              Theme.of(context).colorScheme.tertiary,
            ),
            ..._upcomingExams.map((e) => _buildExamCard(e, colorScheme)),
            const SizedBox(height: 20),
          ] else if (_finishedExams.isNotEmpty) ...[
            _buildNoUpcomingNotice(colorScheme),
          ],
          if (_finishedExams.isNotEmpty) ...[
            _buildSectionHeader(
              "已结束",
              Icons.history,
              Theme.of(context).colorScheme.outline,
            ),
            ..._finishedExams.map((e) => _buildExamCard(e, colorScheme)),
          ],
          if (_upcomingExams.isEmpty && _finishedExams.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 100),
                child: Text("本学期暂无考试安排"),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoUpcomingNotice(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: colorScheme.primary),
          const SizedBox(width: 10),
          const Text("暂无未结束的考试安排", style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: .bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(Map<String, dynamic> exam, ColorScheme colorScheme) {
    bool isFinished = exam['isFinished'];
    return Card(
      elevation: 0,
      child: Opacity(
        opacity: isFinished ? 0.7 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTag(
                    exam['type'],
                    isFinished ? colorScheme.secondary : colorScheme.primary,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: .horizontal,
                      child: Text(
                        exam['courseName'],
                        style: const TextStyle(fontSize: 16, fontWeight: .bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _infoRow(Icons.access_time_rounded, exam['time']),
              const SizedBox(height: 3),
              _infoRow(
                Icons.location_on_outlined,
                exam['location'].toString().isEmpty
                    ? "地点未公布"
                    : exam['location'],
              ),
              if (!isFinished) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "待考",
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      ],
    );
  }
}
