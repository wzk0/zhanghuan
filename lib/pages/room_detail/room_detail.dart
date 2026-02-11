import 'package:flutter/material.dart';

class RoomDetail extends StatelessWidget {
  final Map data;
  const RoomDetail({super.key, required this.data});
  static const List<String> weeks = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    List occupations = data['roomWeekUnitOccupationVms'] ?? [];
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(data['roomNameZh'] ?? '详情'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                children: [
                  _buildLegend(context),
                  const SizedBox(height: 20),
                  _buildOccupationTable(context, colorScheme, occupations),
                ],
              ),
            ),
          ),
          _buildBeautifulBottomDrawer(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildBeautifulBottomDrawer(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return DraggableScrollableSheet(
      initialChildSize: 0.16,
      minChildSize: 0.16,
      maxChildSize: 0.53,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "教室详情",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: .bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildFancyDetailCard(
                      context,
                      icon: Icons.business_rounded,
                      label: "所在楼宇",
                      value: data['buildingNameZh'] ?? '未归属',
                    ),
                    _buildFancyDetailCard(
                      context,
                      icon: Icons.confirmation_number_rounded,
                      label: "教室名称",
                      value: data['roomNameZh']?.split('(').first ?? '-',
                    ),
                    _buildFancyDetailCard(
                      context,
                      icon: Icons.people_alt_rounded,
                      label: "额定座位",
                      value: "${data['seatsForLesson']} 个",
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFancyDetailCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: colorScheme.outline),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: .bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupationTable(
    BuildContext context,
    ColorScheme colorScheme,
    List occupations,
  ) {
    return Table(
      columnWidths: const {0: FixedColumnWidth(35)},
      children: [
        TableRow(
          children: [
            SizedBox(
              height: 25,
              child: Text('星期/节', style: TextStyle(fontSize: 10)),
            ),
            ...weeks.map(
              (w) => Center(
                child: Text(
                  w,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: .bold,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
          ],
        ),
        ...List.generate(12, (uIdx) {
          int unit = uIdx + 1;
          return TableRow(
            children: [
              SizedBox(
                height: 38,
                child: Center(
                  child: Text(
                    '$unit',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.outline,
                      fontWeight: .bold,
                    ),
                  ),
                ),
              ),
              ...List.generate(7, (wIdx) {
                int weekday = wIdx + 1;
                bool isBusy = occupations.any(
                  (o) =>
                      o['weekday'] == weekday &&
                      o['unit'] == unit &&
                      o['activityType'] != null,
                );
                return Container(
                  height: 34,
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isBusy
                        ? colorScheme.errorContainer
                        : colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _legendDot(colorScheme.tertiaryContainer, "空闲"),
          const SizedBox(width: 32),
          _legendDot(colorScheme.errorContainer, "占用"),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
