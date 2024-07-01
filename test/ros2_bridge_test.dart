import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:ros2_bridge/ros2_bridge.dart';

import 'interface_definitions.dart';

void main() {
  test('Test ROS2Bridge Topics', () async {
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
    );

    while (!bridge.isConnected) {
      print('ROS2Bridge Topics Test: Waiting for connection');
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
      while (bridge.isConnected && count < 15) {
        pubTopic.publish(StringMessage('Hello from Flutter $count'));
        await Future.delayed(const Duration(seconds: 1), () {});
        count++;
      }
    } finally {
      bridge.dispose();
    }
  });

  test('Test ROS2Bridge ActionClient', () async {
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
    );

    while (!bridge.isConnected) {
      print('ROS2Bridge ActionClient Test: Waiting for connection');
      await Future.delayed(const Duration(seconds: 1), () {});
    }

    ROS2ActionClient actionClient = bridge.create_action_client(
      'fibonacci',
      FibonacciAction.empty(),
    );

    Goal goal = actionClient
        .send_goal_async(Int32Message(10, field_name: 'order'),
            feedback_callback: (ROS2Message feedback) {
      Int32ArrayMessage message = Int32ArrayMessage.fromROS2Message(feedback);
      print('Feedback: ${message.value}');
    }, result_callback: (ROS2Message result) {
      Int32ArrayMessage message = Int32ArrayMessage.fromROS2Message(result);
      print('Result: ${message.value}');
    });

    goal.feedbackStream.listen((ROS2Message feedback) {
      Int32ArrayMessage message = Int32ArrayMessage.fromROS2Message(feedback);
      print('Feedback Stream: ${message.value}');
    });

    try {
      var result = await goal.resultFuture;
      Int32ArrayMessage message = Int32ArrayMessage.fromROS2Message(result);
      print('Final Result: ${message.value}');
    } finally {
      bridge.dispose();
    }
  });

  test('Test ROS2Bridge ActionClient Cancel', () async {
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
    );

    while (!bridge.isConnected) {
      print('ROS2Bridge ActionClient Test: Waiting for connection');
      await Future.delayed(const Duration(seconds: 1), () {});
    }

    ROS2ActionClient actionClient = bridge.create_action_client(
      'fibonacci',
      FibonacciAction.empty(),
    );

    Goal goal = actionClient
        .send_goal_async(Int32Message(10, field_name: 'order'),
            feedback_callback: (ROS2Message feedback) {
      Int32ArrayMessage message = Int32ArrayMessage.fromROS2Message(feedback);
      print('Feedback: ${message.value}');
    }, result_callback: (ROS2Message result) {
      Int32ArrayMessage message = Int32ArrayMessage.fromROS2Message(result);
      print('Result: ${message.value}');
    });

    goal.feedbackStream.listen((ROS2Message feedback) {
      Int32ArrayMessage message = Int32ArrayMessage.fromROS2Message(feedback);
      print('Feedback Stream: ${message.value}');
    });

    Future.delayed(Duration(seconds: 2), () {
      actionClient.cancel_goal(goal.goalID);
    });

    try {
      var result = await goal.resultFuture;
      Int32ArrayMessage message = Int32ArrayMessage.fromROS2Message(result);
      print('Final Result: ${message.value}');
      throw Exception('Goal was not cancelled');
    } on GoalCancelException catch (e) {
      print(e.message);
    } on GoalFailedException catch (e) {
      print(e.message);
    } finally {
      bridge.dispose();
    }
  });
}
