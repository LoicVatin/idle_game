import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class ScrollableComponentList extends PositionComponent with DragCallbacks {
  ScrollableComponentList({
    super.position,
    super.size,
    this.spacing = 16,
    this.padding = const EdgeInsets.all(16),
  });

  final double spacing;
  final EdgeInsets padding;

  final List<PositionComponent> _items = [];

  late final ScrollbarThumbIndicatorComponent _scrollbarThumb;
  late final BorderComponent _rightBorder;
  late final BorderComponent _leftBorder;

  double _scrollOffset = 0;
  double _contentHeight = 0;

  Future<void> setItems(List<PositionComponent> items) async {
    for (final item in _items) {
      item.removeFromParent();
    }

    _items
      ..clear()
      ..addAll(items);

    for (final item in _items) {
      item.priority = 0;
      await add(item);
    }

    if (!_rightBorder.isMounted) {
      await add(_rightBorder);
    }

    if (!_leftBorder.isMounted) {
      await add(_leftBorder);
    }

    if (!_scrollbarThumb.isMounted) {
      await add(_scrollbarThumb);
    }

    _layoutItems();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _rightBorder = BorderComponent();
    _leftBorder = BorderComponent();
    _scrollbarThumb = ScrollbarThumbIndicatorComponent();
  }

  @override
  void onMount() {
    super.onMount();
    _layoutItems();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layoutItems();
  }

  @override
  set size(Vector2 value) {
    super.size = value;
    if (isMounted) {
      _layoutItems();
    }
  }

  void _layoutItems() {
    double y = padding.top;

    for (final item in _items) {
      item.size.setValues(size.x - padding.horizontal, item.size.y);
      y += item.size.y + spacing;
    }

    _contentHeight = math.max(0, y - spacing + padding.bottom);
    _scrollOffset = _scrollOffset.clamp(0, maxScrollOffset);

    _rightBorder
      ..position.setValues(size.x, 0)
      ..anchor = Anchor.topRight
      ..size.setValues(padding.right, size.y);

    _leftBorder
      ..position.setValues(0, 0)
      ..anchor = Anchor.topLeft
      ..size.setValues(padding.left, size.y);

    _updateItemPositions();
    _updateScrollbarThumbIndicator();
  }

  void _updateItemPositions() {
    double y = padding.top;

    for (final item in _items) {
      item.position.setValues(padding.left, y - _scrollOffset);
      y += item.size.y + spacing;
    }
  }

  void _updateScrollbarThumbIndicator() {
    if (!_canScroll) {
      _scrollbarThumb.visible = false;

      return;
    }

    _scrollbarThumb.visible = true;

    final trackHeight = size.y - padding.vertical;

    final visibleRatio = size.y / _contentHeight;
    final thumbHeight = math.max(32.0, trackHeight * visibleRatio);

    final scrollRatio = _scrollOffset / maxScrollOffset;
    final thumbY = padding.top + (trackHeight - thumbHeight) * scrollRatio;

    _scrollbarThumb
      ..position.setValues(size.x - (padding.right / 2), thumbY)
      ..size.setValues(6, thumbHeight);
  }

  double get maxScrollOffset {
    return math.max(0, _contentHeight - size.y);
  }

  bool get _canScroll => maxScrollOffset > 0;

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_canScroll) {
      return;
    }

    _scrollOffset -= event.localDelta.y;
    _scrollOffset = _scrollOffset.clamp(0, maxScrollOffset);

    _updateItemPositions();
    _updateScrollbarThumbIndicator();
  }

  @override
  void render(Canvas canvas) {
    canvas.save();

    canvas.clipRect(Rect.fromLTWH(0, 0, size.x, size.y));

    super.render(canvas);

    canvas.restore();
  }
}

class ScrollbarThumbIndicatorComponent extends PositionComponent {
  ScrollbarThumbIndicatorComponent()
    : super(priority: 1000, anchor: Anchor.topCenter);

  final Paint _paint = Paint()..color = Colors.grey;

  bool visible = false;

  @override
  void render(Canvas canvas) {
    if (!visible) {
      return;
    }

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    canvas.drawRect(rect, _paint);
  }
}

class BorderComponent extends PositionComponent {
  BorderComponent() : super(priority: 900);

  final Paint _paint = Paint()..color = Colors.black;

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    canvas.drawRect(rect, _paint);
  }
}
