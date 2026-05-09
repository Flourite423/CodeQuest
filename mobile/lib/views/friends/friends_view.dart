import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendsView extends GetView<FriendsController> {
  const FriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('好友'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 15,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.primaries[index % Colors.primaries.length],
              child: Text('好友$index'),
            ),
            title: Text('好友 $index'),
            subtitle: Text('等级 ${10 + index}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FriendsController extends GetxController {
  final friends = <String>[].obs;
}

class FriendsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FriendsController>(() => FriendsController());
  }
}
