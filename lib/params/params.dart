part of ros2_bridge;

enum ParamType {
  BOOL,
  INT64,
  FLOAT64,
  STRING,
  BYTE_ARRAY,
  BOOL_ARRAY,
  INT64_ARRAY,
  FLOAT64_ARRAY,
  STRING_ARRAY,
}

ParamType strToParamType(String str) {
  switch (str) {
    case 'bool':
      return ParamType.BOOL;
    case 'int64':
      return ParamType.INT64;
    case 'float64':
      return ParamType.FLOAT64;
    case 'string':
      return ParamType.STRING;
    case 'byte_array':
      return ParamType.BYTE_ARRAY;
    case 'bool_array':
      return ParamType.BOOL_ARRAY;
    case 'int64_array':
      return ParamType.INT64_ARRAY;
    case 'float64_array':
      return ParamType.FLOAT64_ARRAY;
    case 'string_array':
      return ParamType.STRING_ARRAY;
    default:
      throw Exception('Invalid param type');
  }
}

String paramTypeToStr(ParamType type) {
  switch (type) {
    case ParamType.BOOL:
      return 'bool';
    case ParamType.INT64:
      return 'int64';
    case ParamType.FLOAT64:
      return 'float64';
    case ParamType.STRING:
      return 'string';
    case ParamType.BYTE_ARRAY:
      return 'byte_array';
    case ParamType.BOOL_ARRAY:
      return 'bool_array';
    case ParamType.INT64_ARRAY:
      return 'int64_array';
    case ParamType.FLOAT64_ARRAY:
      return 'float64_array';
    case ParamType.STRING_ARRAY:
      return 'string_array';
  }
}

class Param {
  final String name;
  final ParamType type;
  final dynamic value;

  Param(this.name, this.type, this.value);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': paramTypeToStr(type),
      'value': value,
    };
  }

  factory Param.fromJson(Map<String, dynamic> json) {
    return Param(
      json['name'],
      strToParamType(json['type']),
      json['value'],
    );
  }
}

List<Map<String, dynamic>> paramListToJsonObj(List<Param> params) {
  List<Map<String, dynamic>> jsonList = [];
  for (Param param in params) {
    jsonList.add(param.toJson());
  }
  return jsonList;
}

List<Param> paramListFromJson(String jsonStr) {
  List<Param> params = [];
  List<dynamic> jsonList = json.decode(jsonStr);
  for (var json in jsonList) {
    params.add(Param.fromJson(json));
  }
  return params;
}

class SetParametersResult {
  bool successful;
  String reason;

  SetParametersResult(this.successful, this.reason);

  factory SetParametersResult.fromJson(Map<String, dynamic> json) {
    return SetParametersResult(
      json['successful'],
      json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'successful': successful,
      'reason': reason,
    };
  }
}

List<SetParametersResult> setParametersResultListFromJson(String jsonStr) {
  List<SetParametersResult> results = [];
  List<dynamic> jsonList = json.decode(jsonStr);
  for (var json in jsonList) {
    results.add(SetParametersResult.fromJson(json));
  }
  return results;
}

List<SetParametersResult> setParametersResultListFromJsonObj(
    List<dynamic> jsonList) {
  List<SetParametersResult> results = [];
  for (var json in jsonList) {
    results.add(SetParametersResult.fromJson(json));
  }
  return results;
}
