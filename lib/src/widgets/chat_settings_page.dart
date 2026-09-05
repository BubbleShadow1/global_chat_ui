import 'package:flutter/material.dart';
import '../controller/chat_controller.dart';
import '../models/chat_models.dart';

/// A settings page for editing [ChatController.settings].
class ChatSettingsPage extends StatelessWidget {
  /// Creates a settings screen bound to [controller].
  const ChatSettingsPage({super.key, required this.controller});

  /// Controller whose [ChatController.settings] this page displays and edits.
  final ChatController controller;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final s = controller.settings;
          return Scaffold(
              appBar: AppBar(title: const Text('Chat settings')),
              body: ListView(children: [
                const _Section('Privacy'),
                SwitchListTile.adaptive(
                    key: const Key('read_receipts_toggle'),
                    title: const Text('Read receipts'),
                    subtitle: const Text('Show when you have read messages'),
                    value: s.readReceipts,
                    onChanged: (v) =>
                        controller.updateSettings(s.copyWith(readReceipts: v))),
                SwitchListTile.adaptive(
                    key: const Key('typing_indicators_toggle'),
                    title: const Text('Typing indicators'),
                    subtitle: const Text('Let people know when you are typing'),
                    value: s.typingIndicators,
                    onChanged: (v) => controller
                        .updateSettings(s.copyWith(typingIndicators: v))),
                const _Section('Messages'),
                ListTile(
                    title: const Text('Disappearing messages'),
                    subtitle: Text(_expiry(s.disappearingMessages)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final result = await _durationPicker(context);
                      controller.updateSettings(s.copyWith(
                          disappearingMessages: result,
                          clearDisappearing: result == null));
                    }),
                SwitchListTile.adaptive(
                    key: const Key('enter_to_send_toggle'),
                    title: const Text('Enter to send'),
                    subtitle: const Text(
                        'Press Enter to send instead of adding a new line'),
                    value: s.enterToSend,
                    onChanged: (v) =>
                        controller.updateSettings(s.copyWith(enterToSend: v))),
                SwitchListTile.adaptive(
                    key: const Key('auto_download_toggle'),
                    title: const Text('Auto-download media'),
                    subtitle:
                        const Text('Download photos and files automatically'),
                    value: s.autoDownloadMedia,
                    onChanged: (v) => controller
                        .updateSettings(s.copyWith(autoDownloadMedia: v))),
                const _Section('Appearance'),
                ListTile(
                    key: const Key('wallpaper_picker'),
                    title: const Text('Chat wallpaper'),
                    subtitle: Text(_pretty(s.wallpaper.name)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final selected = await _wallpaperPicker(context);
                      if (selected != null) {
                        controller
                            .updateSettings(s.copyWith(wallpaper: selected));
                      }
                    }),
              ]));
        },
      );
  static Future<Duration?> _durationPicker(BuildContext context) =>
      showModalBottomSheet<Duration?>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (ctx) => _Sheet(
              title: 'Disappearing messages',
              child: ListView(children: [
                ListTile(
                    title: const Text('Off'), onTap: () => Navigator.pop(ctx)),
                ...[
                  const Duration(hours: 24),
                  const Duration(days: 7),
                  const Duration(days: 90)
                ].map((d) => ListTile(
                    title: Text(_expiry(d)),
                    onTap: () => Navigator.pop(ctx, d)))
              ])));
  static Future<ChatWallpaper?> _wallpaperPicker(BuildContext context) =>
      showModalBottomSheet<ChatWallpaper>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (ctx) => _Sheet(
              title: 'Chat wallpaper',
              child: ListView.separated(
                  itemCount: ChatWallpaper.values.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final wall = ChatWallpaper.values[index];
                    return ListTile(
                        title: Text(_pretty(wall.name)),
                        onTap: () => Navigator.pop(ctx, wall));
                  })));
  static String _expiry(Duration? value) => value == null
      ? 'Off'
      : value.inDays > 0
          ? '${value.inDays} days'
          : '${value.inHours} hours';
  static String _pretty(String value) => value
      .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
      .trimLeft();
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => SafeArea(
      child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .72,
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(title,
                        style: Theme.of(context).textTheme.titleLarge))),
            const Divider(height: 1),
            Expanded(child: child)
          ])));
}

class _Section extends StatelessWidget {
  const _Section(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 6),
      child: Text(text.toUpperCase(),
          style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12)));
}
