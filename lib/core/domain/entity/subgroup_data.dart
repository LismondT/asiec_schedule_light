class SubgroupData {
  /// Преподаватель
  final String? teacher;

  /// Аудитория
  final String? classroom;

  /// Корпус
  final String? territory;

  /// Подгруппа занятия
  final int subgroup;

  SubgroupData({
    required this.subgroup,
    this.teacher,
    this.classroom,
    this.territory,
  });

  Map<String, dynamic> toJson() {
    return {
      'teacher': teacher,
      'classroom': classroom,
      'territory': territory,
      'subgroup': subgroup
    };
  }

  factory SubgroupData.fromJson(Map<String, dynamic> json) {
    return SubgroupData(
        teacher: json['teacher'],
        classroom: json['classroom'],
        territory: json['territory'],
        subgroup: json['subgroup'] as int);
  }
}
