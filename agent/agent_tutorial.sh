#!/bin/bash
#
#  Copyright (c) 2015, 2016, 2017, 2018, 2019, Intel Corporation
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#
#      * Redistributions of source code must retain the above copyright
#        notice, this list of conditions and the following disclaimer.
#
#      * Redistributions in binary form must reproduce the above copyright
#        notice, this list of conditions and the following disclaimer in
#        the documentation and/or other materials provided with the
#        distribution.
#
#      * Neither the name of Intel Corporation nor the names of its
#        contributors may be used to endorse or promote products derived
#        from this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY LOG OF THE USE
#  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

set err=0
. ../tutorial_env.sh

export PATH=$GEOPM_BINDIR:$PATH
export PYTHONPATH=$GEOPMPY_PKGDIR:$PYTHONPATH
export LD_LIBRARY_PATH=$GEOPM_LIBDIR:$LD_LIBRARY_PATH

# ensure both required plugins can be found
export GEOPM_TUTORIAL=..
export GEOPM_PLUGIN_PATH=$GEOPM_TUTORIAL/iogroup:$GEOPM_TUTORIAL/agent

echo "Redirecting output to example.stdout and example.stderr."

# Run on 2 nodes
# with 8 MPI ranks
# launch geopm controller as an MPI process
# create a report file
# create trace files
if [ "$GEOPM_LAUNCHER" = "srun" ]; then
    # Use GEOPM launcher wrapper script with SLURM's srun
    geopmlaunch srun \
                -N 2 \
                -n 8 \
                --geopm-ctl=process \
                --geopm-report=agent_tutorial_report \
                --geopm-trace=agent_tutorial_trace \
                --geopm-agent=example \
                --geopm-policy=example_policy.json \
                -- geopmbench agent_tutorial_config.json \
                1>example.stdout 2>example.stderr
    err=$?
elif [ "$GEOPM_LAUNCHER" = "aprun" ]; then
    # Use GEOPM launcher wrapper script with ALPS's aprun
    geopmlaunch aprun \
                -N 4 \
                -n 8 \
                --geopm-ctl=process \
                --geopm-report=agent_tutorial_report \
                --geopm-trace=agent_tutorial_trace \
                --geopm-agent=example \
                --geopm-policy=example_policy.json \
                -- geopmbench agent_tutorial_config.json \
                1>example.stdout 2>example.stderr
    err=$?
elif [ "$MPIEXEC" ]; then
    # Use MPIEXEC and set GEOPM environment variables to launch the job
    LD_DYNAMIC_WEAK=true \
    GEOPM_PMPI_CTL=process \
    GEOPM_REPORT=agent_tutorial_report \
    GEOPM_TRACE=agent_tutorial_trace \
    GEOPM_POLICY=example_policy.json \
    GEOPM_AGENT=example \
    $MPIEXEC \
    geopmbench agent_tutorial_config.json
    err=$?
else
    echo "Error: agent_tutorial.sh: set GEOPM_LAUNCHER to 'srun' or 'aprun'." 2>&1
    echo "       If SLURM or ALPS are not available, set MPIEXEC to" 2>&1
    echo "       a command that will launch an MPI job on your system" 2>&1
    echo "       using 2 nodes and 10 processes." 2>&1
    err=1
fi

exit $err