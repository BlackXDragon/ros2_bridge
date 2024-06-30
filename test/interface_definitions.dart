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

class Int32Message extends ROS2Message {
  final String field_name;
  Int32Message(int data, {this.field_name = 'data'})
      : super('std_msgs/msg/Int32',
            fields: [Field(field_name, FieldType.INT32, data)]);

  factory Int32Message.fromROS2Message(ROS2Message message) {
    if (message.name != 'std_msgs/msg/Int32') {
      throw Exception('Invalid message type');
    }
    if (message.fields.length != 1) {
      throw Exception('Invalid number of fields');
    }
    if (message.fields[0].type != FieldType.INT32) {
      throw Exception('Invalid field type');
    }
    return Int32Message(message.fields[0].value as int,
        field_name: message.fields[0].name);
  }

  int get value => fields[0].value;
}

class Int32ArrayMessage extends ROS2Message {
  final String field_name;
  Int32ArrayMessage(List<int> data, {this.field_name = 'data'})
      : super('std_msgs/msg/Int32MultiArray',
            fields: [Field(field_name, FieldType.INT32_ARRAY, data)]);

  factory Int32ArrayMessage.fromROS2Message(ROS2Message message) {
    if (message.name != 'std_msgs/msg/Int32MultiArray') {
      throw Exception('Invalid message type');
    }
    if (message.fields.length != 1) {
      throw Exception('Invalid number of fields');
    }
    if (message.fields[0].type != FieldType.INT32_ARRAY) {
      throw Exception('Invalid field type');
    }
    List<int> value = List<int>.from(message.fields[0].value);
    return Int32ArrayMessage(value, field_name: message.fields[0].name);
  }

  List<int> get value => fields[0].value;
}

class FibonacciAction extends ROS2Action {
  FibonacciAction({
    int goal = 0,
    List<int> feedback = const [],
    List<int> result = const [],
  }) : super(
          'action_tutorials_interfaces/action/Fibonacci',
          Int32Message(goal, field_name: 'order'),
          Int32ArrayMessage(feedback, field_name: 'partial_sequence'),
          Int32ArrayMessage(result, field_name: 'sequence'),
        );

  factory FibonacciAction.empty() => FibonacciAction();
}
