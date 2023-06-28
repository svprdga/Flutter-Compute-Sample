import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

class WithoutCompute extends StatefulWidget {
  const WithoutCompute({super.key});

  @override
  State<WithoutCompute> createState() => _WithoutComputeState();
}

class _WithoutComputeState extends State<WithoutCompute> {
  static const _url =
      'https://upload.wikimedia.org/wikipedia/commons/3/3f/Fronalpstock_big.jpg';

  late final Future<List<File>> _future;

  @override
  void initState() {
    super.initState();
    _future = _createImages(_url, 4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WITHOUT Compute')),
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

  Future<List<File>> _createImages(String url, int count) async {
    final response = await http.get(Uri.parse(url));
    final List<File> files = [];

    Directory tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/image.jpg')
        .writeAsBytes(response.bodyBytes);
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
