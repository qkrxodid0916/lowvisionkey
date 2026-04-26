import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../curriculum/predefined_courses.dart';
import '../curriculum/curriculum_models.dart';
import '../progress/course_progress_repository.dart';
import 'lesson_screen.dart';
import '../../app/dev_settings.dart';

class CourseLevelsScreen extends StatefulWidget {
  const CourseLevelsScreen({super.key});

  @override
  State<CourseLevelsScreen> createState() => _CourseLevelsScreenState();
}

class _CourseLevelsScreenState extends State<CourseLevelsScreen> {
  final _repo = CourseProgressRepository();
  final PageController _pageController = PageController();

  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("로그인이 필요합니다.")),
      );
    }

    final course = PredefinedCourses.beginner();

    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: FutureBuilder<CourseProgress>(
        future: _repo.getOrCreate(user.uid, course.id),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final progress = snap.data!;

          if (course.stages.isEmpty) {
            return const Center(
              child: Text("표시할 주차가 없습니다."),
            );
          }

          final safePage = _currentPage.clamp(0, course.stages.length - 1);
          final currentStage = course.stages[safePage];

          return Column(
            children: [
              const SizedBox(height: 12),
              Text(
                currentStage.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  currentStage.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${safePage + 1} / ${course.stages.length}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: course.stages.length,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, stageIndex) {
                    final stage = course.stages[stageIndex];
                    return _buildStageGrid(
                      context,
                      course,
                      stageIndex,
                      stage,
                      progress,
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(course.stages.length, (i) {
                  final selected = i == safePage;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 10,
                    ),
                    width: selected ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: selected ? Colors.black : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 6),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStageGrid(
      BuildContext context,
      Course course,
      int stageIndex,
      Stage stage,
      CourseProgress progress,
      ) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1100 ? 3 : (width >= 700 ? 2 : 1);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        itemCount: stage.lessons.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.6,
        ),
        itemBuilder: (context, lessonIndex) {
          final lesson = stage.lessons[lessonIndex];

          final item = _LessonItem(
            stageIndex: stageIndex,
            lessonIndex: lessonIndex,
            stage: stage,
            lesson: lesson,
          );

          final linearIndex = _toLinearIndex(course, stageIndex, lessonIndex);
          final unlocked = DevSettings.unlockAllLessons
              ? true
              : progress.isUnlocked(linearIndex);

          final completed = DevSettings.unlockAllLessons
              ? false
              : _isLessonCompleted(progress, lesson);
          final best = _bestAccuracyOfLesson(progress, lesson);

          return _LessonCard(
            index: linearIndex,
            item: item,
            unlocked: unlocked,
            completed: completed,
            bestAccuracy: best,
            onTap: unlocked
                ? () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (_) => LessonScreen(
                    courseId: course.id,
                    stageIndex: stageIndex,
                    lessonIndex: lessonIndex,
                    lesson: lesson,
                  ),
                ),
              )
                  .then((_) {
                setState(() {});
              });
            }
                : null,
          );
        },
      ),
    );
  }

  int _toLinearIndex(
      Course course,
      int stageIndex,
      int lessonIndex,
      ) {
    int index = 0;

    for (int s = 0; s < course.stages.length; s++) {
      final stage = course.stages[s];
      for (int l = 0; l < stage.lessons.length; l++) {
        if (s == stageIndex && l == lessonIndex) {
          return index;
        }
        index++;
      }
    }

    return index;
  }

  bool _isLessonCompleted(CourseProgress progress, CurriculumLesson lesson) {
    final steps = lesson.effectiveSteps;
    if (steps.isEmpty) return false;

    for (final step in steps) {
      final key = '${lesson.id}:${step.id}';
      if (!progress.isCompleted(key)) {
        return false;
      }
    }
    return true;
  }

  double _bestAccuracyOfLesson(CourseProgress progress, CurriculumLesson lesson) {
    final steps = lesson.effectiveSteps;
    if (steps.isEmpty) return 0.0;

    double best = 0.0;
    for (final step in steps) {
      final key = '${lesson.id}:${step.id}';
      final acc = progress.bestAccuracy(key);
      if (acc > best) best = acc;
    }
    return best;
  }
}

class _LessonItem {
  final int stageIndex;
  final int lessonIndex;
  final Stage stage;
  final CurriculumLesson lesson;

  const _LessonItem({
    required this.stageIndex,
    required this.lessonIndex,
    required this.stage,
    required this.lesson,
  });
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.index,
    required this.item,
    required this.unlocked,
    required this.completed,
    required this.bestAccuracy,
    required this.onTap,
  });

  final int index;
  final _LessonItem item;
  final bool unlocked;
  final bool completed;
  final double bestAccuracy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: unlocked ? Colors.white : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: unlocked ? Colors.black : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    unlocked ? (completed ? "✓" : "${index + 1}") : "🔒",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.stage.title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.lesson.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (completed)
                          const _Pill(
                            text: "완료",
                            bg: Colors.black,
                            fg: Colors.white,
                          )
                        else if (unlocked)
                          const _Pill(
                            text: "진행 가능",
                            bg: Colors.white,
                            fg: Colors.black,
                            border: true,
                          )
                        else
                          const _Pill(
                            text: "잠김",
                            bg: Colors.grey,
                            fg: Colors.white,
                          ),
                        const SizedBox(width: 8),
                        if (unlocked && bestAccuracy > 0)
                          Text(
                            "최고 ${(bestAccuracy * 100).toStringAsFixed(0)}%",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: unlocked ? Colors.black : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(unlocked ? (completed ? "다시하기" : "시작") : "잠김"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.bg,
    required this.fg,
    this.border = false,
  });

  final String text;
  final Color bg;
  final Color fg;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: border ? Border.all(color: Colors.black, width: 1.4) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}