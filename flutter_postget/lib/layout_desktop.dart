import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
  String selectedImageBase64 = "";
  String userMessage = "";

  @override
  void initState() {
    super.initState();
  }

  Future<File> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      return file;
    } else {
      throw Exception("No s'ha seleccionat cap arxiu.");
    }
  }

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);


    return Scaffold(
      body: Column(
        children: [
          _buildMessageArea(appData),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageArea(AppData appData) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(16.0),
        constraints: BoxConstraints(
          maxWidth: 600.0, // Set the maximum width for the messages area
        ),
        decoration: BoxDecoration(
          color: Colors.grey[200], // Set a slightly darker background color
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListView.builder(
          reverse: false, // Set this to false
          itemCount: appData.messages.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                index > 0
                    ? Divider(color: Colors.black, thickness: 1.0)
                    : Container(), // Add a separator line
                appData.messages[index],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    AppData appData = Provider.of<AppData>(context);

    String stringGet = "";
    if (appData.loadingGet && appData.dataGet == "") {
      stringGet = "Loading ...";
    } else if (appData.dataGet != null) {
      stringGet = "GET: ${appData.dataGet.toString()}";
    }

    String stringPost = "";
    if (appData.loadingPost && appData.dataPost == "") {
      stringPost = "Loading ...";
    } else if (appData.dataPost != null) {
      stringPost = "GET: ${appData.dataPost.toString()}";
    }

    String stringFile = "";
    if (appData.loadingFile) {
      stringFile = "Loading ...";
    } else if (appData.dataFile != null) {
      stringFile = "File: ${appData.dataFile}";
    }
    
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: () async {
              File? file = await pickFile();
              if (file != null) {
                // Convert the file to base64 and update the selectedImageBase64
                selectedImageBase64 = appData.fileToBase64(file);
              }
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              userMessage = _messageController.text;
              appData.load(userMessage, selectedImageBase64);
              setState(() {
                if (userMessage.isNotEmpty) {
                  // If userMessage is not empty, add UserMessage
                  appData.messages.add(UserMessage(text: userMessage));
                }
                _messageController.clear();
                appData.messages.add(ChatMessage(text: stringPost));
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
              color: Colors.grey,
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
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
