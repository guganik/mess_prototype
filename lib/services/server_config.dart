class ServerConfig {
  static const String apiBaseUrl = 'https://googa-talk.ru';
}

class VlessConfig {
  static const String serverAddress = 'googa-talk.ru';
  static const int serverPort = 8443;

  static const String uuid = '6ff35b12-23c4-4b0b-9898-4372f06b5e65';
  static const String security = 'reality';
  static const String flow = 'xtls-rprx-vision';
  static const String sni = 'www.google.com';
  static const String fp = 'chrome';
  static const String publicKey = 'qHuDo8hHiioE3MxitYsgXbYc00GZUpBximH7v5ozvyg';
  static const String shortId = '';

  static const String wsUrl = 'wss://googa-talk.ru:8443/messenger-ws';
}

final String serverUrl = ServerConfig.apiBaseUrl;