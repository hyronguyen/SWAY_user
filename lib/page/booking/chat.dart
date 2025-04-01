import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Message {
  final String text;
  final bool isMe;
  final String? avatarUrl;
  final String time;

  Message({
    required this.text,
    required this.isMe,
    this.avatarUrl,
    required this.time,
  });
}

class ChatScreen extends StatefulWidget {
  final String driverId;

  const ChatScreen({
    Key? key,
    required this.driverId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> messages = [];
  late io.Socket socket;

  @override
  void initState() {
    super.initState();
    connectSocket();
  }

  void connectSocket() {
    socket = io.io('ws://10.0.2.2:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('Connected to WebSocket Server');
    });

    socket.onError((error) {
      print('Socket connection error: $error');
    });

    socket.on('message', (data) {
      print("Received message: $data");
      setState(() {
        messages.add(Message(
          text: data['content'],
          isMe: data['senderType'] == 'CUSTOMER',
          time: formatTime(data['timestamp']),
        ));
      });
    });

    socket.onDisconnect((_) => print('Disconnected from WebSocket'));
  }

  String formatTime(String timestamp) {
    DateTime dateTime =
        DateTime.parse(timestamp).toUtc().add(Duration(hours: 7));
    String formattedTime = DateFormat('h:mm a').format(dateTime);
    return formattedTime;
  }

  void sendMessage() async {
    final message = _messageController.text.trim(); // Lưu ngay từ đầu

    if (message.isEmpty) {
      print("Message is empty!");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String? customerIdString = prefs.getString("customer_id");

    if (customerIdString == null || customerIdString.isEmpty) {
      print("Customer ID not found in SharedPreferences!");
      return;
    }

    int? customerId = int.tryParse(customerIdString);
    if (customerId == null) {
      print("Invalid Customer ID: $customerIdString");
      return;
    }

    int? driverId = int.tryParse(widget.driverId.toString());
    if (driverId == null) {
      print("Invalid Driver ID: ${widget.driverId}");
      return;
    }

    // Gửi tin nhắn với nội dung đã lưu
    socket.emit('new message', {
      'driverId': driverId,
      'customerId': customerId,
      'senderType': 'CUSTOMER',
      'content':
          message, // Dùng biến đã lưu thay vì gọi lại _messageController.text
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chat',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                // Kiểm tra có hiển thị avatar không
                final bool showAvatar =
                    index == 0 || messages[index - 1].isMe != message.isMe;

                return _buildMessageBubble(message, showAvatar: showAvatar);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, {bool showAvatar = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isMe) ...[
            showAvatar && message.avatarUrl != null
                ? CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(message.avatarUrl!),
                  )
                : const SizedBox(width: 32),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: message.isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: message.isMe ? Colors.amber : Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: message.isMe ? Colors.black : Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  message.time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(color: Colors.grey[900]!, width: 1),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.grey),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Nhắn tin cho tài xế',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.emoji_emotions_outlined,
                          color: Colors.grey),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.grey),
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  setState(() {
                    sendMessage();
                    _messageController.clear();
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
