import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mess_prototype/models/account_sync.dart';
import 'package:mess_prototype/models/chat.dart';
import 'package:mess_prototype/models/device_session.dart';
import 'package:mess_prototype/models/friend_search_result.dart';

import '../models/user.dart';
import '../services/server_config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({
    required this.statusCode,
    required this.message
  });

  @override
  String toString() {
    return 'ApiException($statusCode):$message';
  }
}

class AuthResponse {
  final String accessToken;
  final String tokenType;

  AuthResponse({
    required this.accessToken,
    required this.tokenType
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
    );
  }
}

class ApiService {
  final http.Client _client;

  ApiService({
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get({
    required String path,
    required String token,
  }) async {
    final response = await _client.get(
      Uri.parse('$serverUrl$path'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _checkResponse(response);

    return _decodeJson(response);
  }

  Future<Map<String, dynamic>> post({
    required String path,
    required String token,
    Map<String, dynamic>? body,
  }) async {
    final response = await _client.post(
      Uri.parse('$serverUrl$path'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body == null ? null : jsonEncode(body),
    );

    _checkResponse(response);

    return _decodeJson(response);
  }

  Future<void> delete({
    required String path,
    required String token,
  }) async {
    final response = await _client.delete(
      Uri.parse('$serverUrl$path'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _checkResponse(response);
  }

  Future<User> register({
    required String username,
    required String password,
    String? firstName,
    String? email,
    String? phone
  }) async {
    final response = await _client.post(
      Uri.parse('$serverUrl/auth/register'),

      headers: {
        'Content-Type': 'application/json'
      },

      body: jsonEncode({
        'username': username,
        'password': password,
        'first_name': firstName,
        'email': email,
        'phone': phone
      })
    );

    _checkResponse(response);

    final data = _decodeJson(response);

    return User.fromJson(data);
  }

  Future<AuthResponse> login({
    required String username,
    required String password
  }) async {
    final response = await _client.post(
      Uri.parse('$serverUrl/auth/login'),

      headers: {
        'Content-Type': 'application/json'
      },

      body: jsonEncode({
        'username': username,
        'password': password
      })
    );

    _checkResponse(response);

    final data = _decodeJson(response);

    return AuthResponse.fromJson(data);
  }

  Future<User> getCurrentUser({
    required String token
  }) async {
    final response = await _client.get(
      Uri.parse('$serverUrl/users/me'),

      headers: {
        'Authorization': 'Bearer $token'
      }
    );

    _checkResponse(response);
    
    final data = _decodeJson(response);

    return User.fromJson(data);
  }


  Future<User> updateCurrentUser({
    required String token,
    String? username,
    String? firstName,
    String? deviceId,
    String? email,
    String? phone,
    String? status
  }) async {
    final Map<String, dynamic> data = {};

    if (username != null) {
      data['username'] = username;
    }

    if (firstName != null) {
      data['first_name'] = firstName;
    }

    if (email != null) {
      data['email'] = email;
    }

    if (phone != null) {
      data['phone'] = phone;
    }

    if (status != null) {
      data['status'] = status;
    }

    final response = await _client.patch(
      Uri.parse('$serverUrl/users/me'),

      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        if (deviceId != null && deviceId.isNotEmpty)
          'X-Device-ID': deviceId,
      },

      body: jsonEncode(data)
    );

    _checkResponse(response);

    final responseData = _decodeJson(response);

    return User.fromJson(responseData);
  }

  Future<String> uploadAvatar({required String token, required List<int> imageBytes, required String fileName}) async {
    final request = http.MultipartRequest('POST', Uri.parse('$serverUrl/files/upload/avatar'));

    request.headers['Authorization'] = 'Bearer $token';
    
    request.files.add(
      http.MultipartFile.fromBytes(
        'upload_file',
        imageBytes,
        filename: fileName
      )
    );

    final streamedResponse = await _client.send(request);

    final response = await http.Response.fromStream(streamedResponse);

    print(response.body);
    _checkResponse(response);

    final data = _decodeJson(response);

    final fileId = data['file_id'];

    if (fileId is! String || fileId.isEmpty) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Invalid avatar upload response'
      );
    }

    return fileId;
  }

  Future<User> updateAvatar({required String token, required String fileId, String? deviceId,}) async {
    final response = await _client.patch(
      Uri.parse('$serverUrl/users/me/avatar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        if (deviceId != null && deviceId.isNotEmpty)
          'X-Device-ID': deviceId,
      },
      body: jsonEncode({'file_id': fileId})
    );

    _checkResponse(response);

    final data = _decodeJson(response);

    return User.fromJson(data);
  }

  Future<User> deleteAvatar({required String token, String? deviceId,}) async {
    final response = await _client.delete(
      Uri.parse('$serverUrl/users/me/avatar'),
      headers: {
        'Authorization': 'Bearer $token',
        if (deviceId != null && deviceId.isNotEmpty)
          'X-Device-ID': deviceId,
      },
    );

    _checkResponse(response);

    final data = _decodeJson(response);

    return User.fromJson(data);
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    String message;

    try {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic> && data['detail'] != null) {
        final detail = data['detail'];

        if (detail is String) {
          message = detail;
        } else {
          message = detail.toString();
        }
      } else {
        message = response.body;
      }
    } catch (_) {
      message = response.body;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: message
    );
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Invalid server response'
      );
    }

    return decoded;
  }

  Future<DeviceSession> registerDevice({
    required String token,
    required String deviceId,
    required String deviceName,
    required String platform,
  }) async {
    final response = await _client.post(
      Uri.parse('$serverUrl/users/me/devices'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'device_id': deviceId,
        'device_name': deviceName,
        'platform': platform,
      }),
    );

    _checkResponse(response);

    final data = _decodeJson(response);

    return DeviceSession.fromJson(data);
  }

