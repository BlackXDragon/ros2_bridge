library ros2_bridge;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';

part 'package:ros2_bridge/interfaces/message.dart';
part 'package:ros2_bridge/interfaces/action.dart';

part 'package:ros2_bridge/topics/topics.dart';
part 'package:ros2_bridge/actions/action_client.dart';

part 'package:ros2_bridge/params/params.dart';

class ROS2Bridge {
  final String url;
  WebSocketChannel? channel;

  bool isConnected = false;
  bool stop = false;

  void Function() connected_callback = () {};
  void Function() disconnected_callback = () {};
  void Function() ws_error_callback = () {};
  void Function(String raw_data) raw_data_callback = (String raw_data) {};

  static int n_instances = 0;

  Map<String, ROS2Topic> topics = {};

  Map<String, ROS2ActionClient> actionClients = {};

  Map<String, Completer> setParamCompleters = {};

  ROS2Bridge({
    this.url = 'ws://localhost:9999',
    this.connected_callback = _empty_callback,
    this.disconnected_callback = _empty_callback,
    this.ws_error_callback = _empty_callback,
    this.raw_data_callback = _empty_raw_data_callback,
  }) {
    n_instances++;
    if (n_instances > 1) {
      throw Exception('Only one instance of ROS2Bridge is allowed');
    }
    reconnect_ws();
  }

  static void _empty_callback() {}
  static void _empty_raw_data_callback(String rawData) {}

  void reconnect_ws() async {
    // Wait for 1 second before reconnecting
    Future.delayed(const Duration(seconds: 1), () async {
      channel = WebSocketChannel.connect(Uri.parse(url));
      try {
        await channel!.ready;
        isConnected = true;
        connected_callback();
      } catch (e) {
        // Try to reconnect
        isConnected = false;
        ws_error_callback();
        if (!stop) {
          reconnect_ws();
        }
        return;
      }

      channel!.stream.listen(
        (message) {
          if (message is String) {
            raw_data_callback(message);
            var data = json.decode(message);
            parse_data(data);
          }
        },
        onDone: () {
          // Try to reconnect
          isConnected = false;
          disconnected_callback();
          channel!.sink.close();
          if (!stop) {
            reconnect_ws();
          }
        },
        onError: (error) {
          // Try to reconnect
          isConnected = false;
          ws_error_callback();
          if (!stop) {
            reconnect_ws();
          }
        },
      );
    });
  }

  void sendRaw(String rawData) {
    if (channel != null) {
      channel!.sink.add(rawData);
    }
  }

  void parse_data(Map<String, dynamic> data) {
    switch (data['op']) {
      case 'subscribe':
        String topicName = data['topic'];
        Map<String, dynamic> msg = data['msg'];
        if (topics.containsKey(topicName) && topics[topicName]!.isSubscriber) {
          print('Received message on topic $topicName');
          if (topics[topicName]!.data_callback != null) {
            topics[topicName]!.data_callback!(ROS2Message.fromJson(msg));
          }
          topics[topicName]!.streamController.add(ROS2Message.fromJson(msg));
        }
        break;
      case 'update_goal_id':
        String tempGoalID = data['tempGoalID'];
        String goalID = data['goalID'];
        String actionServer = data['action_server'];
        if (actionClients.containsKey(actionServer)) {
          actionClients[actionServer]!.updateGoalID(tempGoalID, goalID);
        }
        break;
      case 'action_feedback':
        String goalID = data['goalID'];
        String actionServer = data['action_server'];
        Map<String, dynamic> feedback = data['feedback'];
        if (actionClients.containsKey(actionServer)) {
          actionClients[actionServer]!.handleFeedback(goalID, feedback);
        }
        break;
      case 'action_result':
        String goalID = data['goalID'];
        String actionServer = data['action_server'];
        Map<String, dynamic> result = data['result'];
        if (actionClients.containsKey(actionServer)) {
          actionClients[actionServer]!.handleResult(goalID, result);
        }
        break;
      case 'action_cancel_response':
        String goalID = data['goalID'];
        String actionServer = data['action_server'];
        if (actionClients.containsKey(actionServer)) {
          actionClients[actionServer]!
              .handleCancelResponse(goalID, data['success']);
        }
        break;
      case 'goal_status':
        String goalID = data['goalID'];
        String actionServer = data['action_server'];
        if (actionClients.containsKey(actionServer)) {
          actionClients[actionServer]!.handleGoalStatus(goalID, data['status']);
        }
        break;
      case 'set_parameters_result':
        String opID = data['opID'];
        List<SetParametersResult> results = setParametersResultListFromJsonObj(
          data['results'],
        );
        if (setParamCompleters.containsKey(opID)) {
          setParamCompleters[opID]!.complete(results);
          setParamCompleters.remove(opID);
        }
        break;
    }
  }

