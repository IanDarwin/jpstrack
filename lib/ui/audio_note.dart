import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:record/record.dart';

class AudioNoteScreen extends StatefulWidget {
  const AudioNoteScreen({super.key});

  @override
  _AudioNoteScreenState createState() => _AudioNoteScreenState();
}

class _AudioNoteScreenState extends State<AudioNoteScreen> {
  final record = AudioRecorder();

  _AudioNoteScreenState() {
    debugPrint("_AudioNoteScreenState()");
    _startRecording();
  }

  Future<void> _startRecording() async {
    Directory? directory = await getExternalStorageDirectory();
    if (directory != null) {
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = '${directory.path}/voicenote_$timestamp.m4a';
      if (await record.hasPermission()) {
        await record.start(const RecordConfig(), path: fileName);
        debugPrint("Recording started");
      }
    } else {
      print("ERROR: no external storage directory!?");
    }
  }

  Future<String?> _stopAndSaveRecording() async {
    var path = await record.stop();
    debugPrint("Audio saving as $path");
    record.dispose();
    return path;
  }

  Future<void> _cancelAndDeleteRecording() async {
    record.cancel();
    record.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    _cancelAndDeleteRecording();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context, await _stopAndSaveRecording());
                  },
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

