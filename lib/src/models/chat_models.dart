import 'package:flutter/foundation.dart';

/// Content type represented by a [ChatMessage].
enum MessageKind {
  /// Plain text content.
  text,

  /// Still image content.
  image,

  /// Video content.
  video,

  /// Audio content.
  audio,

  /// Generic file content.
  file,

  /// Location-sharing content.
  location,

  /// Contact-card content.
  contact,

  /// Host-generated system content.
  system,
}

/// Delivery state reported by the host application's transport layer.
enum MessageStatus {
  /// Waiting for the host transport.
  sending,

  /// Accepted by the host transport.
  sent,

  /// Delivered to a recipient device.
  delivered,

  /// Read by a recipient.
  read,

  /// Failed to send.
  failed,
}

/// Presence state shown for a conversation participant.
enum TypingState {
  /// No activity is shown.
  none,

  /// User is composing text.
  typing,

  /// User is recording audio.
  recording,
}

/// Built-in canvas background choices for [ChatSettings].
enum ChatWallpaper {
  /// Package default pattern.
  defaultPattern,

  /// Solid-colour canvas.
  solid,

  /// Gradient canvas.
  gradient,

  /// Host-provided custom canvas.
  custom,

  /// Warm sunset canvas.
  sunset,

  /// Blue ocean canvas.
  ocean,

  /// Green forest canvas.
  forest,

  /// Violet canvas.
  lavender,

  /// Rose canvas.
  rose,

  /// Dark midnight canvas.
  midnight,

  /// Sand canvas.
  sand,

  /// Aurora canvas.
  aurora,

  /// Neutral graphite canvas.
  graphite,

  /// Mint canvas.
  mint,

  /// Doodle-style canvas.
  doodles
}

/// Enables the built-in message interactions rendered by this UI package.
@immutable

/// Enables optional built-in message interactions.
class ChatCapabilities {
  /// Creates switches for optional built-in interactions.
  const ChatCapabilities({this.replies = true, this.reactions = true});

  /// Whether reply interactions are available.
  final bool replies;

  /// Whether emoji reaction interactions are available.
  final bool reactions;
}

@immutable

/// Defines poll metadata for a message.
class ChatPoll {
  /// Creates poll metadata for a host-provided message.
  const ChatPoll(
      {required this.question,
      required this.options,
      this.multipleAnswers = false});

  /// Prompt shown above the poll choices.
  final String question;

  /// Choices available to voters.
  final List<String> options;

  /// Whether one voter may choose multiple options.
  final bool multipleAnswers;
}

@immutable

/// Defines metadata for a URL preview.
class ChatLinkPreview {
  /// Creates metadata for a link preview provided by the host application.
  const ChatLinkPreview(
      {required this.url, this.title, this.description, this.imageUrl});

  /// Canonical link URL.
  final String url;

  /// Optional preview title.
  final String? title;

  /// Optional preview description.
  final String? description;

  /// Optional URL of the preview image.
  final String? imageUrl;
}

@immutable

/// Stores locally unsent text for a conversation.
class ChatDraft {
  /// Creates locally stored, unsent message text.
  const ChatDraft(
      {required this.conversationId, required this.text, this.updatedAt});

  /// ID of the conversation that owns this draft.
  final String conversationId;

  /// Unsaved composer content.
  final String text;

  /// Time when this draft was last updated.
  final DateTime? updatedAt;
}

@immutable

/// Identifies a user participating in a conversation.
class ChatUser {
  /// Creates a conversation participant.
  const ChatUser(
      {required this.id,
      required this.name,
      this.avatarUrl,
      this.isOnline = false,
      this.lastSeen});

  /// Stable host-defined identifier.
  final String id;

  /// Display name for this user.
  final String name;

  /// Optional network avatar URL.
  final String? avatarUrl;

  /// Whether the host currently considers this user online.
  final bool isOnline;

  /// Optional time at which this user was last active.
  final DateTime? lastSeen;
}

@immutable

