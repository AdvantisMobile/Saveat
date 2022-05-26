import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

const bool debug = false;

const String ROOT = debug ? "http://192.168.0.14/saveat.com.br/sistema/" : "https://sistema.saveat.com.br/";
const BASE = debug ? "http://192.168.0.14/saveat.com.br/sistema/api/" : "https://api.saveat.com.br/";

//TODO mudar nome somente para BASE e apagar BASE antiga quando terminar
const BASE_NEW_VERSION = "http://saveat.com.br/sistema2/api/";

const String API = BASE + "v1";
const String TOKEN = "c4ca4238a0b923820dcc509a6f75849b";

//TODO mudar nome somente para API e apagar API antiga quando terminar
const String API_NEW_VERSION = BASE_NEW_VERSION + "v1.1";

const String version = '2.0.5';

String authorization;

var headers = {
  'Authorization': "Bearer YzRjYTQyMzhhMGI5MjM4MjBkY2M1MDlhNmY3NTg0OWI=",
  'Content-Type': 'application/json'
};

List distanciasColetadas = List();
Map globalCidadeAtual = Map();
Map globalUsuarioLogado = Map();

class Api {

  Map formParams = {};
  String pushId = '';
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  Api(){
    getPushId();
  }

  void getPushId() async {
    await OneSignal.shared.consentGranted(true);

    bool requiresConsent = await OneSignal.shared.requiresUserPrivacyConsent();

    if (!requiresConsent) {
      await getUserId().then((v) {
        pushId = v;
      });
    }
  }

  Future<String> getUserId() async {
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    return status.subscriptionStatus.userId;
  }

  Map<String, dynamic> decode(http.Response response){
    return json.decode(response.body);
  }

  Future<Map> getData(resource) async {
    print('getData');
    print(API_NEW_VERSION + resource);
    try {
      http.Response response = await http.get(API_NEW_VERSION + resource, headers: headers);
      return decode(response);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Map> postData(String resource, Map params) async {

    if(Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      AndroidBuildVersion androidVersion = androidInfo.version;

      params['device'] = "${androidInfo.model} - ${androidVersion.release}";
      params['platform'] = 'android';
    }else {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      params['device'] = "${iosDeviceInfo.model} - ${iosDeviceInfo.utsname.release}";
      params['platform'] = 'iOS';
    }

    if(pushId == null) {
      pushId = await getUserId();
    }

    params['pushId'] = pushId ?? '';
    params['version'] = version;

    print(API_NEW_VERSION + resource);

    try {
      http.Response response = await http.post(API_NEW_VERSION + resource, headers: headers, body: json.encode(params));
      return decode(response);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Map> putData(resource, params) async {

    if(Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      AndroidBuildVersion androidVersion = androidInfo.version;

      params['device'] = "${androidInfo.model} - ${androidVersion.release}";
      params['platform'] = 'android';
    }else {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      params['device'] = "${iosDeviceInfo.model} - ${iosDeviceInfo.utsname.release}";
      params['platform'] = 'iOS';
    }

    if(pushId == null) {
      pushId = await getUserId();
    }

    params['pushId'] = pushId ?? '';
    params['version'] = version;

    try{
      http.Response response = await http.put(API + resource, headers: headers, body: json.encode(params));
      return decode(response);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Map> deleteData(resource) async {
    try{
      http.Response response = await http.delete(API + resource, headers: headers);
      return decode(response);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Map> getURL(String url) async {
    try{
      http.Response response = await http.get('$ROOT$url');
      return decode(response);
    } catch (e){
      print(e);
      return null;
    }
  }

  void setInputValue(String key, dynamic value){
    formParams[key] = value;
  }

}