#  FIPHDE model engines

## Overview

The contents of this repository provide instructions and assets necessary to build containerized model engines to run the Forecasting Influenza for Public Health Decision Making (FIPHDE) pipeline. 

Each model engine is built as a Docker image that can be instantiated as a container. The instructions to build the image and run the container are provided below.

Note that currently the only model engine provided is the time series ensemble (TSENS).

## Build the image

The image is available as a GitHub Package and can be pulled as follows:

```
docker pull ghcr.io/signaturescience/fiphde-tsens:latest
docker pull ghcr.io/signaturescience/fiphde-tsens:2.0.0
```

Alternatively to build and tag the TSENS engine, use the command below from the root of this repository:

```
docker build -t fiphde-tsens:latest -t fiphde-tsens:2.0.0 tsens/.
```

## Running the container engine

To run, the container model engine requires a mounted volume to which the submission results will be written. In the example below, this is passed to the container as a bind mount to a local directory specified in an environment variable called "subdir". The container also requires environment variables specified in a file called "var.env":

```
subdir="/local/path/to/submission/directory"

docker run --rm -v $subdir:/submission --env-file=tsens/var.env --cpus="4" fiphde-tsens:latest
```
