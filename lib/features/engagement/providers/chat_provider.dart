import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_model.dart';
import 'wishlist_provider.dart';

final conversationsProvider = AsyncNotifierProvider<ConversationsNotifier, List<ConversationModel>>(() {
  return ConversationsNotifier();
});

class ConversationsNotifier extends AsyncNotifier<List<ConversationModel>> {
  @override
  Future<List<ConversationModel>> build() async {
    final repo = ref.read(engagementRepositoryProvider);
    return repo.getConversations('user123'); // Mocking current user ID
  }
}

class CurrentConversationIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setId(String? id) {
    state = id;
  }
}

// Global state to track which conversation is currently active
final currentConversationIdProvider = NotifierProvider<CurrentConversationIdNotifier, String?>(
  CurrentConversationIdNotifier.new,
);

final chatMessagesProvider = AsyncNotifierProvider<ChatMessagesNotifier, List<MessageModel>>(() {
  return ChatMessagesNotifier();
});

class ChatMessagesNotifier extends AsyncNotifier<List<MessageModel>> {
  @override
  Future<List<MessageModel>> build() async {
    final id = ref.watch(currentConversationIdProvider);
    if (id == null) return [];
    
    final repo = ref.read(engagementRepositoryProvider);
    return repo.getMessages(id);
  }

  Future<void> sendMessage(String text, {String? imageUrl}) async {
    final id = ref.read(currentConversationIdProvider);
    if (id == null) return;
    
    final repo = ref.read(engagementRepositoryProvider);
    
    final tempMsg = MessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'user123',
      text: text,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
    );

    final previousState = state.value ?? [];
    state = AsyncData([...previousState, tempMsg]);

    try {
      await repo.sendMessage(id, 'mock_item_id', text);
      state = AsyncData([...previousState, tempMsg]);
    } catch (e) {
      state = AsyncData(previousState);
    }
  }
}
