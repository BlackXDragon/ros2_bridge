part of ros2_bridge;

class Goal {
  String goalID;
  final ROS2Message goalMessage;
  final StreamController<ROS2Message> feedbackStreamController =
      StreamController<ROS2Message>();
  late Future<ROS2Message> resultFuture;
  ROS2Message? result;
  final Completer<ROS2Message> completer = new Completer<ROS2Message>();

  Stream<ROS2Message> get feedbackStream => feedbackStreamController.stream;

  void Function(ROS2Message)? feedback_callback;
  void Function(ROS2Message)? result_callback;

  Goal({
    required this.goalID,
    required this.goalMessage,
    this.feedback_callback,
    this.result_callback,
  }) {
    resultFuture = completer.future;
  }

  void dispose() {
    feedbackStreamController.close();
  }
}

class ROS2ActionClient {
  final String actionServerName;
  final ROS2Action actionType;
  final ROS2Bridge bridge;

  Random random = Random();

  Map<String, Goal> goals = {};

  ROS2ActionClient({
    required this.actionServerName,
    required this.actionType,
    required this.bridge,
  });

  Goal send_goal_async(
    ROS2Message goalMessage, {
    void Function(ROS2Message)? feedback_callback,
    void Function(ROS2Message)? result_callback,
  }) {
    // Verify that the message type matches the action's goal message type
    if (goalMessage.name != actionType.goal.name) {
      throw Exception('Message name does not match action goal message name');
    }
    bool fieldsMatch = true;
    for (int i = 0; i < goalMessage.fields.length; i++) {
      if (goalMessage.fields[i].name != actionType.goal.fields[i].name ||
          goalMessage.fields[i].type != actionType.goal.fields[i].type) {
        fieldsMatch = false;
        break;
      }
    }
    if (!fieldsMatch) {
      throw Exception('Message fields do not match action goal message fields');
    }

    // Generate random temp goal ID as a hex string
    String goalID = random.nextInt(0xFFFFFFFF).toRadixString(16);

    Map<String, dynamic> goalRequest = {
      'op': 'send_goal',
      'tempGoalID': goalID,
      'action_server': actionServerName,
      'goal': goalMessage.toJson(),
    };
    bridge.sendRaw(json.encode(goalRequest));

    // Create a new goal object and add it to the goals map
    Goal goal = Goal(
      goalID: goalID,
      goalMessage: goalMessage,
      feedback_callback: feedback_callback,
      result_callback: result_callback,
    );

    goals[goalID] = goal;

    return goal;
  }

  void updateGoalID(String tempGoalID, String goalID) {
    if (goals.containsKey(tempGoalID)) {
      Goal goal = goals[tempGoalID]!;
      goals.remove(tempGoalID);
      goals[goalID] = goal;
      goal.goalID = goalID;
    }
  }

  void handleFeedback(String goalID, Map<String, dynamic> feedback) {
    if (goals.containsKey(goalID)) {
      ROS2Message feedbackMessage = ROS2Message.fromJson(feedback);
      goals[goalID]!.feedbackStreamController.add(feedbackMessage);
      if (goals[goalID]!.feedback_callback != null) {
        goals[goalID]!.feedback_callback!(feedbackMessage);
      }
    }
  }

  void handleResult(String goalID, Map<String, dynamic> result) {
    if (goals.containsKey(goalID)) {
      ROS2Message resultMessage = ROS2Message.fromJson(result);
      goals[goalID]!.result = resultMessage;
      goals[goalID]!.completer.complete(resultMessage);
      if (goals[goalID]!.result_callback != null) {
        goals[goalID]!.result_callback!(resultMessage);
      }
    }
  }
}