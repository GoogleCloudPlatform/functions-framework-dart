# How to Contribute

We'd love to accept your patches and contributions to this project. There are
just a few small guidelines you need to follow.

## Contributor License Agreement

Contributions to this project must be accompanied by a Contributor License
Agreement (CLA). You (or your employer) retain the copyright to your
contribution; this simply gives us permission to use and redistribute your
contributions as part of the project. Head over to
<https://cla.developers.google.com/> to see your current agreements on file or
to sign a new one.

You generally only need to submit a CLA once, so if you've already submitted one
(even if it was for a different project), you probably don't need to do it
again.

## Community guidelines

This project follows
[Google's Open Source Community Guidelines](https://opensource.google/conduct/).

## Code reviews

All submissions, including submissions by project members, require review. We
use GitHub pull requests for this purpose. Consult
[GitHub Help](https://help.github.com/articles/about-pull-requests/) for more
information on using pull requests.

### Presubmit checks

Before submitting a pull request, you should run the following from the repo's 
root directory:

```shell
$ mono_repo presubmit
```

This will run package tests, ensure a clean build, and identify formatting and
lint issues.

Ensure there are no failures (`skipped` is okay). Address any errors, 
formatting, and lint issues before you submit your code. These tests are also
run automatically as continuous integration (CI) builds, but your pull requests
won't get attention until these pass anyway, so addressing these early as part
of presubmit is more expeditious as well as more professional.

### Conformance tests

We're just starting on passing conformance tests.

First, sync and build this repository locally.

https://github.com/GoogleCloudPlatform/functions-framework-conformance

To run the tests locally:

#### HTTP

```console
$ $FUNCTION_FRAMEWORK_CONFORMANCE_PATH/client/client -buildpacks=false -start-delay 3 -type=http -cmd="dart test/hello/bin/server.dart --target conformanceHttp"
```

#### Cloud events

```console
$ $FUNCTION_FRAMEWORK_CONFORMANCE_PATH/client/client -buildpacks=false -start-delay 3 -type=cloudevent -cmd="dart test/hello/bin/server.dart --target conformanceCloudEvent --signature-type cloudevent" --validate-mapping=false
```

This corresponds to the configuration in `.github/workflows/conformance.yml`.
