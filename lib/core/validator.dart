class ValidationError {
  final String message;

  ValidationError(this.message);

  @override
  String toString() => message;
}

class SingleFieldValidator<T> {
  final List<_SingleValidationRule<T>> _rules = [];

  void addRule(bool Function(T) condition, String errorMessage) {
    _rules.add(_SingleValidationRule(condition, errorMessage));
  }

  void validate(T value) {
    for (var rule in _rules) {
      if (!rule.condition(value)) {
        throw ValidationError(rule.errorMessage);
      }
    }
  }
}

class MultiFieldValidator {
  final List<_MultiValidationRule> _rules = [];

  /// 如果 condition 为 false 则抛出 ValidationError
  /// 也就是说这里的条件是必须满足的条件
  void addRule(bool Function() condition, String errorMessage) {
    _rules.add(_MultiValidationRule(condition, errorMessage));
  }

  void validate() {
    for (var rule in _rules) {
      if (!rule.condition()) {
        throw ValidationError(rule.errorMessage);
      }
    }
  }
}

class _SingleValidationRule<T> {
  final bool Function(T) condition;
  final String errorMessage;

  _SingleValidationRule(this.condition, this.errorMessage);
}

class _MultiValidationRule {
  final bool Function() condition;
  final String errorMessage;

  _MultiValidationRule(this.condition, this.errorMessage);
}
