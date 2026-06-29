import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';
import '../dao/question_dao.dart';
import '../dao/bookmark_dao.dart';
import '../models/question.dart';
import 'bookmark_provider.dart';

/// 答题状态
class QuizState {
  final List<int> questionIds;
  final int currentIndex;
  final Map<int, String> answers; // questionId -> userAnswer
  final Map<int, bool> isAnswered; // questionId -> isAnswered
  final Map<int, bool> isCorrect; // questionId -> isCorrect
  final String sessionType;

  const QuizState({
    this.questionIds = const [],
    this.currentIndex = 0,
    this.answers = const {},
    this.isAnswered = const {},
    this.isCorrect = const {},
    this.sessionType = 'filter',
  });

  /// 当前题目ID
  int? get currentQuestionId {
    if (questionIds.isEmpty || currentIndex >= questionIds.length) return null;
    return questionIds[currentIndex];
  }

  /// 总题数
  int get total => questionIds.length;

  /// 已答题数
  int get answeredCount => isAnswered.values.where((v) => v).length;

  /// 正确数
  int get correctCount => isCorrect.values.where((v) => v).length;

  QuizState copyWith({
    List<int>? questionIds,
    int? currentIndex,
    Map<int, String>? answers,
    Map<int, bool>? isAnswered,
    Map<int, bool>? isCorrect,
    String? sessionType,
  }) {
    return QuizState(
      questionIds: questionIds ?? this.questionIds,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      isAnswered: isAnswered ?? this.isAnswered,
      isCorrect: isCorrect ?? this.isCorrect,
      sessionType: sessionType ?? this.sessionType,
    );
  }
}

/// 答题状态管理 Notifier
class QuizStateNotifier extends StateNotifier<QuizState> {
  final Ref _ref;

  QuizStateNotifier(this._ref) : super(const QuizState());

  /// 初始化答题会话
  void initSession(List<int> questionIds, String sessionType) {
    state = QuizState(
      questionIds: questionIds,
      currentIndex: 0,
      answers: {},
      isAnswered: {},
      isCorrect: {},
      sessionType: sessionType,
    );
  }

  /// 回答题目
  void answerQuestion(int questionId, String userAnswer, String correctAnswer) {
    final newAnswers = Map<int, String>.from(state.answers);
    final newIsAnswered = Map<int, bool>.from(state.isAnswered);
    final newIsCorrect = Map<int, bool>.from(state.isCorrect);

    newAnswers[questionId] = userAnswer;
    newIsAnswered[questionId] = true;

    // 判断正误：排序后比较（多选题顺序无关）
    final sortedUser = userAnswer.split('').toList()..sort();
    final sortedCorrect = correctAnswer.split('').toList()..sort();
    newIsCorrect[questionId] =
        sortedUser.join() == sortedCorrect.join();

    state = state.copyWith(
      answers: newAnswers,
      isAnswered: newIsAnswered,
      isCorrect: newIsCorrect,
    );
  }

  /// 多选题切换选项（未提交状态）
  void toggleOption(int questionId, String option) {
    final current = state.answers[questionId] ?? '';
    final newAnswers = Map<int, String>.from(state.answers);

    if (current.contains(option)) {
      final newAnswer = current.replaceAll(option, '');
      newAnswers[questionId] = newAnswer.isEmpty ? '' : newAnswer;
    } else {
      // 按字母顺序排列
      final chars = (current + option).split('')..sort();
      newAnswers[questionId] = chars.join();
    }

    state = state.copyWith(answers: newAnswers);
  }

  /// 下一题
  void goNext() {
    if (state.currentIndex < state.questionIds.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  /// 上一题
  void goPrev() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  /// 跳转到指定索引
  void goToIndex(int index) {
    if (index >= 0 && index < state.questionIds.length) {
      state = state.copyWith(currentIndex: index);
    }
  }

  /// 切换当前题目收藏
  Future<void> toggleCurrentBookmark() async {
    final qid = state.currentQuestionId;
    if (qid != null) {
      await toggleBookmark(_ref, qid);
    }
  }
}

/// 答题状态 Provider
final quizProvider =
    StateNotifierProvider<QuizStateNotifier, QuizState>((ref) {
  return QuizStateNotifier(ref);
});

/// 当前题目详情 Provider
/// 只监听 currentQuestionId 变化，答题/选项切换不触发重新查库（防止闪屏）
final currentQuestionProvider = FutureProvider.autoDispose<Question?>((ref) async {
  final qid = ref.watch(quizProvider.select((state) => state.currentQuestionId));
  if (qid == null) return null;

  final db = await ref.watch(databaseProvider.future);
  final dao = QuestionDao(db);
  return dao.queryById(qid);
});

/// 当前题目是否已收藏 Provider（不用 autoDispose，防止切换题目时重建导致按钮闪烁不可点）
final currentIsBookmarkedProvider = FutureProvider<bool>((ref) async {
  final qid = ref.watch(quizProvider.select((state) => state.currentQuestionId));
  if (qid == null) return false;

  // 监听版本号，收藏/取消时触发重新计算
  ref.watch(bookmarkVersionProvider);

  final db = await ref.watch(databaseProvider.future);
  final dao = BookmarkDao(db);
  return dao.isBookmarked(qid);
});
