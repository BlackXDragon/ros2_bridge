part of ros2_bridge;

enum FieldType {
  BOOL,
  BOOL_ARRAY,
  BYTE,
  BYTE_ARRAY,
  CHAR,
  CHAR_ARRAY,
  FLOAT32,
  FLOAT32_ARRAY,
  FLOAT64,
  FLOAT64_ARRAY,
  INT8,
  INT8_ARRAY,
  UINT8,
  UINT8_ARRAY,
  INT16,
  INT16_ARRAY,
  UINT16,
  UINT16_ARRAY,
  INT32,
  INT32_ARRAY,
  UINT32,
  UINT32_ARRAY,
  INT64,
  INT64_ARRAY,
  UINT64,
  UINT64_ARRAY,
  STRING,
  STRING_ARRAY,
  WSTRING,
  WSTRING_ARRAY,
}

dynamic strToFieldType(String str) {
  switch (str) {
    case 'bool':
      return FieldType.BOOL;
    case 'byte':
      return FieldType.BYTE;
    case 'char':
      return FieldType.CHAR;
    case 'float':
      return FieldType.FLOAT64;
    case 'float32':
      return FieldType.FLOAT32;
    case 'float64':
      return FieldType.FLOAT64;
    case 'int':
      return FieldType.INT64;
    case 'int8':
      return FieldType.INT8;
    case 'uint8':
      return FieldType.UINT8;
    case 'int16':
      return FieldType.INT16;
    case 'uint16':
      return FieldType.UINT16;
    case 'int32':
      return FieldType.INT32;
    case 'uint32':
      return FieldType.UINT32;
    case 'int64':
      return FieldType.INT64;
    case 'uint64':
      return FieldType.UINT64;
    case 'string':
      return FieldType.STRING;
    case 'wstring':
      return FieldType.WSTRING;
    default:
      if (str.endsWith('[]')) {
        switch (str.substring(0, str.length - 2)) {
          case 'bool':
            return FieldType.BOOL_ARRAY;
          case 'byte':
            return FieldType.BYTE_ARRAY;
          case 'char':
            return FieldType.CHAR_ARRAY;
          case 'float':
            return FieldType.FLOAT64_ARRAY;
          case 'float32':
            return FieldType.FLOAT32_ARRAY;
          case 'float64':
            return FieldType.FLOAT64_ARRAY;
          case 'int':
            return FieldType.INT64_ARRAY;
          case 'int8':
            return FieldType.INT8_ARRAY;
          case 'uint8':
            return FieldType.UINT8_ARRAY;
          case 'int16':
            return FieldType.INT16_ARRAY;
          case 'uint16':
            return FieldType.UINT16_ARRAY;
          case 'int32':
            return FieldType.INT32_ARRAY;
          case 'uint32':
            return FieldType.UINT32_ARRAY;
          case 'int64':
            return FieldType.INT64_ARRAY;
          case 'uint64':
            return FieldType.UINT64_ARRAY;
          case 'string':
            return FieldType.STRING_ARRAY;
          case 'wstring':
            return FieldType.WSTRING_ARRAY;
          default:
            {
              // Check if the array type is a message type
              String name = str.substring(0, str.length - 2);
              // Split by '/', add 'msg' to the end of the first part
              // and join by '/'
              List<String> parts = name.split('/');
              if (parts.length == 2) {
                parts.add(parts[1]);
                parts[1] = 'msg';
                name = parts.join('/');
              }
              if (ROS2Message.registeredMessages.containsKey(name)) {
                return ROS2Message.registeredMessages[name];
              }

              throw Exception('Invalid message type');
            }
        }
      } else {
        // Check if the type is a message type
        String name = str;
        // Split by '/', add 'msg' to the end of the first part
        // and join by '/'
        List<String> parts = name.split('/');
        if (parts.length == 2) {
          parts.add(parts[1]);
          parts[1] = 'msg';
          name = parts.join('/');
        }
        if (ROS2Message.registeredMessages.containsKey(name)) {
          return ROS2Message.registeredMessages[name];
        }

        throw Exception('Invalid message type');
      }
  }
}

