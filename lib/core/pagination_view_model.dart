import 'package:flutter_templates/core/custom_pagination_view_model.dart';

import 'loading_state.dart';

abstract class PaginationViewModel<T> extends CustomPaginationViewModel<T> {
  @override
  Future<void> loadMore() async {
    if (!hasMore || state.value == LoadingState.loading) return;
    try {
      increasePage();
      final data = await _load();
      if (data == null || data.isEmpty) {
        decreasePage();
        hasMore = false;
      } else {
        updateDataList(data);
      }
    } catch (e) {
      decreasePage();
    }
  }

  @override
  Future<void> refresh({bool first = false}) async {
    try {
      resetPage();
      final data = await _load();
      if (data == null || data.isEmpty) {
        dataList.clear();
      } else {
        dataList.clear();
        updateDataList(data);
      }
    } catch (e) {
      if (first) dataList.clear();
    }
  }

  Future<List<T>?> _load() async {
    try {
      if (dataList.isEmpty) {
        state.value = LoadingState.loading;
      }
      final data = await onLoadData(pageNum);

      if (data == null) {
        state.value = LoadingState.empty;
        return null;
      }
      if (pageNum == 1 && data.isEmpty) {
        state.value = LoadingState.empty;
        return null;
      } else {
        state.value = LoadingState.success;
        return data;
      }
    } catch (e) {
      state.value = LoadingState.error;
      return [];
    }
  }

  @override
  void updateDataList(List<T> items) {
    if (dataList.value.isEmpty) {
      dataList.value = items;
    } else {
      dataList.addAll(items);
    }
    onCompleted(items);
  }

  void onCompleted(List<T> newItems) {}
}
