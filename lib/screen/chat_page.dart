import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:presensi/models/api_key.dart';

class ChatGPTScreen extends StatefulWidget {
  const ChatGPTScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatGPTScreenState createState() => _ChatGPTScreenState();
}

class _ChatGPTScreenState extends State<ChatGPTScreen> {
  final List<Message> _messages = [];
  final TextEditingController _textEditingController = TextEditingController();
  bool isLoading = false;

  // Fungsi untuk mengirim pesan
  void onSendMessage() async {
    String text = _textEditingController.text.trim();

    if (text.isNotEmpty) {
      Message message = Message(text: text, isMe: true);

      _textEditingController.clear();

      setState(() {
        _messages.insert(0, message); // Menambah pesan sendiri ke daftar pesan
        isLoading = true; // loading sedang memuat balasan
      });

      String response = await sendMessageToChatGpt(text);

      Message chatGpt = Message(text: response, isMe: false);

      setState(() {
        _messages.insert(
            0, chatGpt); // Menambah pesan balasan dari GPT ke daftar pesan
        isLoading = false; // Menandai bahwa proses balasan telah selesai
      });
    }
  }

  // Fungsi untuk mengirim pesan ke GPT
  Future<String> sendMessageToChatGpt(String message) async {
    Uri uri = Uri.parse("https://api.openai.com/v1/chat/completions");

    //berisi data yang akan di kirim dalam permintaan
    Map<String, dynamic> body = {
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "user", "content": message}
      ],
      "max_tokens": 500,
    };
    // akan menyimpan respons dari permintaan HTTP.
    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${APIKey.apiKey}",
      },
      body: json.encode(body),
    );

    Map<String, dynamic> parsedReponse = json.decode(response.body);

    String reply = parsedReponse['choices'][0]['message']['content'];

    return reply;
  }

  // Widget tampilan pesan
  Widget _buildMessage(Message message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Column(
          crossAxisAlignment:
              message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              message.isMe ? 'You' : 'GPT',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(message.text),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ai Chatbot'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10.0),
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: onSendMessage,
                ),
              ],
            ),
          ),
          // Widget untuk menampilkan indikator loading
          if (isLoading) ...[
            const SizedBox(height: 10),
            const CircularProgressIndicator(),
          ],
        ],
      ),
    );
  }
}

// Kelas untuk pesan
class Message {
  final String text;
  final bool isMe;

  Message({required this.text, required this.isMe});
}
