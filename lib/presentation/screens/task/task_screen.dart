import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/localization/app_localizations.dart';
import 'package:task_tracker/core/utils/extensions/context_extension.dart';
import 'package:task_tracker/presentation/screens/task/widgets/tasklist_widget.dart';
import 'package:task_tracker/presentation/widgets/common/custom_shimmer_widget.dart';

import '../../../core/utils/extensions/widget_extensions.dart';
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
                padding: EdgeInsets.symmetric(horizontal: (context.isTablet) ? 24 : 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: context.themedTabButton(
                        label: loc?.translate('pending') ?? '',
                        isSelected: provider.tabviewIndex == 0,
                        onPressed: () {
                          widget.tabController.animateTo(0);
                          provider.setTabViewIndex(0);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: context.themedTabButton(
                        label: loc?.translate('completed') ?? '',
                        isSelected: provider.tabviewIndex == 1,
                        onPressed: () {
                          provider.setTabViewIndex(1);
                          widget.tabController.animateTo(1);
                        },
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
                    if (provider.isInitialLoading) {
                      return ListView.builder(
                        itemCount: (context.screenWidth > 600) ? 8 : 5,
                        itemBuilder: (context, index) =>
                            const TaskCardShimmer(),
                      );
                    }
                    return buildTaskList(provider.pendingTasks, context, false);
                  },
                ),

                /// ✅ COMPLETED TASKS — NOW REACTIVE
                Consumer<TaskProvider>(
                  builder: (_, provider, __) {
                    if (provider.isInitialLoading) {
                      return ListView.builder(
                        itemCount: (context.screenWidth > 600) ? 8 : 5,
                        itemBuilder: (context, index) =>
                            const TaskCardShimmer(),
                      );
                    }
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
