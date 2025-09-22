import './room.dart';
import './user.dart';

enum RoomEventType { join, leave, message, closed }

class RoomEvent {
  final RoomEventType type;
  final Room room;
  final User? user;
  final Object? payload;
  final DateTime timestamp;

  RoomEvent({
    required this.type,
    required this.room,
    this.user,
    this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'roomId': room.id,
    'userId': user?.id,
    'payload': payload,
    'timestamp': timestamp.toIso8601String(),
  };
}
