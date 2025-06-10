import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Interactivo',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF76C2FA, {
          50: Color(0xFFD2E9F9),
          100: Color(0xFFAAEEFA),
          200: Color(0xFF76C2FA),
          300: Color(0xFF76C2FA),
          400: Color(0xFF76C2FA),
          500: Color(0xFF76C2FA),
          600: Color(0xFF5BA8E0),
          700: Color(0xFF4A8FC7),
          800: Color(0xFF3976AD),
          900: Color(0xFF285D94),
        }),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({required this.text, required this.isUser, required this.timestamp});
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  // Colores de la paleta
  static const Color backgroundPrimary = Color(0xFFD2E9F9);
  static const Color colorPrimary = Color(0xFF76C2FA);
  static const Color colorSecondary = Color(0xFFAAEEFA);
  static const Color textDark = Color(0xFF333333);
  static const Color white = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    // Mensaje inicial de bienvenida
    _messages.add(
      Message(
        text: "¡Hola! Bienvenido al chat. ¿En qué puedo ayudarte hoy?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        Message(
          text: _controller.text.trim(),
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    final userMessage = _controller.text.trim();
    _controller.clear();
    _scrollToBottom();

    // Simular respuesta del bot después de un delay
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _messages.add(
            Message(
              text: _generateBotResponse(userMessage),
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }
    });
  }

  String _generateBotResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('hola') || message.contains('buenos')) {
      return "¡Hola! Es un placer saludarte. ¿Cómo está tu día?";
    } else if (message.contains('cómo') && message.contains('estás')) {
      return "¡Estoy muy bien, gracias por preguntar! ¿Y tú cómo te encuentras?";
    } else if (message.contains('ayuda')) {
      return "Por supuesto, estoy aquí para ayudarte. ¿Qué necesitas saber?";
    } else if (message.contains('gracias')) {
      return "¡De nada! Es un placer poder ayudarte. ¿Hay algo más en lo que pueda asistirte?";
    } else if (message.contains('adiós') || message.contains('hasta')) {
      return "¡Hasta pronto! Ha sido genial conversar contigo. ¡Que tengas un excelente día!";
    } else if (message.contains('tiempo') || message.contains('clima')) {
      return "No tengo acceso a información del clima en tiempo real, pero espero que tengas buen tiempo donde estés.";
    } else {
      final responses = [
        "Interesante perspectiva. Cuéntame más sobre eso.",
        "Entiendo lo que dices. ¿Podrías darme más detalles?",
        "Esa es una buena observación. ¿Qué opinas sobre ello?",
        "Me parece muy interesante lo que comentas.",
        "¡Qué bueno! Me gustaría saber más al respecto.",
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPrimary,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.chat_bubble_outline, color: white, size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chat Interactivo',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'En línea',
                    style: TextStyle(color: colorPrimary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: white,
        elevation: 2,
        shadowColor: colorSecondary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.support_agent, color: textDark, size: 18),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? colorPrimary : white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: message.isUser
                      ? Radius.circular(18)
                      : Radius.circular(4),
                  bottomRight: message.isUser
                      ? Radius.circular(4)
                      : Radius.circular(18),
                ),
                border: message.isUser
                    ? null
                    : Border.all(color: colorSecondary, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? white : textDark,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      color: message.isUser
                          ? white.withOpacity(0.8)
                          : textDark.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorPrimary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.person, color: white, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorSecondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.support_agent, color: textDark, size: 18),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colorSecondary, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                SizedBox(width: 4),
                _buildDot(1),
                SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: AnimationController(
        duration: Duration(milliseconds: 800),
        vsync: this,
      )..repeat(),
      builder: (context, child) {
        final controller = context.findRenderObject() as RenderBox?;
        final value = (DateTime.now().millisecondsSinceEpoch / 200) % 3;
        final opacity = (value - index).abs() < 1
            ? 1.0 - (value - index).abs()
            : 0.3;

        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: colorPrimary.withOpacity(opacity),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        border: Border(top: BorderSide(color: colorSecondary, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: backgroundPrimary,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorSecondary, width: 1),
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Escribe tu mensaje...',
                  hintStyle: TextStyle(color: textDark.withOpacity(0.6)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(color: textDark),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorPrimary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.send_rounded, color: white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
