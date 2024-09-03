class Constants {

  // Keys for Settings
  static const String KEY_AUTO_UPLOAD = "auto-upload";
  static const String KEY_LOGIN_NAME = "loginName";

  static const String URL_ABOUT = "https://darwinsys.com/jpstrack";

  static const String URL_UPLOAD = "https://api.openstreetmap.org/";

}

enum UploadDest {
  OpenStreetMap('OpenStreetMap Main', 'api.openstreetmap.org'),
  OpenStreetMapTest('OpenStreetMap Test Server',
    'master.apis.dev.openstreetmap.org'),
  CustomBasic('Custom URL, Basic Auth', '_'),
  CustomOAuth2('Custom URL, OAuth2', '_');
  final String name;
  final String url;
  const UploadDest(this.name, this.url);
}
