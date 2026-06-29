import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../models/question.dart';
import '../providers/filter_provider.dart';
import '../providers/question_provider.dart';
import '../widgets/filter_card.dart';

/// 四级筛选页面：学科 → 系统(section) → 章节(chapter) → 考点(topic)
class FilterScreen extends ConsumerStatefulWidget {
  const FilterScreen({super.key});

  @override
  ConsumerState<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen> {
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
      appBar: AppBar(title: const Text('筛选题目')),
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
                      // 清空下级
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
                // 底部留白
                const SizedBox(height: 80),
              ],
            ),
          ),
          // 开始练习按钮
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _startQuiz(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('开始练习'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startQuiz(BuildContext context) async {
    final subjects = ref.read(selectedSubjectProvider);
    final sections = ref.read(selectedSectionsProvider);
    final chapters = ref.read(selectedChaptersProvider);
    final topics = ref.read(selectedTopicsProvider);

    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选择一个学科')),
      );
      return;
    }

    // 多学科筛选：逐个查询后合并去重
    final allQuestions = <Question>[];
    for (final subject in subjects) {
      final filter = QuestionFilter(
        subject: subject,
        sections: sections.isNotEmpty ? sections : null,
        chapters: chapters.isNotEmpty ? chapters : null,
        topics: topics.isNotEmpty ? topics : null,
      );
      final questions = await ref.read(questionsByFilterProvider(filter).future);
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

    // 去重（按 id）
    final seen = <int>{};
    final uniqueQuestions = <Question>[];
    for (final q in allQuestions) {
      if (seen.add(q.id)) {
        uniqueQuestions.add(q);
      }
    }

    final questionIds = uniqueQuestions.map((q) => q.id).toList();
    if (mounted) {
      context.push(AppConstants.routeQuiz, extra: {
        'questionIds': questionIds,
        'sessionType': 'filter',
      });
    }
  }
}
