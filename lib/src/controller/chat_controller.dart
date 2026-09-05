import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';

/// Bridge this controller to REST, WebSocket, Firebase, Stream, or your own SDK.
class ChatController extends ChangeNotifier {
  ChatController(
      {required this.currentUser,
      ChatSettings settings = const ChatSettings(),
      List<ChatConversation> conversations = const [],
      this.capabilities = const ChatCapabilities()})
      : _settings = settings,
        _conversations = conversations;
  final ChatUser currentUser;
  final ChatCapabilities capabilities;
  ChatSettings _settings;
  List<ChatConversation> _conversations;
  final Map<String, ChatDraft> _drafts = {};
  final Set<String> _savedMessageIds = {};
  ChatSettings get settings => _settings;
  List<ChatConversation> get conversations => List.unmodifiable(_conversations);
  ChatDraft? draftFor(String conversationId) => _drafts[conversationId];
  bool isMessageSaved(String messageId) => _savedMessageIds.contains(messageId);
  ChatConversation? byId(String id) {
    for (final item in _conversations) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Called before local state is updated. Persist or send this message to your backend here.
  FutureOr<void> Function(String conversationId, ChatMessage message)?
      onSendMessage;
  FutureOr<void> Function(
      String conversationId, List<ChatAttachment> attachments)? onAttach;
  FutureOr<void> Function(String conversationId, TypingState state)?
      onTypingChanged;
  FutureOr<void> Function(
      String conversationId, String messageId, String emoji)? onReact;
  FutureOr<void> Function(ChatSettings settings)? onSettingsChanged;
  FutureOr<void> Function(String conversationId, String messageId, String text)?
      onEditMessage;
  FutureOr<void> Function(String conversationId, String messageId)?
      onDeleteMessage;
  FutureOr<void> Function(String conversationId, String messageId, bool pinned)?
      onPinMessage;
  FutureOr<void> Function(
          String conversationId, String messageId, List<String> destinations)?
      onForwardMessage;
  FutureOr<void> Function(String conversationId, String messageId)? onMarkRead;
  FutureOr<void> Function(String conversationId, String messageId)?
      onReportMessage;
  FutureOr<void> Function(String conversationId, ChatPoll poll)? onCreatePoll;
  FutureOr<void> Function(
          String conversationId, ChatMessage message, DateTime sendAt)?
      onScheduleMessage;
  FutureOr<void> Function(String conversationId, String messageId, bool saved)?
      onSaveMessage;
  FutureOr<String> Function(String text, String targetLanguage)?
      onTranslateMessage;

  void replaceConversations(List<ChatConversation> conversations) {
    _conversations = conversations;
    notifyListeners();
  }

  void updateSettings(ChatSettings settings) {
    _settings = settings;
    notifyListeners();
    // Persistence is deliberately non-blocking: settings remain responsive
    // when a host app's network/database callback fails.
    Future.sync(() => onSettingsChanged?.call(settings)).catchError((_) {});
  }

  Future<void> sendText(String conversationId, String text,
      {ChatMessage? replyTo}) async {
    if (text.trim().isEmpty) return;
    final message = ChatMessage(
        id: 'local-${DateTime.now().microsecondsSinceEpoch}',
        author: currentUser,
        createdAt: DateTime.now(),
        text: text.trim(),
        status: MessageStatus.sending,
        replyTo: replyTo);
    _append(conversationId, message);
    try {
      await onSendMessage?.call(conversationId, message);
      _updateStatus(conversationId, message.id, MessageStatus.sent);
    } catch (_) {
      _updateStatus(conversationId, message.id, MessageStatus.failed);
      rethrow;
    }
  }

  void saveDraft(String conversationId, String text) {
    if (text.trim().isEmpty) {
      _drafts.remove(conversationId);
    } else {
      _drafts[conversationId] = ChatDraft(
          conversationId: conversationId,
          text: text,
          updatedAt: DateTime.now());
    }
    notifyListeners();
  }

  Future<void> scheduleText(String conversationId, String text, DateTime sendAt,
      {ChatMessage? replyTo}) async {
    if (text.trim().isEmpty || !sendAt.isAfter(DateTime.now())) return;
    final message = ChatMessage(
        id: 'scheduled-${DateTime.now().microsecondsSinceEpoch}',
        author: currentUser,
        createdAt: DateTime.now(),
        text: text.trim(),
        replyTo: replyTo,
        scheduledAt: sendAt);
    await onScheduleMessage?.call(conversationId, message, sendAt);
    _append(conversationId, message);
  }

  Future<void> toggleSavedMessage(
      String conversationId, String messageId) async {
    final saved = !_savedMessageIds.contains(messageId);
    if (saved) {
      _savedMessageIds.add(messageId);
    } else {
      _savedMessageIds.remove(messageId);
    }
    await onSaveMessage?.call(conversationId, messageId, saved);
    notifyListeners();
  }

  Future<String?> translateMessage(String text, String targetLanguage) async =>
      onTranslateMessage?.call(text, targetLanguage);

  Future<void> attach(
          String conversationId, List<ChatAttachment> files) async =>
      onAttach?.call(conversationId, files);
  void setTyping(String conversationId, TypingState state) =>
      onTypingChanged?.call(conversationId, state);
  void react(String conversationId, String messageId, String emoji) {
    onReact?.call(conversationId, messageId, emoji);
  }

  Future<void> editMessage(
      String conversationId, String messageId, String text) async {
    if (text.trim().isEmpty) return;
    await onEditMessage?.call(conversationId, messageId, text.trim());
    _mapMessages(
        conversationId,
        (m) => m.id == messageId
            ? m.copyWith(text: text.trim(), isEdited: true)
            : m);
  }

  Future<void> deleteMessage(String conversationId, String messageId) async {
    await onDeleteMessage?.call(conversationId, messageId);
    _replaceMessages(conversationId,
        (items) => items.where((m) => m.id != messageId).toList());
  }

  Future<void> pinMessage(String conversationId, String messageId) async {
    final messages = byId(conversationId)?.messages ?? const <ChatMessage>[];
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index < 0) return;
    final pinned = !messages[index].isPinned;
    await onPinMessage?.call(conversationId, messageId, pinned);
    _mapMessages(conversationId,
        (m) => m.id == messageId ? m.copyWith(isPinned: pinned) : m);
  }

