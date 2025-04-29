TypeChecker<T> checkType<T>() => TypeChecker<T>();

class TypeChecker<T> {
  bool isExtendOf<P>() => <T>[] is List<P>;
  bool isSuperOf<P>() => <T>[] is List<P>;
}
