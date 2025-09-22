import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

class User {
  final String username;
  final String id;

  final WebSocketChannel _socket;
  final StreamController _outgoing = StreamController(sync: true);

  DateTime lastActivity;
  bool _closed = false;

  User({
    required this.username,
    required WebSocketChannel socket,
    String? id })
      : _socket = socket,
        id = id ?? _generateId(),
        lastActivity = DateTime.now()
  {
    _outgoing.stream.listen((event) {
      if (_closed) {
        return;
      }

      try {
        if (event is String || event is List<int>) {
          _socket.sink.add(event);

        } else {
          _socket.sink.add(jsonEncode(event));

        }
      } catch (_) {
        close();
      }
    });

    _socket.stream.listen(onMessage);

    _socket.sink.done.whenComplete(close);
  }

  WebSocketChannel get rawSocket => _socket;

  bool get isClosed => _closed;

  void send(dynamic data) {
    if (_closed) {
      return;
    }
    
    _socket.sink.add(data);

    // _outgoing.add(data);
  }

  Future<void> close([int code = WebSocketStatus.normalClosure, String reason = '']) async {
    if (_closed) {
      return;
    }

    _closed = true;
    
    await _outgoing.close();

    try {
      await _socket.sink.close(code, reason);

    } catch (_) {
      // ...
    }
  }

  // Stream<dynamic> get messages async* {
  //   yield* _socket.sink;
  // }

  void touch() {
    lastActivity = DateTime.now();
  }

  void onMessage(dynamic data) {
    touch();

    print('Received message from $username: $data');
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'lastActivity': lastActivity.toIso8601String(),
  };

  @override
  String toString() => 'User($username:$id closed=$_closed)';

  @override
  bool operator ==(Object other) => other is User && other.id == id;

  @override
  int get hashCode => id.hashCode;

  static String _generateId() {
    final ms = DateTime.now().microsecondsSinceEpoch;
    final rand = (ms ^ (ms >> 7)).toRadixString(36);

    return rand;
  }
}

class UserManager {
  UserManager._();
  static final UserManager instance = UserManager._();

  final Map<String, User> _byId = {};

  Iterable<User> get users => _byId.values;

  int get length => _byId.length;

  bool get isEmpty => _byId.isEmpty;

  User? byId(String id) => _byId[id];
  
  bool containsId(String id) => _byId.containsKey(id);

  bool add(User user) {
    if (_byId.containsKey(user.id) || containsUsername(user.username)) {
      return false;
    }

    _byId[user.id] = user;

    user.rawSocket.sink.done.whenComplete(() {
      removeById(user.id);
    });

    return true;
  }

  User? byUsername(String username) {
    for (final userValue in _byId.values) {
      if (userValue.username == username) {
        return userValue;
      }
    }

    return null;
  }

  bool containsUsername(String username) {
    for (final userValue in _byId.values) {
      if (userValue.username == username) {
        return true;
      }

    }

    return false;
  }

  User? removeById(String id) {
    return _byId.remove(id);
  }

  User? removeByUsername(String username) {
    String? toRemove;

    _byId.forEach((id, user) {
      if (toRemove == null && user.username == username) {
        toRemove = id;
      }

    });

    if (toRemove != null) {
      return _byId.remove(toRemove);
    }

    return null;
  }

  Future<void> closeAndRemove(String id, { int code = WebSocketStatus.normalClosure, String reason = '' }) async {
    final user = removeById(id);

    if (user != null) {
      await user.close(code, reason);
    }

  }

  void broadcast(dynamic data, { bool Function(User user)? where }) {
    for (final userValue in _byId.values) {
      if (where == null || where(userValue)) {
        userValue.send(data);
      }

    }
  }

  int pruneInactive(Duration maxIdle) {
    final cutoff = DateTime.now().subtract(maxIdle);
    final toRemove = <String>[];

    for (final userValue in _byId.values) {
      if (userValue.lastActivity.isBefore(cutoff) || userValue.isClosed) {
        toRemove.add(userValue.id);
      }
    }

    for (final id in toRemove) {
      removeById(id);
    }

    return toRemove.length;
  }

  Future<void> shutdown(
      {int code = WebSocketStatus.normalClosure, String reason = 'shutdown'}) async {
    final list = List<User>.from(_byId.values);
    _byId.clear();
    for (final u in list) {
      await u.close(code, reason);
    }
  }

  Map<String, dynamic> describe() => {
    'count': length,
    'users': users.map((u) => u.toJson()).toList(),
  };
}

