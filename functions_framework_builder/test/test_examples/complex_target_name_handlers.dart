// Copyright 2020 Google LLC
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

import 'package:functions_framework/functions_framework.dart';

@CloudFunction(target: "'single quotes'")
void function1(CloudEvent request) => throw UnimplementedError();

@CloudFunction(target: '"double quotes"')
void function2(CloudEvent request) => throw UnimplementedError();

@CloudFunction(target: r'$dollar signs$')
void function3(CloudEvent request) => throw UnimplementedError();

@CloudFunction(target: 'white space\t\n\r\nall over')
void function4(CloudEvent request) => throw UnimplementedError();
