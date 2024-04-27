#  FIPHDE model engines

```
docker build -t fiphde-tsens:latest -t fiphde-tsens:2.0.0 tsens/.
```

```
subdir="/local/path/to/submission/directory"

docker run --rm -v $subdir:/submission --env-file=tsens/vars.env --cpus="4" fiphde-tsens:latest
```
