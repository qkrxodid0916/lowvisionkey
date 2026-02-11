import 'package:flutter/material.dart';
import 'package:lowvision_key/screens/menu_screen.dart';

class FontSelectionScreen extends StatefulWidget {
  const FontSelectionScreen({super.key});

  @override
  State<FontSelectionScreen> createState() => _FontSelectionScreenState();
}

class _FontSelectionScreenState extends State<FontSelectionScreen> {
  double _fontSize = 30.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text(
                "글씨가 잘 보이시나요?",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue, width: 5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Text(
                      "설정한 글씨 크기가\n적용된 화면입니다.\n잘 보이시나요?",
                      style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  const Text("가", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Slider(
                      value: _fontSize,
                      min: 20.0,
                      max: 60.0,
                      activeColor: Colors.blue,
                      inactiveColor: Colors.blueAccent,
                      thumbColor: Colors.blue,
                      label: "${_fontSize.round()}",
                      onChanged: (value) {
                        setState(() => _fontSize = value);
                      },
                    ),
                  ),
                  const Text("가", style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 80,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _showConfirmationDialog,
                  child: const Text(
                    "확 인",
                    style: TextStyle(fontSize: 35, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue, width: 5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "확인해주세요",
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                ),
                const SizedBox(height: 30),
                Text(
                  "지금 설정하 hook신 크기로\n수업을 시작할까요?",
                  style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 70,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blue, width: 3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("다시 설정", style: TextStyle(fontSize: 24, color: Colors.blue, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: SizedBox(
                        height: 70,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MenuScreen(fontSize: _fontSize),
                              ),
                            );
                          },
                          child: const Text("시작하기", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
