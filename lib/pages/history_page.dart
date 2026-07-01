import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("打刻履歴"),
      ),
      body: const Center(
        child: Text(
          "まだ履歴はありません",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}