  List<ChatMessage> searchMessages(String conversationId, String query) {
    final search = query.trim().toLowerCase();
    if (search.isEmpty) return const [];
    return (byId(conversationId)?.messages ?? const [])
        .where((m) =>
            m.text.toLowerCase().contains(search) ||
            m.attachments
                .any((file) => file.name.toLowerCase().contains(search)))
        .toList()
        .reversed
        .toList();
  }

  Future<void> forwardMessage(String conversationId, String messageId,
          List<String> destinations) async =>
      onForwardMessage?.call(conversationId, messageId, destinations);
  Future<void> markRead(String conversationId, String messageId) async =>
      onMarkRead?.call(conversationId, messageId);
  Future<void> reportMessage(String conversationId, String messageId) async =>
      onReportMessage?.call(conversationId, messageId);
  Future<void> createPoll(String conversationId, ChatPoll poll) async =>
      onCreatePoll?.call(conversationId, poll);

  void _append(String id, ChatMessage message) {
    _conversations = _conversations
        .map((c) => c.id == id
            ? ChatConversation(
                id: c.id,
                title: c.title,
                members: c.members,
                avatarUrl: c.avatarUrl,
                messages: [...c.messages, message],
                typing: c.typing,
                isMuted: c.isMuted,
                isPinned: c.isPinned,
                unreadCount: c.unreadCount)
            : c)
        .toList();
    notifyListeners();
  }

  void _updateStatus(String id, String messageId, MessageStatus status) {
    _mapMessages(id, (m) => m.id == messageId ? m.copyWith(status: status) : m);
  }

  void _mapMessages(String id, ChatMessage Function(ChatMessage) map) =>
      _replaceMessages(id, (items) => items.map(map).toList());
  void _replaceMessages(
      String id, List<ChatMessage> Function(List<ChatMessage>) replace) {
    _conversations = _conversations
        .map((c) => c.id == id
            ? ChatConversation(
                id: c.id,
                title: c.title,
                members: c.members,
                avatarUrl: c.avatarUrl,
                messages: replace(c.messages),
                typing: c.typing,
                isMuted: c.isMuted,
                isPinned: c.isPinned,
                unreadCount: c.unreadCount)
            : c)
        .toList();
    notifyListeners();
  }
}
