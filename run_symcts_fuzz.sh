#!/bin/bash

cat <<EOF > experiment_config_symcts_fuzz.yaml
# The number of trials of a fuzzer-benchmark pair.
trials: 2

# The amount of time in seconds that each trial is run for.
# 1 day = 24 * 60 * 60 = 86400
max_total_time: 86400

# The location of the docker registry.
# FIXME: Support custom docker registry.
# See https://github.com/google/fuzzbench/issues/777
docker_registry: gcr.io/fuzzbench

# The local experiment folder that will store most of the experiment data.
# Please use an absolute path.
experiment_filestore: /nvme/lukas/fuzzbench-symcts-fuzz-full-experiment

# The local report folder where HTML reports and summary data will be stored.
# Please use an absolute path.
report_filestore: /nvme/lukas/fuzzbench-symcts-fuzz-full-reports

# Flag that indicates this is a local experiment.
local_experiment: true

snapshot_period: 300
EOF

FUZZERS=(
    libafl
    libafl_symcts_fuzz
)
BENCHMARKS=(
    bloaty_fuzz_target
    curl_curl_fuzzer_http
    freetype2_ftfuzzer
    harfbuzz_hb-shape-fuzzer
    jsoncpp_jsoncpp_fuzzer
    lcms_cms_transform_fuzzer
    libjpeg-turbo_libjpeg_turbo_fuzzer
    libpcap_fuzz_both
    libpng_libpng_read_fuzzer
    libxml2_xml
    libxslt_xpath
    mbedtls_fuzz_dtlsclient
    openh264_decoder_fuzzer
    openssl_x509
    openthread_ot-ip6-send-fuzzer
    proj4_proj_crs_to_crs_fuzzer
    re2_fuzzer
    sqlite3_ossfuzz
    stb_stbi_read_fuzzer
    systemd_fuzz-link-parser
    vorbis_decode_fuzzer
    woff2_convert_woff2ttf_fuzzer
    zlib_zlib_uncompress_fuzzer
)

BUILDS=()
for b in "${BENCHMARKS[@]}"; do
    for f in $FUZZERS; do
        BUILDS+=("build-${f}-${b}")
    done
done
echo "Building ${#BUILDS[@]} images: ${BUILDS[*]}"
# make -j8 "${BUILDS[@]}"
echo "Starting experiment"

set -x
PYTHONPATH=. python3 experiment/run_experiment.py \
  -c experiment_config_symcts_fuzz.yaml \
  --experiment-name symcts-fuzz-experiment-full \
  --allow-uncommitted-changes \
  --fuzzers "${FUZZERS[@]}" \
  --benchmarks "${BENCHMARKS[@]}"
