#!/bin/bash

source /opt/intel/compiler/latest/bin/compilervars.sh intel64
source /opt/intel/impi/latest/compilers_and_libraries/linux/mpi/intel64/bin/mpivars.sh
source /home/cmcantal/geopm-env.sh

NUM_NODES=2
RANKS_PER_NODE=4
TOTAL_RANKS=$(($RANKS_PER_NODE * $NUM_NODES))

geopmlaunch impi \
            -ppn $RANKS_PER_NODE \
            -n $TOTAL_RANKS \
            -bootstrap ssh \
            --geopm-report=tutorial_0.report \
            --geopm-trace=tutorial_0.trace \
            --geopm-preload \
            -- ./tutorial_0

geopmlaunch impi \
            -ppn $RANKS_PER_NODE \
            -n $TOTAL_RANKS \
            -bootstrap ssh \
            --geopm-report=tutorial_1.report \
            --geopm-trace=tutorial_1.trace \
            --geopm-preload \
            -- ./tutorial_1

geopmlaunch impi \
            -ppn $RANKS_PER_NODE \
            -n $TOTAL_RANKS \
            -bootstrap ssh \
            --geopm-report=tutorial_2.report \
            --geopm-trace=tutorial_2.trace \
            -- ./tutorial_2

echo '{"loop-count": 100,' > bench_config.json
echo ' "region": ["dgemm", "stream"],' >> bench_config.json
echo ' "big-o": [28.0, 1.75]}' >> bench_config.json

STICKER_FREQ=$(geopmread FREQUENCY_STICKER board 0)
MIN_FREQ=$(geopmread FREQUENCY_MIN board 0)
PERF_MARGIN=0.1

geopmagent -a energy_efficient \
           -p $MIN_FREQ,$STICKER_FREQ,$PERF_MARGIN \
           > efficient_policy.json

geopmagent -a energy_efficient \
           -p $STICKER_FREQ,$STICKER_FREQ,$PERF_MARGIN \
           > fixed_policy.json

geopmlaunch impi \
            -ppn $RANKS_PER_NODE \
            -n $TOTAL_RANKS \
            -bootstrap ssh \
            --geopm-report=fixed.report \
            --geopm-agent=energy_efficient \
            --geopm-policy=fixed_policy.json \
            -- geopmbench bench_config.json

geopmlaunch impi \
            -ppn $RANKS_PER_NODE \
            -n $TOTAL_RANKS \
            -bootstrap ssh \
            --geopm-report=efficient.report \
            --geopm-agent=energy_efficient \
            --geopm-policy=efficient_policy.json \
            -- geopmbench bench_config.json

