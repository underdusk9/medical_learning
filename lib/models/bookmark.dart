/// 收藏数据模型
class Bookmark {
  final int? id;
  final int questionId;
  final String createdAt;

  const Bookmark({
    this.id,
    required this.questionId,
    required this.createdAt,
  });

  /// 从数据库 Map 构建
  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as int?,
      questionId: map['question_id'] as int,
      createdAt: map['created_at'] as String,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'question_id': questionId,
      'created_at': createdAt,
    };
    if (id != null) map['id'] = id!;
    return map;
  }
}
