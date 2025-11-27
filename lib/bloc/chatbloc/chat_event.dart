import 'package:ludo/model/chat_message_model.dart';

abstract class ChatEvent {}

class LoadChatMessages extends ChatEvent {
  final String contactId;
  LoadChatMessages(this.contactId);
}

class SendMessage extends ChatEvent {
  final String text;
  SendMessage(this.text);
}

class ReceiveMessage extends ChatEvent {
  final ChatMessage message;
  ReceiveMessage(this.message);
}

class MarkMessagesAsRead extends ChatEvent {}

class DeleteMessage extends ChatEvent {
  final String messageId;
  DeleteMessage(this.messageId);
}

class StartTyping extends ChatEvent {}

class StopTyping extends ChatEvent {}
