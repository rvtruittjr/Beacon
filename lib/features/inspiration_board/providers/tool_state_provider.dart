import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/board_item_type.dart';
import '../models/drawing_stroke.dart';

/// Currently active tool on the whiteboard.
final activeToolProvider = StateProvider<ToolMode>((ref) => ToolMode.select);

/// Pen drawing options.
final penColorProvider = StateProvider<String>((ref) => '#FFFFFF');
final penStrokeWidthProvider = StateProvider<double>((ref) => 3.0);

/// Shape options.
final shapeTypeProvider = StateProvider<ShapeType>((ref) => ShapeType.rectangle);
final shapeFillColorProvider = StateProvider<String>((ref) => '#6C63FF');
final shapeStrokeColorProvider = StateProvider<String>((ref) => '#FFFFFF');

/// Sticky note default color.
final stickyNoteColorProvider = StateProvider<String>((ref) => '#FFEB3B');

/// Active in-progress stroke while drawing.
final activeStrokeProvider = StateProvider<DrawingStroke?>((ref) => null);

/// Preset color palette for toolbar quick picks.
const toolbarColors = [
  '#FFFFFF',
  '#000000',
  '#FF6B6B',
  '#6C63FF',
  '#00C853',
  '#FFEB3B',
  '#FF9800',
  '#2196F3',
  '#E91E63',
  '#00BCD4',
];
