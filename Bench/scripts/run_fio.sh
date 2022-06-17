#!/bin/bash

source scripts/config.sh

function tool_cmdline()
{
	local TOOL=$1

	if [ "$TOOL" == "ipmw" ]; then
		echo "scripts/ipmw.sh"
	elif [ "$TOOL" == "flame-graph" ]; then
		echo "scripts/flame_graph.sh results/"$ENGINE""$workload"-"$njobs"-"$bsize"-"$case".svg fio"
	else
		echo ""
	fi
}

# Number of threads
: ${NJOBS:="1 2 4 8 16 28"}

# Block (IO) size
: ${BSIZE:="64 128 256 512 1024 2048 4096"}

# Workloads
: ${WORKLOADS:="SeqR SeqW RandR RandW"}

# Engine
: ${ENGINE:="Libpmem"}

# PMEM data dir
: ${PMEM_DIR:="/mnt/pmem1"}

# NUMA node to pin workload to
: ${NUMA_NODE:=0}

# Analysis tool
: ${TOOL:=""} # ipmw or flame-graph

case=$1

# Uncomment to use AVX512f nt-stores
#export PMEM_AVX512F=1

# Uncomment to only use nt-stores
#export PMEM_MOVNT_THRESHOLD=0

# Uncomment to disable nt-stores
#export PMEM_NO_MOVNT=1

# Uncomment to disable cache flush
#export PMEM_NO_FLUSH=1

#if [ ! -z "${PMEM_MOVNT_THRESHOLD}" ] && [ $PMEM_MOVNT_THRESHOLD -eq 0 ]; then
#	DIRECT=1
#else
#	#DIRECT=0
#fi

: ${DIRECT:=0}
: ${SYNC:=1}

if [ ! -z "$NUMA_NODE" ] && [ $NUMA_NODE -eq 1 ]; then
	NUMA="28-55"
else
	NUMA="0-27"
fi


mkdir -p results

for njobs in ${NJOBS[*]}; do
	for bsize in ${BSIZE[*]}; do
		for workload in ${WORKLOADS[*]}; do
			# Copy job file
			cp workloads/fio/"$ENGINE""$workload".fio.in workloads/fio/"$ENGINE""$workload".fio

			# Update configuration
			sed -i -- "s/NJOBS/$njobs/g" workloads/fio/"$ENGINE""$workload".fio
			sed -i -- "s/BSIZE/$bsize/g" workloads/fio/"$ENGINE""$workload".fio
			sed -i -- "s/SYNC/$SYNC/g" workloads/fio/"$ENGINE""$workload".fio
			sed -i -- "s/DIRECT/$DIRECT/g" workloads/fio/"$ENGINE""$workload".fio
			sed -i -- "s/NUMA/$NUMA/g" workloads/fio/"$ENGINE""$workload".fio
			sed -i -- "s+PMEM_DIR+$PMEM_DIR+g" workloads/fio/"$ENGINE""$workload".fio

			# Run test
			$FIO_HOME/fio --output=results/"$ENGINE""$workload"-"$njobs"-"$bsize"-"$case".log workloads/fio/"$ENGINE""$workload".fio
			sleep 5
		done
	done
done
