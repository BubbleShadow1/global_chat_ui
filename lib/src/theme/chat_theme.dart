import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Visual treatments available for message bubbles.
enum ChatBubbleStyle {
  /// Large rounded corners.
  rounded,

  /// WhatsApp-like bubble shape.
  whatsapp,

  /// Telegram-like bubble shape.
  telegram,

  /// iMessage-like bubble shape.
  iMessage,

  /// Flat, low-decoration bubble.
  minimal,

  /// Messenger-like bubble shape.
  messenger,

  /// Discord-like bubble shape.
  discord,

  /// Slack-like bubble shape.
  slack,

  /// Signal-like bubble shape.
  signal,

  /// Nearly square corners.
  squared,

  /// Fully pill-shaped corners.
  pill
}

/// Controls built-in chat motion. Pass [ChatAnimations.disabled] for static UI.
@immutable
class ChatAnimations {
  /// Creates enabled motion with the supplied message duration and curve.
  const ChatAnimations(
      {this.enabled = true,
      this.messageDuration = const Duration(milliseconds: 260),
      this.curve = Curves.easeOutCubic});

  /// Creates a reduced-motion configuration with no message entrance motion.
  const ChatAnimations.disabled()
      : enabled = false,
        messageDuration = Duration.zero,
        curve = Curves.linear;

  /// Whether conversation widgets animate messages into view.
  final bool enabled;

  /// Duration used by each message entrance animation.
  final Duration messageDuration;

  /// Animation curve used by message entrance transitions.
  final Curve curve;
}

@immutable

/// Immutable visual tokens consumed by Global Chat widgets.
class ChatTheme extends ThemeExtension<ChatTheme> {
  /// Creates a theme extension used by Global Chat widgets.
  const ChatTheme(
      {required this.sentBubble,
      required this.receivedBubble,
      required this.composerColor,
      required this.wallpaperColor,
      this.radius = 18,
      this.bubbleStyle = ChatBubbleStyle.whatsapp,
      this.sentTextColor,
      this.receivedTextColor,
      this.animations = const ChatAnimations()});

  /// Background colour for messages sent by the current user.
  final Color sentBubble;

  /// Background colour for received messages.
  final Color receivedBubble;

  /// Background colour for the message composer.
  final Color composerColor;

  /// Fallback conversation canvas colour.
  final Color wallpaperColor;

  /// Base radius used by compatible bubble styles.
  final double radius;

  /// Default bubble design. Override per [ConversationScreen] if needed.
  final ChatBubbleStyle bubbleStyle;

  /// Optional text colour for sent messages.
  final Color? sentTextColor;

  /// Optional text colour for received messages.
  final Color? receivedTextColor;

  /// Default motion configuration for conversation screens.
  final ChatAnimations animations;

  /// A light WhatsApp-inspired preset.
  factory ChatTheme.light() => const ChatTheme(
      sentBubble: Color(0xFFD9FDD3),
      receivedBubble: Colors.white,
      composerColor: Colors.white,
      wallpaperColor: Color(0xFFEFF4F1));

  /// A dark WhatsApp-inspired preset.
  factory ChatTheme.dark() => const ChatTheme(
      sentBubble: Color(0xFF005C4B),
      receivedBubble: Color(0xFF202C33),
      composerColor: Color(0xFF202C33),
      wallpaperColor: Color(0xFF0B141A));

  /// A cool blue preset.
  factory ChatTheme.ocean() => const ChatTheme(
      sentBubble: Color(0xFFB9E6FF),
      receivedBubble: Colors.white,
      composerColor: Colors.white,
      wallpaperColor: Color(0xFFE9F7FF));

  /// A warm coral preset.
  factory ChatTheme.sunset() => const ChatTheme(
      sentBubble: Color(0xFFFFDBC7),
      receivedBubble: Colors.white,
      composerColor: Colors.white,
      wallpaperColor: Color(0xFFFFF3ED));

  /// A green preset.
  factory ChatTheme.forest() => const ChatTheme(
      sentBubble: Color(0xFFCBE9D6),
      receivedBubble: Colors.white,
      composerColor: Colors.white,
      wallpaperColor: Color(0xFFF0F8F1));

  /// A soft violet preset.
  factory ChatTheme.lavender() => const ChatTheme(
      sentBubble: Color(0xFFE4D9FF),
      receivedBubble: Colors.white,
      composerColor: Colors.white,
      wallpaperColor: Color(0xFFF7F3FF));

  /// A pink preset.
  factory ChatTheme.rose() => const ChatTheme(
      sentBubble: Color(0xFFFFD9E5),
      receivedBubble: Colors.white,
      composerColor: Colors.white,
      wallpaperColor: Color(0xFFFFF2F6));

  /// A high-contrast dark-blue preset.
  factory ChatTheme.midnight() => const ChatTheme(
      sentBubble: Color(0xFF304B73),
      receivedBubble: Color(0xFF1D2735),
      composerColor: Color(0xFF1D2735),
      wallpaperColor: Color(0xFF111827));

  /// A warm neutral preset.
  factory ChatTheme.sand() => const ChatTheme(
      sentBubble: Color(0xFFFFE4B8),
      receivedBubble: Colors.white,
      composerColor: Colors.white,
      wallpaperColor: Color(0xFFFFF8E9));

  /// A fresh mint preset.
  factory ChatTheme.mint() => const ChatTheme(
      sentBubble: Color(0xFFC9F3E5),
      receivedBubble: Colors.white,
      composerColor: Colors.white,
      wallpaperColor: Color(0xFFEFFFF9));
  @override
  ChatTheme copyWith(
          {Color? sentBubble,
          Color? receivedBubble,
          Color? composerColor,
          Color? wallpaperColor,
          double? radius,
          ChatBubbleStyle? bubbleStyle,
          Color? sentTextColor,
          Color? receivedTextColor,
          ChatAnimations? animations}) =>
      ChatTheme(
          sentBubble: sentBubble ?? this.sentBubble,
          receivedBubble: receivedBubble ?? this.receivedBubble,
          composerColor: composerColor ?? this.composerColor,
          wallpaperColor: wallpaperColor ?? this.wallpaperColor,
          radius: radius ?? this.radius,
          bubbleStyle: bubbleStyle ?? this.bubbleStyle,
          sentTextColor: sentTextColor ?? this.sentTextColor,
          receivedTextColor: receivedTextColor ?? this.receivedTextColor,
          animations: animations ?? this.animations);
  @override
  ChatTheme lerp(ThemeExtension<ChatTheme>? other, double t) {
    if (other is! ChatTheme) return this;
    return ChatTheme(
        sentBubble: Color.lerp(sentBubble, other.sentBubble, t)!,
        receivedBubble: Color.lerp(receivedBubble, other.receivedBubble, t)!,
        composerColor: Color.lerp(composerColor, other.composerColor, t)!,
        wallpaperColor: Color.lerp(wallpaperColor, other.wallpaperColor, t)!,
        radius: lerpDouble(radius, other.radius, t)!,
        bubbleStyle: t < .5 ? bubbleStyle : other.bubbleStyle,
        sentTextColor: Color.lerp(sentTextColor, other.sentTextColor, t),
        receivedTextColor:
            Color.lerp(receivedTextColor, other.receivedTextColor, t),
        animations: t < .5 ? animations : other.animations);
  }
}
