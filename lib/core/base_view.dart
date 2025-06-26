import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'base_view_model.dart';

abstract class BaseView<T extends BaseViewModel> extends StatelessWidget {
  const BaseView({super.key});

  T createViewModel();

  @protected
  T viewModel(BuildContext context) => Provider.of<T>(context, listen: false);

  Widget buildView(BuildContext context, T viewModel);

  @protected
  void onViewModelReady(T viewModel) {}

  @protected
  Widget buildError(BuildContext context, Object error) =>
      Center(child: Text('发生错误: ${error.toString()}'));

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        try {
          final viewModel = createViewModel();
          viewModel.init();
          onViewModelReady(viewModel);
          return viewModel;
        } catch (e) {
          debugPrint('ViewModel初始化错误: $e');
          return throw e;
        }
      },
      dispose: (context, value) => value.dispose(),
      child: Consumer<T>(
        builder: (context, viewModel, _) => buildView(context, viewModel),
      ),
    );
  }
}
