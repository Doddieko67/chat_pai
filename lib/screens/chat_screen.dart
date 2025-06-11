// ==================== ARCHIVO: chat_screen.dart ====================
import 'package:chat_pai/riverpod/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:chat_pai/riverpod/theme_provider.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

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

  void _toggleTheme() {
    ref.read(themeModeProvider.notifier).toggleTheme();
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
    } else if (message.contains('oscuro') || message.contains('tema')) {
      return "¡Me gusta el nuevo tema! ¿Prefieres el modo claro u oscuro? Puedes cambiar entre ellos con el botón en la parte superior.";
    } else if (message.contains('riverpod') || message.contains('estado')) {
      return "¡Excelente elección usar Riverpod para el manejo de estado! Es muy potente y reactivo.";
    } else {
      final responses = [
        "Interesante perspectiva. Cuéntame más sobre eso.",
        "Entiendo lo que dices. ¿Podrías darme más detalles?",
        "Esa es una buena observación. ¿Qué opinas sobre ello?",
        "Me parece muy interesante lo que comentas.",
        "¡Qué bueno! Me gustaría saber más al respecto.",
        "Esa es una idea fascinante. ¿Cómo llegaste a esa conclusión?",
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
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeModeType.dark;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        shadowColor: theme.appBarTheme.shadowColor,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: colorScheme.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chat Interactivo',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'En línea',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: _toggleTheme,
              icon: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  key: ValueKey(isDarkMode),
                  color: colorScheme.primary,
                  size: 26,
                ),
              ),
              tooltip: isDarkMode ? 'Modo claro' : 'Modo oscuro',
              splashRadius: 24,
            ),
          ),
        ],
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
                  return _buildTypingIndicator(colorScheme);
                }
                return _buildMessageBubble(_messages[index], colorScheme);
              },
            ),
          ),
          _buildMessageInput(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, ColorScheme colorScheme) {
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
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.support_agent,
                color: colorScheme.onSecondary,
                size: 18,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? colorScheme.primary : colorScheme.surfaceVariant,
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
                    : Border.all(color: colorScheme.secondary.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
                      color: message.isUser 
                          ? colorScheme.onPrimary 
                          : colorScheme.onSurface,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      color: message.isUser 
                          ? colorScheme.onPrimary.withOpacity(0.8) 
                          : colorScheme.onSurface.withOpacity(0.6),
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
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                color: colorScheme.onPrimary,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ColorScheme colorScheme) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.support_agent,
              color: colorScheme.onSecondary,
              size: 18,
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colorScheme.secondary.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0, colorScheme.primary),
                SizedBox(width: 4),
                _buildDot(1, colorScheme.primary),
                SizedBox(width: 4),
                _buildDot(2, colorScheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, Color color) {
    return AnimatedBuilder(
      animation: AnimationController(
        duration: Duration(milliseconds: 800),
        vsync: this,
      )..repeat(),
      builder: (context, child) {
        final value = (DateTime.now().millisecondsSinceEpoch / 200) % 3;
        final opacity = (value - index).abs() < 1 ? 1.0 - (value - index).abs() : 0.3;
        
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color.withOpacity(opacity),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.secondary.withOpacity(0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Escribe tu mensaje...',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              style: TextStyle(color: colorScheme.onSurface),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 12),
          FloatingActionButton(
            onPressed: _sendMessage,
            backgroundColor: colorScheme.primary,
            child: Icon(
              Icons.send_rounded,
              color: colorScheme.onPrimary,
              size: 24,
            ),
            mini: true,
            elevation: 4,
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
