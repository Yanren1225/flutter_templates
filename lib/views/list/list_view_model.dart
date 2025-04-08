import 'package:flutter_templates/core/pagination_view_model.dart';

class ListViewModel extends PaginationViewModel<String> {
  @override
  Future<List<String>> onLoad(int pageNum, int pageSize) {
    if (pageNum == 10) {
      return Future.value([]);
    }

    return Future.delayed(const Duration(seconds: 2), () {
      return List.generate(
        pageSize,
        (index) => 'Item ${pageNum * pageSize + index}',
      );
    });
  }
}
