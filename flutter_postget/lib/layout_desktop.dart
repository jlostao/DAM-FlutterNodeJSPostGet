import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_postget/app_data.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();

  Future<File> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      return file;
    } else {
      throw Exception("No s'ha seleccionat cap arxiu.");
    }
  }

  // Funció per carregar l'arxiu seleccionat amb una sol·licitud POST
  Future<void> uploadFile(AppData appData) async {
    try {
      appData.load("POST", selectedFile: await pickFile());
    } catch (e) {
      if (kDebugMode) {
        print("Excepció (uploadFile): $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatGPT'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              reverse: true,
              padding: const EdgeInsets.all(16.0),
              children: [
                // Replace the following with messages from the AI and user
                ChatMessage(text: 'Hello! How can I help you?'),
                UserMessage(text: 'Hi there!'),
              ],
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    AppData appData = Provider.of<AppData>(context);
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              uploadFile(appData);
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              // Handle sending the message
              String userMessage = _messageController.text;
              // You can send the user message to an AI model here
              // and update the chat UI with the AI's response
              setState(() {
                // Replace the following with AI response
                // For simplicity, just echoing the user's message
                ChatMessage(text: userMessage);
                _messageController.clear();
              });
            },
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;

  const ChatMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class UserMessage extends StatelessWidget {
  final String text;

  const UserMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
