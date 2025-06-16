import 'package:flutter/material.dart';

/// 一组可展开的 Widget，可以控制内部的展开和收起状态
class ExpandableGroup extends StatefulWidget {
  final List<ExpandableChild> children;
  final int initialExpandedIndex;

  const ExpandableGroup({
    super.key,
    required this.children,
    this.initialExpandedIndex = -1,
  });

  @override
  State<ExpandableGroup> createState() => _ExpandableGroupState();
}

class _ExpandableGroupState extends State<ExpandableGroup> {
  int _expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    _expandedIndex = widget.initialExpandedIndex;
  }

  void _handleExpansionChanged(int index, bool isExpanded) {
    setState(() {
      if (isExpanded) {
        _expandedIndex = index;
      } else if (_expandedIndex == index) {
        _expandedIndex = -1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          widget.children
              .asMap()
              .entries
              .map(
                (entry) => ExpandableWidget(
                  key: entry.value.key,
                  header: entry.value.header,
                  body: entry.value.body,
                  initiallyExpanded: _expandedIndex == entry.key,
                  onExpansionChanged: (isExpanded) {
                    entry.value.onExpansionChanged?.call(isExpanded);

                    _handleExpansionChanged(entry.key, isExpanded);

                    if (isExpanded && entry.key != _expandedIndex) {
                      for (var i = 0; i < widget.children.length; i++) {
                        if (i != entry.key) {
                          widget.children[i].controller.collapse();
                        }
                      }
                    }
                  },
                  indicatorBuilder: entry.value.indicatorBuilder,
                  indicatorPosition: entry.value.indicatorPosition,
                  indicatorOverlay: entry.value.indicatorOverlay,
                  animationDuration: entry.value.animationDuration,
                  backgroundColor: entry.value.backgroundColor,
                  headerBackgroundColor:
                      entry.value.headerBackgroundColor ?? Colors.transparent,
                ),
              )
              .toList(),
    );
  }
}

class ExpandableChild {
  ExpandableChild({
    this.key,
    required this.header,
    required this.body,
    this.indicatorBuilder,
    this.indicatorPosition = IndicatorPosition.endCenter,
    this.indicatorOverlay = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onExpansionChanged,
    this.backgroundColor,
    this.headerBackgroundColor,
  }) : controller = ExpandableController();

  final Key? key;
  final Widget header;
  final Widget body;
  final Widget Function(BuildContext, bool, Animation<double>)?
  indicatorBuilder;
  final IndicatorPosition indicatorPosition;
  final bool indicatorOverlay;
  final Duration animationDuration;
  final ValueChanged<bool>? onExpansionChanged;
  final Color? backgroundColor;
  final Color? headerBackgroundColor;
  final ExpandableController controller;
}

class ExpandableController {
  VoidCallback? _expandCallback;
  VoidCallback? _collapseCallback;

  void expand() {
    if (_expandCallback != null) {
      _expandCallback!();
    }
  }

  void collapse() {
    if (_collapseCallback != null) {
      _collapseCallback!();
    }
  }

  void registerCallbacks({
    required VoidCallback onExpand,
    required VoidCallback onCollapse,
  }) {
    _expandCallback = onExpand;
    _collapseCallback = onCollapse;
  }
}

/// 可展开的 Widget，可以自定义头部和内容部分以及展开图标
class ExpandableWidget extends StatefulWidget {
  const ExpandableWidget({
    super.key,
    required this.header,
    required this.body,
    this.initiallyExpanded = false,
    this.indicatorBuilder,
    this.indicatorPosition = IndicatorPosition.endCenter,
    this.indicatorOverlay = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onExpansionChanged,
    this.backgroundColor,
    this.headerBackgroundColor,
    this.controller,
  });

  final ExpandableController? controller;

  /// 头部Widget
  final Widget header;

  /// 内容Widget
  final Widget body;

  /// 是否默认展开
  final bool initiallyExpanded;

  /// 自定义指示器构建器
  /// 参数分别为当前上下文、是否展开状态、动画值
  final Widget Function(
    BuildContext context,
    bool isExpanded,
    Animation<double> animation,
  )?
  indicatorBuilder;

  /// 指示器位置
  final IndicatorPosition indicatorPosition;

  /// 指示器是否悬浮在头部上
  final bool indicatorOverlay;

  /// 动画持续时间
  final Duration animationDuration;

  /// 展开/收起状态改变回调
  final ValueChanged<bool>? onExpansionChanged;

  /// 背景颜色
  final Color? backgroundColor;

  /// 头部背景颜色
  final Color? headerBackgroundColor;

  @override
  State<ExpandableWidget> createState() => _ExpandableWidgetState();
}

class _ExpandableWidgetState extends State<ExpandableWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }

    if (widget.controller != null) {
      widget.controller!.registerCallbacks(
        onExpand: () {
          if (!_isExpanded) {
            _toggleExpand();
          }
        },
        onCollapse: () {
          if (_isExpanded) {
            _toggleExpand();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }

      if (widget.onExpansionChanged != null) {
        widget.onExpansionChanged!(_isExpanded);
      }
    });
  }

  CrossAxisAlignment _getCrossAxisAlignment(IndicatorPosition position) {
    switch (position) {
      case IndicatorPosition.startTop:
      case IndicatorPosition.endTop:
        return CrossAxisAlignment.start;
      case IndicatorPosition.startBottom:
      case IndicatorPosition.endBottom:
        return CrossAxisAlignment.end;
      default:
        return CrossAxisAlignment.center;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final ThemeData theme = Theme.of(context);

    Widget? indicator;
    if (widget.indicatorBuilder != null) {
      indicator = widget.indicatorBuilder!(context, _isExpanded, _animation);
    } else {
      // 默认指示器
      indicator = Padding(
        padding: const EdgeInsets.all(8.0),
        child: RotationTransition(
          turns: Tween(begin: 0.0, end: 0.5).animate(_animation),
          child: const Icon(Icons.keyboard_arrow_down),
        ),
      );
    }

    // 构建头部
    Widget headerWidget;
    if (widget.indicatorPosition == IndicatorPosition.none) {
      headerWidget = widget.header;
    } else if (widget.indicatorOverlay) {
      // 当指示器需要悬浮在header上时，使用Stack布局
      final bool isStart =
          widget.indicatorPosition == IndicatorPosition.startTop ||
          widget.indicatorPosition == IndicatorPosition.startCenter ||
          widget.indicatorPosition == IndicatorPosition.startBottom;

      // final bool isEnd =
      //     widget.indicatorPosition == IndicatorPosition.endTop ||
      //     widget.indicatorPosition == IndicatorPosition.endCenter ||
      //     widget.indicatorPosition == IndicatorPosition.endBottom;

      Alignment alignment = Alignment.center; // 默认中间对齐

      // 确定垂直对齐方式
      if (widget.indicatorPosition == IndicatorPosition.startTop ||
          widget.indicatorPosition == IndicatorPosition.endTop) {
        alignment = isStart ? Alignment.topLeft : Alignment.topRight;
      } else if (widget.indicatorPosition == IndicatorPosition.startCenter ||
          widget.indicatorPosition == IndicatorPosition.endCenter) {
        alignment = isStart ? Alignment.centerLeft : Alignment.centerRight;
      } else if (widget.indicatorPosition == IndicatorPosition.startBottom ||
          widget.indicatorPosition == IndicatorPosition.endBottom) {
        alignment = isStart ? Alignment.bottomLeft : Alignment.bottomRight;
      }

      headerWidget = Stack(
        children: [
          widget.header,
          Positioned.fill(child: Align(alignment: alignment, child: indicator)),
        ],
      );
    } else {
      // 使用Row布局
      final bool isStart =
          widget.indicatorPosition == IndicatorPosition.startTop ||
          widget.indicatorPosition == IndicatorPosition.startCenter ||
          widget.indicatorPosition == IndicatorPosition.startBottom;

      final bool isEnd =
          widget.indicatorPosition == IndicatorPosition.endTop ||
          widget.indicatorPosition == IndicatorPosition.endCenter ||
          widget.indicatorPosition == IndicatorPosition.endBottom;

      Widget startIndicator = isStart ? indicator : const SizedBox();
      Widget endIndicator = isEnd ? indicator : const SizedBox();

      headerWidget = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: _getCrossAxisAlignment(widget.indicatorPosition),
        children: [
          startIndicator,
          if (isStart) const SizedBox(width: 8),
          Expanded(child: widget.header),
          if (isEnd) const SizedBox(width: 8),
          endIndicator,
        ],
      );
    }

    headerWidget = InkWell(onTap: _toggleExpand, child: headerWidget);

    // 构建内容
    final Widget bodyWidget = AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return ClipRect(
          child: Align(heightFactor: _animation.value, child: child),
        );
      },
      child: widget.body,
    );

    // 组合最终组件
    return Container(
      color: widget.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[headerWidget, bodyWidget],
      ),
    );
  }
}

enum IndicatorPosition {
  startTop,
  startCenter,
  startBottom,
  endTop,
  endCenter,
  endBottom,
  none,
}
