import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'base_view_model.dart';

abstract class BaseView<T extends BaseViewModel> extends StatefulWidget {
  const BaseView({super.key});

  @override
  State<BaseView<T>> createState() => BaseViewState<T>();

  /// 视图模型
  T createViewModel();

  /// 构建视图
  Widget buildView(BuildContext context, T viewModel);

  /// 视图模型初始化后回调
  @protected
  void onViewModelReady(T viewModel) {}

  /// 构建错误时的视图
  @protected
  Widget buildError(BuildContext context, Object error) =>
      Center(child: Text('发生错误: ${error.toString()}'));
}

class BaseViewState<T extends BaseViewModel> extends State<BaseView<T>> {
  late final T viewModel;
  Object? _initError;

  @nonVirtual
  @override
  void initState() {
    super.initState();
    try {
      viewModel = widget.createViewModel();
      viewModel.init();
      widget.onViewModelReady(viewModel);
    } catch (e) {
      _initError = e;
      debugPrint('ViewModel初始化错误: $e');
    }
  }

  @nonVirtual
  @override
  void dispose() {
    if (_initError == null) {
      viewModel.dispose();
    }
    super.dispose();
  }

  @nonVirtual
  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return widget.buildError(context, _initError!);
    }

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return widget.buildView(context, viewModel);
      },
    );
  }
}
