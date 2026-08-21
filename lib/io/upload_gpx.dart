import 'package:flutter/material.dart';
import '../model/track.dart';
import '../service/osm_auth_service.dart';

class UploadGpxScreen extends StatefulWidget {
  const UploadGpxScreen(this.track, {super.key});
  final Track track;

  @override
  UploadGpxScreenState createState() => UploadGpxScreenState();
}

class UploadGpxScreenState extends State<UploadGpxScreen> {
  final OsmAuthService _authService = OsmAuthService.instance;

  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  Future<void> _startFlow() async {
    // Check if we need to authenticate
    String? token = await _authService.getValidAccessToken();
    if (token == null) {
      bool success = await _authService.authenticate();
      if (!success) {
        if (mounted) {
          _showResultAndExit('Authentication failed or cancelled.');
        }
        return;
      }
    }
    
    // Perform upload
    if (mounted) {
      String result = await _authService.uploadGpx(widget.track);
      _showResultAndExit(result);
    }
  }

  void _showResultAndExit(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Upload Results"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss dialog
              Navigator.of(context).pop(); // Exit screen
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JPSTrack Upload'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Processing GPX upload...'),
          ],
        ),
      ),
    );
  }
}
