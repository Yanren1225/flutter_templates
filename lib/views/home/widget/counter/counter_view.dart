import 'package:flutter/material.dart';
import 'package:flutter_templates/core/base_view.dart';
import 'package:flutter_templates/core/base_view_model.dart';
import 'package:signals/signals_flutter.dart';

class CounterViewModel extends BaseViewModel {
  final number = signal(0);

  void increment() {
    number.value++;
  }
}

class CounterView extends BaseView<CounterViewModel> {
  const CounterView({super.key});

  @override
  CounterViewModel createViewModel() => CounterViewModel();

  @override
  Widget buildView(BuildContext context, CounterViewModel viewModel) {
    return Center(
      child: Column(
        children: [
          Watch((_) => Text(viewModel.number.value.toString())),
          ElevatedButton(
            onPressed: () {
              viewModel.increment();
            },
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}
