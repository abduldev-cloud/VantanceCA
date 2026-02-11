import 'package:vantanceCA/helpers/constant/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:vantanceCA/images.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatPageContent extends StatefulWidget {
  const ChatPageContent({super.key});

  @override
  State<ChatPageContent> createState() => _chatState();
}

class _chatState extends State<ChatPageContent> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, String>> messages = [];
  final bool _isLoading = false;

  final Map<String, String> hardcodedResponses = {
    "Hii!": "Hello",
    "can you help me ?": "Yeah sure !",
  };

  String getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return "?";
    final names = name.trim().split(RegExp(r"\s+"));
    if (names.length >= 2) {
      return names[0][0].toUpperCase() + names[1][0].toUpperCase();
    } else {
      return names[0].substring(0, names[0].length >= 2 ? 2 : 1).toUpperCase();
    }
  }

  void _handleSend() async {
    String input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      messages.add({"sender": "me", "text": input});

      messages.add({"sender": "model", "text": "..."});
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse(API.generalChatUrl),
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer AF7D3F0-8CVMPFX-HM9932T-QJWE7RW",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "message": input,
          "mode": "chat",
          "sessionId": "identifier-to-partition-chats-by-external-id",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data["textResponse"] ?? "No response from AI";

        setState(() {
          messages.removeLast();
          messages.add({"sender": "model", "text": reply});
        });
      } else {
        setState(() {
          messages.removeLast();
          messages.add({
            "sender": "model",
            "text": "Something went wrong, please try again later !"
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.removeLast();
        messages.add({"sender": "model", "text": "⚠️ Failed to connect: $e"});
      });
    }
  }

  Widget _buildMessageBubble(Map<String, String> message) {
    bool fromMe = message["sender"] == "me";
    return Row(
      mainAxisAlignment:
          fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!fromMe)
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 6),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage(Images.elephant),
            ),
          ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            constraints: BoxConstraints(maxWidth: 450.w),
            decoration: BoxDecoration(
              color: fromMe
                  ? const Color.fromRGBO(159, 60, 187, 1)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(fromMe ? 18 : 0),
                bottomRight: Radius.circular(fromMe ? 0 : 18),
              ),
            ),
            child: Text(
              message["text"] ?? "",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                color: fromMe ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
        if (fromMe)
          Padding(
            padding: const EdgeInsets.only(left: 6, right: 8),
            child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color.fromRGBO(159, 60, 187, 1),
                child: Text(
                  getInitials(LocalStorage.getUserName()),
                  style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                )),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: SizedBox(
                    height: 120,
                    width: 120,
                    child: Center(
                      child: Image.asset(
                        Images.elephant,
                        height: 88,
                        width: 88,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemCount: messages.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    return _buildMessageBubble(message);
                  },
                ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          width: double.infinity,
          height: 1,
          color: Colors.grey,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    minLines: 1,
                    maxLines: 5,
                    onSubmitted: (_) => _handleSend(),
                    decoration: const InputDecoration(
                      hintText: "✨ I am AI can I help you?",
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _handleSend,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(159, 60, 187, 1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
