abstract class CallEvent {
  CallEvent();
}

class LoadCallHistory extends CallEvent {}

class MakeCall extends CallEvent {
  final String phoneNumber;
  final String name;
  final String? avatar;

  MakeCall({this.avatar, required this.name, required this.phoneNumber});
}

class AnswerCall extends CallEvent {
  final String callId;
  AnswerCall({required this.callId});
}

class EndCall extends CallEvent {
  final String callId;
  EndCall({required this.callId});
}

class ToggleMute extends CallEvent {}

class ToggleSpeaker extends CallEvent {}

class ToggleVideo extends CallEvent {}

class UpdateCallDuration extends CallEvent {
  final Duration duration;
  UpdateCallDuration(Duration newDuration, {required this.duration});
}

class IncomingCall extends CallEvent {
  final String phoneNumber;
  final String name;
  final String? avatar;

  IncomingCall({
    this.avatar,
    required this.name,
    required this.phoneNumber,
    required String call,
  });
}
