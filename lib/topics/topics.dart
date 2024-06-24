import 'dart:async';
import 'dart:convert';

import 'package:ros2_bridge/interfaces/message.dart';
import 'package:ros2_bridge/ros2_bridge.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ROS2Topic {
  final String topicName;
  final ROS2Message messageType;
  final String qosProfile;

  bool isPublisher = false;
  bool isSubscriber = false;

  StreamController<ROS2Message> streamController =
      StreamController<ROS2Message>();

  Stream<ROS2Message> get stream => streamController.stream;

  final ROS2Bridge? bridge;

  void Function(ROS2Message data)? data_callback;

  ROS2Topic({
    required this.topicName,
    required this.messageType,
    required this.qosProfile,
    required this.bridge,
    this.data_callback,
  });

  Map<String, dynamic> toJson() {
    return {
      'topicName': topicName,
      'messageType': messageType.toJson(),
      'qosProfile': qosProfile,
    };
  }

  void publish(ROS2Message data) {
    if (!isPublisher) {
      throw Exception('This topic is not a publisher');
    }
    // Verify that the message type matches the topic's message type
    if (data.name != messageType.name) {
      throw Exception('Message name does not match topic message name');
    }
    bool fieldsMatch = true;
    for (int i = 0; i < data.fields.length; i++) {
      if (data.fields[i].name != messageType.fields[i].name ||
          data.fields[i].type != messageType.fields[i].type) {
        fieldsMatch = false;
        break;
      }
    }
    if (!fieldsMatch) {
      throw Exception('Message fields do not match topic message fields');
    }
    Map<String, dynamic> message = {
      'op': 'publish',
      'topic': topicName,
      'qos_profile': qosProfile,
      'msg': data.toJson(),
    };
    bridge!.sendRaw(json.encode(message));
  }
}
