import 'package:ludo/model/message_model.dart';

abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessageLoading extends MessageState {}

class MessageLoaded extends MessageState {
  final List<Message> messages;
  final List<Message> filteredMessages;

  MessageLoaded({required this.messages, List<Message>? filteredMessages})
    : filteredMessages = filteredMessages ?? messages;
}

class MessageError extends MessageState {
  final String error;
  MessageError(this.error);
}
