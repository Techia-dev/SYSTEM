import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  String? _authToken;

  ApiClient({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  void setToken(String? token) => _authToken = token;
  void clearToken() => _authToken = null;
  bool get isAuthenticated => _authToken != null;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Uri _buildUri(String path, [Map<String, String>? params]) {
    final uri = Uri.parse('$baseUrl$path');
    return params != null ? uri.replace(queryParameters: params) : uri;
  }

  Future<dynamic> get(String path, {Map<String, String>? params}) async {
    try {
      final response = await _client
          .get(_buildUri(path, params), headers: _headers)
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _client
          .post(
            _buildUri(path),
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _client
          .patch(
            _buildUri(path),
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _client
          .put(
            _buildUri(path),
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _client
          .delete(_buildUri(path), headers: _headers)
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Auto-unwrap {success: true, data: ...} format used by the API
      if (body is Map && body['success'] == true && body.containsKey('data')) {
        return body['data'];
      }
      return body;
    } else if (response.statusCode == 401) {
      throw ApiException('Unauthorized. Please sign in again.', statusCode: 401);
    } else if (response.statusCode == 403) {
      throw ApiException('Access forbidden.', statusCode: 403);
    } else if (response.statusCode == 404) {
      throw ApiException('Resource not found.', statusCode: 404);
    } else if (response.statusCode >= 500) {
      throw ApiException('Server error. Please try again.', statusCode: response.statusCode);
    } else {
      final message = body?['message'] ?? body?['error'] ?? 'Request failed';
      throw ApiException(message.toString(), statusCode: response.statusCode);
    }
  }

  void dispose() {
    _client.close();
  }
}
