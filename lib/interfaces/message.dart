enum FieldType {
  BOOL,
  BYTE,
  CHAR,
  FLOAT32,
  FLOAT64,
  INT8,
  UINT8,
  INT16,
  UINT16,
  INT32,
  UINT32,
  INT64,
  UINT64,
  STRING,
  WSTRING,
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
  final String name;
  final List<Field> fields;

  ROS2Message(this.name, this.fields);

  factory ROS2Message.fromJson(Map<String, dynamic> json) {
    List<Field> fields = [];
    for (var field in json['fields']) {
      fields.add(Field(
        field['name'],
        strToFieldType(field['type']),
        field['value'],
      ));
    }
    return ROS2Message(json['name'], fields);
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
