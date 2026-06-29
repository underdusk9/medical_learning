import 'dart:convert';

/// 题目数据模型
class Question {
  final int id;
  final String type; // 'single' | 'multiple'
  final String subject;
  final String? section;
  final String chapter;
  final String? topic;
  final String stem;
  final String options; // JSON数组字符串
  final String answer; // 单选: "A", 多选: "ABD"
  final String? analysis;

  const Question({
    required this.id,
    required this.type,
    required this.subject,
    this.section,
    required this.chapter,
    this.topic,
    required this.stem,
    required this.options,
    required this.answer,
    this.analysis,
  });

  /// 解析选项为字符串列表
  List<String> get optionsList {
    final decoded = jsonDecode(options);
    if (decoded is List) {
      return decoded.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// 判断是否为多选题
  bool get isMultiple => type == 'multiple' || type == 'multi';

  /// 从数据库 Map 构建
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as int,
      type: map['type'] as String,
      subject: map['subject'] as String,
      section: map['section'] as String?,
      chapter: map['chapter'] as String,
      topic: map['topic'] as String?,
      stem: map['stem'] as String,
      options: map['options'] as String,
      answer: map['answer'] as String,
      analysis: map['analysis'] as String?,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'subject': subject,
      'section': section,
      'chapter': chapter,
      'topic': topic,
      'stem': stem,
      'options': options,
      'answer': answer,
      'analysis': analysis,
    };
  }

  /// 从 JSON 构建（种子数据导入用）
  factory Question.fromJson(Map<String, dynamic> json) {
    // options 在 JSON 中可能是 List，需转为 JSON 字符串存储
    final optionsData = json['options'];
    List<String> rawOptions;
    if (optionsData is String) {
      rawOptions = (jsonDecode(optionsData) as List).map((e) => e.toString()).toList();
    } else if (optionsData is List) {
      rawOptions = optionsData.map((e) => e.toString()).toList();
    } else {
      rawOptions = [];
    }

    // 去除选项中的字母前缀（如 "A. ", "B、", "a) " 等）
    final prefixPattern = RegExp(r'^[A-Za-z][.、):]\s*');
    final cleanedOptions = rawOptions.map((opt) {
      return opt.replaceFirst(prefixPattern, '');
    }).toList();

    final optionsStr = jsonEncode(cleanedOptions);

    // 标准化答案格式：去除逗号和空格（如 "A,B,C" → "ABC"）
    final rawAnswer = json['answer'] as String;
    final normalizedAnswer = rawAnswer.replaceAll(',', '').replaceAll(' ', '');

    return Question(
      id: json['id'] as int,
      type: json['type'] as String,
      subject: json['subject'] as String,
      section: json['section'] as String?,
      chapter: json['chapter'] as String,
      topic: json['topic'] as String?,
      stem: json['stem'] as String,
      options: optionsStr,
      answer: normalizedAnswer,
      analysis: json['analysis'] as String?,
    );
  }
}
