

import 'package:app4/global/enviroment.dart';
import 'package:dio/dio.dart';

class TrafficInterceptor extends Interceptor{

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: implement onRequest
    options.queryParameters.addAll({
      'alternatives'      : true,
      'continue_straight' : true,
      'geometries'        : 'polyline',
      'language'          : 'es',
      'overview'          : 'simplified',
      'steps'             : true,
      'access_token'      : Environment.accessTokenMapbox,

    });
    super.onRequest(options, handler);
  } 
}