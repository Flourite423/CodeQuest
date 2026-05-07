import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CourseDetailView extends GetView<CourseController> {
  const CourseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.book, size: 80, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Course Title',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Course description goes here. This is a detailed description of what the course covers and what students will learn.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Lessons',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text('Lesson ${index + 1}'),
                    subtitle: const Text('10 min'),
                    trailing: const Icon(Icons.play_circle_outline),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CourseController extends GetxController {
  final courseId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    courseId.value = Get.parameters['id'] ?? '';
  }
}

class CourseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CourseController>(() => CourseController());
  }
}