  ROS2Topic create_subscription(
    String topicName,
    ROS2Message messageType,
    String qosProfile,
    void Function(ROS2Message) dataCallback,
  ) {
    if (topics.containsKey(topicName)) {
      throw Exception(
          'Topic name is already in use as a publisher or subscriber in this bridge instance');
    }
    Map<String, dynamic> message = {
      'op': 'create_subscription',
      'topic': topicName,
      'message_type': messageType.toJson(),
      'qos_profile': qosProfile,
    };
    sendRaw(json.encode(message));
    topics[topicName] = ROS2Topic(
      topicName: topicName,
      messageType: messageType,
      qosProfile: qosProfile,
      bridge: this,
      data_callback: dataCallback,
    );
    topics[topicName]!.isSubscriber = true;

    return topics[topicName]!;
  }

  ROS2Topic create_publisher(
    String topicName,
    ROS2Message messageType,
    String qosProfile,
  ) {
    if (topics.containsKey(topicName)) {
      throw Exception(
          'Topic name is already in use as a publisher or subscriber in this bridge instance');
    }
    Map<String, dynamic> message = {
      'op': 'create_publisher',
      'topic': topicName,
      'message_type': messageType.toJson(),
      'qos_profile': qosProfile,
    };
    sendRaw(json.encode(message));
    topics[topicName] = ROS2Topic(
      topicName: topicName,
      messageType: messageType,
      qosProfile: qosProfile,
      bridge: this,
    );
    topics[topicName]!.isPublisher = true;

    return topics[topicName]!;
  }

  ROS2Topic get_topic(String topicName) {
    if (!topics.containsKey(topicName)) {
      throw Exception('Topic $topicName does not exist');
    }
    return topics[topicName]!;
  }

  ROS2ActionClient create_action_client(
    String actionServerName,
    ROS2Action actionType,
  ) {
    if (actionClients.containsKey(actionServerName)) {
      throw Exception('Action client already exists for $actionServerName');
    }

    Map<String, dynamic> message = {
      'op': 'create_action_client',
      'action_server': actionServerName,
      'action_type': actionType.toJson(),
    };
    sendRaw(json.encode(message));
    actionClients[actionServerName] = ROS2ActionClient(
      actionServerName: actionServerName,
      actionType: actionType,
      bridge: this,
    );

    return actionClients[actionServerName]!;
  }

  Future<List<SetParametersResult>> set_parameters(
      String nodeName, List<Param> params) async {
    String opID = Random().nextInt(100000).toString();

    List<Map<String, dynamic>> params0 = paramListToJsonObj(params);
    Map<String, dynamic> message = {
      'op': 'set_parameters',
      'opID': opID,
      'node_name': nodeName,
      'params': params0,
    };
    sendRaw(json.encode(message));

    Completer<List<SetParametersResult>> completer =
        Completer<List<SetParametersResult>>();
    setParamCompleters[opID] = completer;

    return completer.future;
  }

  void dispose() {
    stop = true;
    n_instances--;
    channel!.sink.close();
    for (var topic in topics.values) {
      topic.dispose();
    }
    for (var actionClient in actionClients.values) {
      actionClient.dispose();
    }
  }
}
