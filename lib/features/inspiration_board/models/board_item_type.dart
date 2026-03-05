enum BoardItemType {
  image,
  drawing,
  shape,
  stickyNote,
  text,
  connector;

  static BoardItemType fromString(String value) => switch (value) {
        'image' => BoardItemType.image,
        'drawing' => BoardItemType.drawing,
        'shape' => BoardItemType.shape,
        'sticky_note' => BoardItemType.stickyNote,
        'text' => BoardItemType.text,
        'connector' => BoardItemType.connector,
        _ => BoardItemType.image,
      };

  String toDbString() => switch (this) {
        BoardItemType.image => 'image',
        BoardItemType.drawing => 'drawing',
        BoardItemType.shape => 'shape',
        BoardItemType.stickyNote => 'sticky_note',
        BoardItemType.text => 'text',
        BoardItemType.connector => 'connector',
      };
}

enum ShapeType {
  rectangle,
  circle,
  line,
  arrow;

  static ShapeType fromString(String value) => switch (value) {
        'rectangle' => ShapeType.rectangle,
        'circle' => ShapeType.circle,
        'line' => ShapeType.line,
        'arrow' => ShapeType.arrow,
        _ => ShapeType.rectangle,
      };
}

enum ToolMode {
  select,
  pen,
  shape,
  text,
  stickyNote,
  eraser,
}
