import 'package:flutter/foundation.dart';

enum MessageKind { text, image, video, audio, file, location, contact, system }

enum MessageStatus { sending, sent, delivered, read, failed }

enum TypingState { none, typing, recording }

enum ChatWallpaper {
  defaultPattern,
  solid,
  gradient,
  custom,
  sunset,
  ocean,
  forest,
  lavender,
  rose,
  midnight,
  sand,
  aurora,
  graphite,
  mint,
  doodles
}

/// Enables the built-in message interactions rendered by this UI package.
@immutable
class ChatCapabilities {
  const ChatCapabilities({this.replies = true, this.reactions = true});
  final bool replies;
  final bool reactions;
}

@immutable
class ChatPoll {
  const ChatPoll(
      {required this.question,
      required this.options,
      this.multipleAnswers = false});
  final String question;
  final List<String> options;
  final bool multipleAnswers;
}

@immutable
class ChatLinkPreview {
  const ChatLinkPreview(
      {required this.url, this.title, this.description, this.imageUrl});
  final String url;
  final String? title;
  final String? description;
  final String? imageUrl;
}

@immutable
class ChatDraft {
  const ChatDraft(
      {required this.conversationId, required this.text, this.updatedAt});
  final String conversationId;
  final String text;
  final DateTime? updatedAt;
}

@immutable
class ChatUser {
  const ChatUser(
      {required this.id,
      required this.name,
      this.avatarUrl,
      this.isOnline = false,
      this.lastSeen});
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;
}

@immutable
class ChatAttachment {
  const ChatAttachment(
      {required this.url,
      required this.name,
      this.mimeType,
      this.sizeBytes,
      this.thumbnailUrl,
      this.duration});
  final String url;
  final String name;
  final String? mimeType;
  final int? sizeBytes;
  final String? thumbnailUrl;
  final Duration? duration;
}

@immutable
class ChatReaction {
  const ChatReaction({required this.emoji, required this.userIds});
  final String emoji;
  final Set<String> userIds;
}

@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.author,
    required this.createdAt,
    this.text = '',
    this.kind = MessageKind.text,
    this.status = MessageStatus.sent,
    this.attachments = const [],
    this.reactions = const [],
    this.replyTo,
    this.isEdited = false,
    this.isForwarded = false,
    this.isPinned = false,
    this.mentions = const [],
    this.linkPreview,
    this.scheduledAt,
  });
  final String id;
  final ChatUser author;
  final DateTime createdAt;
  final String text;
  final MessageKind kind;
  final MessageStatus status;
  final List<ChatAttachment> attachments;
  final List<ChatReaction> reactions;
  final ChatMessage? replyTo;
  final bool isEdited;
  final bool isForwarded;
  final bool isPinned;
  final List<String> mentions;
  final ChatLinkPreview? linkPreview;
  final DateTime? scheduledAt;

  ChatMessage copyWith(
          {String? text,
          MessageStatus? status,
          List<ChatReaction>? reactions,
          bool? isEdited,
          bool? isPinned}) =>
      ChatMessage(
        id: id,
        author: author,
        createdAt: createdAt,
        text: text ?? this.text,
        kind: kind,
        status: status ?? this.status,
        attachments: attachments,
        reactions: reactions ?? this.reactions,
        replyTo: replyTo,
        isEdited: isEdited ?? this.isEdited,
        isForwarded: isForwarded,
        isPinned: isPinned ?? this.isPinned,
        mentions: mentions,
        linkPreview: linkPreview,
        scheduledAt: scheduledAt,
      );
}

@immutable
class ChatConversation {
  const ChatConversation(
      {required this.id,
      required this.title,
      required this.members,
      this.avatarUrl,
      this.messages = const [],
      this.typing = TypingState.none,
      this.isMuted = false,
      this.isPinned = false,
      this.unreadCount = 0});
  final String id;
  final String title;
  final List<ChatUser> members;
  final String? avatarUrl;
  final List<ChatMessage> messages;
  final TypingState typing;
  final bool isMuted;
  final bool isPinned;
  final int unreadCount;
  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;
}

@immutable
class ChatSettings {
  const ChatSettings(
      {this.readReceipts = true,
      this.typingIndicators = true,
      this.enterToSend = false,
      this.autoDownloadMedia = true,
      this.disappearingMessages,
      this.wallpaper = ChatWallpaper.defaultPattern,
      this.customWallpaperUrl});
  final bool readReceipts;
  final bool typingIndicators;
  final bool enterToSend;
  final bool autoDownloadMedia;
  final Duration? disappearingMessages;
  final ChatWallpaper wallpaper;
  final String? customWallpaperUrl;
  ChatSettings copyWith(
          {bool? readReceipts,
          bool? typingIndicators,
          bool? enterToSend,
          bool? autoDownloadMedia,
          Duration? disappearingMessages,
          bool clearDisappearing = false,
          ChatWallpaper? wallpaper,
          String? customWallpaperUrl}) =>
      ChatSettings(
        readReceipts: readReceipts ?? this.readReceipts,
        typingIndicators: typingIndicators ?? this.typingIndicators,
        enterToSend: enterToSend ?? this.enterToSend,
        autoDownloadMedia: autoDownloadMedia ?? this.autoDownloadMedia,
        disappearingMessages: clearDisappearing
            ? null
            : (disappearingMessages ?? this.disappearingMessages),
        wallpaper: wallpaper ?? this.wallpaper,
        customWallpaperUrl: customWallpaperUrl ?? this.customWallpaperUrl,
      );
}
