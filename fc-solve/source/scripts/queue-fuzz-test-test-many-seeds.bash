#!/bin/bash
export USE_C="1"
export FCS_PATH="$(pwd)"
let items_per_page=2
let data_seed=500
while true ; do
    for seed in `seq 1 20`; do
        if ! perl scripts/queue-fuzz-test.pl "$items_per_page" "$data_seed" "$seed" ; then
            echo "Fuzz test program failed with items_per_page=$items_per_page data_seed=$data_seed and interval_seed=$seed"
            exit 1
        fi
    done
    let items_per_page++
done
