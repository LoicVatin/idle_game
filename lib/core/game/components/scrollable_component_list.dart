import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:idle_game/core/game/components/playground_component.dart';
import 'package:idle_game/core/game/components/component_utils.dart';

class ScrollableComponentList extends PositionComponent with DragCallbacks {
  ScrollableComponentList({
    super.position,
    super.size,
    this.spacing = Dimensions.small,
    this.padding = const EdgeInsets.all(Dimensions.small),
  });

  final double spacing;
  final EdgeInsets padding;

  final List<PlaygroundComponent> _items = [];

  late final ScrollbarThumbIndicatorComponent _scrollbarThumb;

  double _scrollOffset = 0;
  double _contentHeight = 0;

  Future<void> setItems(List<PlaygroundComponent> items) async {
    for (final item in _items) {
      item.removeFromParent();
    }

    _items
      ..clear()
      ..addAll(items);

    for (final item in _items) {
      item.priority = Priorities.background;
      await add(item);
    }

    await _ensureBordersMounted();

    _layoutItems();
  }

  Future<void> addItem(PlaygroundComponent item) async {
    _items.add(item);

    item.priority = Priorities.background;
    await add(item);

    await _ensureBordersMounted();

    _layoutItems();
  }

  Future<void> _ensureBordersMounted() async {
    if (!_scrollbarThumb.isMounted) {
      await add(_scrollbarThumb);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
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
    _updateItemPositions();
    _updateScrollbarThumbIndicator();
  }

  void _updateItemPositions() {
    double y = padding.top;

    for (final item in _items) {
      final itemY = y - _scrollOffset;
      item.position.setValues(padding.left, itemY);
      item.isVisible = itemY + item.size.y > 0 && itemY < size.y;
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
    final thumbHeight = math.max(
      Dimensions.regular,
      trackHeight * visibleRatio,
    );

    final scrollRatio = _scrollOffset / maxScrollOffset;
    final thumbY = padding.top + (trackHeight - thumbHeight) * scrollRatio;

    _scrollbarThumb
      ..position.setValues(size.x - (padding.right / 2), thumbY)
      ..size.setValues(Dimensions.tiny, thumbHeight);
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
    : super(priority: Priorities.alwaysOnTop, anchor: Anchor.topCenter);

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
