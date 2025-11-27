import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ludo/bloc/messagebloc/message_event.dart';
import 'package:ludo/bloc/messagebloc/message_state.dart';
import 'package:ludo/model/message_model.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  MessageBloc() : super(MessageInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<RefreshMessages>(_onRefreshMessages);
    on<SearchMessages>(_onSearchMessages);
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<MessageState> emit,
  ) async {
    emit(MessageLoading());
    await Future.delayed(Duration(milliseconds: 500));

    // Mock data - replace with actual API call
    final messages = _generateMockMessages();
    emit(MessageLoaded(messages: messages));
  }

  Future<void> _onRefreshMessages(
    RefreshMessages event,
    Emitter<MessageState> emit,
  ) async {
    await Future.delayed(Duration(milliseconds: 300));
    final messages = _generateMockMessages();
    emit(MessageLoaded(messages: messages));
  }

  Future<void> _onSearchMessages(
    SearchMessages event,
    Emitter<MessageState> emit,
  ) async {
    if (state is MessageLoaded) {
      final currentState = state as MessageLoaded;
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        emit(MessageLoaded(messages: currentState.messages));
      } else {
        final filtered = currentState.messages
            .where(
              (message) =>
                  message.senderName.toLowerCase().contains(query) ||
                  message.lastMessage.toLowerCase().contains(query),
            )
            .toList();
        emit(
          MessageLoaded(
            messages: currentState.messages,
            filteredMessages: filtered,
          ),
        );
      }
    }
  }

  List<Message> _generateMockMessages() {
    return [
      Message(
        id: '1',
        senderName: 'Sarah Johnson',
        senderAvatar: 'SJ',
        lastMessage: 'Hey! How are you doing today?',
        timestamp: DateTime.now().subtract(Duration(minutes: 5)),
        unreadCount: 3,
        isOnline: true,
      ),
      Message(
        id: '2',
        senderName: 'Mike Chen',
        senderAvatar: 'MC',
        lastMessage: 'Can we reschedule the meeting?',
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        unreadCount: 1,
        isOnline: true,
      ),
      Message(
        id: '3',
        senderName: 'Emily Rodriguez',
        senderAvatar: 'ER',
        lastMessage: 'Thanks for your help with the project!',
        timestamp: DateTime.now().subtract(Duration(hours: 5)),
        unreadCount: 0,
        isOnline: false,
      ),
      Message(
        id: '4',
        senderName: 'Alex Turner',
        senderAvatar: 'AT',
        lastMessage: 'Did you see the latest updates?',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
        unreadCount: 0,
        isOnline: true,
      ),
      Message(
        id: '5',
        senderName: 'Lisa Anderson',
        senderAvatar: 'LA',
        lastMessage: 'Looking forward to our collaboration',
        timestamp: DateTime.now().subtract(Duration(days: 2)),
        unreadCount: 0,
        isOnline: false,
      ),
      Message(
        id: '6',
        senderName: 'James Wilson',
        senderAvatar: 'JW',
        lastMessage: 'Great job on the presentation!',
        timestamp: DateTime.now().subtract(Duration(days: 3)),
        unreadCount: 0,
        isOnline: false,
      ),
    ];
  }
}