String FieldTypeToStr(dynamic type) {
  // Check if the type is a message type
  if (type is ROS2Message) {
    return type.name;
  }

  switch (type) {
    case FieldType.BOOL:
      return 'bool';
    case FieldType.BYTE:
      return 'byte';
    case FieldType.CHAR:
      return 'char';
    case FieldType.FLOAT32:
      return 'float32';
    case FieldType.FLOAT64:
      return 'float64';
    case FieldType.INT8:
      return 'int8';
    case FieldType.UINT8:
      return 'uint8';
    case FieldType.INT16:
      return 'int16';
    case FieldType.UINT16:
      return 'uint16';
    case FieldType.INT32:
      return 'int32';
    case FieldType.UINT32:
      return 'uint32';
    case FieldType.INT64:
      return 'int64';
    case FieldType.UINT64:
      return 'uint64';
    case FieldType.STRING:
      return 'string';
    case FieldType.WSTRING:
      return 'wstring';
    default:
      if (type.toString().endsWith('_ARRAY')) {
        switch (type.toString().split('_')[0].split('.')[1]) {
          case 'BOOL':
            return 'bool[]';
          case 'BYTE':
            return 'byte[]';
          case 'CHAR':
            return 'char[]';
          case 'FLOAT32':
            return 'float32[]';
          case 'FLOAT64':
            return 'float64[]';
          case 'INT8':
            return 'int8[]';
          case 'UINT8':
            return 'uint8[]';
          case 'INT16':
            return 'int16[]';
          case 'UINT16':
            return 'uint16[]';
          case 'INT32':
            return 'int32[]';
          case 'UINT32':
            return 'uint32[]';
          case 'INT64':
            return 'int64[]';
          case 'UINT64':
            return 'uint64[]';
          case 'STRING':
            return 'string[]';
          case 'WSTRING':
            return 'wstring[]';
          default:
            throw Exception('Invalid message type: $type');
        }
      }
      throw Exception('Invalid message type: $type');
  }
}

class Field {
  final String name;
  final dynamic type;
  dynamic value;

  Field(this.name, this.type, this.value) {
    if (type is ROS2Message) {
      if (value is Map<String, dynamic>) {
        value = ROS2Message.fromJson(value);
      } else {
        value = value;
      }
    }
  }
}

class ROS2Message {
  String name;
  List<Field> fields;

  static Map<String, ROS2Message> registeredMessages = {};

  static void registerMessage(ROS2Message message) {
    registeredMessages[message.name] = message;
  }

  ROS2Message(this.name, {this.fields = const []});

  factory ROS2Message.fromJson(Map<String, dynamic> json) {
    List<Field> fields = [];
    for (var field in json['fields']) {
      fields.add(Field(
        field['name'],
        strToFieldType(field['type']),
        field['value'],
      ));
      if (fields.last.value is Map<String, dynamic>) {
        fields.last.value = ROS2Message.fromJson(fields.last.value);
      }
      if (fields.last.value is ROS2Message) {
        fields.last.value.name = fields.last.type.name;
      }
    }
    return ROS2Message(json['name'], fields: fields);
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> fields = [];
    for (var field in this.fields) {
      fields.add({
        'name': field.name,
        'type': FieldTypeToStr(field.type),
        'value': field.value,
      });
    }
    return {
      'name': name,
      'fields': fields,
    };
  }

  @override
  bool operator ==(Object other) {
    if (other is ROS2Message) {
      if (name != other.name) {
        return false;
      }
      if (fields.length != other.fields.length) {
        return false;
      }
      for (int i = 0; i < fields.length; i++) {
        if (fields[i].name != other.fields[i].name) {
          return false;
        }
        if (fields[i].type != other.fields[i].type) {
          return false;
        }
        if (fields[i].value != other.fields[i].value) {
          return false;
        }
      }
      return true;
    }
    return false;
  }
}
