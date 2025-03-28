import 'package:flutter/material.dart';
import 'doctor_list.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  _AIChatPageState createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> messages = [];
  bool isWaitingForHi = true;
  bool isCollectingUserInfo = false;
  bool showQuestionButtons = false;
  bool showOptionsAfterResponse = false;
  String? userName, userEmail;

  final Map<String, String> aiResponses = {
    "How to get sleep quickly?":
        "Try to relax, avoid screens before bedtime, and follow a bedtime routine.",
    "What time is most suitable to wake up?":
        "It depends on your sleep cycle. Ideally, after completing a 90-minute cycle.",
    "Why can't I sleep?":
        "There can be many reasons, such as stress, caffeine intake, or screen time before bed.",
    "What is the best food for better sleep?":
        "Foods like almonds, bananas, and warm milk can help improve sleep quality.",
  };

  final List<String> questions = [
    "How to get sleep quickly?",
    "What time is most suitable to wake up?",
    "Why can't I sleep?",
    "What is the best food for better sleep?"
  ];

  @override
  void initState() {
    super.initState();
    messages.add({
      "sender": "bot",
      "text": "Hello 👋 I'm StarryAI Bot. Please type 'Hi' to start the chat."
    });
  }

  void sendMessage() {
    if (_controller.text.isNotEmpty) {
      String userMessage = _controller.text.trim();
      setState(() {
        messages.add({"sender": "user", "text": userMessage});
        handleChatResponse(userMessage);
        _controller.clear();
      });
      Future.delayed(Duration(milliseconds: 300), _scrollToBottom);
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void handleChatResponse(String userMessage) {
    if (isWaitingForHi) {
      if (userMessage.toLowerCase() == "hi") {
        isWaitingForHi = false;
        isCollectingUserInfo = true;
        messages.add({"sender": "bot", "text": "Great! What's your name?"});
      } else {
        messages.add({
          "sender": "bot",
          "text": "Please type 'Hi' to start the conversation."
        });
      }
      setState(() {});
      return;
    }

    if (isCollectingUserInfo) {
      if (userName == null) {
        userName = userMessage;
        messages.add({
          "sender": "bot",
          "text": "Thanks, $userName! Now, please enter your email."
        });
      } else if (userEmail == null) {
        userEmail = userMessage;
        isCollectingUserInfo = false;
        messages.add({
          "sender": "bot",
          "text": "Thank you! Here are some common questions: "
        });
        setState(() {
          showQuestionButtons = true;
        });
      }
      setState(() {});
      return;
    }

    if (showQuestionButtons) {
      if (aiResponses.containsKey(userMessage)) {
        setState(() {
          messages.add({"sender": "bot", "text": aiResponses[userMessage]!});
          showQuestionButtons = false;
          showOptionsAfterResponse = true;
        });
        _scrollToBottom();
      }
    }

    if (showOptionsAfterResponse) {
      if (userMessage.toLowerCase() == "still got any other questions?") {
        setState(() {
          messages.add({
            "sender": "bot",
            "text": "Sure! Here are some questions again:"
          });
          showQuestionButtons = true;
          showOptionsAfterResponse = false;
        });
        _scrollToBottom();
      } else if (userMessage.toLowerCase() == "live agent") {
        messages.add({
          "sender": "bot",
          "text":
              "Connecting you to a live agent... Thank you for your patience!"
        });
        Future.delayed(Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DoctorListPage()), // Ensure DoctorList exists
          );
        });
      } else if (userMessage.toLowerCase() == "end chat") {
        setState(() {
          messages.add({
            "sender": "bot",
            "text": "Thank you for chatting! See you next time."
          });
        });
        _scrollToBottom();
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pop(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
                backgroundImage: AssetImage('assets/images/aichatbot.jpg')),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("StarryAI Bot",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Text("@official",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF091E40), Color(0xFF66363A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  bool isUser = messages[index]['sender'] == 'user';
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        messages[index]['text']!,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (showQuestionButtons)
              Wrap(
                spacing: 10,
                children: questions.map((question) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        messages.add({"sender": "user", "text": question});
                        messages.add(
                            {"sender": "bot", "text": aiResponses[question]!});
                        showQuestionButtons = false;
                        showOptionsAfterResponse = true;
                      });
                      _scrollToBottom();
                    },
                    child: Text(question),
                  );
                }).toList(),
              ),
            if (showOptionsAfterResponse)
              Wrap(
                spacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      handleChatResponse("Still got any other questions?");
                    },
                    child: Text("Still got any other questions?"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      handleChatResponse("Live agent");
                    },
                    child: Text("Live agent"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      handleChatResponse("End chat");
                    },
                    child: Text("End chat"),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16), // 调整内边距
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15), // 调小圆角
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8), // 控制按钮与输入框的间隔
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
