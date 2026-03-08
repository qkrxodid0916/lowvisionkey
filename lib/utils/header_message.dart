import 'dart:math';
import '../lesson/models/lesson_result.dart';

class HeaderMessageBuilder {
  static int computeStreakKst(List<LessonResult> results) {
    if (results.isEmpty) return 0;

    // finishedAt 기준 (이미 desc로 들어온다고 가정해도 안전하게 정렬)
    final sorted = [...results]..sort((a, b) => b.finishedAt.compareTo(a.finishedAt));

    // KST 기준 "날짜"로만 비교
    DateTime kstDate(DateTime dt) {
      final kst = dt.toUtc().add(const Duration(hours: 9));
      return DateTime(kst.year, kst.month, kst.day);
    }

    final uniqueDays = <DateTime>{};
    for (final r in sorted) {
      uniqueDays.add(kstDate(r.finishedAt));
    }

    final days = uniqueDays.toList()..sort((a, b) => b.compareTo(a));
    if (days.isEmpty) return 0;

    final today = kstDate(DateTime.now());
    final first = days.first;

    // 오늘/어제부터 시작 가능한지 체크
    if (first != today && first != today.subtract(const Duration(days: 1))) {
      return 0;
    }

    int streak = 1;
    DateTime cursor = first;

    for (int i = 1; i < days.length; i++) {
      final next = days[i];
      final expected = cursor.subtract(const Duration(days: 1));
      if (next == expected) {
        streak++;
        cursor = next;
      } else {
        break;
      }
    }
    return streak;
  }

  static String build({
    required String? name,
    required int streak,
    int? totalMinutesToday, // 나중에 확장용(없으면 null)
  }) {
    final displayName = (name == null || name.trim().isEmpty) ? "사용자" : name.trim();
    final r = Random();

    final greetings = <String>[
      "안녕하세요 $displayName님 👋",
      "$displayName님, 반가워요 🎵",
      "오늘도 함께해요 $displayName님 😊",
    ];

    final streakLines = (streak >= 2)
        ? <String>[
      "$streak일째 연속 학습 중이에요!",
      "🔥 $streak일 연속 기록을 이어가고 있어요!",
      "🌟 꾸준함이 실력이 됩니다 ($streak일 연속)",
      "🚀 연속 학습 $streak일째!",
    ]
        : <String>[
      "오늘도 한 걸음씩 시작해볼까요?",
      "가볍게 워밍업부터 해봐요!",
      "오늘의 연습을 시작해요 👀",
    ];

    final main = greetings[r.nextInt(greetings.length)];
    final sub = streakLines[r.nextInt(streakLines.length)];

    return "$main\n$sub";
  }
}