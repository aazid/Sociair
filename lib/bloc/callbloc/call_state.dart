import 'package:ludo/model/call_model.dart';

abstract class CallState {
  const CallState();
}

class CallInitial extends CallState {}

class CallLoading extends CallState {}

class CallHistoryLoaded extends CallState {
  final List<CallModel> calls;
  CallHistoryLoaded({required this.calls});
}

class CallInProgress extends CallState {
  final CallModel activeCall;
  CallInProgress({required this.activeCall});
}

class CallEnded extends CallState {
  final CallModel call;
  final String reason;
  CallEnded({required this.call, required this.reason});
}

class CallError extends CallState {
  final String message;
  CallError({required this.message});
}

class IncomingCallState extends CallState {
  final CallModel call;
  IncomingCallState({required this.call});
}
