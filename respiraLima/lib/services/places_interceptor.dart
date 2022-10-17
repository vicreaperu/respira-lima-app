
import 'package:app4/global/enviroment.dart';
import 'package:dio/dio.dart';

class PlacesInterceptor extends Interceptor{
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: implement onRequest
    options.queryParameters.addAll({
      'access_token' : Environment.accessTokenMapbox,
      'language'     : 'es',
      'limit'        : 10,
      'country'      : 'pe'
    });
    super.onRequest(options, handler);
  }
}