  Future<List<DeviceSession>> getMyDevices({
    required String token,
  }) async {
    final response = await _client.get(
      Uri.parse('$serverUrl/users/me/devices'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _checkResponse(response);

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Invalid devices response',
      );
    }

    return decoded
        .map(
          (item) => DeviceSession.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> deleteDevice({
    required String token,
    required String sessionId,
  }) async {
    final response = await _client.delete(
      Uri.parse('$serverUrl/users/me/devices/$sessionId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _checkResponse(response);
  }

  Future<AccountSync> syncAccount({
    required String token,
  }) async {
    final response = await _client.get(
      Uri.parse('$serverUrl/users/me/sync'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _checkResponse(response);

    return AccountSync.fromJson(
      _decodeJson(response),
    );
  }

  Future<List<Chat>> syncChats({
    required String token,
  }) async {
    final response = await _client.get(
      Uri.parse('$serverUrl/chats/sync'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _checkResponse(response);

    final decoded = jsonDecode(
      response.body,
    );

    if (decoded is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Invalid chats response',
      );
    }

    final chats = decoded["chats"];

    if (chats is! List) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Invalid chats list',
      );
    }

    return chats
        .map(
          (item) => Chat.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }


  Future<int> createDirectChat({
    required String token,
    required int userId,
  }) async {
    final response = await _client.post(
      Uri.parse('$serverUrl/chats/direct'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
      }),
    );

    _checkResponse(response);

    final data = _decodeJson(response);

    return data["chat_id"] as int;
  }


  Future<List<ChatMessage>> getMessages({
    required String token,
    required int chatId,
    int limit = 50,
    int? beforeId,
  }) async {
    final uri = Uri.parse(
      '$serverUrl/chats/$chatId/messages',
    ).replace(
      queryParameters: {
        "limit": limit.toString(),
        if (beforeId != null)
          "before_id": beforeId.toString(),
      },
    );

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _checkResponse(response);

    final data = _decodeJson(response);

    final messages = data["messages"];

    if (messages is! List) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Invalid messages response',
      );
    }

    return messages
        .map(
          (item) => ChatMessage.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<FriendSearchResult>> searchFriendUsers({
    required String token,
    required String query,
  }) async {
    final uri = Uri.parse(
      '$serverUrl/friends/search',
    ).replace(
      queryParameters: {
        'q': query,
      },
    );

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    _checkResponse(response);

    final decoded = jsonDecode(
      response.body,
    );

    if (decoded is! List) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Invalid search response',
      );
    }

    return decoded
        .map(
          (item) => FriendSearchResult.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  void dispose() {
    _client.close();
  }
}