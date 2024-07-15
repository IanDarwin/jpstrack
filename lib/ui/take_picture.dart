import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key});

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late File _imageFile;

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _savePicture() async {
    Directory? directory = await getExternalStorageDirectory();
    if (directory != null) {
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String imagePath = '${directory.path}/image_$timestamp.jpg';
      await _imageFile.copy(imagePath);
      Navigator.pop(context, imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Picture'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.file(_imageFile),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _takePicture,
              child: const Text('Take Picture'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _imageFile != null ? _savePicture : null,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

