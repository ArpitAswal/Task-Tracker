import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:task_tracker/presentation/screens/task/widgets/taskcard_widget.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/task_model.dart';

Widget buildTaskList(
  List<TaskModel> tasks,
  BuildContext context,
  bool isCompleted,
) {
  if (tasks.isEmpty) {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.3,
        width: double.infinity,
        child: Lottie.asset(
          AppConstants.taskLottie,
          fit: BoxFit.contain,
          repeat: true,
          reverse: true,
          options: LottieOptions(enableMergePaths: true),
        ),
      ),
    );
  }

  return ListView.builder(
    itemCount: tasks.length,
    itemBuilder: (context, index) {
      return buildTaskCard(tasks[index], context);
    },
  );
}
