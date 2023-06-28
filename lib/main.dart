import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final Future<List<File>> _future;

  @override
  void initState() {
    super.initState();
    _future = _createImages('assets/image.jpg', 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compute Sample')),
      body: FutureBuilder<List<File>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final files = snapshot.data!;

            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    Text(
                        'Image ${index + 1} Size: ${files[index].lengthSync()} bytes'),
                    Image.file(files[index]),
                    const SizedBox(
                      height: 24.0,
                    ),
                  ],
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<List<File>> _createImages(String path, int count) async {
    final byteData = await rootBundle.load(path);
    final List<File> files = [];

    Directory tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/image.jpg').writeAsBytes(byteData
        .buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    img.Image? image = img.decodeImage(file.readAsBytesSync());

    for (var i = 0; i < count; i++) {
      if (image == null) continue;

      img.Image resizedImage = img.copyResize(image,
          width: (image.width * 0.5).round(),
          height: (image.height * 0.5).round());
      List<int> resizedImageData = img.encodeJpg(resizedImage);

      file = await File('${tempDir.path}/image$i.jpg')
          .writeAsBytes(resizedImageData);
      files.add(file);

      image = img.decodeImage(file.readAsBytesSync());
    }

    return files;
  }
}
