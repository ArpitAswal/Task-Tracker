import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/core/localization/app_localizations.dart';
import 'package:task_tracker/data/models/user_model.dart';
import 'package:task_tracker/presentation/providers/auth_provider.dart';

class MySlider extends StatelessWidget {
  final Function(int) onItemSelected;

  const MySlider({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final List<IconData> icons = [Icons.home, Icons.person, Icons.settings];
    final List<String> texts = [
      loc?.translate('home') ?? 'Home',
      loc?.translate('profile_label') ?? 'Profile',
      loc?.translate('settings') ?? 'Settings',
    ];

    return Selector<AuthProvider, UserModel?>(
      builder: (context, user, _) {
        final na = loc?.translate('na') ?? 'NA';
        return _buildDrawer(
          context,
          user?.email ?? na,
          user?.displayName ?? na,
          loc,
          icons,
          texts,
        );
      },
      selector: (_, provider) => provider.userData,
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    String userEmail,
    String userName,
    AppLocalizations? loc,
    List<IconData> icons,
    List<String> texts,
  ) {
    Size size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 18.0),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            minRadius: 32,
            maxRadius: 52,
            backgroundImage: AssetImage('assets/images/employees.png'),
          ),
          SizedBox(height: size.height * 0.025),
          Expanded(
            child: ListView.builder(
              itemCount: icons.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, i) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                leading: Icon(icons[i], color: Colors.white, size: 30),
                title: Text(
                  texts[i],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onTap: () => onItemSelected(i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
