import 'package:ludo/bloc/callbloc/call_bloc.dart';
import 'package:ludo/model/call_model.dart';

class ActiveCall {
  final CallModel call;
  final Duration duration;
  final CallConnectionState state;
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isVideoEnabled;

  ActiveCall({
    required this.call,
    required this.duration,
    required this.state,
    this.isMuted = false,
    this.isSpeakerOn = false,
    this.isVideoEnabled = false,
  });

  ActiveCall copyWith({
    CallModel? call,
    Duration? duration,
    CallConnectionState? state,
    bool? isMuted,
    bool? isSpeakerOn,
    bool? isVideoEnabled,
  }) {
    return ActiveCall(
      call: call ?? this.call,
      duration: duration ?? this.duration,
      state: state ?? this.state,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
    );
  }
}
