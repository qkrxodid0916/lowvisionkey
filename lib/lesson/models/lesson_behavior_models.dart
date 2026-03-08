enum LedMode {
  hold,
  blinkOnce,
  off,
}

class TaskBehavior {
  /// 학습/연습: true
  /// 확인/테스트: false
  final bool retryOnWrong;

  /// 피드백 표시 시간
  final int feedbackMs;

  /// ESP32 / UI 하이라이트 동작
  final LedMode ledMode;

  const TaskBehavior({
    required this.retryOnWrong,
    this.feedbackMs = 1000,
    this.ledMode = LedMode.off,
  });
}