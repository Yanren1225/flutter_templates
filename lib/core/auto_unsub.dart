mixin AutoUnsub {
  final subscriptionList = <Function>[];

  void addSubscription(Function subscription) {
    subscriptionList.add(subscription);
  }

  void clearSubscriptions() {
    for (final subscription in subscriptionList) {
      subscription();
    }
    subscriptionList.clear();
  }
}
