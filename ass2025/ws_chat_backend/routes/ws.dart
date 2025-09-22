import 'dart:math';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

import '../utils/room_manager.dart';
import '../utils/user.dart';

final _random = Random();

final List<String> _availableNames = [
  'Orion',
  'Lyra',
  'Nova',
  'Atlas',
  'Zephyr',
  'Echo',
  'Pixel',
  'Cipher',
  'Quill',
  'Ember',
  'Kairo',
  'Vega',
  'Zara',
  'Dune',
  'Lumen',
  'Rune',
  'Sol',
  'Aster',
  'Drift',
  'Nyx',
];

String getRandomNameAndRemove() {
  if (_availableNames.isEmpty) {
    return 'user_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}';
  }

  final index = _random.nextInt(_availableNames.length);

  return _availableNames.removeAt(index);
}

void clearUser(String userId) {
  print('Clearing user $userId');
  
  RoomManager.instance.removeUserEverywhere(UserManager.instance.byId(userId)!);
  UserManager.instance.removeById(userId);
}

void handleNewWebSocketConnection(WebSocketChannel channel) {
  print('New connection!');

  final user = new User(
    username: getRandomNameAndRemove(),
    socket: channel,
  );

  print('Assigned username: ${user.username}');

  UserManager.instance.add(user);

  RoomManager.instance.join(
    RoomManager.instance.getAnyRoom().id,
    user);

  user.send('welcome ${user.username} on ass-2025 WekW server');

  channel.stream.listen(
    print,
    onDone: () => clearUser(user.id),
    onError: (_) => clearUser(user.id),
    cancelOnError: true,
  );
}

Future<Response> onRequest(RequestContext context) async {
  return webSocketHandler(
    (channel, protocol) {
      handleNewWebSocketConnection(channel);
    },
  )(context);
}
