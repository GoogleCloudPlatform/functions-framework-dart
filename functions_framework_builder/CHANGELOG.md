# 0.1.1-dev

* Add a number of checks to the builder to make sure the annotations are used
  on the correct type of functions.
* Renamed the builder library from `functions_framework_builder.dart` to
  `builder.dart`. This is the convention for builders. This is potentially
  breaking for anyone why imports this library – but that's not expected.
* Hid the `FunctionsFrameworkGenerator` class. Not meant for external
  consumption.

# 0.1.0 - 2020-11-23

This is a preview release of the Functions Framework Builder package for Dart to
demonstrate http functions support only (cloudevent support is not yet
implemented). This is a work in progress and currently does not pass conformance
testing.
