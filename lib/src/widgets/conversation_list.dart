import 'package:flutter/material.dart';
import '../controller/chat_controller.dart';
import '../models/chat_models.dart';

class ConversationList extends StatelessWidget {
  const ConversationList(
      {super.key,
      required this.controller,
      required this.onConversationTap,
      this.emptyBuilder});
  final ChatController controller;
  final ValueChanged<ChatConversation> onConversationTap;
  final WidgetBuilder? emptyBuilder;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final chats = [...controller.conversations]..sort((a, b) =>
            (b.lastMessage?.createdAt ?? DateTime(0))
                .compareTo(a.lastMessage?.createdAt ?? DateTime(0)));
        if (chats.isEmpty) {
          return emptyBuilder?.call(context) ??
              const Center(child: Text('No conversations yet'));
        }
        return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (_, i) {
              final chat = chats[i];
              final last = chat.lastMessage;
              return ListTile(
                  leading: CircleAvatar(
                      backgroundImage: chat.avatarUrl == null
                          ? null
                          : NetworkImage(chat.avatarUrl!),
                      child: chat.avatarUrl == null
                          ? Text(chat.title.characters.first.toUpperCase())
                          : null),
                  title: Row(children: [
                    if (chat.isPinned)
                      const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.push_pin, size: 14)),
                    Expanded(
                        child:
                            Text(chat.title, overflow: TextOverflow.ellipsis))
                  ]),
                  subtitle: Text(
                      chat.typing == TypingState.typing
                          ? 'typing...'
                          : (last?.text ?? 'No messages'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (last != null)
                          Text(
                              '${last.createdAt.hour.toString().padLeft(2, '0')}:${last.createdAt.minute.toString().padLeft(2, '0')}',
                              style: Theme.of(context).textTheme.labelSmall),
                        if (chat.unreadCount > 0)
                          Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle),
                              child: Text('${chat.unreadCount}',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 10)))
                      ]),
                  onTap: () => onConversationTap(chat));
            });
      });
}
