import 'package:signals/signals_flutter.dart';
import 'base_view_model.dart';
import 'loading_state.dart';

abstract class PaginationViewModel<T> extends BaseViewModel {
  final dataList = Signal<List<T>>([]);
  final state = Signal<LoadingState>(LoadingState.initial);
  final errorMessage = Signal<String>('');

  int _pageNum = 1;
  final int pageSize;
  bool _hasMore = true;

  PaginationViewModel({this.pageSize = 20});

  /// 子类需要实现的加载方法
  /// @param pageNum 当前页码
  /// @param pageSize 每页大小
  /// @return 返回加载的数据列表
  Future<List<T>> onLoad(int pageNum, int pageSize);

  /// 刷新数据
  Future<void> refresh() async {
    _pageNum = 1;
    _hasMore = true;
    dataList.value = [];
    await _load();
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (!_hasMore || state.value == LoadingState.loading) return;
    _pageNum++;
    await _load();
  }

  Future<void> _load() async {
    try {
      if (dataList.value.isEmpty) {
        state.value = LoadingState.loading;
      }
      final List<T> items = await onLoad(_pageNum, pageSize);

      if (_pageNum == 1) {
        dataList.value = items;
        if (items.isEmpty) {
          state.value = LoadingState.empty;
          return;
        }
      } else {
        dataList.value = [...dataList.value, ...items];
      }

      _hasMore = items.length >= pageSize;
      state.value = _hasMore ? LoadingState.success : LoadingState.noMore;
    } catch (e) {
      if (_pageNum > 1) _pageNum--;
      errorMessage.value = e.toString();
      state.value = LoadingState.error;
    }
  }

  @override
  void init() {
    super.init();
    refresh();
  }
}
