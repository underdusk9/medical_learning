/// 科目+章节组合键（用于 topics 查询）
class SectionChapterKey {
  final String subject;
  final List<String> sections;
  final List<String> chapters;

  const SectionChapterKey({
    required this.subject,
    this.sections = const [],
    this.chapters = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SectionChapterKey &&
          subject == other.subject &&
          _listEquals(sections, other.sections) &&
          _listEquals(chapters, other.chapters);

  @override
  int get hashCode =>
      Object.hash(subject, Object.hashAll(sections), Object.hashAll(chapters));

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
