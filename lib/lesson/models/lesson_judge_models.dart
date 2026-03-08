enum JudgeMode {
  press,
  sequence,
  beat,
  recall,
}

class JudgeSpec {
  final JudgeMode mode;

  /// beat / recall 에서 사용
  final int? windowMs;

  /// 최대 시도 횟수
  final int attempts;

  const JudgeSpec({
    required this.mode,
    this.windowMs,
    this.attempts = 1,
  });
}