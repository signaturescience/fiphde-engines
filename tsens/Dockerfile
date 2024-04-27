FROM rocker/r-ver:latest

## add system level dependencies
RUN apt-get update && apt-get install -y libcurl4-openssl-dev libssl-dev libxt6

## copy the renv.lock into the image
COPY renv.lock /renv.lock

## install renv and zeallot outside of renv
RUN Rscript -e 'install.packages(c("renv","zeallot"))'

## set the renv path var to the renv lib
ENV RENV_PATHS_LIBRARY renv/library

## restore packages from renv.lock
RUN Rscript -e 'renv::restore(lockfile="/renv.lock", repos="https://packagemanager.posit.co/cran/__linux__/jammy/latest")'

## install distfromq dependency
RUN Rscript -e 'renv::install("reichlab/distfromq")'

## copy in built R package
COPY fiphde_2.0.0.tar.gz /fiphde_2.0.0.tar.gz

## run script to install built R package from source
RUN Rscript -e 'install.packages("/fiphde_2.0.0.tar.gz", type="source", repos=NULL)'

COPY assets/submission.R /src/submission.R
COPY assets/run.sh /src/run.sh

## run the shell script to initiate forecasting
ENTRYPOINT ["bash", "/src/run.sh"]
