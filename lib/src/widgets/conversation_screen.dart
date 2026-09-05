import 'package:flutter/material.dart';
import '../controller/chat_controller.dart';
import '../models/chat_models.dart';
import '../theme/chat_theme.dart';
import 'chat_composer.dart';

/// A complete message timeline and composer for one conversation.
class ConversationScreen extends StatefulWidget {
  /// Creates a complete conversation screen for [conversationId].
  const ConversationScreen(
      {super.key,
      required this.controller,
      required this.conversationId,
      this.appBarActionsBuilder,
      this.composerActionsBuilder,
      this.enableSwipeToReply = true,
      this.bubbleStyle,
      this.animations,
      this.showSearch = true,
      this.onMessageTap,
      this.onMessageDoubleTap});

  /// Controller that owns conversation data and host action callbacks.
  final ChatController controller;

  /// ID of the conversation displayed by this screen.
  final String conversationId;

  /// Host-owned controls, such as calls, profile, or settings.
  final List<Widget> Function(BuildContext context, ChatConversation chat)?
      appBarActionsBuilder;

  /// Host-owned composer controls, such as attachment, voice, GIF, or emoji.
  final List<Widget> Function(BuildContext context, ChatConversation chat)?
      composerActionsBuilder;

  /// Enables the built-in horizontal swipe-to-reply gesture.
  final bool enableSwipeToReply;

  /// Optional per-screen override for bubble styling.
  final ChatBubbleStyle? bubbleStyle;

  /// Optional per-screen override for animations.
  final ChatAnimations? animations;

  /// Shows search by default. Set false to remove the search UI.
  final bool showSearch;

  /// Called when a message bubble is tapped.
  final ValueChanged<ChatMessage>? onMessageTap;

