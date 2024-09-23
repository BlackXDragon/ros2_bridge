part of ros2_bridge;

enum GoalStatus {
  PENDING,
  REJECTED,
  ACTIVE,
  COMPLETED,
  ABORTED,
  CANCELED,
  CANCELING,
}

class Goal {
  String goalID;
  final ROS2Message goalMessage;
  final StreamController<ROS2Message> feedbackStreamController =
      StreamController<ROS2Message>();
  final StreamController<GoalStatus> statusStreamController =
      StreamController<GoalStatus>();
  GoalStatus status = GoalStatus.PENDING;
  late Future<ROS2Message> resultFuture;
  ROS2Message? result;
  final Completer<ROS2Message> completer = Completer<ROS2Message>();

  Stream<ROS2Message> get feedbackStream => feedbackStreamController.stream;
  Stream<GoalStatus> get statusStream => statusStreamController.stream;

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
    statusStreamController.close();
  }
}

class GoalCancelException implements Exception {
  final String message;

  GoalCancelException(this.message);
}

class GoalFailedException implements Exception {
  final String message;

  GoalFailedException(this.message);
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

  void cancel_goal(String goalID) {
    if (goals.containsKey(goalID)) {
      Map<String, dynamic> cancelRequest = {
        'op': 'cancel_goal',
        'goalID': goalID,
        'action_server': actionServerName,
      };
      bridge.sendRaw(json.encode(cancelRequest));
      goals[goalID]!.statusStreamController.add(GoalStatus.CANCELING);
      goals[goalID]!.status = GoalStatus.CANCELING;
    }
  }

  void updateGoalID(String tempGoalID, String goalID) {
    if (goals.containsKey(tempGoalID)) {
      Goal goal = goals[tempGoalID]!;
      goals.remove(tempGoalID);
      goal.goalID = goalID;
      goals[goalID] = goal;
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

  void handleCancelResponse(String goalID, bool success) {
    if (goals.containsKey(goalID)) {
      if (success) {
        goals[goalID]!
            .completer
            .completeError(GoalCancelException('Goal was canceled'));
        goals.remove(goalID);
      }
    }
  }

  void handleGoalStatus(String goalID, String status) {
    if (goals.containsKey(goalID)) {
      Goal goal = goals[goalID]!;
      switch (status) {
        case 'pending':
          goal.statusStreamController.add(GoalStatus.PENDING);
          goal.status = GoalStatus.PENDING;
          break;
        case 'rejected':
          goal.statusStreamController.add(GoalStatus.REJECTED);
          goal.status = GoalStatus.REJECTED;
          goal.completer
              .completeError(GoalFailedException('Goal was rejected'));
          break;
        case 'active':
          goal.statusStreamController.add(GoalStatus.ACTIVE);
          goal.status = GoalStatus.ACTIVE;
          break;
        case 'completed':
          goal.statusStreamController.add(GoalStatus.COMPLETED);
          goal.status = GoalStatus.COMPLETED;
          break;
        case 'aborted':
          goal.statusStreamController.add(GoalStatus.ABORTED);
          goal.status = GoalStatus.ABORTED;
          goal.completer.completeError(GoalFailedException('Goal was aborted'));
          break;
        case 'canceled':
          goal.statusStreamController.add(GoalStatus.CANCELED);
          goal.status = GoalStatus.CANCELED;
          // goal.completer
          //     .completeError(GoalCancelException('Goal was canceled'));
          break;
        case 'cancel_rejected':
          goal.statusStreamController.add(GoalStatus.ACTIVE);
          goal.status = GoalStatus.ACTIVE;
          break;
      }
    }
  }

  void dispose() {
    for (Goal goal in goals.values) {
      goal.dispose();
    }
  }
}
