import 'package:flutter/material.dart';
import 'package:zhanghuan/pages/room_detail/room_detail.dart';
import '../../services/network_service.dart';

class EmptyRoom extends StatefulWidget {
  final int week;
  final int semesterId;
  const EmptyRoom({super.key, required this.week, required this.semesterId});

  @override
  State<EmptyRoom> createState() => _EmptyRoomState();
}

class _EmptyRoomState extends State<EmptyRoom> {
  List _allRooms = [];
  List _displayRooms = [];
  bool _isLoading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  @override
  void didUpdateWidget(EmptyRoom oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.week != widget.week ||
        oldWidget.semesterId != widget.semesterId) {
      _fetchRooms();
    }
  }

  Future<void> _fetchRooms() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    String url =
        "https://eams.tjzhic.edu.cn/student/for-std/room-week-occupation/semester/${widget.semesterId}/search";
    final data = await NetworkService().request(
      url,
      isPost: true,
      body: {
        "teachingWeek": widget.week,
        "campus": 1,
        "buildingAssocs": [],
        "roomAssocs": [],
        "seatsForLessonLowerLimit": "",
        "seatsForLessonUpperLimit": "",
        "enabled": 1,
      },
    );
    if (data != null && mounted) {
      setState(() {
        _allRooms = data is List ? data : (data['data'] ?? []);
        _filterRooms(_searchQuery);
        _isLoading = false;
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterRooms(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _displayRooms = _allRooms;
      } else {
        _displayRooms = _allRooms
            .where(
              (room) => room['roomNameZh'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SearchBar(
            hintText: "搜索教室, 示例: 1109",
            leading: const Row(
              children: [SizedBox(width: 12), Icon(Icons.search)],
            ),
            onChanged: _filterRooms,
            elevation: WidgetStateProperty.all(0),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchRooms,
                  child: _displayRooms.isEmpty
                      ? Column(
                          mainAxisAlignment: .center,
                          children: [
                            Center(
                              child: Text(
                                _allRooms.isEmpty
                                    ? "无法获取数据, 请尝试重新登录"
                                    : "未找到相关教室, 换个关键词试试",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _displayRooms.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 5),
                          itemBuilder: (context, index) {
                            final room = _displayRooms[index];
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.meeting_room,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                title: Text(
                                  room['roomNameZh'] ?? '未知',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "${room['buildingNameZh'] ?? '未知'} · 可容纳${room['seatsForLesson'] ?? 0}人",
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RoomDetail(data: room),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}
