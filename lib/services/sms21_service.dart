import 'package:dio/dio.dart';


class SmsApiService {
  final Dio dio = Dio();
  final String apiKey = '68021e700998e';
  final String senderId = 'LAFINA';
  final String route = 'transsms';
  final String baseUrl = 'https://sms.creativepoint.in/api/push.json';

  Future<Map<String, dynamic>> sendSms({
    required String mobileNo,
    required String text,
  }) async {
    try {
      print("📩 Sending SMS...");
      print("➡️ Mobile No: $mobileNo");
      print("➡️ Text: $text");


      final formData = FormData.fromMap({
        'apikey': apiKey,
        'route': route,
        'sender': senderId,
        'mobileno': mobileNo,
        'text': text,
      });

      // Add headers
      final options = Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
      );

      final response = await dio.post(
        baseUrl,
        data: formData,
        options: options,
      );

      print("✅ API Called Successfully");
      print("📡 Status Code: ${response.statusCode}");
      print("📨 Response Data: ${response.data}");

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'description': response.data.toString(),
        };
      } else {
        return {
          'status': 'error',
          'description': 'Failed with status code ${response.statusCode}',
        };
      }
    } catch (e) {
      print("❌ Error while sending SMS: $e");
      return {
        'status': 'error',
        'description': e.toString(),
      };
    }
  }
}

