import 'dart:convert';

/// 答题会话数据模型
class QuizSession {
  final int? id;
  final String type; // 'filter' | 'random' | 'bookmark'
  final String questionIds; // JSON数组字符串 [1,2,3]
  final int currentIndex;
  final String answers; // JSON对象字符串 {qid: userAnswer}
  final String createdAt;

  const QuizSession({
    this.id,
    required this.type,
    required this.questionIds,
    this.currentIndex = 0,
    this.answers = '{}',
    required this.createdAt,
  });

  /// 解析题目ID列表
  List<int> get questionIdsList {
    final decoded = jsonDecode(questionIds);
    if (decoded is List) {
      return decoded.map((e) => e as int).toList();
    }
    return [];
  }

  /// 解析答案映射
  Map<String, String> get answersMap {
    final decoded = jsonDecode(answers);
    if (decoded is Map) {
      return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return {};
  }

  /// 从数据库 Map 构建
  factory QuizSession.fromMap(Map<String, dynamic> map) {
    return QuizSession(
      id: map['id'] as int?,
      type: map['type'] as String,
      questionIds: map['question_ids'] as String,
      currentIndex: map['current_index'] as int? ?? 0,
      answers: map['answers'] as String? ?? '{}',
      createdAt: map['created_at'] as String,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'question_ids': questionIds,
      'current_index': currentIndex,
      'answers': answers,
      'created_at': createdAt,
    };
  }

  /// 创建副本
  QuizSession copyWith({
    int? id,
    String? type,
    String? questionIds,
    int? currentIndex,
    String? answers,
    String? createdAt,
  }) {
    return QuizSession(
      id: id ?? this.id,
      type: type ?? this.type,
      questionIds: questionIds ?? this.questionIds,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
