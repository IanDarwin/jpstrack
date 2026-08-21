import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:properties/properties.dart';

class OsmAuthService {
  static final OsmAuthService instance = OsmAuthService();

  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();


  // Storage keys (not values) into the secureStorage.
  static const String _accessTokenKey = 'osm_access_token';
  static const String _refreshTokenKey = 'osm_refresh_token';

  // Configuration - These come from the Properties file in assets.
  // The Redirect URI must match what you registered on OSM exactly.
  // Setup AndroidManifest.xml and Info.plist to handle this scheme.
  // N.B. The actual values are loaded from properties; do NOT code yours here.
  String redirectUrl = 'osm://callback';
  
  // Default to Production
  String _baseUrl = 'https://www.openstreetmap.org';
  String _clientId = 'YOUR_PRODUCTION_CLIENT_ID'; 
  List<String> _scopes = ['write_gpx', 'read_gpx'];

  /// Call this when the user changes the URL in settings
  void configure(Properties properties) {
    _baseUrl = properties.get('osm.baseUrl') ?? _baseUrl;
    _clientId = properties.get('osm.clientId') ?? _clientId;
    redirectUrl = properties.get('osm.redirectUrl') ?? redirectUrl;
    
    final scopesString = properties.get('osm.scopes');
    if (scopesString != null) {
      _scopes = scopesString.split(',').map((e) => e.trim()).toList();
    }
  }

  /// Returns a valid Access Token, refreshing it if necessary.
  /// Returns null if the user is not logged in.
  Future<String?> getValidAccessToken() async {
    // 1. Try to read existing token
    String? accessToken = await _secureStorage.read(key: _accessTokenKey);
    String? refreshToken = await _secureStorage.read(key: _refreshTokenKey);

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    // 2. Test if token is still valid (optional, or just catch 401s later)
    // For simplicity, we assume if we have it, we try to use it. 
    // If you want to be robust, check expiration or try a lightweight API call.
    
    // If known expired (OSM tokens last a while, but logic is good to have):
    // return await _refreshAccessToken(refreshToken);

    return accessToken;
  }

  /// Triggers the full UI flow:
  /// 1. Opens system browser to OSM
  /// 2. User logs in and clicks "Authorize"
  /// 3. OSM redirects back to app
  /// 4. App exchanges code for tokens
  Future<bool> authenticate() async {
    try {
      // OSM OAuth2 Endpoints
      final String authorizationEndpoint = '$_baseUrl/oauth2/authorize';
      final String tokenEndpoint = '$_baseUrl/oauth2/token';

      // Perform the Authorization Code Flow with PKCE
      final AuthorizationTokenResponse? result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          redirectUrl,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: authorizationEndpoint,
            tokenEndpoint: tokenEndpoint,
          ),
          scopes: _scopes,
          
          // PKCE is enabled by default in flutter_appauth
        ),
      );

      if (result != null && result.accessToken != null) {
        await _secureStorage.write(key: _accessTokenKey, value: result.accessToken);
        if (result.refreshToken != null) {
          await _secureStorage.write(key: _refreshTokenKey, value: result.refreshToken);
        }
        return true;
      }
    } catch (e) {
      print('OAuth Error: $e');
      // Common errors: User cancelled, network failure, or misconfigured Redirect URI
    }
    return false;
  }

  /// Helper to refresh token if the API returns 401
  Future<String?> refreshAccessToken() async {
    try {
      final String? refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null) return null;

      final String tokenEndpoint = '$_baseUrl/oauth2/token';

      final TokenResponse? result = await _appAuth.token(
        TokenRequest(
          _clientId,
          redirectUrl,
          refreshToken: refreshToken,
          grantType: 'refresh_token',
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: '$_baseUrl/oauth2/authorize',
            tokenEndpoint: tokenEndpoint,
          ),
        ),
      );

      if (result != null && result.accessToken != null) {
        await _secureStorage.write(key: _accessTokenKey, value: result.accessToken);
        // Refresh tokens can rotate, so save the new one if provided
        if (result.refreshToken != null) {
          await _secureStorage.write(key: _refreshTokenKey, value: result.refreshToken);
        }
        return result.accessToken;
      }
    } catch (e) {
      print('Refresh Error: $e');
      // If refresh fails, usually means user revoked access. Clear storage.
      await logout();
    }
    return null;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  /// Example of how to use the token in an upload request
  Future<void> uploadChangeset(String xmlData) async {
    String? token = await getValidAccessToken();
    
    // If token is invalid or expired, try to refresh once
    if (token == null) {
       // logic to trigger UI prompt or fail
       throw Exception("User not logged in");
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/api/0.6/changeset/create'), // Simplified endpoint example
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/xml',
      },
      body: xmlData,
    );

    if (response.statusCode == 401) {
      // Token expired, try refresh
      token = await refreshAccessToken();
      if (token != null) {
        // Retry request...
      }
    }
  }
}
