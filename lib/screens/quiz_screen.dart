import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../providers/quiz_provider.dart';
import '../providers/question_provider.dart';
import '../widgets/question_card.dart';
import '../widgets/bookmark_star.dart';
import '../widgets/question_drawer.dart';
import '../providers/note_provider.dart';
import '../providers/settings_provider.dart';

/// 答题页面
class QuizScreen extends ConsumerStatefulWidget {
  final List<int> questionIds;
  final String sessionType;

  const QuizScreen({
    super.key,
    required this.questionIds,
    this.sessionType = 'filter',
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(quizProvider.notifier).initSession(
            widget.questionIds,
            widget.sessionType,
          );
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizProvider);
    final questionAsync = ref.watch(currentQuestionProvider);
    final isBookmarkedAsync = ref.watch(currentIsBookmarkedProvider);

    if (!_initialized || quizState.questionIds.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${quizState.currentIndex + 1} / ${quizState.total}',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          // 收藏星标
          isBookmarkedAsync.when(
            loading: () => const IconButton(
              icon: Icon(Icons.star_border),
              onPressed: null,
            ),
            data: (isMarked) => BookmarkStar(
              isBookmarked: isMarked,
              onTap: () => ref.read(quizProvider.notifier).toggleCurrentBookmark(),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // 订正答案按钮
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: '订正答案',
            onPressed: () {
              final qid = quizState.currentQuestionId;
              if (qid != null) {
                questionAsync.whenData((q) {
                  if (q != null) _showCorrectDialog(context, q.id, q.answer);
                });
              }
            },
          ),
          // 笔记按钮
          IconButton(
            icon: const Icon(Icons.note_add_outlined),
            tooltip: '添加笔记',
            onPressed: () {
              final qid = quizState.currentQuestionId;
              if (qid != null) {
                context.push(AppConstants.routeNoteEdit, extra: {
                  'questionId': qid,
                });
              }
            },
          ),
          // 题号抽屉按钮
          IconButton(
            icon: const Icon(Icons.grid_view),
            tooltip: '题号',
            onPressed: () => _showQuestionDrawer(context, quizState),
          ),
        ],
      ),
      body: questionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (question) {
          if (question == null) {
            return const Center(child: Text('题目不存在'));
          }

          final isAnswered = quizState.isAnswered[question.id] ?? false;
          final currentAnswer = quizState.answers[question.id] ?? '';
          final isCorrect = quizState.isCorrect[question.id] ?? false;

          // 监听该题的笔记
          final noteAsync = ref.watch(noteByQuestionProvider(question.id));
          final showNoteWithAnswer = ref.watch(noteWithAnswerProvider);

          return Column(
            children: [
              // 题目卡片
              Expanded(
                child: QuestionCard(
                  question: question,
                  userAnswer: currentAnswer.isNotEmpty ? currentAnswer : null,
                  isAnswered: isAnswered,
                  isCorrect: isCorrect,
                  onOptionTap: (label) => _handleOptionTap(question, label, isAnswered),
                  showAnalysis: true,
                  noteContent: noteAsync.when(
                    data: (note) => note?.content,
                    loading: () => null,
                    error: (_, __) => null,
                  ),
                  showNoteWithAnswer: showNoteWithAnswer,
                ),
              ),

              // 多选题确认提交按钮
              if (question.isMultiple && !isAnswered) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ElevatedButton(
                    onPressed: (quizState.answers[question.id] ?? '').isNotEmpty
                        ? () => _submitMultipleAnswer(question.id, question.answer)
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text('确认提交', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],

              // 底部导航栏
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 上一题
                    Expanded(
                      child: OutlinedButton(
                        onPressed: quizState.currentIndex > 0
                            ? () => ref.read(quizProvider.notifier).goPrev()
                            : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('上一题'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 下一题
                    Expanded(
                      child: ElevatedButton(
                        onPressed: quizState.currentIndex < quizState.total - 1
                            ? () => ref.read(quizProvider.notifier).goNext()
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('下一题'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 处理选项点击
  void _handleOptionTap(dynamic question, String label, bool isAnswered) {
    if (isAnswered) return; // 已答题不可修改

    if (question.isMultiple) {
      // 多选：切换选项，暂不提交（直接更新 quiz state）
      ref.read(quizProvider.notifier).toggleOption(question.id, label);
    } else {
      // 单选：点击即判
      ref.read(quizProvider.notifier).answerQuestion(
            question.id,
            label,
            question.answer,
          );
    }
  }

  /// 提交多选答案
  void _submitMultipleAnswer(int questionId, String correctAnswer) {
    final quizState = ref.read(quizProvider);
    final userAnswer = quizState.answers[questionId] ?? '';
    if (userAnswer.isEmpty) return;

    ref.read(quizProvider.notifier).answerQuestion(
          questionId,
          userAnswer,
          correctAnswer,
        );
  }

  /// 显示答案订正对话框
  void _showCorrectDialog(BuildContext context, int questionId, String currentAnswer) {
    final controller = TextEditingController(text: currentAnswer);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('订正答案'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('请输入正确答案：',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '例：A 或 a,c（多选不区分顺序）',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.none,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final raw = controller.text.trim();
              if (raw.isEmpty || raw == currentAnswer) {
                Navigator.pop(ctx);
                return;
              }
              // 归一化：去逗号、去空格、排序（与 fromJson 逻辑一致）
              final normalized = (raw.replaceAll(',', '').replaceAll(' ', ''))
                  .split('')
                  .toList()
                ..sort();
              final result = normalized.join();
              await correctAnswer(ref, questionId, result);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('答案已订正为 $normalized'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('确认订正'),
          ),
        ],
      ),
    );
  }

  /// 显示题号抽屉
  void _showQuestionDrawer(BuildContext context, QuizState quizState) {
    // 将 questionId-keyed Map 转换为 index-keyed Map
    final indexAnswered = <int, bool>{};
    final indexCorrect = <int, bool>{};
    final indexBookmarked = <int, bool>{};
    for (int i = 0; i < quizState.questionIds.length; i++) {
      final qid = quizState.questionIds[i];
      indexAnswered[i] = quizState.isAnswered[qid] ?? false;
      indexCorrect[i] = quizState.isCorrect[qid] ?? false;
      // 收藏状态暂不在此映射，留空
      indexBookmarked[i] = false;
    }

    QuestionDrawer.show(
      context,
      total: quizState.total,
      currentIndex: quizState.currentIndex,
      isAnswered: indexAnswered,
      isCorrect: indexCorrect,
      isBookmarkedMap: indexBookmarked,
      onJump: (index) {
        ref.read(quizProvider.notifier).goToIndex(index);
        Navigator.of(context).pop();
      },
    );
  }
}
