import 'package:adminapp/core/network/network_info.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_client/link_api.dart';
import '../errors/exceptions.dart';
import 'api_consumer.dart';

class DioConsumer implements ApiConsumer {
  final Dio dio;
  final SharedPreferences _preferences;
  final NetworkInfo networkInfo = NetworkInfo();
  static const _sessionCookieKey = 'admin_session_cookie';

  DioConsumer(this.dio, this._preferences) {
    dio.options.baseUrl = ApiConstants.Api;

    dio.options.connectTimeout = const Duration(seconds: 40);

    dio.options.receiveTimeout = const Duration(seconds: 20);

    dio.options.sendTimeout = const Duration(seconds: 20);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final sessionCookie = _preferences.getString(_sessionCookieKey);
          if (sessionCookie != null && sessionCookie.isNotEmpty) {
            options.headers['Cookie'] = sessionCookie;
          }
          handler.next(options);
        },
        onResponse: (response, handler) async {
          final setCookieHeaders = response.headers['set-cookie'] ?? const [];
          if (setCookieHeaders.isNotEmpty) {
            await _saveSessionCookies(setCookieHeaders);
          }
          handler.next(response);
        },
      ),
    );
  }

  Future<void> _saveSessionCookies(List<String> setCookieHeaders) async {
    final cookies = <String, String>{};
    final existingCookie = _preferences.getString(_sessionCookieKey);
    if (existingCookie != null && existingCookie.isNotEmpty) {
      for (final cookie in existingCookie.split(';')) {
        final separator = cookie.indexOf('=');
        if (separator > 0) {
          cookies[cookie.substring(0, separator).trim()] = cookie
              .substring(separator + 1)
              .trim();
        }
      }
    }

    for (final header in setCookieHeaders) {
      final parts = header.split(';');
      final separator = parts.first.indexOf('=');
      if (separator <= 0) continue;

      final name = parts.first.substring(0, separator).trim();
      final value = parts.first.substring(separator + 1).trim();
      final expires = parts.skip(1).any((attribute) {
        final normalized = attribute.trim().toLowerCase();
        if (normalized == 'max-age=0') return true;
        if (!normalized.startsWith('expires=')) return false;
        final date = DateTime.tryParse(
          attribute.substring(attribute.indexOf('=') + 1).trim(),
        );
        return date != null && !date.isAfter(DateTime.now());
      });

      if (expires || value.isEmpty) {
        cookies.remove(name);
      } else {
        cookies[name] = value;
      }
    }

    if (cookies.isEmpty) {
      await _preferences.remove(_sessionCookieKey);
    } else {
      final cookieHeader = cookies.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join('; ');
      await _preferences.setString(_sessionCookieKey, cookieHeader);
    }
  }

  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _request(
      () => dio.get(path, queryParameters: queryParameters, options: options),
    );
  }

  @override
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _request(
      () => dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  @override
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _request(
      () => dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  @override
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _request(
      () => dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  @override
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _request(
      () => dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<Response> _request(Future<Response> Function() request) async {
    try {
      final response = await request();
      print(response);

      _checkResponse(response);
      return response;
    } on DioException catch (error) {
      print('TYPE: ${error.type}');
      print('MESSAGE: ${error.message}');
      print('ERROR: ${error.error}');
      print('REQUEST URL: ${error.requestOptions.uri}');
      print('RESPONSE: ${error.response?.data}');

      if (error.response != null) {
        throw ServerException(
          _messageFrom(error.response) ??
              error.message ??
              'Server request failed',
          statusCode: error.response?.statusCode,
        );
      }

      throw NetworkException(
        error.message ?? error.error?.toString() ?? 'Network error',
      );
    }
  }

  void _checkResponse(Response response) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw ServerException(
        _messageFrom(response.data) ?? 'Server request failed',
        statusCode: statusCode,
      );
    }

    if (response.data is! Map) return;

    final data = response.data as Map<String, dynamic>;
    print(data);
    final status = data['status']?.toString().toLowerCase();
    final failed =
        status == 'failure' || status == 'error' || status == 'false';

    if (failed) {
      throw ServerException(
        _messageFrom(data) ?? 'Server request failed',
        statusCode: statusCode,
      );
    }
  }

  String? _messageFrom(dynamic data) {
    if (data is! Map) return null;

    return data['message'] ?? data['status'];
  }
}
