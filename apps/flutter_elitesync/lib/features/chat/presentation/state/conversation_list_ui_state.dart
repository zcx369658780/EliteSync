import 'package:flutter_elitesync/features/chat/domain/entities/conversation_entity.dart';

class ConversationListUiState {
  const ConversationListUiState({this.items = const [], this.error});
  final List<ConversationEntity> items;
  final String? error;
}
