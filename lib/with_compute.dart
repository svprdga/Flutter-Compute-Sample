import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

class WithCompute extends StatefulWidget {
  const WithCompute({super.key});

  @override
  State<WithCompute> createState() => _WithComputeState();
}

class _WithComputeState extends State<WithCompute> {
  static const _url =
      'https://upload.wikimedia.org/wikipedia/commons/3/3f/Fronalpstock_big.jpg';

  late final Future<List<File>> _future;

  @override
  void initState() {
    super.initState();
    _future = _createImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WITH Compute')),
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

  Future<List<File>> _createImages() async {
    return compute(
      createImages,
      CreateImagesParams(
        url: _url,
        count: 4,
        directory: await getTemporaryDirectory(),
      ),
    );
  }
}

class CreateImagesParams {
  final String url;
  final int count;
  final Directory directory;

  CreateImagesParams({
    required this.url,
    required this.count,
    required this.directory,
  });
}

Future<List<File>> createImages(CreateImagesParams params) async {
  final response = await http.get(Uri.parse(params.url));
  final List<File> files = [];

  File file = await File('${params.directory.path}/image.jpg')
      .writeAsBytes(response.bodyBytes);
  img.Image? image = img.decodeImage(file.readAsBytesSync());

  for (var i = 0; i < params.count; i++) {
    if (image == null) continue;

    img.Image resizedImage = img.copyResize(image,
        width: (image.width * 0.5).round(),
        height: (image.height * 0.5).round());
    List<int> resizedImageData = img.encodeJpg(resizedImage);

    file = await File('${params.directory.path}/image$i.jpg')
        .writeAsBytes(resizedImageData);
    files.add(file);

    image = img.decodeImage(file.readAsBytesSync());
  }

  return files;
}
