# Global Chat usage

Global Chat is a backend-agnostic Flutter chat UI library. Create a controller for the signed-in user, hydrate conversations from your backend, and replace them when realtime data arrives.

```dart
final chat = ChatController(
  currentUser: const ChatUser(id: 'me', name: 'Me'),
  conversations: conversationsFromApi,
)
  ..onSendMessage = api.sendMessage
  ..onSettingsChanged = api.saveChatSettings;
```

Use `ConversationList` for an inbox and `ConversationScreen` for a chat:

```dart
ConversationScreen(
  controller: chat,
  conversationId: conversation.id,
  appBarActionsBuilder: (context, conversation) => [
    IconButton(icon: const Icon(Icons.more_vert), onPressed: openMenu),
  ],
  composerActionsBuilder: (context, conversation) => [
    IconButton(icon: const Icon(Icons.attach_file), onPressed: pickFiles),
  ],
)
```

Use `ChatTheme` for colours, bubble styles, and animations. Set `showSearch: false` to remove built-in message search. Use `ChatCapabilities(replies: false, reactions: false)` to disable built-in reply swipe and reactions.

Global Chat does not implement your server, authentication, encryption, file storage, calls, notifications, or moderation. Connect the controller callbacks to those services in your app.
