import 'package:flutter/material.dart';
import 'package:flutter_templates/core/base_view.dart';
import 'package:flutter_templates/core/loading_state_widget.dart';
import 'package:flutter_templates/views/net/net_view_model.dart';
import 'package:signals/signals_flutter.dart';

class NetView extends BaseView<NetViewModel> {
  const NetView({super.key});

  @override
  NetViewModel createViewModel() => NetViewModel();

  @override
  Widget buildView(BuildContext context, NetViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(title: const Text('网络请求')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Watch(
              (_) => LoadingStateWidget(
                state: viewModel.state.value,
                onRetry: () => viewModel.loadImage(),
                child: Image.network(viewModel.imageUrl.value ?? ''),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                viewModel.loadImage();
              },
              child: const Text('请求图片'),
            ),
          ],
        ),
      ),
    );
  }
}
