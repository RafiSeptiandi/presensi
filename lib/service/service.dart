import 'package:http/http.dart' as myHttp;
import 'package:presensi/utils/constants/urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<myHttp.Response> postLogin(
      String email, String password) async {
    Map<String, String> body = {"email": email, "password": password};
    return await myHttp.post(
      Uri.parse(Urls.baseUrl + Urls.login),
      body: body,
    );
  }

  static Future<myHttp.Response> getPresensi(String token) async {
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    return await myHttp.get(Uri.parse(Urls.baseUrl + Urls.gpresensi),
        headers: headers);
  }

  static Future<bool> register(
      String name, String email, String password) async {
    Map<String, String> body = {
      "name": name,
      "email": email,
      "password": password,
    };

    var response = await myHttp.post(
      Uri.parse(Urls.baseUrl + Urls.register),
      body: body,
    );

    return response.statusCode == 200;
  }

  static Future<void> logout() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove("name");
    await pref.remove("token");
  }

  static Future<myHttp.Response> savePresensi(
      String latitude, String longitude, String token) async {
    Map<String, String> body = {
      "latitude": latitude,
      "longitude": longitude,
    };

    final Map<String, String> headers = {'Authorization': 'Bearer $token'};

    return await myHttp.post(
      Uri.parse('${Urls.baseUrl}save-presensi'),
      body: body,
      headers: headers,
    );
  }
}
