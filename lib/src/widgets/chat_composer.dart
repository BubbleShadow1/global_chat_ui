import 'package:flutter/material.dart';
import '../models/chat_models.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer(
      {super.key,
      required this.onSend,
      this.leadingActions = const [],
      this.trailingActions = const [],
      this.replyTo,
      this.onCancelReply});
  final ValueChanged<String> onSend;
  final List<Widget> leadingActions;
  final List<Widget> trailingActions;
  final ChatMessage? replyTo;
  final VoidCallback? onCancelReply;
  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _text = TextEditingController();
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _send() {
    final value = _text.text;
    if (value.trim().isNotEmpty) {
      widget.onSend(value);
      _text.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      top: false,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (widget.replyTo case final reply?)
          Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.reply, size: 18),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(reply.text,
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: widget.onCancelReply)
              ])),
        Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Row(children: [
              ...widget.leadingActions,
              Expanded(
                  child: TextField(
                      controller: _text,
                      minLines: 1,
                      maxLines: 5,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                          hintText: 'Message',
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10)))),
              ...widget.trailingActions,
              if (_text.text.trim().isNotEmpty)
                IconButton(
                    tooltip: 'Send',
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: _send),
            ])),
      ]));
}
