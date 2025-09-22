import 'dart:async';

import './user.dart';
import './room_event.dart';

typedef RoomId = String;

/// Represents a chat room holding a set of users and emitting events.
class Room {
  final RoomId id;
  final Set<User> _members = <User>{};
  final StreamController<RoomEvent> _events = StreamController<RoomEvent>.broadcast();

  String? topic;

  Room(this.id, { this.topic });

  Stream<RoomEvent> get events => _events.stream;

  List<User> get members => List.unmodifiable(_members);

  bool contains(User user) => _members.contains(user);

  int get memberCount => _members.length;

  bool join(User user) {
    // if (_events.isClosed) {
    //   return false;
    // }
    
    final added = _members.add(user);
    
    if (added) {
      _emit(RoomEventType.join, user: user);
    }

    print('User ${user.username} joined: ${topic}');

    return added;
  }

  bool leave(User user) {
    final removed = _members.remove(user);

    if (removed) {
      _emit(RoomEventType.leave, user: user);

      if (_members.isEmpty) {
        close();
      }
    }

    return removed;
  }

  void broadcast(Object payload, { User? from }) {
    // if (_events.isClosed) {
    //   return;
    // }

    for (final member in _members) {
      if (member.id != from?.id) {
        member.send(payload);
      }
    }

    _emit(RoomEventType.message, user: from, payload: payload);
  }

  void _emit(RoomEventType type, {User? user, Object? payload}) {
    if (_events.isClosed) {
      return;
    }

    _events.add(RoomEvent(type: type, room: this, user: user, payload: payload));
  }

  void close() {
    if (_events.isClosed) {
      return;
    }

    _emit(RoomEventType.closed);

    _events.close();
    _members.clear();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'topic': topic,
    'memberCount': memberCount,
    'members': _members.map((u) => u.id).toList(),
  };

  @override
  String toString() => 'Room($id members=$memberCount)';
}
