import 'package:flutter/material.dart';

/// 动态行布局
///
/// ```dart
/// DynamicRow(
///   itemCount: 5,
///   itemBuilder: (context, index) {
///     return Text('Item $index');
///   },
///   separatorBuilder: (context, index) {
///     return Divider();
///   },
///   direction: Axis.horizontal,
/// )
/// ```
class DynamicRow extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final Axis direction;

  const DynamicRow({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.direction = Axis.horizontal,
  }) : assert(itemCount > 0, 'itemCount must be greater than 0'),
       assert(
         direction == Axis.horizontal || direction == Axis.vertical,
         'direction must be either Axis.horizontal or Axis.vertical',
       );

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: direction,
      children: List.generate(itemCount * 2 - 1, (index) {
        if (index.isOdd && separatorBuilder != null) {
          return separatorBuilder!(context, index ~/ 2);
        }
        return itemBuilder(context, index ~/ 2);
      }),
    );
  }
}
