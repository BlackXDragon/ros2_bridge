import 'package:flutter_test/flutter_test.dart';
import 'package:ros2_bridge/interfaces/message.dart';

import 'package:ros2_bridge/ros2_bridge.dart';
import 'package:ros2_bridge/topics/topics.dart';

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
      ROS2Message(
        'std_msgs/msg/String',
        fields: [
          Field('data', FieldType.STRING, ''),
        ],
      ),
      'default',
    );

    ROS2Topic subTopic = bridge.create_subscription(
      'sub_test',
      ROS2Message(
        'std_msgs/msg/String',
        fields: [
          Field('data', FieldType.STRING, ''),
        ],
      ),
      'default',
      (ROS2Message data) {
        print('Callback received: ${data.fields[0].value}');
      },
    );

    subTopic.stream.listen((data) {
      print('Stream received: ${data.fields[0].value}');
    });

    int count = 0;
    try {
      while (bridge.isConnected) {
        pubTopic.publish(ROS2Message('std_msgs/msg/String', fields: [
          Field('data', FieldType.STRING, 'Hello from Flutter $count'),
        ]));
        await Future.delayed(const Duration(seconds: 1), () {});
        count++;
      }
    } finally {
      bridge.dispose();
    }
  });
}
