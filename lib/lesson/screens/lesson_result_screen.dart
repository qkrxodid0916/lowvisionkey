import 'package:flutter/material.dart';
import '../models/lesson_result.dart';
import '../../function/result_uploader.dart';

class LessonResultScreen extends StatefulWidget {
  final LessonResult result;
  final VoidCallback onRestart;

  const LessonResultScreen({
    super.key,
    required this.result,
    required this.onRestart,
  });

  @override
  State<LessonResultScreen> createState() => _LessonResultScreenState();
}

class _LessonResultScreenState extends State<LessonResultScreen> {
  bool _uploading = false;
  bool? _uploaded; // null=진행중/미시도, true=성공, false=실패
  String? _error;

  @override
  void initState() {
    super.initState();
    _upload(); // ✅ 결과 화면 진입하면 자동 업로드
  }

  Future<void> _upload() async {
    setState(() {
      _uploading = true;
      _uploaded = null;
      _error = null;
    });

    try {
      await ResultUploader.I.upload(widget.result);
      if (!mounted) return;
      setState(() => _uploaded = true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploaded = false;
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() => _uploading = false);
    }
  }

  void _goMain() {
    // ✅ “메인화면”이 앱의 첫 route라면 이게 가장 깔끔
    Navigator.of(context).popUntil((route) => route.isFirst);

    // 만약 메뉴가 첫 화면이 아니라면:
    // Navigator.of(context).pushAndRemoveUntil(
    //   MaterialPageRoute(builder: (_) => const MenuScreen()),
    //   (route) => false,
    // );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final duration = r.finishedAt.difference(r.startedAt);

    final wrongTop = r.wrongByMidi.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text("레슨 결과")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "정확도 ${(r.accuracy * 100).toStringAsFixed(1)}%",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              "총 ${r.total} / 정답 ${r.correct} / 오답 ${r.wrong}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text("소요시간: ${duration.inSeconds}s"),

            const SizedBox(height: 16),
            Text("새로 배운 음: ${r.newNotes.isEmpty ? '없음' : r.newNotes.join(', ')}"),

            const SizedBox(height: 16),
            const Text("많이 틀린 음 TOP3", style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            if (wrongTop.isEmpty)
              const Text("오답 없음 🎉")
            else
              for (final e in wrongTop.take(3)) Text("midi ${e.key}: ${e.value}회"),

            const Spacer(),

            // ✅ 업로드 상태 표시
            if (_uploading)
              const Text("서버에 업로드 중...", style: TextStyle(fontWeight: FontWeight.w900))
            else if (_uploaded == true)
              const Text("업로드 완료 ✅", style: TextStyle(fontWeight: FontWeight.w900))
            else if (_uploaded == false)
                Text("업로드 실패 ❌ ${_error ?? ""}", style: const TextStyle(fontWeight: FontWeight.w900)),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onRestart,
                    child: const Text("다시 하기"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  // ✅ “서버에 업로드” 대신 “메인화면”
                  // 업로드 중에도 메인으로 갈 수 있게 둘지(현재), 막을지 원하면 onPressed 조건 바꾸면 됨
                  child: ElevatedButton(
                    onPressed: _goMain,
                    child: const Text("메인화면"),
                  ),
                ),
              ],
            ),

            // (선택) 업로드 실패했을 때만 “재시도” 버튼 하나 더 두고 싶으면:
            // if (_uploaded == false) ...[
            //   const SizedBox(height: 10),
            //   SizedBox(
            //     width: double.infinity,
            //     child: ElevatedButton(
            //       onPressed: _upload,
            //       child: const Text("업로드 재시도"),
            //     ),
            //   ),
            // ],
          ],
        ),
      ),
    );
  }
}
