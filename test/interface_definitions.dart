import 'package:ros2_bridge/ros2_bridge.dart';

// String Message
// string data
class StringMessage extends ROS2Message {
  final String field_name;
  StringMessage({String data = '', this.field_name = 'data'})
      : super('std_msgs/msg/String',
            fields: [Field(field_name, FieldType.STRING, data)]);

  factory StringMessage.fromROS2Message(ROS2Message message) {
    if (message.name != 'std_msgs/msg/String') {
      throw Exception(
          'Invalid message type. Expected std_msgs/msg/String. Got ${message.name}');
    }
    if (message.fields.length != 1) {
      throw Exception('Invalid number of fields');
    }
    if (message.fields[0].type != FieldType.STRING) {
      throw Exception(
          'Invalid field type. Expected string. Got ${FieldTypeToStr(message.fields[0].type)}');
    }
    return StringMessage(
      data: message.fields[0].value as String,
      field_name: message.fields[0].name,
    );
  }

  @override
  String toString() {
    return 'StringMessage($field_name = $data)';
  }

  String get data => fields[0].value as String;
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

class BoolMessage extends ROS2Message {
  final String field_name;
  BoolMessage({bool data = false, this.field_name = 'data'})
      : super('std_msgs/msg/Bool',
            fields: [Field(field_name, FieldType.BOOL, data)]);

  factory BoolMessage.fromROS2Message(ROS2Message message) {
    if (message.name != 'std_msgs/msg/Bool') {
      throw Exception(
          'Invalid message type. Expected std_msgs/msg/Bool. Got ${message.name}');
    }
    if (message.fields.length != 1) {
      throw Exception('Invalid number of fields');
    }
    if (message.fields[0].type != FieldType.BOOL) {
      throw Exception(
          'Invalid field type. Expected bool. Got ${FieldTypeToStr(message.fields[0].type)}');
    }
    return BoolMessage(
      data: message.fields[0].value as bool,
      field_name: message.fields[0].name,
    );
  }

  @override
  String toString() {
    return 'BoolMessage($field_name = $data)';
  }

  bool get data => fields[0].value as bool;
}

List<ROS2Message> messageTypes = [
  StringMessage(),
  Int32Message(0),
  Int32ArrayMessage([]),
  BoolMessage(),
];
