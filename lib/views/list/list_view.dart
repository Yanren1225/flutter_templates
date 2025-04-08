import 'package:flutter/material.dart';
import 'package:flutter_templates/core/base_view.dart';
import 'package:flutter_templates/core/loading_state.dart';
import 'package:flutter_templates/core/loading_state_widget.dart';
import 'package:flutter_templates/views/list/list_view_model.dart';
import 'package:signals/signals_flutter.dart';

class ListView extends BaseView<ListViewModel> {
  const ListView({super.key});

  @override
  ListViewModel createViewModel() => ListViewModel();

  @override
  Widget buildView(BuildContext context, ListViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(title: Text('列表加载')),
      body: RefreshIndicator(
        child: Watch((_) {
          return LoadingStateWidget(
            state: viewModel.state.value,
            onRetry: () => viewModel.refresh(),
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final data = viewModel.dataList.value[index];
                    // 当滚动到最后一项时加载更多
                    if (index == viewModel.dataList.value.length - 1) {
                      viewModel.loadMore();
                    }
                    return ListTile(title: Text(data));
                  }, childCount: viewModel.dataList.value.length),
                ),
                if (viewModel.state.value == LoadingState.noMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: Text('没有更多数据了')),
                    ),
                  ),
              ],
            ),
          );
        }),
        onRefresh: () => viewModel.refresh(),
      ),
    );
  }
}
