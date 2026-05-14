import 'package:lowvision_key/lesson/curriculum/weeks/beginner_week10.dart';
import 'package:lowvision_key/lesson/curriculum/weeks/beginner_week11.dart';
import 'package:lowvision_key/lesson/curriculum/weeks/beginner_week12.dart';

import 'curriculum_models.dart';

import 'weeks/beginner_middle_octave_guide.dart';
import 'weeks/beginner_high_octave_guide.dart';
import 'weeks/beginner_low_octave_guide.dart';
import 'weeks/beginner_half_step_guide.dart';

import 'weeks/beginner_week1.dart';
import 'weeks/beginner_week2.dart';
import 'weeks/beginner_week3.dart';
import 'weeks/beginner_week4.dart';
import 'weeks/beginner_week5.dart';
import 'weeks/beginner_week6.dart';
import 'weeks/beginner_week7.dart';
import 'weeks/beginner_week8.dart';
import 'weeks/beginner_week9.dart';

class PredefinedCourses {
  static Course beginner() {
    return Course(
      id: 'beginner',
      title: '초급 코스',
      stages: [
        BeginnerMiddleOctaveGuide.stage(),

        BeginnerWeek1.stage(),
        BeginnerWeek2.stage(),
        BeginnerWeek3.stage(),

        BeginnerHighOctaveGuide.stage(),

        BeginnerWeek4.stage(),
        BeginnerWeek5.stage(),
        BeginnerWeek6.stage(),

        BeginnerLowOctaveGuide.stage(),

        BeginnerWeek7.stage(),
        BeginnerWeek8.stage(),
        BeginnerWeek9.stage(),

        BeginnerHalfStepGuide.stage(),

        BeginnerWeek10.stage(),
        BeginnerWeek11.stage(),
        BeginnerWeek12.stage()
      ],
    );
  }
}