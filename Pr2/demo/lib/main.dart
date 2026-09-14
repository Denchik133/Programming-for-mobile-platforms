import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo()));

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  final controller = ScrollController();
  late final int cachedValue;

  @override
  void initState() {
    super.initState();
    cachedValue = heavyCalculation();
    controller.addListener(() => setState(() {}));
  }

  int heavyCalculation() {
    var result = 0;
    for (var i = 0; i < 5000000; i++) {
      result = (result + i * 31) % 1000003;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Оптимізовано')),
      body: ListView.builder(
        controller: controller,
        itemCount: 100,
        itemBuilder: (_, i) => ListTile(
          title: Text('Елемент $i'),
          subtitle: Text('Результат: $cachedValue'),
        ),
      ),
    );
  }
}