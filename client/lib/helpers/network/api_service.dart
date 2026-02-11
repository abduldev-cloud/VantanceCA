import 'package:vantanceCA/helpers/logger/logger.dart';
import 'package:vantanceCA/helpers/network/webclinet.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// DIO interceptor to add the authentication token
InterceptorsWrapper addAuthToken({String authTokenHeader = 'Authorization'}) =>
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        options.headers.addAll(<String, dynamic>{
          authTokenHeader: "Bearer ${LocalStorage.getAuthToken()}",
        });
        handler.next(options); //continue
      },
    );

/// Dio interceptor to encrypt the request body
InterceptorsWrapper encryptBody() => InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        final String method = options.method.toUpperCase();

        if (options.headers['encrypt'] as bool) {
          switch (method) {
            case 'POST':
            case 'PUT':
            case 'PATCH':
              logW('encrypting $method method');
              if (options.data.runtimeType.toString() ==
                  '_InternalLinkedHashMap<String, dynamic>') {
                logI('Data will be encrypted before sending request');
                options.data = <String, dynamic>{};
              } else {
                logI(
                    'Skipping encryption for ${options.data.runtimeType} type');
              }

              break;
            default:
              logWTF('Skipping encryption for $method method');
              break;
          }
        }
        handler.next(options); //continue
      },
    );

/// API service of the application. To use Get, POST, PUT and PATCH rest methods
class APIService {
  static final Dio _dioWithoutAuth = Dio();

  static final _dio = WebClient.basicDio!;
  static final _dioCatch = WebClient.getCacheDio!;

  static late String _prodBaseApiUrl;
  static late String _devBaseApiUrl;

  static String get _baseUrl => kReleaseMode ? _prodBaseApiUrl : _devBaseApiUrl;

  /// Initialize the API service
  static Future<void> initializeAPIService({
    required String devBaseUrl,
    required String prodBaseUrl,
    bool encryptData = false,
    String authHeader = 'Authorization',
    String xAPIKeyHeader = 'x-api-key',
    String xAPIKeyValue = 'x-api-key',
  }) async {
    _devBaseApiUrl = devBaseUrl;
    _prodBaseApiUrl = prodBaseUrl;
    await WebClient.init();

    // Configure _dioWithoutAuth with timeouts and base URL
    _dioWithoutAuth.options.baseUrl = _baseUrl;
    _dioWithoutAuth.options.connectTimeout = const Duration(seconds: 30);
    _dioWithoutAuth.options.receiveTimeout = const Duration(seconds: 30);
    _dioWithoutAuth.options.sendTimeout = const Duration(seconds: 30);

    // _dio.options.headers
    //     .addAll(<String, dynamic>{"accept": "application/json"});
    _dio.options.receiveTimeout =
        const Duration(seconds: 20); // Receive timeout
    // Receive timeout
    // _dio.options.headers
    //     .addAll(<String, dynamic>{"Content-Type": "application/json"});
    // _dioWithoutAuth.options.headers
    //     .addAll(<String, dynamic>{"accept": "application/json"});
    // _dioWithoutAuth.options.headers
    //     .addAll(<String, dynamic>{"Content-Type": "application/json"});

    _dio.interceptors.add(addAuthToken(authTokenHeader: authHeader));
    _dioCatch.interceptors.add(addAuthToken(authTokenHeader: authHeader));
    //Add interceptor for encryption layer
    // if (encryptData) {
    //   logI('Data will be encrypted for POST / PUT / PATCH');
    //   _dio.interceptors.add(encryptBody());
    // }
    final bool enableDioLogger =
        dotenv.env['ENABLE_DIO_LOGGER']?.toLowerCase() == 'true';

    final bool enableDioResponseLog =
        dotenv.env['ENABLE_DIO_RESPONSE_LOG']?.toLowerCase() == 'true';

    if (enableDioLogger) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: false,
          responseBody: enableDioResponseLog,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );

