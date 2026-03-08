import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../curriculum/predefined_courses.dart';
import '../curriculum/curriculum_models.dart';
import '../progress/course_progress_repository.dart';
import 'lesson_screen.dart';

class CourseLevelsScreen extends StatefulWidget {
  const CourseLevelsScreen({super.key});

  @override
  State<CourseLevelsScreen> createState() => _CourseLevelsScreenState();
}

class _CourseLevelsScreenState extends State<CourseLevelsScreen> {
  final _repo = CourseProgressRepository();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("로그인이 필요합니다.")),
      );
    }

    final course = PredefinedCourses.beginner();
    final lessonItems = _flattenLessons(course);

    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: FutureBuilder<CourseProgress>(
        future: _repo.getOrCreate(user.uid, course.id),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final progress = snap.data!;
          final width = MediaQuery.of(context).size.width;
          final crossAxisCount = width >= 1100 ? 3 : (width >= 700 ? 2 : 1);

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.6,
            ),
            itemCount: lessonItems.length,
            itemBuilder: (context, i) {
              final item = lessonItems[i];

              final unlocked = progress.isUnlocked(i);
              final completed = _isLessonCompleted(progress, item.lesson);
              final best = _bestAccuracyOfLesson(progress, item.lesson);

              return _LessonCard(
                index: i,
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
                        stageIndex: item.stageIndex,
                        lessonIndex: item.lessonIndex,
                        lesson: item.lesson,
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
          );
        },
      ),
    );
  }

  List<_LessonItem> _flattenLessons(Course course) {
    final items = <_LessonItem>[];

    for (int s = 0; s < course.stages.length; s++) {
      final stage = course.stages[s];
      for (int l = 0; l < stage.lessons.length; l++) {
        items.add(
          _LessonItem(
            stageIndex: s,
            lessonIndex: l,
            stage: stage,
            lesson: stage.lessons[l],
          ),
        );
      }
    }

    return items;
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
                    const SizedBox(height: 4),
                    Text(
                      _stepSummary(item.lesson),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
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

  String _stepSummary(CurriculumLesson lesson) {
    final titles = lesson.effectiveSteps.map((e) => e.title).toList();
    return titles.join(" · ");
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