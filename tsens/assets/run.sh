#!/bin/bash

## create relevant output directories
mkdir -p /submission/SigSci-TSENS/artifacts/plots
mkdir -p /submission/SigSci-TSENS/artifacts/params
mkdir -p /config

## run R submission code
Rscript /src/submission.R
