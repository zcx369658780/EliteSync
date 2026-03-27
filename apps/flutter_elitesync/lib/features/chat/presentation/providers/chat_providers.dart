import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync/features/chat/data/datasource/chat_remote_data_source.dart';
import 'package:flutter_elitesync/features/chat/data/datasource/chat_socket_data_source.dart';
import 'package:flutter_elitesync/features/chat/data/mapper/chat_mapper.dart';
import 'package:flutter_elitesync/features/chat/data/repository/chat_repository_impl.dart';
import 'package:flutter_elitesync/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync/features/chat/domain/repository/chat_repository.dart';
import 'package:flutter_elitesync/features/chat/domain/usecases/get_conversations_usecase.dart';
import 'package:flutter_elitesync/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:flutter_elitesync/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:flutter_elitesync/features/chat/presentation/state/conversation_list_ui_state.dart';
import 'package:flutter_elitesync/shared/providers/app_providers.dart';

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  final env = ref.watch(appEnvProvider);
  return ChatRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
    useMock: env.useMockChat,
  );
});

final chatSocketDataSourceProvider = Provider<ChatSocketDataSource>((
  ref,
) => ChatSocketDataSource());

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    remote: ref.watch(chatRemoteDataSourceProvider),
    socket: ref.watch(chatSocketDataSourceProvider),
    mapper: const ChatMapper(),
  );
});

final getConversationsUseCaseProvider = Provider<GetConversationsUseCase>(
  (ref) => GetConversationsUseCase(ref.watch(chatRepositoryProvider)),
);
final getMessagesUseCaseProvider = Provider<GetMessagesUseCase>(
  (ref) => GetMessagesUseCase(ref.watch(chatRepositoryProvider)),
);
final sendMessageUseCaseProvider = Provider<SendMessageUseCase>(
  (ref) => SendMessageUseCase(ref.watch(chatRepositoryProvider)),
);
final conversationListProvider = FutureProvider<ConversationListUiState>((
  ref,
) async {
  try {
    final items = await ref.read(getConversationsUseCaseProvider).call();
    return ConversationListUiState(items: items);
  } catch (e) {
    return ConversationListUiState(error: e.toString());
  }
});

final chatRoomMessagesProvider = FutureProvider.family<List<MessageEntity>, String>((
  ref,
  conversationId,
) async {
  return ref.read(getMessagesUseCaseProvider).call(conversationId);
});

final chatConnectionProvider = Provider<String>((ref) => 'connected');
