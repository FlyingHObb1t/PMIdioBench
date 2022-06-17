#!/bin/bash
### Idiosyncrasy Test 2
### Asymmetric load/p-store bandwidth

source scripts/config.sh

echo ""
echo "$0 $@"

#rm -rf /dev/shm/*
echo "DRAM load and nt-store b/w"
PMEM_DIR="/dev/shm" NJOBS="28" WORKLOADS="SeqR SeqW" PMEM_IS_PMEM_FORCE=1 DIRECT=1 scripts/run_fio.sh i2-dram-nt
sleep 2
NJOBS="28" WORKLOADS="SeqR SeqW" scripts/get_fio_results.sh i2-dram-nt
sleep 2
echo "DRAM store+clwb b/w"
PMEM_DIR="/dev/shm" NJOBS="28" WORKLOADS="SeqW" PMEM_IS_PMEM_FORCE=1 DIRECT=0 scripts/run_fio.sh i2-dram-s
sleep 2
NJOBS="28" WORKLOADS="SeqW" scripts/get_fio_results.sh i2-dram-s
sleep 2

echo "PMEM load b/w"
PMEM_DIR=$PMEM_DIR1 NJOBS="28" WORKLOADS="SeqR" DIRECT=1 scripts/run_fio.sh i2-pmem-nt
sleep 2
NJOBS="28" WORKLOADS="SeqR" scripts/get_fio_results.sh i2-pmem-nt
sleep 2
echo "PMEM nt-store b/w"
PMEM_DIR=$PMEM_DIR1 NJOBS="8" WORKLOADS="SeqW" DIRECT=1 scripts/run_fio.sh pmem-i2-nt
sleep 2
NJOBS="8" WORKLOADS="SeqW" scripts/get_fio_results.sh pmem-i2-nt
sleep 2
echo "PMEM store+clwb b/w"
PMEM_DIR=$PMEM_DIR1 NJOBS="8" WORKLOADS="SeqW" DIRECT=0 scripts/run_fio.sh i2-pmem-s
sleep 2
NJOBS="8" WORKLOADS="SeqW" scripts/get_fio_results.sh i2-pmem-s
sleep 2
