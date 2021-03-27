import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'JpsTrack Menu',
              style: TextStyle(color: Colors.black, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: Colors.lightGreen,
                image: DecorationImage(
                    fit: BoxFit.none,
                    image: AssetImage('images/logo.png')) // Need logo here
            ),
          ),
          ListTile(
            leading: Icon(Icons.input),
            title: Text('JpsTrack Intro'),
            onTap: () { },
          ),
          // XXX More ListTiles here plez
        ],
      ),
    );
  }
}