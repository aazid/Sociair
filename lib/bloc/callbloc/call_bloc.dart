import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ludo/model/active_call.dart';
import '../../model/call_model.dart';
import 'call_event.dart';
import 'call_state.dart';

enum CallConnectionState { dialing, ringing, connected, ended }

class CallBloc extends Bloc<CallEvent, CallState> {
  List<CallModel> _callHistory = [];
  ActiveCall? _activeCall;
  Timer? _callTimer;
  final Random _random = Random();

  CallBloc() : super(CallInitial() as CallState) {
    on<LoadCallHistory>(_onLoadCallHistory);
    on<MakeCall>(_onMakeCall);
    on<AnswerCall>(_onAnswerCall);
    on<EndCall>(_onEndCall);
    on<ToggleMute>(_onToggleMute);
    on<ToggleSpeaker>(_onToggleSpeaker);
    on<ToggleVideo>(_onToggleVideo);
    on<UpdateCallDuration>(_onUpdateCallDuration);
    on<IncomingCall>(_onIncomingCall);
  }

  void _onLoadCallHistory(
    LoadCallHistory event,
    Emitter<CallState> emit,
  ) async {
    try {
      emit(CallLoading());
      await Future.delayed(const Duration(milliseconds: 500));

      if (_callHistory.isEmpty) {
        _generateRandomCallHistory();
      }

      emit(CallHistoryLoaded(calls: List.from(_callHistory)));
    } catch (e) {
      emit(CallError(message: 'Failed to load call history: ${e.toString()}'));
    }
  }

  void _onMakeCall(MakeCall event, Emitter<CallState> emit) async {
    try {
      final call = CallModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.name,
        phoneNumber: event.phoneNumber,
        avatar: event.avatar,
        timestamp: DateTime.now(),
        type: CallType.outgoing,
        status: CallStatus.answered,
      );

      _activeCall = ActiveCall(
        call: call,
        duration: Duration.zero,
        state: CallConnectionState.dialing,
      );

      emit(CallInProgress(activeCall: _activeCall!.call));

      // Simulate call connection
      await Future.delayed(const Duration(seconds: 2));

      if (_activeCall != null && !isClosed) {
        _activeCall = _activeCall!.copyWith(
          state: CallConnectionState.connected,
        );
        emit(CallInProgress(activeCall: _activeCall!.call));
        _startCallTimer();
      }
    } catch (e) {
      emit(CallError(message: 'Failed to make call: ${e.toString()}'));
    }
  }

  void _onAnswerCall(AnswerCall event, Emitter<CallState> emit) {
    try {
      if (_activeCall?.call.id == event.callId) {
        _activeCall = _activeCall!.copyWith(
          state: CallConnectionState.connected,
        );
        emit(CallInProgress(activeCall: _activeCall!.call));
        _startCallTimer();
      }
    } catch (e) {
      emit(CallError(message: 'Failed to answer call: ${e.toString()}'));
    }
  }

  void _onEndCall(EndCall event, Emitter<CallState> emit) {
    try {
      if (_activeCall != null) {
        _callTimer?.cancel();

        final endedCall = _activeCall!.call.copyWith(
          duration: _activeCall!.duration,
          status: CallStatus.answered,
        );

        _callHistory.insert(0, endedCall);

        emit(CallEnded(call: endedCall, reason: 'Call ended'));
        _activeCall = null;

        // Return to call history after a delay
        Timer(const Duration(seconds: 2), () {
          if (!isClosed) {
            add(LoadCallHistory());
          }
        });
      }
    } catch (e) {
      emit(CallError(message: 'Failed to end call: ${e.toString()}'));
    }
  }

  void _onToggleMute(ToggleMute event, Emitter<CallState> emit) {
    if (_activeCall != null) {
      _activeCall = _activeCall!.copyWith(isMuted: !_activeCall!.isMuted);
      emit(CallInProgress(activeCall: _activeCall!.call));
    }
  }

  void _onToggleSpeaker(ToggleSpeaker event, Emitter<CallState> emit) {
    if (_activeCall != null) {
      _activeCall = _activeCall!.copyWith(
        isSpeakerOn: !_activeCall!.isSpeakerOn,
      );
      emit(CallInProgress(activeCall: _activeCall!.call));
    }
  }

  void _onToggleVideo(ToggleVideo event, Emitter<CallState> emit) {
    if (_activeCall != null) {
      _activeCall = _activeCall!.copyWith(
        isVideoEnabled: !_activeCall!.isVideoEnabled,
      );
      emit(CallInProgress(activeCall: _activeCall!.call));
    }
  }

  void _onUpdateCallDuration(
    UpdateCallDuration event,
    Emitter<CallState> emit,
  ) {
    if (_activeCall != null) {
      _activeCall = _activeCall!.copyWith(duration: event.duration);
      emit(CallInProgress(activeCall: _activeCall!.call));
    }
  }

  void _onIncomingCall(IncomingCall event, Emitter<CallState> emit) {
    try {
      final call = CallModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.name,
        phoneNumber: event.phoneNumber,
        avatar: event.avatar,
        timestamp: DateTime.now(),
        type: CallType.incoming,
        status: CallStatus.answered,
      );

      _activeCall = ActiveCall(
        call: call,
        duration: Duration.zero,
        state: CallConnectionState.ringing,
      );

      emit(IncomingCallState(call: call));
    } catch (e) {
      emit(
        CallError(message: 'Failed to handle incoming call: ${e.toString()}'),
      );
    }
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeCall != null && !isClosed) {
        final newDuration = Duration(seconds: timer.tick);
        add(
          UpdateCallDuration(
            newDuration,
            duration: Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  void _generateRandomCallHistory() {
    final contacts = [
      {'name': 'John Doe', 'phone': '+1 234 567 8901'},
      {'name': 'Jane Smith', 'phone': '+1 234 567 8902'},
      {'name': 'Alex Johnson', 'phone': '+1 234 567 8903'},
      {'name': 'Sarah Wilson', 'phone': '+1 234 567 8904'},
      {'name': 'Mike Brown', 'phone': '+1 234 567 8905'},
      {'name': 'Emily Davis', 'phone': '+1 234 567 8906'},
      {'name': 'Chris Lee', 'phone': '+1 234 567 8907'},
      {'name': 'Lisa Garcia', 'phone': '+1 234 567 8908'},
    ];

    for (int i = 0; i < 12; i++) {
      final contact = contacts[_random.nextInt(contacts.length)];
      final types = [CallType.incoming, CallType.outgoing, CallType.missed];
      final statuses = [
        CallStatus.answered,
        CallStatus.missed,
        CallStatus.rejected,
      ];

      _callHistory.add(
        CallModel(
          id: (DateTime.now().millisecondsSinceEpoch + i).toString(),
          name: contact['name']!,
          phoneNumber: contact['phone']!,
          timestamp: DateTime.now().subtract(
            Duration(hours: _random.nextInt(72), minutes: _random.nextInt(60)),
          ),
          type: types[_random.nextInt(types.length)],
          status: statuses[_random.nextInt(statuses.length)],
          duration: _random.nextBool()
              ? Duration(seconds: _random.nextInt(3600))
              : null,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _callTimer?.cancel();
    return super.close();
  }
}
