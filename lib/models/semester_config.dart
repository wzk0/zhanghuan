class SemesterConfig {
  final String name; // 学期名
  final String id; // 教务系统 ID
  final String startDate; // 开学日期

  SemesterConfig({
    required this.name,
    required this.id,
    required this.startDate,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'id': id,
    'startDate': startDate,
  };

  factory SemesterConfig.fromJson(Map<String, dynamic> json) {
    return SemesterConfig(
      name: json['name'] ?? '',
      id: json['id']?.toString() ?? '',
      startDate: json['startDate'] ?? '',
    );
  }
}
