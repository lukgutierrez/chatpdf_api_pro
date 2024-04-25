import 'dart:typed_data';

import 'package:chat_pdf_api/chatpdfservice.dart';
import 'package:document_file_save_plus/document_file_save_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'dart:io';

import 'package:pdf/widgets.dart' as pw;

void main() {
  runApp(ChatPDFApp());
}

class ChatPDFApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatPDF Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatPDF Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Respuesta del chat:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            ElevatedButton(
                onPressed: () async {
                  // Agregar URL y obtener sourceId
                  final sourceId = await ChatPDFService.addURL(
                      "https://uscode.house.gov/static/constitution.pdf");
                  if (sourceId != null) {
                    print("Source ID: $sourceId");

                    // Enviar mensaje y obtener respuesta
                    final response = await ChatPDFService.sendMessage(
                        sourceId, "Who wrote the constitution?");
                    if (response != null) {
                      print("Response: $response");
                      // Hacer lo que necesites con la respuesta
                    } else {
                      print("Failed to send message.");
                    }
                  } else {
                    print("Failed to add URL.");
                  }
                },
                child: Text("hola")),
            ElevatedButton(
                onPressed: () async {
                  final String apiKey =
                      "sec_hgfsSajtfyYAJQgQeQzAEcNvHq4tZoAE"; // Reemplaza con tu clave API real
                  final String url =
                      "https://api.chatpdf.com/v1/sources/add-url";
                  final Map<String, String> headers = {
                    "x-api-key": apiKey,
                    "Content-Type": "application/json",
                  };
                  final Map<String, String> data = {
                    "url":
                        "http://autoditac.net/wp-content/uploads/2024/04/Joseph-Fadelle-EL-PRECIO-A-PAGAR.pdf",
                  };

                  try {
                    final http.Response response = await http.post(
                      Uri.parse(url),
                      headers: headers,
                      body: jsonEncode(data),
                    );

                    if (response.statusCode == 200) {
                      final dynamic responseData = jsonDecode(response.body);
                      print("Source ID: ${responseData['sourceId']}");
                    } else {
                      print("Error: ${response.reasonPhrase}");
                      print("Response: ${response.body}");
                    }
                  } catch (error) {
                    print("Error: $error");
                  }
                },
                child: Text("SOURCE ID")),
            ElevatedButton(
                onPressed: () async {
                  generatePDF();
                },
                child: Text("Message")),
          ],
        ),
      ),
    );
  }

  Future<void> generatePDF() async {
    var url = Uri.parse('https://api.chatpdf.com/v1/chats/message');

    var headers = {
      'x-api-key': 'sec_hgfsSajtfyYAJQgQeQzAEcNvHq4tZoAE',
      'Content-Type': 'application/json'
    };

    var data = {
      'sourceId': 'src_9b6bevPrQFHSXsy6lrFQI',
      'messages': [
        {
          'role': 'user',
          'content':
              'saca frases delibro y crea una tablas que diga la frase en español y  otra en ingles ,no escribas nada mas que las frases por ejemplo maximo de frases que incluya el texto',
        },
      ],
    };

    try {
      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body)['content'];
        await createPDF(responseData);
        print('PDF generado con éxito.');
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> createPDF(String content) async {
    final pdf = pw.Document();

    final lines = content.split('\n'); // Dividir el contenido en líneas

    for (var line in lines) {
      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Center(
              child: pw.Text(
                line,
                style: pw.TextStyle(fontSize: 20),
              ),
            );
          },
        ),
      );
    }

    final Directory? directory = await getDownloadsDirectory();

    final File file = File('${directory!.path}/LUKGTZ.pdf');
    print('Ruta del archivo PDF: ${file.path}');

    await file.writeAsBytes(await pdf.save());
    final Uint8List data = await file.readAsBytes();

    await DocumentFileSavePlus().saveFile(
      data,
      generateUniqueFileName('Subtiviosrwerwe.pdf'),
      'appliation/pdf',
    );
  }

  String generateUniqueFileName(String baseFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = baseFileName.replaceAll('', '');
    return '$fileName$timestamp.pdf';
  }
}
