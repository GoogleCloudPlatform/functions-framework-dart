import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_model.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<AppModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
      ),
      body: ListView.builder(
        itemCount: model.pastGreetings.length,
        itemBuilder: (context, index) {
          final greeting = model.pastGreetings[index];
          return ListTile(
              title: Text('${greeting.salutation}, ${greeting.name}'));
        },
      ),
    );
  }
}
