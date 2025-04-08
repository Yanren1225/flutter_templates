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
}

class BaseViewState<T extends BaseViewModel> extends State<BaseView<T>> {
  late final T viewModel;

  @nonVirtual
  @override
  void initState() {
    super.initState();
    viewModel = widget.createViewModel();
    viewModel.init();
  }

  @nonVirtual
  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @nonVirtual
  @override
  Widget build(BuildContext context) {
    return widget.buildView(context, viewModel);
  }
}