      _dioWithoutAuth.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: false,
          responseBody: enableDioResponseLog,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }
    // _restClient.getTasks();
  }

  /// GET rest API call
  /// Used to get data from backend
  ///
  /// Use [forcedBaseUrl] when want to use specific baseurl other
  /// than configured
  ///
  /// The updated data to be passed in [data]
  ///
  /// [params] are query parameters
  ///
  /// [path] is the part of the path after the base URL
  ///
  /// set [encrypt] to true if the body needs to be encrypted. Make sure the
  /// encryption keys in the backend matches with the one in frontend
  static Future<dynamic> get({
    required String path,
    Map<String, dynamic>? params,
    bool encrypt = false,
    bool withOutAuth = false,
    bool cache = true,
    Map<String, dynamic>? headers,
    String? forcedBaseUrl,
  }) async {
    final baseUrl = forcedBaseUrl ?? _baseUrl;
    // Handle path that already starts with /
    final fullUrl = path.startsWith('/') ? '$baseUrl$path' : '$baseUrl/$path';

    return withOutAuth
        ? _dioWithoutAuth.get(
            fullUrl,
            queryParameters: params,
          )
        : _dio.get(
            fullUrl,
            queryParameters: params,
          );
  }

  static Future<Response<Map<String, dynamic>?>> resourceGet({
    required String path,
    Map<String, dynamic>? params,
    bool encrypt = false,
    String? forcedBaseUrl,
  }) async =>
      _dio.request(
        (forcedBaseUrl ?? _baseUrl) + path,
        queryParameters: params,
        options: Options(headers: <String, dynamic>{"Accept": "*/*"}),
      );

  /// POST rest API call
  /// Used to send any data to server and get a response
  ///
  /// Use [forcedBaseUrl] when want to use specific baseurl other
  /// than configured
  ///
  /// The updated data to be passed in [data]
  ///
  /// [params] are query parameters
  ///‚
  /// [path] is the part of the path after the base URL
  ///
  /// set [encrypt] to true if the body needs to be encrypted. Make sure the
  /// encryption keys in the backend matches with the one in frontend
  static Future<Response<dynamic>> post({
    required String path,
    FormData? data,
    Object? mapData,
    Map<String, dynamic>? params,
    bool encrypt = true,
    Map<String, dynamic>? headers,
    String? forcedBaseUrl,
  }) async {
    final baseUrl = forcedBaseUrl ?? _baseUrl;
    // Handle path that already starts with /
    final fullUrl = path.startsWith('/') ? '$baseUrl$path' : '$baseUrl/$path';

    return _dio.post<dynamic>(
      fullUrl,
      data: mapData ?? data,
      queryParameters: params,
      options: Options(headers: headers),
    );
  }

  static Future<Response<dynamic>> postWithoutAth({
    required String path,
    FormData? data,
    Map<String, dynamic>? mapData,
    Map<String, dynamic>? params,
    bool encrypt = true,
    Map<String, dynamic>? headers,
    String? forcedBaseUrl,
    // Function(double progress)? callback,
  }) async {
    final baseUrl = forcedBaseUrl ?? _baseUrl;
    // Handle path that already starts with /
    final fullUrl = path.startsWith('/') ? '$baseUrl$path' : '$baseUrl/$path';

    return _dioWithoutAuth.post<dynamic>(fullUrl,
        data: mapData ?? data,
        queryParameters: params,
        options: Options(headers: headers));
  }

  /// PUT rest API call
  /// Usually used to create new record
  ///
  /// Use [forcedBaseUrl] when want to use specific baseurl other
  /// than configured
  ///
  /// The updated data to be passed in [data]
  ///
  /// [params] are query parameters
  ///
  /// [path] is the part of the path after the base URL
  ///
  /// set [encrypt] to true if the body needs to be encrypted. Make sure the
  /// encryption keys in the backend matches with the one in frontend
  static Future<Response<Map<String, dynamic>?>> put({
    required String path,
    FormData? data,
    Map<String, dynamic>? mapData,
    Map<String, dynamic>? params,
    bool withOutAuth = false,
    bool encrypt = true,
    String? forcedBaseUrl,
  }) async {
    final baseUrl = forcedBaseUrl ?? _baseUrl;
    // Handle path that already starts with /
    final fullUrl = path.startsWith('/') ? '$baseUrl$path' : '$baseUrl/$path';

    return withOutAuth
        ? _dioWithoutAuth.put<Map<String, dynamic>?>(fullUrl,
            queryParameters: params, data: mapData)
        : _dio.put<Map<String, dynamic>?>(
            fullUrl,
            data: mapData ?? data,
            queryParameters: params,
            options: Options(headers: <String, dynamic>{}),
          );
  }

  /// PATCH rest API call
  /// Usually used to update any record
  ///
  /// Use [forcedBaseUrl] when want to use specific baseurl other
  /// than configured
  ///
  /// The updated data to be passed in [data]
  ///
  /// [params] are query parameters
  ///
  /// [path] is the part of the path after the base URL
  ///
  /// set [encrypt] to true if the body needs to be encrypted. Make sure the
  /// encryption keys in the backend matches with the one in frontend
  static Future<Response<Map<String, dynamic>?>?> patch({
    required String path,
    FormData? data,
    Map<String, dynamic>? params,
    dynamic mapData,
    bool encrypt = true,
    String? forcedBaseUrl,
  }) async {
    final baseUrl = forcedBaseUrl ?? _baseUrl;
    // Handle path that already starts with /
    final fullUrl = path.startsWith('/') ? '$baseUrl$path' : '$baseUrl/$path';

    return _dio.patch<Map<String, dynamic>?>(
      fullUrl,
      data: mapData ?? data,
      queryParameters: params,
      options: Options(headers: <String, dynamic>{}),
    );
  }

  static Future<Response<Map<String, dynamic>?>> delete({
    required String path,
    FormData? data,
    Map<String, dynamic>? mapData,
    Map<String, dynamic>? params,
    bool encrypt = true,
    String? forcedBaseUrl,
  }) async {
    final baseUrl = forcedBaseUrl ?? _baseUrl;
    // Handle path that already starts with /
    final fullUrl = path.startsWith('/') ? '$baseUrl$path' : '$baseUrl/$path';

    return _dio.delete(
      fullUrl,
      data: mapData ?? data,
      queryParameters: params,
      options: Options(headers: <String, dynamic>{
        "Accept": "*/*",
      }),
    );
  }
}
