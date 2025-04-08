import 'package:flutter/material.dart';
import 'package:flutter_templates/core/base_view.dart';
import 'package:flutter_templates/core/base_view_model.dart';
import 'package:flutter_templates/core/loading_state.dart';
import 'package:flutter_templates/core/loading_state_widget.dart';
import 'package:signals/signals_flutter.dart';

class LoadingViewModel extends BaseViewModel {
  final state = signal(LoadingState.initial);

  @override
  void init() {
    super.init();

    state.value = LoadingState.success;
  }

  void loading() {
    state.value = LoadingState.loading;
    Future.delayed(const Duration(seconds: 2), () {
      state.value = LoadingState.success;
    });
  }
}

class LoadingView extends BaseView<LoadingViewModel> {
  const LoadingView({super.key});

  @override
  LoadingViewModel createViewModel() => LoadingViewModel();

  @override
  Widget buildView(BuildContext context, LoadingViewModel viewModel) {
    return Center(
      child: Watch((_) {
        return LoadingStateWidget(
          state: viewModel.state.value,
          child: ElevatedButton(
            onPressed: () {
              viewModel.loading();
            },
            child: Text('点击开始加载'),
          ),
        );
      }),
    );
  }
}
