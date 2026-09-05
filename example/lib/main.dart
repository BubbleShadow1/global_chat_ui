import 'package:global_chat/global_chat.dart';
import 'package:flutter/material.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatefulWidget {
  const DemoApp({super.key});
  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  late final ChatController chat;
  @override
  void initState() {
    super.initState();
    const me = ChatUser(id: 'me', name: 'You');
    const sam = ChatUser(id: 'sam', name: 'Sam', isOnline: true);
    chat = ChatController(currentUser: me, conversations: [
      ChatConversation(id: 'sam', title: 'Sam', members: const [
        me,
        sam
      ], messages: [
        ChatMessage(
            id: 'welcome',
            author: sam,
            createdAt: DateTime.now(),
            text: 'Welcome! Swipe this message to reply.')
      ])
    ])
      ..onSendMessage = (conversationId, message) async {
        debugPrint('Send ${message.text} to $conversationId');
      }
      ..onSettingsChanged = (settings) async {
        debugPrint('Persist settings: $settings');
      };
  }

  @override
  void dispose() {
    chat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
      theme: ThemeData(colorSchemeSeed: Colors.teal, extensions: [
        ChatTheme.sunset().copyWith(bubbleStyle: ChatBubbleStyle.slack)
      ]),
      home: Scaffold(
          appBar: AppBar(title: const Text('Global Chat')),
          body: Builder(builder: (context) {
            return ConversationList(
                controller: chat,
                onConversationTap: (item) => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Scaffold(
                                body: ConversationScreen(
                              animations: const ChatAnimations(enabled: true),
                              controller: chat,
                              conversationId: item.id,
                            )))));
          })));
}
