import 'package:flutter/material.dart';
import 'package:pai_app/presentation/providers/chat/chat_with_context.dart';
import 'package:pai_app/presentation/widgets/chat/custom_bottom_input.dart';

import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pai_app/presentation/providers/users/user_provider.dart';

class ChatContextScreen extends ConsumerWidget {
  const ChatContextScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final chatMessages = ref.watch(chatWithContextProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat conversacional'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(chatWithContextProvider.notifier).newChat();
            },
            icon: const Icon(Icons.clear_outlined),
          ),
        ],
      ),
      body: Chat(
        messages: chatMessages,

        // On Send Message
        onSendPressed: (_) {},
        user: user,
        theme: DefaultChatTheme(
          sentMessageBodyTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          inputBackgroundColor: Colors.white,
          inputTextColor: Colors.black87,
          inputTextStyle: const TextStyle(fontSize: 16),
          messageBorderRadius: 10.0,
          messageInsetsHorizontal: 16.0,
          messageInsetsVertical: 10.0,
          userNameTextStyle: const TextStyle(fontWeight: FontWeight.bold),
          dateDividerTextStyle: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        showUserNames: true,

        // Custom Input Area
        customBottomWidget: CustomBottomInput(
          onSend: (partialText, {images = const []}) {
            final chatNotifier = ref.read(chatWithContextProvider.notifier);
            chatNotifier.addMessage(
              partialText: partialText,
              user: user,
              images: images,
            );
          },
        ),
      ),
    );
  }
}
