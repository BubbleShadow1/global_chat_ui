# Global Chat

A server-agnostic Flutter library for building polished chat applications quickly. It covers conversations, message bubbles, replies, reactions, delivery states, attachments, typing, voice/video-call entry points, theming, wallpapers, and a WhatsApp-inspired settings screen.

See the complete [usage guide](doc/USAGE.md) and the runnable [example app](example/lib/main.dart).

Maintainers: see the [pub.dev publishing guide](doc/PUBLISHING_TO_PUB_DEV.md) before releasing this package.

## Install

```yaml
dependencies:
  global_chat:
    path: ../global_chat # or use your published version
```

## Use

```dart
final controller = ChatController(
  currentUser: const ChatUser(id: 'me', name: 'Me'),
  conversations: [/* hydrate from your API */],
)
  ..onSendMessage = (chatId, message) => api.sendMessage(chatId, message)
  ..onSettingsChanged = (settings) => api.saveChatSettings(settings);

MaterialApp(
  theme: ThemeData(extensions: [ChatTheme.light().copyWith(
    bubbleStyle: ChatBubbleStyle.telegram,
  )]),
  home: ConversationScreen(
    controller: controller,
    conversationId: 'team',
    enableSwipeToReply: true,
  ),
);
```

`ChatBubbleStyle` provides `whatsapp`, `rounded`, `telegram`, `iMessage`, and `minimal` designs. Set it in `ChatTheme` for the whole app or directly on an individual `ConversationScreen`. Swiping either direction over any message opens a reply quote in the composer; this can be disabled with `enableSwipeToReply: false`.

The library intentionally does not impose a backend or authentication provider. Call `replaceConversations()` whenever your WebSocket/Firebase/REST layer receives data; connect the controller callbacks to your send, upload, reaction, typing, call, and persistence endpoints.

## Advanced message actions

Connect these optional controller hooks to your backend, then use the methods from your own action sheet, menu, or moderation UI:

```dart
controller
  ..onEditMessage = api.editMessage
  ..onDeleteMessage = api.deleteMessage
  ..onPinMessage = api.pinMessage;

await controller.editMessage('team', messageId, 'Corrected text');
await controller.pinMessage('team', messageId);
await controller.deleteMessage('team', messageId);
```

Pinned messages render with a small in-bubble indicator. Edits update the local UI immediately after the backend callback completes.

The package exposes `ChatCapabilities` for built-in replies and reactions, plus `searchMessages`, `forwardMessage`, `markRead`, `reportMessage`, and `createPoll` integration hooks. Keep server, encryption, storage, calls, notifications, and moderation in your app's backend layer.

For productivity features, use `saveDraft`, `scheduleText`, `toggleSavedMessage`, and `translateMessage`. Messages now support mentions, link previews, and scheduled-send metadata.

## Optional animations

Use `ChatTheme.light().copyWith(animations: const ChatAnimations.disabled())` to disable built-in UI motion for all chats. You can create `ChatAnimations(enabled: true, messageDuration: Duration(milliseconds: 400), curve: Curves.easeOutBack)` to customize the package animation settings.

For attachments, calls, settings, voice input, GIFs, and other controls, use `composerActionsBuilder` or `appBarActionsBuilder`. This keeps picker, permissions, encryption, storage, transport, and placement choices in your application.
