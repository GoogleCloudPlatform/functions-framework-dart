# Quickstart: Cloud Run

This quickstart discusses how to build and deploy a function using
[Cloud Run], a serverless platform on [Google Cloud].

The instructions in this quickstart can be run from a terminal on your own
machine or from [Cloud Shell], an online development and operations environment,
using the [Cloud Shell Editor].

Using the [Cloud Shell Editor] is beyond the scope of this quickstart, but
this [codelab] can help you get started.

## Prerequisites

The only prerequisites are to have a Google Cloud project ID and the Cloud
SDK (`gcloud`) installed and configured (authenticated) on your machine.

### Set up your Google Cloud project

Go to the [project selector] page. Select an existing or create a new
project. **Note your project ID for later.**

Creating a new project is highly recommended because you can destroy all
resources when you're finished just by deleting the project.

Make sure that billing is enabled for your project ([see how]).

### Set up the Cloud SDK (gcloud)

Install and configure [gcloud].

If you need help installing or configuring `gcloud` on your machine, see
[Quickstart: Getting started with Cloud SDK][quickstart]. Don't forget to run
the `gcloud auth login` command to authenticate your terminal.

> Note: `gcloud` is preinstalled in [Cloud Shell].

### Set your gcloud project

Update your `gcloud` configuration to use your project ID.

```shell
$ gcloud config set core/project <PROJECT-ID>
Updated property [core/project].
```

## Get a copy of the `hello` example

* Run `dartfn` to create a new project using the `helloworld` generator (see
  [Installing and using dartfn])
* Clone this repo or download a [zip] archive and extract the contents
  * Change directory to `examples/hello`.

## Build and deploy with a single command

Use the `gcloud run deploy` command to build and deploy your function in a
single step.

```shell
gcloud run deploy NAME \
  --source=PATH \          # can use $PWD or . for current dir
  --project=PROJECT \      # the Google Cloud project ID
  --region=REGION  \       # ex: us-central1
  --platform=managed \     # for Cloud Run
  --allow-unauthenticated  # for public access
```

Since the project ID was saved to the `gcloud` configuration in the
[Set your gcloud project](#set-your-gcloud-project) section, you can also do the
same for platform and region and omit the arguments from the command line.

> For Cloud Run, the platform must be set to `managed`.
> For a list of regions, run `gcloud compute regions list`.

```shell
gcloud config set run/platform managed
gcloud config set run/region us-central1
```

For example:

```shell
$ gcloud run deploy hello --allow-unauthenticated --source=.
Building using Dockerfile and deploying container to Cloud Run service [hello] in project [dart-demo] region [us-central1]
✓ Building and deploying new service... Done.
  ✓ Uploading sources...
  ✓ Building Container... Logs are available at [https://console.cloud.google.com/cloud-build/builds/df7f07d1-d88b-4443-a2b1-bdfd3cdab15b?project=700116488077].
  ✓ Creating Revision... Revision deployment finished. Waiting for health check to begin.
  ✓ Routing traffic...
  ✓ Setting IAM Policy...
Done.
Service [hello] revision [hello-00001-yen] has been deployed and is serving 100 percent of traffic.
Service URL: https://hello-gpua4upw6q-uc.a.run.app
```

## If connecting to Cloud SQL

If your Cloud Run service will connect to Cloud SQL via the [Cloud SQL Auth Proxy], then it is important
to select the `gen2` Cloud Run execution environment.

**Note:** To do this, you may need to install the `beta` version of the gcloud CLI, but if this is required, you will be prompted. Enter `y` to accept the extra installation.

```shell
gcloud beta run deploy NAME \
  --source=PATH \               # can use $PWD or . for current dir
  --project=PROJECT \           # the Google Cloud project ID
  --region=REGION  \            # ex: us-central1
  --platform=managed \          # for Cloud Run
  --allow-unauthenticated       # for public access
  --execution-environment=gen2  # helpful if using CloudSQL
```

<br>

**Congratulations!** You have successfully built and deployed your function
to Cloud Run. You can now access your function at the Service URL that is
printed in the last line of output.

## Clean up

Cloud Run does not charge when the service is not in use. However, you might
incur charges while the image is still stored in the Container Registry.

You can either just [delete the image] or delete the entire project (which will
free up all resources and stop any other charges from incurring) from
the [Manage resources] page.

---
[[toc]](../README.md) [[back]](02-quickstart-docker.md)

<!-- reference links -->
[Cloud Build]: https://cloud.google.com/cloud-build
[Cloud Run]: https://cloud.google.com/run
[Cloud Shell]: https://cloud.google.com/shell
[Cloud Shell Editor]: https://shell.cloud.google.com/?show=ide&environment_deployment=ide
[Cloud SQL Auth Proxy]: https://github.com/GoogleCloudPlatform/cloud-sql-proxy
[codelab]: https://codelabs.developers.google.com/codelabs/cloud-shell
[delete the image]: https://cloud.google.com/container-registry/docs/managing#deleting_images
[gcloud]: https://cloud.google.com/sdk/docs/install
[Google Cloud]: https://cloud.google.com/gcp
[incur charges]: https://cloud.google.com/container-registry/pricing
[Installing and using dartfn]: 00-install-dartfn.md
[Manage resources]: https://console.cloud.google.com/iam-admin/projects
[project selector]: https://console.cloud.google.com/projectselector2/home/dashboard
[quickstart]: https://cloud.google.com/sdk/docs/quickstart
[see how]: https://cloud.google.com/billing/docs/how-to/modify-project
[zip]: https://github.com/GoogleCloudPlatform/functions-framework-dart/archive/main.zip
