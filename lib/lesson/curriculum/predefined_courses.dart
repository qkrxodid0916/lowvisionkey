import 'curriculum_models.dart';
import 'weeks/beginner_week1.dart';
import 'weeks/beginner_week2.dart';
import 'weeks/beginner_week3.dart';
import 'weeks/beginner_week4.dart';
import 'weeks/beginner_week5.dart';

class PredefinedCourses {
  static Course beginner() {
    return Course(
      id: 'beginner',
      title: '초급 코스',
      stages: [
        BeginnerWeek1.stage(),
        BeginnerWeek2.stage(),
        BeginnerWeek3.stage(),
        BeginnerWeek4.stage(),
        BeginnerWeek5.stage(),
      ],
    );
  }
}