/// References a media or file attachment owned by the host application.
class ChatAttachment {
  /// Creates a reference to a host-stored media or file attachment.
  const ChatAttachment(
      {required this.url,
      required this.name,
      this.mimeType,
      this.sizeBytes,
      this.thumbnailUrl,
      this.duration});

  /// Download or playback URL.
  final String url;

  /// Display file name.
  final String name;

  /// Optional MIME type.
  final String? mimeType;

  /// Optional attachment size in bytes.
  final int? sizeBytes;

  /// Optional thumbnail URL.
  final String? thumbnailUrl;

  /// Optional duration for audio or video content.
  final Duration? duration;
}

@immutable

/// Groups a reaction emoji and the users who selected it.
class ChatReaction {
  /// Creates an emoji reaction and the users that applied it.
  const ChatReaction({required this.emoji, required this.userIds});

  /// Emoji shown in the reaction chip.
  final String emoji;

  /// IDs of users who added this reaction.
  final Set<String> userIds;
}

@immutable

/// Represents one immutable message in a conversation.
class ChatMessage {
  /// Creates an immutable chat message.
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

  /// Stable host-defined message identifier.
  final String id;

  /// Participant who authored the message.
  final ChatUser author;

  /// Original message creation time.
  final DateTime createdAt;

  /// Plain-text message content.
  final String text;

  /// Type of content represented by this message.
  final MessageKind kind;

  /// Latest delivery status from the host transport.
  final MessageStatus status;

  /// Host-provided file and media attachments.
  final List<ChatAttachment> attachments;

  /// Emoji reactions currently applied to the message.
  final List<ChatReaction> reactions;

  /// Message quoted by this message, if any.
  final ChatMessage? replyTo;

  /// Whether the host has marked the text as edited.
  final bool isEdited;

  /// Whether the host has marked the message as forwarded.
  final bool isForwarded;

  /// Whether the message is pinned.
  final bool isPinned;

  /// User IDs mentioned in the message.
  final List<String> mentions;

  /// Optional host-provided URL preview.
  final ChatLinkPreview? linkPreview;

  /// Optional future send time.
  final DateTime? scheduledAt;

  /// Returns a copy with selected mutable message presentation fields changed.
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

/// Represents one loaded conversation and its current UI state.
class ChatConversation {
  /// Creates a conversation with its participants and loaded messages.
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

  /// Stable host-defined conversation identifier.
  final String id;

  /// Title displayed in inbox and conversation UI.
  final String title;

  /// Participants in this conversation.
  final List<ChatUser> members;

  /// Optional network avatar URL.
  final String? avatarUrl;

  /// Messages currently loaded for the conversation.
  final List<ChatMessage> messages;

  /// Typing activity supplied by the host.
  final TypingState typing;

  /// Whether host notifications are muted.
  final bool isMuted;

  /// Whether the conversation is pinned in the inbox.
  final bool isPinned;

  /// Number of unread messages.
  final int unreadCount;

  /// Latest loaded message, or null for an empty conversation.
  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;
}

@immutable

/// Stores user-selectable privacy, composer, and display preferences.
class ChatSettings {
  /// Creates user-selectable chat display and privacy preferences.
  const ChatSettings(
      {this.readReceipts = true,
      this.typingIndicators = true,
      this.enterToSend = false,
      this.autoDownloadMedia = true,
      this.disappearingMessages,
      this.wallpaper = ChatWallpaper.defaultPattern,
      this.customWallpaperUrl});

  /// Whether read receipts are enabled.
  final bool readReceipts;

  /// Whether typing states are shared.
  final bool typingIndicators;

  /// Whether Enter sends the current message.
  final bool enterToSend;

  /// Whether media is downloaded automatically.
  final bool autoDownloadMedia;

  /// Optional retention duration for disappearing messages.
  final Duration? disappearingMessages;

  /// Selected built-in wallpaper.
  final ChatWallpaper wallpaper;

  /// Optional host-provided wallpaper URL.
  final String? customWallpaperUrl;

  /// Returns a copy with selected preference fields changed.
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
