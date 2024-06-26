part of ros2_bridge;

class ROS2Action {
  final String name;
  final ROS2Message goal;
  final ROS2Message result;
  final ROS2Message feedback;

  ROS2Action(this.name, this.goal, this.result, this.feedback);

  factory ROS2Action.fromJson(Map<String, dynamic> json) {
    return ROS2Action(
      json['name'],
      ROS2Message.fromJson(json['goal']),
      ROS2Message.fromJson(json['result']),
      ROS2Message.fromJson(json['feedback']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'goal': goal.toJson(),
      'result': result.toJson(),
      'feedback': feedback.toJson(),
    };
  }
}
