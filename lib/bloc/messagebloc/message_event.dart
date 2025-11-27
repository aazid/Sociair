abstract class MessageEvent {}

class LoadMessages extends MessageEvent {}

class RefreshMessages extends MessageEvent {}

class SearchMessages extends MessageEvent {
  final String query;
  SearchMessages(this.query);
}
