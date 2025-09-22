import './room.dart';
import './user.dart';

class RoomManager {
  RoomManager._();
  static final RoomManager instance = RoomManager._();

  final Map<RoomId, Room> _rooms = {};

  Room getAnyRoom() {
    if (_rooms.isNotEmpty) {
      print('Found existing room: ${_rooms.values.first.topic}');

      return _rooms.values.first;

    } else {
      final newRoom = Room('default-room', topic: 'default-topic');
      print('Created new room: ${newRoom.topic}');

      _rooms[newRoom.id] = newRoom;

      return newRoom;
    }

  }

  /// Get existing room or create a new one.
  Room getOrCreate(RoomId id, { String? topic }) {
    return _rooms.putIfAbsent(id, () => Room(id, topic: topic));
  }

  Room? find(RoomId id) => _rooms[id];

  bool removeIfEmpty(RoomId id) {
    final room = _rooms[id];

    if (room == null) {
      return false;
    }
    
    if (room.memberCount == 0) {
      room.close();
      _rooms.remove(id);

      print('Removed empty room $id');

      return true;
    }

    return false;
  }

  List<Room> allRooms() => List.unmodifiable(_rooms.values);

  Room join(RoomId id, User user, { String? topic }) {
    final room = getOrCreate(id, topic: topic);

    room.join(user);

    print('DEBUG: User ${user.username} joined room $id');

    broadcast(id, '${user.username} has joined the room.', from: user);

    return room;
  }

  bool leave(RoomId id, User user) {
    final room = _rooms[id];

    if (room == null) {
      return false;
    }

    final removed = room.leave(user);

    if (removed) {
      broadcast(id, '${user.username} has left the room.', from: user);
    }

    if (room.memberCount == 0) {
      removeIfEmpty(id);
    }

    return removed;
  }

  void removeUserEverywhere(User user) {
    final toCheck = List<Room>.from(_rooms.values);

    for (final room in toCheck) {
      final removed = leave(room.id, user);

      if (removed && room.memberCount == 0) {
        removeIfEmpty(room.id);
      }
    }
  }

  List<Room> roomsOf(User user) {
    return _rooms.values.where((room) => room.contains(user)).toList(growable: false);
  }

  void broadcast(RoomId id, Object payload, { User? from }) {
    final room = _rooms[id];

    if (room == null) {
      print('No room with id $id found for broadcasting.');
      return;
    }

    print('Broadcasting in room $id');

    room.broadcast(payload, from: from);
  }

  void closeAll() {
    for (final room in _rooms.values) {
      room.close();
    }
    
    _rooms.clear();
  }
}

// class RoomEventForwarder {
//   final Room room;
//   final void Function(User user, Map<String, dynamic> data) deliver;

//   late final StreamSubscription _sub;

//   RoomEventForwarder(this.room, this.deliver) {
//     _sub = room.events.listen(_forward);
//   }

//   void _forward(RoomEvent e) {
//     // Example: Only forward message events; adjust as needed.
//     if (e.type == RoomEventType.message) {
//       final msg = {
//         'roomId': room.id,
//         'type': 'room_message',
//         'from': e.user?.id,
//         'payload': e.payload,
//         'ts': e.timestamp.toIso8601String(),
//       };

//       for (final member in room.members) {
//         deliver(member, msg);
//       }
//     }
//   }

//   Future<void> dispose() async {
//     await _sub.cancel();
//   }
// }
