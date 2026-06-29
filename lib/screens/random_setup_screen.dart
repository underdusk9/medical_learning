import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../models/question.dart';
import '../providers/filter_provider.dart';
import '../providers/question_provider.dart';
import '../widgets/filter_card.dart';

/// 随机组卷设置页面（chip 筛选 + 题量选择）
class RandomSetupScreen extends ConsumerStatefulWidget {
  const RandomSetupScreen({super.key});

  @override
  ConsumerState<RandomSetupScreen> createState() => _RandomSetupScreenState();
}

class _RandomSetupScreenState extends ConsumerState<RandomSetupScreen> {
  double _count = 20;

  @override
  Widget build(BuildContext context) {
    final selectedSubjects = ref.watch(selectedSubjectProvider);
    final selectedSections = ref.watch(selectedSectionsProvider);
    final selectedChapters = ref.watch(selectedChaptersProvider);
    final selectedTopics = ref.watch(selectedTopicsProvider);

    final subjectsAsync = ref.watch(availableSubjectsProvider);
    final sectionsAsync = ref.watch(availableSectionsProvider);
    final chaptersAsync = ref.watch(availableChaptersProvider);
    final topicsAsync = ref.watch(availableTopicsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('随机组卷')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 学科卡片
                subjectsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('加载失败: $e'),
                  data: (subjects) => SelectionCard(
                    icon: Icons.school,
                    title: '学科',
                    options: subjects,
                    selected: selectedSubjects,
                    onChanged: (list) {
                      ref.read(selectedSubjectProvider.notifier).state = list;
                      ref.read(selectedSectionsProvider.notifier).state = [];
                      ref.read(selectedChaptersProvider.notifier).state = [];
                      ref.read(selectedTopicsProvider.notifier).state = [];
                    },
                  ),
                ),
                // section 卡片
                if (selectedSubjects.isNotEmpty)
                  sectionsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(),
                    ),
                    error: (e, _) => Text('加载失败: $e'),
                    data: (sections) => sections.isEmpty
                        ? const SizedBox.shrink()
                        : SelectionCard(
                            icon: Icons.menu_book,
                            title: '系统',
                            options: sections,
                            selected: selectedSections,
                            onChanged: (list) {
                              ref.read(selectedSectionsProvider.notifier).state = list;
                              ref.read(selectedChaptersProvider.notifier).state = [];
                              ref.read(selectedTopicsProvider.notifier).state = [];
                            },
                          ),
                  ),
                // chapter 卡片
                if (selectedSubjects.isNotEmpty && selectedSections.isNotEmpty)
                  chaptersAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(),
                    ),
                    error: (e, _) => Text('加载失败: $e'),
                    data: (chapters) => chapters.isEmpty
                        ? const SizedBox.shrink()
                        : SelectionCard(
                            icon: Icons.layers,
                            title: '章节',
                            options: chapters,
                            selected: selectedChapters,
                            onChanged: (list) {
                              ref.read(selectedChaptersProvider.notifier).state = list;
                              ref.read(selectedTopicsProvider.notifier).state = [];
                            },
                          ),
                  ),
                // topic 卡片
                if (selectedSubjects.isNotEmpty && selectedSections.isNotEmpty && selectedChapters.isNotEmpty)
                  topicsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(),
                    ),
                    error: (e, _) => Text('加载失败: $e'),
                    data: (topics) => topics.isEmpty
                        ? const SizedBox.shrink()
                        : SelectionCard(
                            icon: Icons.local_offer,
                            title: '考点',
                            options: topics,
                            selected: selectedTopics,
                            onChanged: (list) {
                              ref.read(selectedTopicsProvider.notifier).state = list;
                            },
                          ),
                  ),
                // 题量设置区域
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppStyles.radiusCard,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.format_list_numbered,
                              size: 20, color: AppColors.primaryDark),
                          const SizedBox(width: 8),
                          Text(
                            '题量：${_count.toInt()} 题',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Slider(
                        value: _count,
                        min: 5,
                        max: 100,
                        divisions: 19,
                        label: _count.toInt().toString(),
                        onChanged: (value) => setState(() => _count = value),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [10, 20, 30, 50].map((n) {
                          return GestureDetector(
                            onTap: () => setState(() => _count = n.toDouble()),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: _count.toInt() == n
                                    ? AppColors.primary
                                    : Colors.white,
                                borderRadius: AppStyles.radiusButton,
                                border: Border.all(
                                  color: _count.toInt() == n
                                      ? AppColors.primary
                                      : AppColors.cardBorder,
                                ),
                              ),
                              child: Text(
                                '$n',
                                style: TextStyle(
                                  color: _count.toInt() == n
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: _count.toInt() == n
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                // 底部留白
                const SizedBox(height: 80),
              ],
            ),
          ),
          // 开始答题按钮
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startRandom,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('开始答题'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startRandom() async {
    final subjects = ref.read(selectedSubjectProvider);
    final sections = ref.read(selectedSectionsProvider);
    final chapters = ref.read(selectedChaptersProvider);
    final topics = ref.read(selectedTopicsProvider);
    final count = _count.toInt();

    if (subjects.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请至少选择一个学科')),
        );
      }
      return;
    }

    // 多学科随机抽题
    final allQuestions = <Question>[];
    for (final subject in subjects) {
      final filter = RandomFilter(
        subject: subject,
        sections: sections.isNotEmpty ? sections : null,
        chapters: chapters.isNotEmpty ? chapters : null,
        topics: topics.isNotEmpty ? topics : null,
        count: count,
      );
      final questions = await ref.read(randomQuestionsProvider(filter).future);
      allQuestions.addAll(questions);
    }

    if (allQuestions.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('没有符合条件的题目')),
        );
      }
      return;
    }

    // 去重后随机打乱
    final seen = <int>{};
    final uniqueQuestions = <Question>[];
    for (final q in allQuestions) {
      if (seen.add(q.id)) {
        uniqueQuestions.add(q);
      }
    }
    uniqueQuestions.shuffle();

    // 限制最终题量
    final finalQuestions = uniqueQuestions.take(count).toList();

    if (finalQuestions.length < count) {
      if (!mounted) return;
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('题量不足'),
          content: Text(
            '当前条件下只有 ${finalQuestions.length} 道题目，少于设置的 $count 题。是否继续？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('继续'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    final questionIds = finalQuestions.map((q) => q.id).toList();
    if (mounted) {
      context.push(AppConstants.routeQuiz, extra: {
        'questionIds': questionIds,
        'sessionType': 'random',
      });
    }
  }
}
