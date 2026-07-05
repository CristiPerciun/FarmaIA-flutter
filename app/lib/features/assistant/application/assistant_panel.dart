import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/chat_message.dart';
import 'chat_controller.dart';

/// Desktop 70/30 panel state (§12.6, step 4B.5). The conversation itself
/// lives in [chatControllerProvider] and survives open/close; this tracks
/// only visibility and the unread badge shown on the floating pill.
class AssistantPanelState {
  const AssistantPanelState({this.isOpen = false, this.unread = 0});

  final bool isOpen;
  final int unread;

  AssistantPanelState copyWith({bool? isOpen, int? unread}) =>
      AssistantPanelState(
        isOpen: isOpen ?? this.isOpen,
        unread: unread ?? this.unread,
      );
}

final assistantPanelProvider =
    NotifierProvider<AssistantPanelNotifier, AssistantPanelState>(
      AssistantPanelNotifier.new,
    );

class AssistantPanelNotifier extends Notifier<AssistantPanelState> {
  @override
  AssistantPanelState build() {
    // Replies that arrive while the panel is closed bump the pill badge.
    ref.listen(chatControllerProvider, (previous, next) {
      final prevCount = previous?.messages.length ?? 0;
      final grew = next.messages.length > prevCount;
      final lastIsAssistant =
          next.messages.isNotEmpty &&
          next.messages.last.role == ChatRole.assistant;
      if (grew && lastIsAssistant && !state.isOpen) {
        state = state.copyWith(unread: state.unread + 1);
      }
    });
    return const AssistantPanelState();
  }

  void show() => state = const AssistantPanelState(isOpen: true);
  void hide() => state = state.copyWith(isOpen: false);
  void toggle() => state.isOpen ? hide() : show();
}
