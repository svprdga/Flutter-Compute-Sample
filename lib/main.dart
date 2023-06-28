import 'package:compute_heavy_tasks/with_compute.dart';
import 'package:compute_heavy_tasks/without_compute.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compute Sample',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Compute Sample'),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: ElevatedButton(
                  child: const Text('WITHOUT compute'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const WithoutCompute(),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ElevatedButton(
                  child: const Text('WITH compute'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const WithCompute(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
}
