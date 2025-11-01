class LessonTag {
  final String full;
  final String short;

  LessonTag({required this.full, required this.short});

  LessonTag copyWith({String? full, String? short}) {
    return LessonTag(full: full ?? this.full, short: short ?? this.short);
  }
}
