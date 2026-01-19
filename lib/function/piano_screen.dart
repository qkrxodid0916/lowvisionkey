import 'package:flutter/material.dart';

class PianoScreen extends StatefulWidget {
  const PianoScreen({super.key});

  @override
  State<PianoScreen> createState() => _PianoScreenState();
}

class _PianoScreenState extends State<PianoScreen> {
  void playNote(String note) {
    print("건반 눌림: $note");
    // 나중에 소리 재생 기능 추가 예정
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("피아노 연주")),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          height: double.infinity,
          child: Stack(
            children: [
              // 흰 건반
              Row(
                children: [
                  _buildWhiteKey("도"),
                  _buildWhiteKey("레"),
                  _buildWhiteKey("미"),
                  _buildWhiteKey("파"),
                  _buildWhiteKey("솔"),
                  _buildWhiteKey("라"),
                  _buildWhiteKey("시"),
                  _buildWhiteKey("도(높은)"),
                ],
              ),
              // 검은 건반
              Positioned(
                left: 45, // 위치 조절
                top: 0,
                child: Row(
                  children: [
                    _buildBlackKey("도#"),
                    const SizedBox(width: 25),
                    _buildBlackKey("레#"),
                    const SizedBox(width: 85),
                    _buildBlackKey("파#"),
                    const SizedBox(width: 25),
                    _buildBlackKey("솔#"),
                    const SizedBox(width: 25),
                    _buildBlackKey("라#"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhiteKey(String note) {
    return GestureDetector(
      onTapDown: (_) => playNote(note),
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        ),
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 20),
        child: Text(note, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBlackKey(String note) {
    return GestureDetector(
      onTapDown: (_) => playNote(note),
      child: Container(
        width: 50,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        ),
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 20),
        child: Text(note, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ),
    );
  }
}