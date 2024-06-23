import 'dart:convert';

import 'package:ros2_bridge/topics/message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ROS2Topic {
  final String topicName;
  final ROS2Message messageType;
  final String qosProfile;

  final WebSocketChannel? channel;

  void Function(ROS2Message data) data_callback = (ROS2Message data) {};

  ROS2Topic({
    required this.topicName,
    required this.messageType,
    required this.qosProfile,
    required this.channel,
    data_callback,
  });

  Map<String, dynamic> toJson() {
    return {
      'topicName': topicName,
      'messageType': messageType.toJson(),
      'qosProfile': qosProfile,
    };
  }

  void publish(ROS2Message data) {
    Map<String, dynamic> message = {
      'op': 'publish',
      'topic': topicName,
      'qos_profile': qosProfile,
      'msg': data.toJson(),
    };
    channel!.sink.add(json.encode(message));
  }
}
