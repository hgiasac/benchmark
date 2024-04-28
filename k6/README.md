# K6 benchmark

## Get Started

```sh
./bench.sh --vus=600 --duration=1m example/RPS-optimized.js
```

Results will be reported in the `output` folder.

## Dependencies

The benchmarks depend on a few utilities to collect the performance results:

- [jq](https://stedolan.github.io/jq/) is used to extract the VUs and RPS values from the JSON output returned by the k6 REST API.
- [curl](https://curl.se/) to make requests to the k6 REST API.
- GNU coreutils like `ps`, `top`, `cat`, `awk`, and Bash itself, of course.
