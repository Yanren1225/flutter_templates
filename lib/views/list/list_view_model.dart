import 'package:flutter_templates/core/pagination_view_model.dart';

class ListViewModel extends PaginationViewModel<String> {
  @override
  Future<List<String>?> onLoadData(int pageNum) {
    if (pageNum == 10) {
      return Future.value([]);
    }

    return Future.delayed(Duration(seconds: pageNum == 1 ? 2 : 0), () {
      return List.generate(
        pageSize,
        (index) => 'Item ${pageNum * pageSize + index}',
      );
    });
  }
}
