import 'package:flutter/material.dart';
import '../screens/home_screen.dart';

class DrawerNavigation extends StatefulWidget {
  const DrawerNavigation({Key? key}) : super(key: key);

  @override
  State<DrawerNavigation> createState() => _DrawerNavigationState();
}

class _DrawerNavigationState extends State<DrawerNavigation> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(),
              accountName: Text('Const'),
              accountEmail: Text('fite')),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomeScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.view_list),
            title: const Text('Programs'),
            onTap: () {},
          )
        ],
      ),
    );
  }
}
