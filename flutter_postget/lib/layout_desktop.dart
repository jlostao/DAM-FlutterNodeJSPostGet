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
  final ScrollController _scrollController = ScrollController();
  String selectedImageBase64 = "";
  String userMessage = "";
  File? selectedImageFile;

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

  void showImagePreview(File file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 300,
            height: 300,
            child: Image.file(file, fit: BoxFit.cover),
          ),
        );
      },
    );
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
          controller: _scrollController, // Attach ScrollController here
          itemCount: appData.messages.length,
          itemBuilder: (BuildContext context, int index) {
            // Determine message type based on position
            Widget messageWidget;
            if (index % 2 == 0) {
              // Even index: user message
              messageWidget = UserMessage(text: appData.messages[index]);
            } else {
              // Odd index: system message
              messageWidget = ChatMessage(text: appData.messages[index]);
            }
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Align(
                alignment: (index % 2 == 0)
                    ? Alignment.centerRight // Align user messages to the right
                    : Alignment.centerLeft, // Align system messages to the left
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: (index % 2 == 0)
                        ? Colors.blue
                        : Colors.grey, // Switched colors
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    appData.messages[index],
                    style: TextStyle(color: Colors.white),
                    maxLines: null, // Allow text to expand vertically
                  ),
                ),
              ),
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
                setState(() {
                  selectedImageBase64 = appData.fileToBase64(file);
                  showImagePreview(file);
                });
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
                  appData.messages.add(userMessage);
                }
                _messageController.clear();
                appData.messages.add(stringPost);
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
              style: const TextStyle(color: Colors.blue),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
