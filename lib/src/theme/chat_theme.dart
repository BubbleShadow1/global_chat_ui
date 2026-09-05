import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Visual treatments available for message bubbles.
enum ChatBubbleStyle {
  rounded,
  whatsapp,
  telegram,
  iMessage,
  minimal,
  messenger,
  discord,
  slack,
  signal,
  squared,
  pill
}

/// Controls built-in chat motion. Pass [ChatAnimations.disabled] for static UI.
@immutable
class ChatAnimations {
  const ChatAnimations(
      {this.enabled = true,
      this.messageDuration = const Duration(milliseconds: 260),
      this.curve = Curves.easeOutCubic});
  const ChatAnimations.disabled()
      : enabled = false,
        messageDuration = Duration.zero,
        curve = Curves.linear;
  final bool enabled;
  final Duration messageDuration;
  final Curve curve;
}

@immutable
class ChatTheme extends ThemeExtension<ChatTheme> {
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
  final Color sentBubble;
  final Color receivedBubble;
  final Color composerColor;
  final Color wallpaperColor;
  final double radius;

  /// Default bubble design. Override per [ConversationScreen] if needed.
  final ChatBubbleStyle bubbleStyle;
  final Color? sentTextColor;
  final Color? receivedTextColor;
  final ChatAnimations animations;
  factory ChatTheme.light() => const ChatTheme(
      sentBubble: Color(0xFFD9FDD3),
      receivedBubble: Colors.white,
      composerColor: Colors.white,
      wallpaperColor: Color(0xFFEFF4F1));
  factory ChatTheme.dark() => const ChatTheme(
      sentBubble: Color(0xFF005C4B),
      receivedBubble: Color(0xFF202C33),
      composerColor: Color(0xFF202C33),
      wallpaperColor: Color(0xFF0B141A));
  factory ChatTheme.ocean() => const ChatTheme(
      sentBubble: Color(0xFFB9E6FF),
      receivedBubble: Colors.white,
      composerColor: Colors.white,
      wallpaperColor: Color(0xFFE9F7FF));
  factory ChatTheme.sunset() => const ChatTheme(
      sentBubble: Color(0xFFFFDBC7),
      receivedBubble: Colors.white,
      composerColor: Colors.white,
      wallpaperColor: Color(0xFFFFF3ED));
  factory ChatTheme.forest() => const ChatTheme(
      sentBubble: Color(0xFFCBE9D6),
      receivedBubble: Colors.white,
      composerColor: Colors.white,
      wallpaperColor: Color(0xFFF0F8F1));
  factory ChatTheme.lavender() => const ChatTheme(
      sentBubble: Color(0xFFE4D9FF),
      receivedBubble: Colors.white,
      composerColor: Colors.white,
      wallpaperColor: Color(0xFFF7F3FF));
  factory ChatTheme.rose() => const ChatTheme(
      sentBubble: Color(0xFFFFD9E5),
      receivedBubble: Colors.white,
      composerColor: Colors.white,
      wallpaperColor: Color(0xFFFFF2F6));
  factory ChatTheme.midnight() => const ChatTheme(
      sentBubble: Color(0xFF304B73),
      receivedBubble: Color(0xFF1D2735),
      composerColor: Color(0xFF1D2735),
      wallpaperColor: Color(0xFF111827));
  factory ChatTheme.sand() => const ChatTheme(
      sentBubble: Color(0xFFFFE4B8),
      receivedBubble: Colors.white,
      composerColor: Colors.white,
      wallpaperColor: Color(0xFFFFF8E9));
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
