import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/track.dart';
import 'gpx.dart';

part 'upload_gpx.g.dart';	// see upload_gpx.g.template

oauth2.AuthorizationCodeGrant? authorizationCodeGrant;
late Uri authorizationUrl;
const proto = 'https';
const api = "0.6";

class UploadGpxScreen extends StatefulWidget {
  const UploadGpxScreen(this.track, {super.key});
  final Track track;

  @override
  UploadGpxScreenState createState() => UploadGpxScreenState(track);
}

class UploadGpxScreenState extends State<UploadGpxScreen> {

  Track track;
  oauth2.Client? client;
  String? bearerAuth;
  final appLinks = AppLinks();

  UploadGpxScreenState(this.track);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JPSTrack Upload'),
      ),
      body: const Center(
        child: Text('Submitting...'),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (authorizationCodeGrant == null) {
      authorizationCodeGrant ??= oauth2.AuthorizationCodeGrant(
        clientId,
        authorizationEndpoint,
        tokenEndpoint,
        secret: secret,
      );
      authorizationUrl =
          authorizationCodeGrant!.getAuthorizationUrl(redirectUrl,
              scopes: ['write_api', 'read_gpx', 'write_gpx']);
    }
    appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleUri(uri);
      }
    });
    authenticate();
  }

  // XXX to be called from the Upload button when in jpstrack
  // This method launches the browser URL for validation,
  // then terminatess; the app should be called again when
  // the redirect URL is successfully interpreted.
  Future<void> authenticate() async {
    await launchUrl(authorizationUrl);
  }

  void _handleUri(Uri uri) {
    final code = uri.queryParameters['code'];
    if (code != null) {
      _exchangeCodeForToken(code);
    }
  }

  Future<void> _exchangeCodeForToken(String code) async {
    if (client == null) {
      client = await authorizationCodeGrant!.handleAuthorizationResponse(
        {'code': code},
      );
      bearerAuth = client!.credentials.accessToken;
    }
    _uploadData();
  }

  Future<void> _uploadData() async {

      var uploadResponse = await uploadGpx();

      debugPrint('Upload response:$uploadResponse');

      // Tell the user what happened
      if (!mounted) {
        debugPrint("Not mounted, abandoning");
        return;
      }

      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => AlertDialog(
              title: const Text("Upload results"),
              content: Text(uploadResponse),
              actions: [
                TextButton(
                    child: const Text("OK"),
                    onPressed: () async {
                      Navigator.of(context).pop(); // alert
                      Navigator.of(context).pop(); // upload gpx screen
                    }
                )
              ]
          )));
    }

    // Upload GPX Data
    Future<String> uploadGpx() async {
      var uploadUrl =
          '$proto://$apiHost/api/$api/gpx/create';
      var mp = MultipartFile.fromString('file', Gpx.buildGPXString(track),
          filename: 'filename1',
          contentType: MediaType('application', 'gpx+xml'));
      var request = MultipartRequest('POST', Uri.parse(uploadUrl))
        ..files.add(mp)
        ..headers['Authorization'] = 'Bearer $bearerAuth'
        ..fields['file'] = 'filename1'
        ..fields['description'] = 'GPX Map Track created by JPSTrack v2'
        ..fields['visibility'] = 'public';
      if (!prodMode) {
        debugPrint('Request: ${request.toString()}');
        debugPrint('Request headers: ${request.headers}');
        debugPrint('Request fields: ${request.fields}');
        debugPrint(
            'Request file: ${request.files[0].filename} ${request.files[0].contentType}');
      }
      var response = await client!.send(request);

      if (response.statusCode == 200) {
        return 'Sucessful upload.';
      }  else {
        var message = 'Failed to upload GPX data: ${response.statusCode} ${response.reasonPhrase}';
        debugPrint(message);
        return message;
      }
    }
}
