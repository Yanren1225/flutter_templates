import 'package:flutter/material.dart';
import 'package:flutter_templates/core/base_view.dart';
import 'package:flutter_templates/router/router_ext.dart';
import 'package:flutter_templates/views/home/home_view_model.dart';
import 'package:flutter_templates/views/home/widget/counter/counter_view.dart';
import 'package:flutter_templates/views/home/widget/loading/loading_view.dart';
import 'package:signals/signals_flutter.dart';

class HomeView extends BaseView<HomeViewModel> {
  const HomeView({super.key});

  @override
  HomeViewModel createViewModel() => HomeViewModel();

  @override
  Widget buildView(BuildContext context, viewModel) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'net':
                  context.toNet();
                  break;
                case 'list':
                  context.toList();
                  break;
              }
            },
            itemBuilder:
                (_) => [
                  const PopupMenuItem<String>(
                    value: 'net',
                    child: Text('网络请求'),
                  ),
                  PopupMenuItem<String>(value: 'list', child: Text('列表加载')),
                ],
          ),
        ],
      ),
      body: Watch(
        (_) => IndexedStack(
          index: viewModel.index.value,
          children: [LoadingView(), CounterView()],
        ),
      ),
      bottomNavigationBar: Watch(
        (_) => BottomNavigationBar(
          currentIndex: viewModel.index.value,
          onTap: (index) {
            viewModel.index.value = index;
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time),
              label: 'Loading',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.plus_one),
              label: 'Counter',
            ),
          ],
        ),
      ),
    );
  }
}
