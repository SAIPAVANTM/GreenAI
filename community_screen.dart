import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenai/url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Replace with your Flask server URL
  final String baseUrl = '${Url.Urls}'; // For Android emulator
  // final String baseUrl = 'http://localhost:5000'; // For iOS simulator
  // final String baseUrl = 'http://your-server-ip:5000'; // For real device

  List<CommunityMessage> messages = [];
  int onlineMembers = 5;
  bool isLoading = false;

  // Keep it as "Anonymous" always
  final String currentUserName = "Anonymous";

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_messages'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            messages = (data['messages'] as List)
                .map((msg) => CommunityMessage.fromJson(msg))
                .toList();
          });
          _scrollToBottom();
        }
      } else {
        _showErrorSnackbar('Failed to load messages');
      }
    } catch (e) {
      _showErrorSnackbar('Network error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sendMessageToServer(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send_message'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': currentUserName, // Always sends "Anonymous"
          'message': message,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          // Add message to local list
          final newMessage = CommunityMessage.fromJson(data['data']);
          setState(() {
            messages.add(newMessage);
          });
          _scrollToBottom();
        }
      } else {
        _showErrorSnackbar('Failed to send message');
      }
    } catch (e) {
      _showErrorSnackbar('Network error: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBDBDBD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 26,
          ),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FARMER\'S COMMUNITY',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            Text(
              '$onlineMembers members online',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.black,
              size: 24,
            ),
            onPressed: _loadMessages,
          ),
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () => _showCommunityInfo(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildOnlineStatusBar(),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFBDBDBD),
                    const Color(0xFFBDBDBD).withOpacity(0.9),
                  ],
                ),
              ),
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                ),
              )
                  : RefreshIndicator(
                onRefresh: _loadMessages,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildCommunityMessage(messages[index]);
                  },
                ),
              ),
            ),
          ),

          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildOnlineStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.people,
            size: 20,
            color: Color(0xFF4CAF50),
          ),
          const SizedBox(width: 8),
          Text(
            '$onlineMembers farmers online',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityMessage(CommunityMessage message) {
    // Generate a unique ID for each message to distinguish between different anonymous users
    final messageId = message.id ?? 0;
    final isCurrentUser = message.timestamp.difference(DateTime.now()).abs().inSeconds < 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserAvatar(message),
          const SizedBox(width: 12),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isAdmin
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : isCurrentUser
                    ? const Color(0xFFE3F2FD)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                border: message.isAdmin
                    ? Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3))
                    : isCurrentUser
                    ? Border.all(color: const Color(0xFF2196F3).withOpacity(0.3))
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isCurrentUser ? "You" : "Anonymous", // Always show Anonymous or You
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: message.isAdmin
                              ? const Color(0xFF4CAF50)
                              : isCurrentUser
                              ? const Color(0xFF2196F3)
                              : Colors.black87,
                        ),
                      ),
                      if (message.isAdmin) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        _formatTime(message.timestamp),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Text(
                    message.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(CommunityMessage message) {
    // Generate different colors for different message IDs to distinguish anonymous users
    final messageId = message.id ?? 0;
    final isCurrentUser = message.timestamp.difference(DateTime.now()).abs().inSeconds < 5;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: message.isAdmin
            ? const Color(0xFF4CAF50)
            : isCurrentUser
            ? const Color(0xFF2196F3)
            : _getAvatarColorById(messageId),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        message.isAdmin
            ? Icons.admin_panel_settings
            : isCurrentUser
            ? Icons.account_circle
            : Icons.person,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  // Generate colors based on message ID to distinguish different anonymous users
  Color _getAvatarColorById(int messageId) {
    final colors = [
      const Color(0xFF81C784),
      const Color(0xFF64B5F6),
      const Color(0xFFFFB74D),
      const Color(0xFF90A4AE),
      const Color(0xFFE57373),
      const Color(0xFFBA68C8),
      const Color(0xFF4DB6AC),
      const Color(0xFFFFD54F),
    ];
    return colors[messageId % colors.length];
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF81C784),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF81C784).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 22),
                onPressed: () => _showAttachmentOptions(),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Share your farming experience anonymously...',
                    hintStyle: TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => _sendMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    // Send to server
    _sendMessageToServer(messageText);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Fixed time formatting method - converts UTC to local time
  String _formatTime(DateTime timestamp) {
    // The timestamp is already in UTC from server, convert to local
    final localTime = timestamp.toLocal();
    final now = DateTime.now();
    final difference = now.difference(localTime);

    if (difference.inDays > 0) {
      return "${difference.inDays}d ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ago";
    } else {
      return "Just now";
    }
  }

  void _showAttachmentOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFFBDBDBD),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share with Community',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  Icons.camera_alt,
                  'Camera',
                  const Color(0xFF4CAF50),
                      () => Navigator.pop(context),
                ),
                _buildAttachmentOption(
                  Icons.photo_library,
                  'Gallery',
                  const Color(0xFF2196F3),
                      () => Navigator.pop(context),
                ),
                _buildAttachmentOption(
                  Icons.agriculture,
                  'Crop Info',
                  const Color(0xFFFF9800),
                      () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showCommunityInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFBDBDBD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Anonymous Community Guidelines',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '• This is an anonymous farming community\n'
                    '• Share your farming experiences openly\n'
                    '• Ask questions and help others anonymously\n'
                    '• Be respectful to all members\n'
                    '• Share photos of your crops\n'
                    '• Discuss best farming practices\n'
                    '• No spam or promotional content\n'
                    '• Your identity remains private',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Got it', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class CommunityMessage {
  final int? id;
  final String content;
  final String senderName;
  final bool isAdmin;
  final DateTime timestamp;
  final String senderAvatar;

  CommunityMessage({
    this.id,
    required this.content,
    required this.senderName,
    required this.isAdmin,
    required this.timestamp,
    required this.senderAvatar,
  });

  factory CommunityMessage.fromJson(Map<String, dynamic> json) {
    return CommunityMessage(
      id: json['id'],
      content: json['message'],
      senderName: "Anonymous", // Always return Anonymous
      isAdmin: json['name'].toString().toLowerCase() == 'admin',
      timestamp: DateTime.parse(json['timestamp']).toUtc(), // Ensure it's treated as UTC
      senderAvatar: "anonymous",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': content,
      'name': "Anonymous", // Always save as Anonymous
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
