import 'package:ludo/model/chat_message_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final String contactName;
  final bool isOnline;

  ChatLoaded({
    required this.messages,
    this.isTyping = false,
    this.contactName = '',
    this.isOnline = false,
  });

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    String? contactName,
    bool? isOnline,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      contactName: contactName ?? this.contactName,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class ChatError extends ChatState {
  final String error;
  ChatError(this.error);
}
