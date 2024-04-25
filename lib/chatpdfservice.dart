import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatPDFService {
  static const String apiKey = "sec_hgfsSajtfyYAJQgQeQzAEcNvHq4tZoAE";
  static const String baseURL = "https://api.chatpdf.com/v1";

  static Future<String?> addURL(String url) async {
    final Map<String, String> headers = {
      "x-api-key": apiKey,
      "Content-Type": "application/json",
    };
    final Map<String, String> data = {"url": url};

    try {
      final response = await http.post(
        Uri.parse("$baseURL/sources/add-url"),
        headers: headers,
        body: jsonEncode(data),
      );
      final responseData = jsonDecode(response.body);
      return responseData["sourceId"];
    } catch (e) {
      debugPrint("Error: $e");
      return null;
    }
  }

  static Future<String?> sendMessage(String sourceId, String message) async {
    final Map<String, String> headers = {
      "x-api-key": apiKey,
      "Content-Type": "application/json",
    };
    final Map<String, dynamic> data = {
      "sourceId": sourceId,
      "messages": [
        {"role": "user", "content": message}
      ],
    };

    try {
      final response = await http.post(
        Uri.parse("$baseURL/chats/message"),
        headers: headers,
        body: jsonEncode(data),
      );
      final responseData = jsonDecode(response.body);
      return responseData["content"];
    } catch (e) {
      debugPrint("Error: $e");
      return null;
    }
  }
}
