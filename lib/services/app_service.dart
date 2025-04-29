import 'package:flutter_templates/core/event_bus.dart';
import 'package:flutter_templates/core/service.dart';

class AppService extends Service {
  @override
  void onInit() {
    super.onInit();

    addSubscription(EventBus.instance.on((event) {}));
  }
}
