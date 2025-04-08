import 'package:flutter/material.dart';
import 'loading_state.dart';

class LoadingStateWidget extends StatelessWidget {
  final LoadingState state;
  final Widget child;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const LoadingStateWidget({
    super.key,
    required this.state,
    required this.child,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case LoadingState.initial:
        return const Center(child: Text('初始化...'));
      case LoadingState.loading:
        return const Center(child: Text('加载中...'));
      case LoadingState.success:
      case LoadingState.noMore:
        return child;
      case LoadingState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage ?? '加载失败'),
              if (onRetry != null)
                TextButton(onPressed: onRetry, child: const Text('重试')),
            ],
          ),
        );
      case LoadingState.empty:
        return const Center(child: Text('暂无数据'));
    }
  }
}
