import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:properties/properties.dart';

import '../constants.dart';
import '../io/gpx.dart';
import '../model/track.dart';

class OsmAuthService {
  static final OsmAuthService instance = OsmAuthService();

  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Storage keys
  static const String _accessTokenKey = 'osm_access_token';
  static const String _refreshTokenKey = 'osm_refresh_token';

  // Configuration
  bool _prodMode = true;
  String _authBaseUrl = 'https://www.openstreetmap.org';
  String _apiBaseUrl = 'https://api.openstreetmap.org';
  String _clientId = '';
  String _clientSecret = '';
  String _redirectUrl = 'osm://jpstrack/authok';
  List<String> _scopes = ['write_gpx', 'read_gpx', 'write_api'];

  bool get isAuthenticated => _accessToken != null;
  String? _accessToken;

  /// Initialize configuration from properties.
  void configure(Properties properties, {bool prodMode = true}) {
    _prodMode = prodMode;
    if (_prodMode) {
      _authBaseUrl = 'https://www.openstreetmap.org';
      _apiBaseUrl = properties.get('osm.baseUrl') ?? 'https://api.openstreetmap.org';
      _clientId = properties.get('osm.clientId') ?? '';
      _clientSecret = properties.get('osm.clientSecret') ?? '';
    } else {
      String devBase = properties.get('osm.baseUrl.dev') ?? 'https://master.apis.dev.openstreetmap.org';
      _authBaseUrl = devBase;
      _apiBaseUrl = devBase;
      _clientId = properties.get('osm.clientId.dev') ?? '';
      _clientSecret = properties.get('osm.clientSecret.dev') ?? '';
    }
    _redirectUrl = properties.get('osm.redirectUrl') ?? _redirectUrl;

    final scopesString = properties.get('osm.scopes');
    if (scopesString != null) {
      _scopes = scopesString.split(',').map((e) => e.trim()).toList();
    }
  }

  /// Loads saved tokens from secure storage.
  Future<void> init() async {
    _accessToken = await _secureStorage.read(key: _accessTokenKey);
  }

  /// Returns a valid Access Token, refreshing it if necessary.
  Future<String?> getValidAccessToken() async {
    _accessToken ??= await _secureStorage.read(key: _accessTokenKey);
    return _accessToken;
  }

  /// Triggers the full UI flow using flutter_appauth.
  Future<bool> authenticate() async {
    try {
      final String authorizationEndpoint = '$_authBaseUrl/oauth2/authorize';
      final String tokenEndpoint = '$_authBaseUrl/oauth2/token';

      final AuthorizationTokenResponse result =
          await _appAuth.authorizeAndExchangeCode(
          AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          clientSecret: _clientSecret.isNotEmpty ? _clientSecret : null,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: authorizationEndpoint,
            tokenEndpoint: tokenEndpoint,
          ),
          scopes: _scopes,
        ),
      );

      if (result.accessToken != null) {
        _accessToken = result.accessToken;
        await _secureStorage.write(key: _accessTokenKey, value: _accessToken);
        if (result.refreshToken != null) {
          await _secureStorage.write(
              key: _refreshTokenKey, value: result.refreshToken);
        }
        return true;
      }
    } catch (e) {
      debugPrint('OAuth Error: $e');
    }
    return false;
  }

  /// Upload GPX Data to OpenStreetMap.
  Future<String> uploadGpx(Track track) async {
    String? token = await getValidAccessToken();
    if (token == null) {
      return 'Error: Not authenticated. Please log in.';
    }

    var uploadUrl = '$_apiBaseUrl/api/0.6/gpx/create';
    var gpxString = Gpx.buildGPXString(track);
    
    var mp = http.MultipartFile.fromString(
      'file',
      gpxString,
      filename: 'track_${track.id}.gpx',
      contentType: MediaType('application', 'gpx+xml'),
    );


    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
      ..files.add(mp)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['User-Agent'] = Constants.USER_AGENT
      ..fields['description'] = 'GPX Map Track created by JPSTrack v2'
      ..fields['visibility'] = 'trackable';

    try {
      // DO THE UPLOAD
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return 'Successful upload.';
      } else if (response.statusCode == 401) {
        // Potential token expiry, could attempt refresh here if implemented
        return 'Error: Unauthorized. Please log in again.';
      } else {
        var message =
            'Failed to upload GPX data: ${response.statusCode} ${response.reasonPhrase}';
        debugPrint(message);
        debugPrint('Response body: ${response.body}');
        return message;
      }
    } catch (e) {
      debugPrint('Upload Error: $e');
      return 'Error during upload: $e';
    }
  }

  Future<void> logout() async {
    _accessToken = null;
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }
}
