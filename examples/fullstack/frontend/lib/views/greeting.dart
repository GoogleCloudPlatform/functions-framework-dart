// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_model.dart';

class Greeting extends StatefulWidget {
  @override
  GreetingState createState() => GreetingState();
}

class GreetingState extends State<Greeting> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  FocusNode? _focusNameNode;

  @override
  void initState() {
    super.initState();
    _focusNameNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNameNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                autofocus: true,
                focusNode: _focusNameNode,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name...',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submit(context),
                onSaved: (input) => _name = input,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () => _submit(context),
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      );

  Future<void> _submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final model = context.read<AppModel>();
      await model.greet(_name);

      ScaffoldMessenger.of(context)
          // clear queued snackbars from clicking too fast (only supported
          // in dev channel though)
          // .clearSnackBars()
          .showSnackBar(SnackBar(
        content: Text('${model.salutation}, ${model.name}'),
      ));

      _focusNameNode?.requestFocus();
    }
  }
}
