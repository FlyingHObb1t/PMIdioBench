#!/bin/bash
### Idiosyncrasy Test 6
### Sequential IO faster than random IO

source scripts/config.sh

echo ""
echo "$0 $@"

rm -rf /dev/shm/*
echo "DRAM Seq and Rand Read b/w"
NJOBS=16 PMEM_DIR="/dev/shm" WORKLOADS="SeqR RandR" PMEM_IS_PMEM_FORCE=1 scripts/run_fio.sh i6-dram-bw
sleep 2
NJOBS=16 WORKLOADS="SeqR RandR" scripts/get_fio_results.sh i6-dram-bw
sleep 2

echo "PMEM Seq and Rand Read b/w"
NJOBS=16 PMEM_DIR=$PMEM_DIR1 WORKLOADS="SeqR RandR" scripts/run_fio.sh i6-pmem-bw
sleep 2
NJOBS=16 WORKLOADS="SeqR RandR" scripts/get_fio_results.sh i6-pmem-bw
sleep 2

echo "PMEM Seq Read counters"
TOOL="ipmw" NJOBS=16 BSIZE=256 PMEM_DIR=$PMEM_DIR1 WORKLOADS="SeqR" scripts/run_fio.sh i6-pmem-counters
sleep 2
echo "PMEM Rand Read counters"
TOOL="ipmw" NJOBS=16 BSIZE=256 PMEM_DIR=$PMEM_DIR1 WORKLOADS="RandR" scripts/run_fio.sh i6-pmem-counters
sleep 2
