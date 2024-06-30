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

FieldType strToFieldType(String str) {
  switch (str) {
    case 'bool':
      return FieldType.BOOL;
    case 'byte':
      return FieldType.BYTE;
    case 'char':
      return FieldType.CHAR;
    case 'float32':
      return FieldType.FLOAT32;
    case 'float64':
      return FieldType.FLOAT64;
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
          case 'float32':
            return FieldType.FLOAT32_ARRAY;
          case 'float64':
            return FieldType.FLOAT64_ARRAY;
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
            throw Exception('Invalid message type');
        }
      }
      throw Exception('Invalid message type');
  }
}

String FieldTypeToStr(FieldType type) {
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
            throw Exception('Invalid message type');
        }
      }
      throw Exception('Invalid message type');
  }
}

class Field {
  final String name;
  final FieldType type;
  final dynamic value;

  Field(this.name, this.type, this.value);
}

class ROS2Message {
  String name;
  List<Field> fields;

  ROS2Message(this.name, {this.fields = const []});

  factory ROS2Message.fromJson(Map<String, dynamic> json) {
    List<Field> fields = [];
    for (var field in json['fields']) {
      fields.add(Field(
        field['name'],
        strToFieldType(field['type']),
        field['value'],
      ));
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
}
