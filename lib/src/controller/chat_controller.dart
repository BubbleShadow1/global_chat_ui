import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';

/// Bridge this controller to REST, WebSocket, Firebase, Stream, or your own SDK.
class ChatController extends ChangeNotifier {
  /// Creates a controller for [currentUser] and the supplied conversation snapshot.
  ChatController(
      {required this.currentUser,
      ChatSettings settings = const ChatSettings(),
      List<ChatConversation> conversations = const [],
      this.capabilities = const ChatCapabilities()})
      : _settings = settings,
        _conversations = conversations;

  /// Signed-in user used to identify locally authored messages.
  final ChatUser currentUser;

  /// Controls optional reply and reaction UI.
  final ChatCapabilities capabilities;
  ChatSettings _settings;
  List<ChatConversation> _conversations;
  final Map<String, ChatDraft> _drafts = {};
  final Set<String> _savedMessageIds = {};

  /// Current chat preferences.
  ChatSettings get settings => _settings;

  /// Read-only list of loaded conversations.
  List<ChatConversation> get conversations => List.unmodifiable(_conversations);

  /// Returns a locally saved draft, if any.
  ChatDraft? draftFor(String conversationId) => _drafts[conversationId];

  /// Whether a message is locally marked as saved.
  bool isMessageSaved(String messageId) => _savedMessageIds.contains(messageId);

  /// Returns a loaded conversation by ID, or null when unavailable.
  ChatConversation? byId(String id) {
    for (final item in _conversations) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Called before local state is updated. Persist or send this message to your backend here.
  FutureOr<void> Function(String conversationId, ChatMessage message)?
      onSendMessage;

  /// Invoked when the host app handles selected attachment references.
  FutureOr<void> Function(
      String conversationId, List<ChatAttachment> attachments)? onAttach;

  /// Invoked when a host app sends typing-state changes.
  FutureOr<void> Function(String conversationId, TypingState state)?
      onTypingChanged;

  /// Invoked when the user selects an emoji reaction.
  FutureOr<void> Function(
      String conversationId, String messageId, String emoji)? onReact;

  /// Invoked after the user changes a chat preference.
  FutureOr<void> Function(ChatSettings settings)? onSettingsChanged;

  /// Invoked before a local message is updated with edited text.
  FutureOr<void> Function(String conversationId, String messageId, String text)?
      onEditMessage;

  /// Invoked before a locally loaded message is removed.
  FutureOr<void> Function(String conversationId, String messageId)?
      onDeleteMessage;

  /// Invoked when the pin state of a message changes.
  FutureOr<void> Function(String conversationId, String messageId, bool pinned)?
      onPinMessage;

  /// Invoked when a message should be forwarded to destination conversations.
  FutureOr<void> Function(
          String conversationId, String messageId, List<String> destinations)?
      onForwardMessage;

  /// Invoked when the user marks a message as read.
  FutureOr<void> Function(String conversationId, String messageId)? onMarkRead;

  /// Invoked when the user reports a message.
  FutureOr<void> Function(String conversationId, String messageId)?
      onReportMessage;

  /// Invoked when the user creates a poll.
  FutureOr<void> Function(String conversationId, ChatPoll poll)? onCreatePoll;

  /// Invoked when the user schedules a message for later delivery.
  FutureOr<void> Function(
          String conversationId, ChatMessage message, DateTime sendAt)?
      onScheduleMessage;

  /// Invoked when local saved-message state changes.
  FutureOr<void> Function(String conversationId, String messageId, bool saved)?
      onSaveMessage;

  /// Invoked when a host service should translate [text] to a target language.
  FutureOr<String> Function(String text, String targetLanguage)?
      onTranslateMessage;

  /// Replaces loaded conversations with a fresh backend snapshot.
  void replaceConversations(List<ChatConversation> conversations) {
    _conversations = conversations;
    notifyListeners();
  }

  /// Updates preferences and notifies listeners before host persistence completes.
  void updateSettings(ChatSettings settings) {
    _settings = settings;
    notifyListeners();
    // Persistence is deliberately non-blocking: settings remain responsive
    // when a host app's network/database callback fails.
    Future.sync(() => onSettingsChanged?.call(settings)).catchError((_) {});
  }

  /// Optimistically sends non-empty [text] and delegates transport to [onSendMessage].
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

  /// Saves draft text locally, or removes the draft when [text] is blank.
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

  /// Creates a scheduled text message through the host callback.
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

  /// Toggles local saved state and delegates persistence to [onSaveMessage].
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

  /// Delegates text translation to [onTranslateMessage].
  Future<String?> translateMessage(String text, String targetLanguage) async =>
      onTranslateMessage?.call(text, targetLanguage);

  /// Delegates attachment handling to [onAttach].
  Future<void> attach(
          String conversationId, List<ChatAttachment> files) async =>
      onAttach?.call(conversationId, files);

  /// Delegates a typing state change to [onTypingChanged].
  void setTyping(String conversationId, TypingState state) =>
      onTypingChanged?.call(conversationId, state);

  /// Delegates an emoji reaction to [onReact].
  void react(String conversationId, String messageId, String emoji) {
    onReact?.call(conversationId, messageId, emoji);
  }

  /// Updates a message locally after the host edit callback succeeds.
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

  /// Removes a message locally after the host delete callback succeeds.
  Future<void> deleteMessage(String conversationId, String messageId) async {
    await onDeleteMessage?.call(conversationId, messageId);
    _replaceMessages(conversationId,
        (items) => items.where((m) => m.id != messageId).toList());
  }

  /// Toggles a message pin after delegating persistence to [onPinMessage].
  Future<void> pinMessage(String conversationId, String messageId) async {
    final messages = byId(conversationId)?.messages ?? const <ChatMessage>[];
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index < 0) return;
    final pinned = !messages[index].isPinned;
    await onPinMessage?.call(conversationId, messageId, pinned);
    _mapMessages(conversationId,
        (m) => m.id == messageId ? m.copyWith(isPinned: pinned) : m);
  }

  /// Searches loaded message text and attachment names in one conversation.
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

  /// Delegates forwarding to [onForwardMessage].
  Future<void> forwardMessage(String conversationId, String messageId,
          List<String> destinations) async =>
      onForwardMessage?.call(conversationId, messageId, destinations);

  /// Delegates read state to [onMarkRead].
  Future<void> markRead(String conversationId, String messageId) async =>
      onMarkRead?.call(conversationId, messageId);

  /// Delegates message reporting to [onReportMessage].
  Future<void> reportMessage(String conversationId, String messageId) async =>
      onReportMessage?.call(conversationId, messageId);

  /// Delegates poll creation to [onCreatePoll].
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
