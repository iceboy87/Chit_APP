import 'dart:convert';
import 'package:dio/dio.dart';

class PendingRepository {
  final PendingApi _api = PendingApi();

  Future<Map<String, dynamic>> sendPendingSms({
    required String mobileNo,
    required String text,
  }) async {
    return await _api.sendSms(mobileNo: mobileNo, text: text);
  }
}

class PendingApi {
  final Dio dio = Dio();
  final String apiKey = '68021e700998e';
  final String senderId = 'LAFINA';
  final String route = 'transsms';
  final String templateId = 'tmpl_140042'; // ✅ Template ID added
  final String baseUrl = 'http://sms.creativepoint.in/api/push.json';

  Future<Map<String, dynamic>> sendSms({
    required String mobileNo,
    required String text,
  }) async {
    try {
      final encodedText = Uri.encodeComponent(text);

      final url =
          "$baseUrl?apikey=$apiKey&sender=$senderId&route=$route"
          "&mobileno=$mobileNo&text=$encodedText&templateid=$templateId";

      final response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (status) => true,
        ),
      );

      print("✅ Final URL: $url");
      print("📩 Status: ${response.statusCode}");
      print("📩 Raw Response: ${response.data}");

      final Map<String, dynamic> decoded =
      jsonDecode(response.data.toString());

      return decoded;
    } catch (e) {
      print("❌ API Error: $e");
      return {'status': 'failed', 'description': e.toString()};
    }
  }
}
