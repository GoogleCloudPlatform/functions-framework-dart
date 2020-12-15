Unless otherwise noted, follow the guidance here:
https://github.com/dart-lang/sdk/wiki/External-Package-Maintenance

The most important rules are:

1. Never publish anything that is not committed.
1. Never commit anything that hasn't been reviewed and approved.

It's critical to keep in mind that in the Dart package ecosystem, publishing is
_forever_.
This means special care has to be taken to make sure that everything is correct
before a package is published. The Dart team has spent hours and in some cases
days fixing problems due to a mistake when publishing.
It is hard to be _too_ careful here.

Assuming that we want to release both
[`functions_framework`](https://pub.dev/packages/functions_framework) and
[`functions_framework_builder`](https://pub.dev/packages/functions_framework_builder)
at the same time, follow these steps.

1. Prepare a PR to release `functions_framework`.
   - Remove the `-dev` from `pubspec.yaml` and `CHANGELOG.md`.
1. Get the PR approved and commit it.
1. Publish `functions_framework`.
1. Tag the commit with the package name and version.
   - The tag should be in the format of `[package_name]-v[version]`.
   - e.g. `functions_framework-v1.2.3`
1. Prepare a PR to release `functions_framework_builder`
   - Make sure to remove the `dev_dependencies` section and update the
     dependency on `functions_framework` to the just published version.
   - Remove the `-dev` from `pubspec.yaml` and `CHANGELOG.md`.
1. Get the PR approved and commit it.
1. Publish `functions_framework_builder`.
1. Tag the commit with the package name and version.
1. Prepare a PR to update the examples to the latest stable versions.
   - Make sure that `pub upgrade` actually resolves to the just published
     versions.
1. Get the PR approved and commit it.