  /// Called when a message bubble is double-tapped.
  final ValueChanged<ChatMessage>? onMessageDoubleTap;
  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  ChatMessage? _reply;
  bool _searching = false;
  String _query = '';
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final chat = widget.controller.byId(widget.conversationId);
        if (chat == null) {
          return const Scaffold(
              body: Center(child: Text('Conversation not found')));
        }
        final theme =
            Theme.of(context).extension<ChatTheme>() ?? ChatTheme.light();
        final results = _query.isEmpty
            ? chat.messages
            : widget.controller.searchMessages(chat.id, _query);
        final actions = <Widget>[
          if (widget.showSearch)
            IconButton(
                onPressed: () => setState(() => _searching = true),
                icon: const Icon(Icons.search)),
          ...?widget.appBarActionsBuilder?.call(context, chat),
        ];
        return Scaffold(
          appBar: AppBar(
              titleSpacing: 0,
              title: _searching
                  ? TextField(
                      controller: _search,
                      autofocus: true,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                          hintText: 'Search in ${chat.title}',
                          border: InputBorder.none))
                  : Text(chat.title),
              actions: _searching
                  ? [
                      if (_query.isNotEmpty)
                        Center(child: Text('${results.length}')),
                      IconButton(
                          onPressed: () => setState(() {
                                _searching = false;
                                _query = '';
                                _search.clear();
                              }),
                          icon: const Icon(Icons.close))
                    ]
                  : actions),
          body: Column(children: [
            if (_searching && _query.isNotEmpty)
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Text('${results.length} matching messages')),
            Expanded(
                child: Container(
                    color:
                        _wallpaper(theme, widget.controller.settings.wallpaper),
                    child: ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(12),
                        itemCount: results.length,
                        itemBuilder: (_, index) {
                          final message = results[results.length - 1 - index];
                          final bubble = _MessageBubble(
                              message: message,
                              mine: message.author.id ==
                                  widget.controller.currentUser.id,
                              theme: theme,
                              style: widget.bubbleStyle ?? theme.bubbleStyle,
                              query: _query,
                              allowReply: widget.enableSwipeToReply &&
                                  widget.controller.capabilities.replies,
                              allowReactions:
                                  widget.controller.capabilities.reactions,
                              onReply: () => setState(() => _reply = message),
                              onReact: (emoji) => widget.controller
                                  .react(chat.id, message.id, emoji),
                              onTap: widget.onMessageTap == null
                                  ? null
                                  : () => widget.onMessageTap!(message),
                              onDoubleTap: widget.onMessageDoubleTap == null
                                  ? null
                                  : () => widget.onMessageDoubleTap!(message));
                          final motion = widget.animations ?? theme.animations;
                          return motion.enabled
                              ? TweenAnimationBuilder<double>(
                                  key: ValueKey(message.id),
                                  tween: Tween(begin: 0, end: 1),
                                  duration: motion.messageDuration,
                                  curve: motion.curve,
                                  builder: (_, value, child) => Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                          offset: Offset(
                                              (message.author.id ==
                                                          widget.controller
                                                              .currentUser.id
                                                      ? 1
                                                      : -1) *
                                                  18 *
                                                  (1 - value),
                                              0),
                                          child: child)),
                                  child: bubble)
                              : bubble;
                        }))),
            ChatComposer(
                replyTo: _reply,
                onCancelReply: () => setState(() => _reply = null),
                onSend: (text) {
                  widget.controller.sendText(chat.id, text, replyTo: _reply);
                  setState(() => _reply = null);
                },
                leadingActions:
                    widget.composerActionsBuilder?.call(context, chat) ??
                        const []),
          ]),
        );
      });
  Color _wallpaper(ChatTheme theme, ChatWallpaper wall) => switch (wall) {
        ChatWallpaper.sunset => const Color(0xFFFFF0E8),
        ChatWallpaper.ocean => const Color(0xFFE6F7FF),
        ChatWallpaper.forest => const Color(0xFFEAF7EF),
        ChatWallpaper.lavender => const Color(0xFFF2EDFF),
        ChatWallpaper.rose => const Color(0xFFFFEDF4),
        ChatWallpaper.midnight => const Color(0xFF101827),
        ChatWallpaper.sand => const Color(0xFFFFF7E5),
        ChatWallpaper.aurora => const Color(0xFFE8FFF6),
        ChatWallpaper.graphite => const Color(0xFFECEFF1),
        ChatWallpaper.mint => const Color(0xFFE9FFF7),
        ChatWallpaper.doodles => const Color(0xFFF5F2E9),
        _ => theme.wallpaperColor
      };
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble(
      {required this.message,
      required this.mine,
      required this.theme,
      required this.style,
      required this.query,
      required this.allowReply,
      required this.allowReactions,
      required this.onReply,
      required this.onReact,
      this.onTap,
      this.onDoubleTap});
  final ChatMessage message;
  final bool mine, allowReply, allowReactions;
  final ChatTheme theme;
  final ChatBubbleStyle style;
  final String query;
  final VoidCallback onReply;
  final ValueChanged<String> onReact;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  @override
  Widget build(BuildContext context) {
    final content = Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: mine ? theme.sentBubble : theme.receivedBubble,
            borderRadius: BorderRadius.circular(_radius()),
            border: style == ChatBubbleStyle.minimal ||
                    style == ChatBubbleStyle.discord
                ? Border.all(color: Colors.black12)
                : null),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (message.replyTo case final reply?)
            Text(reply.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          if (message.isPinned)
            const Text('Pinned', style: TextStyle(fontSize: 11)),
          _Highlight(message.text, query),
          Text(_time(message.createdAt), style: const TextStyle(fontSize: 10))
        ]));
    return Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Dismissible(
            key: ValueKey(message.id),
            direction: allowReply
                ? DismissDirection.horizontal
                : DismissDirection.none,
            confirmDismiss: (_) async {
              onReply();
              return false;
            },
            background: const _Swipe(alignment: Alignment.centerLeft),
            secondaryBackground: const _Swipe(alignment: Alignment.centerRight),
            child: GestureDetector(
                onTap: onTap,
                onDoubleTap: onDoubleTap,
                onLongPress: allowReactions ? () => _sheet(context) : null,
                child: content)));
  }

  double _radius() => switch (style) {
        ChatBubbleStyle.minimal || ChatBubbleStyle.squared => 4,
        ChatBubbleStyle.pill => 28,
        ChatBubbleStyle.rounded => 24,
        ChatBubbleStyle.telegram => 16,
        ChatBubbleStyle.iMessage || ChatBubbleStyle.messenger => 22,
        ChatBubbleStyle.discord => 8,
        ChatBubbleStyle.slack => 12,
        ChatBubbleStyle.signal => 18,
        ChatBubbleStyle.whatsapp => theme.radius
      };
  void _sheet(BuildContext context) => showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
          child: Wrap(
              children: ['👍', '❤️', '😂', '😮', '😢', '🙏']
                  .map((e) => IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onReact(e);
                      },
                      icon: Text(e, style: const TextStyle(fontSize: 24))))
                  .toList())));
  String _time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _Highlight extends StatelessWidget {
  const _Highlight(this.text, this.query);
  final String text, query;
  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return Text(text);
    final r = RegExp(RegExp.escape(query), caseSensitive: false);
    final spans = <TextSpan>[];
    var pos = 0;
    for (final m in r.allMatches(text)) {
      if (m.start > pos) {
        spans.add(TextSpan(text: text.substring(pos, m.start)));
      }
      spans.add(TextSpan(
          text: text.substring(m.start, m.end),
          style: TextStyle(
              backgroundColor: Colors.amber.shade300,
              color: Colors.black,
              fontWeight: FontWeight.bold)));
      pos = m.end;
    }
    if (pos < text.length) spans.add(TextSpan(text: text.substring(pos)));
    return Text.rich(
        TextSpan(style: DefaultTextStyle.of(context).style, children: spans));
  }
}

class _Swipe extends StatelessWidget {
  const _Swipe({required this.alignment});
  final Alignment alignment;
  @override
  Widget build(BuildContext context) => Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: const Icon(Icons.reply));
}
