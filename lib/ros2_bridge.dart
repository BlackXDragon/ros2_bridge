library ros2_bridge;

import 'dart:convert';

import 'package:ros2_bridge/interfaces/message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:ros2_bridge/topics/topics.dart';

class ROS2Bridge {
  final String url;
  WebSocketChannel? channel;

  void Function() connected_callback = () {};
  void Function() disconnected_callback = () {};
  void Function() ws_error_callback = () {};
  void Function(String raw_data) raw_data_callback = (String raw_data) {};

  static int n_instances = 0;

  Map<String, ROS2Topic> topics = {};

  ROS2Bridge({
    this.url = 'ws://localhost:9999',
    required this.connected_callback,
    required this.disconnected_callback,
    required this.ws_error_callback,
    required this.raw_data_callback,
  }) {
    n_instances++;
    if (n_instances > 1) {
      throw Exception('Only one instance of ROS2Bridge is allowed');
    }
    reconnect_ws();
  }

  void reconnect_ws() async {
    // Wait for 1 second before reconnecting
    Future.delayed(const Duration(seconds: 1), () async {
      channel = WebSocketChannel.connect(Uri.parse(this.url));
      try {
        await channel!.ready;
        connected_callback();
      } catch (e) {
        // Try to reconnect
        ws_error_callback();
        reconnect_ws();
        return;
      }

      channel!.stream.listen(
        (message) {
          if (message is String) {
            raw_data_callback(message);
            var data = json.decode(message);
            parse_data(data);
          }
        },
        onDone: () {
          // Try to reconnect
          disconnected_callback();
          channel!.sink.close();
          reconnect_ws();
        },
        onError: (error) {
          // Try to reconnect
          ws_error_callback();
          reconnect_ws();
        },
      );
    });
  }

  void parse_data(Map<String, dynamic> data) {
    if (data['op'] == 'subscribe') {
      String topicName = data['topic'];
      Map<String, dynamic> msg = data['msg'];
      if (topics.containsKey(topicName)) {
        topics[topicName]!.data_callback(ROS2Message.fromJson(msg));
      }
    }
  }

  void dispose() {
    n_instances--;
    channel!.sink.close();
  }
}
