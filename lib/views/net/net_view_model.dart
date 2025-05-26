import 'package:flutter_templates/core/base_view_model.dart';
import 'package:flutter_templates/core/loading_state.dart';
import 'package:flutter_templates/http/http_client.dart';
import 'package:signals/signals_flutter.dart';

class NetViewModel extends BaseViewModel {
  final state = signal(LoadingState.initial);
  final imageUrl = signal<String?>(null);

  void loadImage() async {
    state.value = LoadingState.loading;
    final result = await RawHttpClient.get(
      'https://deno-api.imyan.ren/spotlight?format=url',
    );

    if (result.data != null &&
        result.data is String &&
        result.data.isNotEmpty) {
      state.value = LoadingState.success;
      imageUrl.value = result.data;
    } else {
      state.value = LoadingState.error;
      imageUrl.value = null;
    }
  }
}
