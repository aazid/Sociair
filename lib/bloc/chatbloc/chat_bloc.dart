import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ludo/bloc/chatbloc/chat_event.dart';
import 'package:ludo/bloc/chatbloc/chat_state.dart';
import 'package:ludo/model/chat_message_model.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<LoadChatMessages>(_onLoadChatMessages);
    on<SendMessage>(_onSendMessage);
    on<ReceiveMessage>(_onReceiveMessage);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<DeleteMessage>(_onDeleteMessage);
    on<StartTyping>(_onStartTyping);
    on<StopTyping>(_onStopTyping);
  }

  Future<void> _onLoadChatMessages(
    LoadChatMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    await Future.delayed(Duration(milliseconds: 500));

    // Mock data - replace with actual API call
    final messages = _generateMockMessages();
    emit(
      ChatLoaded(
        messages: messages,
        contactName: 'Sarah Johnson',
        isOnline: true,
      ),
    );
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;

      // Create new message
      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: event.text,
        timestamp: DateTime.now(),
        isSentByMe: true,
        status: MessageStatus.sending,
      );

      // Add message with sending status
      final updatedMessages = [...currentState.messages, newMessage];
      if (emit.isDone) return;
      emit(currentState.copyWith(messages: updatedMessages));

      // Simulate network delay
      await Future.delayed(Duration(milliseconds: 500));

      // Update message status to sent
      if (emit.isDone) return;
      final sentMessage = newMessage.copyWith(status: MessageStatus.sent);
      final sentMessages = updatedMessages
          .map((m) => m.id == newMessage.id ? sentMessage : m)
          .toList();
      emit(currentState.copyWith(messages: sentMessages));

      // Simulate message delivered
      await Future.delayed(Duration(milliseconds: 300));
      if (emit.isDone) return;
      final deliveredMessage = sentMessage.copyWith(
        status: MessageStatus.delivered,
      );
      final deliveredMessages = sentMessages
          .map((m) => m.id == newMessage.id ? deliveredMessage : m)
          .toList();
      emit(currentState.copyWith(messages: deliveredMessages));

      // Simulate auto-reply after 2 seconds
      await Future.delayed(Duration(seconds: 2));
      if (emit.isDone) return;
      await _simulateReply(emit);
    }
  }

  Future<void> _simulateReply(Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) return;
    final currentState = state as ChatLoaded;

    // Simulate typing indicator
    if (emit.isDone) return;
    emit(currentState.copyWith(isTyping: true));
    await Future.delayed(Duration(milliseconds: 1500));

    // Generate random reply
    final replies = [
      "That's great! 😊",
      "Thanks for letting me know!",
      "Sounds good to me 👍",
      "I'll get back to you on that.",
      "Perfect! Let's do it.",
      "Looking forward to it!",
    ];

    final replyMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: (replies..shuffle()).first,
      timestamp: DateTime.now(),
      isSentByMe: false,
      status: MessageStatus.read,
    );

    // Get fresh state
    if (state is! ChatLoaded) return;
    final freshState = state as ChatLoaded;
    final updatedMessages = [...freshState.messages, replyMessage];

    if (emit.isDone) return;
    emit(freshState.copyWith(messages: updatedMessages, isTyping: false));
  }

  Future<void> _onReceiveMessage(
    ReceiveMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final updatedMessages = [...currentState.messages, event.message];
      emit(currentState.copyWith(messages: updatedMessages));
    }
  }

  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsRead event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final updatedMessages = currentState.messages
          .map((m) => m.copyWith(isRead: true))
          .toList();
      emit(currentState.copyWith(messages: updatedMessages));
    }
  }

  Future<void> _onDeleteMessage(
    DeleteMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final updatedMessages = currentState.messages
          .where((m) => m.id != event.messageId)
          .toList();
      emit(currentState.copyWith(messages: updatedMessages));
    }
  }

  Future<void> _onStartTyping(
    StartTyping event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      emit(currentState.copyWith(isTyping: true));
    }
  }

  Future<void> _onStopTyping(StopTyping event, Emitter<ChatState> emit) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      emit(currentState.copyWith(isTyping: false));
    }
  }

  List<ChatMessage> _generateMockMessages() {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: '1',
        text: 'Hey! How are you doing?',
        timestamp: now.subtract(Duration(hours: 2)),
        isSentByMe: false,
        isRead: true,
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '2',
        text: "I'm doing great! Thanks for asking 😊",
        timestamp: now.subtract(Duration(hours: 2, minutes: 58)),
        isSentByMe: true,
        isRead: true,
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '3',
        text: 'Did you finish the project we discussed?',
        timestamp: now.subtract(Duration(hours: 1, minutes: 30)),
        isSentByMe: false,
        isRead: true,
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '4',
        text:
            "Yes! I just submitted it this morning. Would you like to review it?",
        timestamp: now.subtract(Duration(hours: 1, minutes: 25)),
        isSentByMe: true,
        isRead: true,
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '5',
        text: "That would be perfect! Can you send me the link?",
        timestamp: now.subtract(Duration(minutes: 45)),
        isSentByMe: false,
        isRead: true,
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '6',
        text: "Sure, I'll send it right away! 🚀",
        timestamp: now.subtract(Duration(minutes: 40)),
        isSentByMe: true,
        isRead: true,
        status: MessageStatus.delivered,
      ),
    ];
  }
}
