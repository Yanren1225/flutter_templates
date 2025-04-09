import 'package:meta/meta.dart';
import 'package:signals/signals_flutter.dart';
import 'base_view_model.dart';
import 'loading_state.dart';

/// 用于自定义分页加载的控制器
/// 提供了更灵活的状态控制，允许完全自定义加载逻辑
abstract class CustomPaginationViewModel<T> extends BaseViewModel {
  final dataList = listSignal<T>([]);
  final state = Signal<LoadingState>(LoadingState.initial);
  final errorMessage = Signal<String>('');

  int _pageNum = 1;
  final int pageSize;
  bool _hasMore = true;

  CustomPaginationViewModel({this.pageSize = 20});

  /// 获取当前页码
  int get pageNum => _pageNum;

  /// 是否还有更多数据
  bool get hasMore => _hasMore;

  /// 设置是否还有更多数据
  set hasMore(bool value) {
    _hasMore = value;
    if (!value) {
      state.value = LoadingState.noMore;
    }
  }

  /// 重置页码
  void resetPage() {
    _pageNum = 1;
    _hasMore = true;
  }

  /// 增加页码
  void increasePage() {
    _pageNum++;
  }

  /// 减少页码
  void decreasePage() {
    if (_pageNum > 1) _pageNum--;
  }

  Future<List<T>?> onLoadData(int pageNum);

  /// 更新数据列表
  void updateDataList(List<T> newItems);

  /// 更新加载状态
  @protected
  void updateState(LoadingState newState) {
    state.value = newState;
  }

  /// 更新错误信息
  @protected
  void updateError(String message) {
    errorMessage.value = message;
  }

  /// 检查是否应该加载更多
  @protected
  bool shouldLoadMore() {
    return hasMore && state.value != LoadingState.loading;
  }

  /// 自定义刷新逻辑
  Future<void> refresh({bool first = false}) async {
    try {
      resetPage();
      final data = await onLoadData(pageNum);
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

  /// 自定义加载更多逻辑
  Future<void> loadMore();

  @override
  void init() {
    super.init();
    refresh(first: true);
  }
}
