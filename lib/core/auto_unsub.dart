import 'dart:async';

mixin AutoUnsub {
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
