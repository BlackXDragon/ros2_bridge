import 'package:flutter_test/flutter_test.dart';

import 'package:ros2_bridge/ros2_bridge.dart';

class StringMessage extends ROS2Message {
  StringMessage(String data)
      : super('std_msgs/msg/String',
            fields: [Field('data', FieldType.STRING, data)]);

  factory StringMessage.fromROS2Message(ROS2Message message) {
    if (message.name != 'std_msgs/msg/String') {
      throw Exception('Invalid message type');
    }
    if (message.fields.length != 1) {
      throw Exception('Invalid number of fields');
    }
    if (message.fields[0].name != 'data') {
      throw Exception('Invalid field name');
    }
    if (message.fields[0].type != FieldType.STRING) {
      throw Exception('Invalid field type');
    }
    return StringMessage(message.fields[0].value);
  }

  String get value => fields[0].value;
}

void main() {
  test('Test ROS2Bridge', () async {
    ROS2Bridge bridge = ROS2Bridge(
      connected_callback: () {
        print('Connected');
      },
      disconnected_callback: () {
        print('Disconnected');
      },
      ws_error_callback: () {
        print('Error');
      },
      raw_data_callback: (String raw_data) {
        print('Raw data: $raw_data');
      },
    );

    while (!bridge.isConnected) {
      print('Waiting for connection');
      await Future.delayed(const Duration(seconds: 1), () {});
    }

    ROS2Topic pubTopic = bridge.create_publisher(
      'pub_test',
      StringMessage(''),
      'default',
    );

    ROS2Topic subTopic = bridge.create_subscription(
      'sub_test',
      StringMessage(''),
      'default',
      (ROS2Message data) {
        StringMessage message = StringMessage.fromROS2Message(data);
        print('Callback received: ${message.value}');
      },
    );

    subTopic.stream.listen((ROS2Message data) {
      var msg = StringMessage.fromROS2Message(data);
      print('Stream received: ${msg.value}');
    });

    int count = 0;
    try {
      while (bridge.isConnected) {
        pubTopic.publish(StringMessage('Hello from Flutter $count'));
        await Future.delayed(const Duration(seconds: 1), () {});
        count++;
      }
    } finally {
      bridge.dispose();
    }
  });
}
