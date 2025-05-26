import 'dart:async';

mixin AutoDispose {
  final subscriptionList = <StreamSubscription>[];

  void addSubscription(StreamSubscription subscription) {
    subscriptionList.add(subscription);
  }

  void clearSubscriptions() {
    for (final subscription in subscriptionList) {
      subscription.cancel();
    }
    subscriptionList.clear();
  }
}
