class SemesterConfig {
  final String name;
  final String id;
  final String startDate;

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
