class CallModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String? avatar;
  final DateTime timestamp;
  final CallType type;
  final CallStatus status;
  final Duration? duration;

  const CallModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.avatar,
    required this.timestamp,
    required this.type,
    required this.status,
    this.duration,
  });

  CallModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? avatar,
    DateTime? timestamp,
    CallType? type,
    CallStatus? status,
    Duration? duration,
  }) {
    return CallModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      duration: duration ?? this.duration,
    );
  }
}

enum CallType { incoming, outgoing, missed }

enum CallStatus { answered, missed, rejected, busy }
