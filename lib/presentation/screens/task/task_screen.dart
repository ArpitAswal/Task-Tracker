import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/localization/app_localizations.dart';
import 'package:task_tracker/presentation/screens/task/widgets/tasklist_widget.dart';

import '../../providers/task_provider.dart';

class TaskTabView extends StatefulWidget {
  const TaskTabView({super.key, required this.tabController});

  final TabController tabController;
  @override
  State<TaskTabView> createState() => _TaskTabViewState();
}

class _TaskTabViewState extends State<TaskTabView> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: [
          Consumer<TaskProvider>(
            builder: (_, provider, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.tabController.animateTo(0);
                          provider.setTabViewIndex(0);
                        },
                        style: (provider.tabviewIndex == 0)
                            ? Theme.of(context).elevatedButtonTheme.style
                            : Theme.of(context).outlinedButtonTheme.style,
                        child: Text(loc?.translate('pending') ?? ''),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          provider.setTabViewIndex(1);
                          widget.tabController.animateTo(1);
                        },
                        style: (provider.tabviewIndex == 1)
                            ? Theme.of(context).elevatedButtonTheme.style
                            : Theme.of(context).outlinedButtonTheme.style,
                        child: Text(loc?.translate('completed') ?? ''),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: TabBarView(
              controller: widget.tabController,
              children: [
                /// ✅ PENDING TASKS — NOW REACTIVE
                Consumer<TaskProvider>(
                  builder: (_, provider, __) {
                    return buildTaskList(provider.pendingTasks, context, false);
                  },
                ),

                /// ✅ COMPLETED TASKS — NOW REACTIVE
                Consumer<TaskProvider>(
                  builder: (_, provider, __) {
                    return buildTaskList(
                      provider.completedTasks,
                      context,
                      true,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
