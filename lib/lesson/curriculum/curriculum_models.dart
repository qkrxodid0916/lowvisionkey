// lib/lesson/curriculum/curriculum_models.dart

enum LessonInputMode {
  app, // 화면 터치 피아노
  ble, // BLE 실제 피아노
  both,
}

class Course {
  final String id;       // "beginner"
  final String title;    // "초급 코스"
  final List<Stage> stages;

  const Course({
    required this.id,
    required this.title,
    required this.stages,
  });
}

class Stage {
  final String id;          // "stage_1"
  final String title;       // "단음 인지"
  final String description; // 설명
  final List<CurriculumLesson> lessons;

  const Stage({
    required this.id,
    required this.title,
    required this.description,
    required this.lessons,
  });
}

/// ✅ 레슨 내부 단계를 표현
class LessonPlanStep {
  final String id;            // "s1"
  final String title;         // "가이드 ON"
  final String description;   // 단계 설명(옵션)
  final LessonPlan plan;      // 단계 플랜
  final PassRule passRule;    // 단계 통과 조건

  /// 가이드(ESP32 LED / 힌트 노출 등) 정책
  final bool guideEnabled;

  const LessonPlanStep({
    required this.id,
    required this.title,
    this.description = "",
    required this.plan,
    required this.passRule,
    this.guideEnabled = true,
  });
}

class CurriculumLesson {
  final String id; // "l1"
  final String title;
  final LessonInputMode mode;

  /// ✅ (구버전 호환용) 레슨 플랜
  /// 단계 시스템(steps)을 쓰면 화면에서 step.plan을 사용하고,
  /// steps가 없으면 이 plan을 단일 단계로 간주한다.
  final LessonPlan plan;

  /// ✅ (구버전 호환용) 레슨 통과 조건
  final PassRule passRule;

  /// ✅ 단계형 레슨
  /// 비어있으면 plan/passRule로 1단계 레슨처럼 동작
  final List<LessonPlanStep> steps;

  const CurriculumLesson({
    required this.id,
    required this.title,
    required this.mode,
    required this.plan,
    required this.passRule,
    this.steps = const <LessonPlanStep>[],
  });

  /// ✅ steps가 없으면 (plan/passRule)을 1단계로 래핑해서 제공
  List<LessonPlanStep> get effectiveSteps {
    if (steps.isNotEmpty) return steps;
    return <LessonPlanStep>[
      LessonPlanStep(
        id: "default",
        title: "기본 단계",
        plan: plan,
        passRule: passRule,
        guideEnabled: true,
      ),
    ];
  }
}

enum LessonPlanType { singleNotes, chords }

class LessonPlan {
  final LessonPlanType type;

  /// 문제를 구성하는 음(단음일 때는 1개짜리 리스트가 반복)
  /// 예: [[60],[62],[64]] 또는 화음 [[60,64,67]]
  final List<List<int>> sequences;

  /// 총 문제 수(엔진이 이 횟수만큼 출제)
  final int totalQuestions;

  /// 정답 제한시간(ms) - 타이밍 판정 붙일 때 활용 가능
  final int? timeLimitMs;

  const LessonPlan({
    required this.type,
    required this.sequences,
    required this.totalQuestions,
    this.timeLimitMs,
  });
}

class PassRule {
  final double minAccuracy; // 0.8 = 80%
  final int? maxFails;      // 선택: 실패 제한
  const PassRule({required this.minAccuracy, this.maxFails});
}