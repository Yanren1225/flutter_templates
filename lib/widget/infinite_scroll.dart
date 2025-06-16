import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

class InfiniteScroll extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final Future<void> Function() loadMore;
  final bool hasMore;
  final String? endMessage;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final Future<void> Function()? onRefresh;
  final double spacing;
  final double autoLoadMoreDistance;
  final bool shrinkWrap;

  const InfiniteScroll({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    required this.loadMore,
    required this.hasMore,
    required this.onRefresh,
    this.endMessage,
    this.padding,
    this.controller,
    this.spacing = 0,
    this.autoLoadMoreDistance = 200,
    this.shrinkWrap = false,
  });

  @override
  State<InfiniteScroll> createState() => _InfiniteScrollState();
}

class _InfiniteScrollState extends State<InfiniteScroll> {
  late EasyRefreshController _refreshController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshController = EasyRefreshController();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      controller: _refreshController,
      onLoad: widget.hasMore
          ? () async {
              await widget.loadMore();
              _refreshController.finishLoad();
            }
          : null,
      onRefresh: widget.onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (!widget.hasMore || _isLoading) return false;
          if (notification is ScrollUpdateNotification) {
            final metrics = notification.metrics;
            if (metrics.pixels >=
                metrics.maxScrollExtent - widget.autoLoadMoreDistance) {
              _isLoading = true;
              _refreshController.callLoad();
              widget.loadMore().whenComplete(() {
                _isLoading = false;
                _refreshController.finishLoad();
              });
            }
          }
          return false;
        },
        child: ListView.separated(
          controller: widget.controller,
          padding: widget.padding,
          shrinkWrap: widget.shrinkWrap,
          itemCount: widget.hasMore ? widget.itemCount : widget.itemCount + 1,
          itemBuilder: (context, index) {
            if (!widget.hasMore && index == widget.itemCount) {
              if (widget.endMessage == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    widget.endMessage!,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              );
            }
            return widget.itemBuilder(context, index);
          },
          separatorBuilder: (context, index) =>
              SizedBox(height: widget.spacing),
        ),
      ),
    );
  }
}
