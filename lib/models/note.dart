/// 笔记数据模型
class Note {
  final int? id;
  final int questionId;
  final String content;
  final String updatedAt;

  const Note({
    this.id,
    required this.questionId,
    required this.content,
    required this.updatedAt,
  });

  /// 从数据库 Map 构建
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      questionId: map['question_id'] as int,
      content: map['content'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'question_id': questionId,
      'content': content,
      'updated_at': updatedAt,
    };
    if (id != null) map['id'] = id!;
    return map;
  }

  /// 创建副本
  Note copyWith({
    int? id,
    int? questionId,
    String? content,
    String? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      content: content ?? this.content,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
