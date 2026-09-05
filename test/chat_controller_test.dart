import 'package:global_chat/global_chat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const me = ChatUser(id: 'me', name: 'Me');
  const other = ChatUser(id: 'other', name: 'Other');

  ChatController controller({List<ChatMessage> messages = const []}) =>
      ChatController(currentUser: me, conversations: [
        ChatConversation(
            id: 'chat',
            title: 'Chat',
            members: const [me, other],
            messages: messages)
      ]);

  test('sends a message and marks it sent after the host callback succeeds',
      () async {
    final chat = controller();
    ChatMessage? delivered;
    chat.onSendMessage = (_, message) => delivered = message;

    await chat.sendText('chat', ' Hello ');

    expect(delivered?.text, 'Hello');
    expect(chat.byId('chat')!.messages.single.text, 'Hello');
    expect(chat.byId('chat')!.messages.single.status, MessageStatus.sent);
  });

  test('marks an optimistic message failed when the host callback fails',
      () async {
    final chat = controller()
      ..onSendMessage = (_, __) => throw StateError('offline');

    await expectLater(chat.sendText('chat', 'Hello'), throwsStateError);

    expect(chat.byId('chat')!.messages.single.status, MessageStatus.failed);
  });

  test('updates settings, preserves drafts, and searches messages', () {
    final chat = controller(messages: [
      ChatMessage(
          id: 'a',
          author: other,
          createdAt: DateTime(2026),
          text: 'Project invoice'),
      ChatMessage(
          id: 'b',
          author: other,
          createdAt: DateTime(2026, 1, 2),
          text: 'Lunch'),
    ]);

    chat.updateSettings(chat.settings.copyWith(readReceipts: false));
    chat.saveDraft('chat', 'Draft');

    expect(chat.settings.readReceipts, isFalse);
    expect(chat.draftFor('chat')!.text, 'Draft');
    expect(chat.searchMessages('chat', 'invoice').map((m) => m.id), ['a']);
  });
}
