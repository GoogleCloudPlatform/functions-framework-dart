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

import 'cli_test.dart' as cli_test;
import 'common_test.dart' as common_test;
import 'generators_test.dart' as generators_test;
import 'mock_test.dart' as mock_test;

void main() {
  cli_test.main();
  common_test.main();
  generators_test.main();
  mock_test.main();
}
