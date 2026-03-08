import 'package:flutter/foundation.dart';

class AppSettings {
  /// 1.0 = 기본, 1.2 = 20% 확대
  static final ValueNotifier<double> fontScale = ValueNotifier<double>(1.0);
}