import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text(
              'JpsTrack Menu',
              textAlign: TextAlign.end,
              style: TextStyle(color: Colors.black, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: Colors.lightGreen,
                image: DecorationImage(
                    fit: BoxFit.none,
                    image: AssetImage('images/logo.png'))
            ),
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('JpsTrack Intro'),
            onTap: () { },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () { },
          ),
          // XXX More ListTiles here plez
        ],
      ),
    );
  }
}