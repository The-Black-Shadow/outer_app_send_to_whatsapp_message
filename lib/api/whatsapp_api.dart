import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WhatsappApi {
  static final String accessPermanentToken = dotenv.env['ACCESS_PERMANENT_TOKEN'] ?? "";
  static final String fromPhoneNumberId = dotenv.env['FROM_PHONE_NUMBER_ID'] ?? "";

  static Future<Map<String, dynamic>?> sendText(
    String receiverPhnNo,
    String name,
    String orderDetails,
    String address,
  ) async {
    final url = Uri.parse(
      "https://graph.facebook.com/v25.0/$fromPhoneNumberId/messages",
    );

    // Helper to format strings to meet WhatsApp template parameter constraints
    // WhatsApp template variables cannot contain newlines, tabs, or consecutive spaces
    String cleanParam(String text) {
      return text
          .replaceAll(RegExp(r'[\n\t\r]'), ' ')
          .replaceAll(RegExp(r'\s{2,}'), ' ')
          .trim();
    }

    // >>> Send Order Template Message =======================
    // Using the pre-approved template that works for business-initiated conversations.
    final data = {
      "messaging_product": "whatsapp",
      "to": receiverPhnNo,
      "type": "template",
      "template": {
        "name": "jaspers_market_order_confirmation_v1",
        "language": {"code": "en_US"},
        "components": [
          {
            "type": "body",
            "parameters": [
              {"type": "text", "text": cleanParam(name)},
              {"type": "text", "text": cleanParam(orderDetails)},
              {"type": "text", "text": cleanParam(address)},
            ],
          },
        ],
      },
    };
    // <<< Send Order Template Message =======================

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $accessPermanentToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (kDebugMode) {
          print("Success : $result");
        }
        return result;
      } else {
        if (kDebugMode) {
          print("Failed : ${response.statusCode} ${response.body}");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error sending message: $e");
      }
    }
    return null;
  }
}
