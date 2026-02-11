import 'package:vantanceCA/helpers/constant/app_constant.dart';
import 'package:dio/dio.dart';

class WebClient {
  static RequestOptions? _newoptions;
  static RequestOptions? get newoptions => _newoptions;

  static Dio? basicDio;
  static Dio? basicDioWithoutToken;

  static Dio? getCacheDio;
  static Dio? getDioCacheWithoutToken;

  static init() async {
    basicDio = createDio();

    getCacheDio = createDio(cache: true);
  }

  static Dio createDio({bool cache = false}) {
    Dio dio = Dio(BaseOptions(
      baseUrl: API.baseURl,
      connectTimeout: const Duration(minutes: 2), // Sync API takes time
      receiveTimeout: const Duration(milliseconds: 25000),
    ));
    // dio.interceptors.add(DioFirebasePerformanceInterceptor());

    return dio;
  }

  static Dio createDioWithoutToken({bool cache = false}) {
    Dio dio = Dio(BaseOptions(
      baseUrl: API.baseURl,
      connectTimeout: const Duration(milliseconds: 25000),
      receiveTimeout: const Duration(milliseconds: 25000),
    ));
    dio.options.headers = {
      "content-type": "application/json",
      "accept": "application/json"
    };
    // dio.interceptors.add(DioFirebasePerformanceInterceptor());

    return dio;
  }
}
