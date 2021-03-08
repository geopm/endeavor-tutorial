GEOPM ENDEAVOR TUTORIAL
=======================
This directory contains a step by step tutorial on how to use the
GEOPM package on the Endeavor system.  There is a script that can be
submitted to LSF to execute all of the tutorial steps:

    ./tutorial_bsub ./tutorial_all.sh

The first script, "tutorial_bsub", sets bsub command line arguments
for the run.  The second script "tutorial_all.sh" runs a sequence
of experiments that are documented here.

This tutorial is derived from the more general GEOPM tutorial that
is distributed as part of the source code:

https://github.com/geopm/geopm/tree/dev/tutorial


General
-------
To use GEOPM you will need access to certain MSR (model specific
registers) on the compute nodes. Full access to all MSRs is not
permitted for security reasons. We use the "msr_safe" kernel driver to
grant access to a certain MSRs on an allowed list. As this enables you to
control certain power constraints the nodes will be automatically
rebooted after your job is completed. This ensures no changes to MSRs
a user can do would impact the next user on the same node.  How to
enable MSR_SAFE access:

- You need to be in group msr_safe to use MSRs. Access requires a
  business reason - write an e-mail with your request and
  justification to crt-dc@intel.com.

- To enable the msr_safe kernel module use: bsub -l MSRSAFE=1 ....
  nodes will be rebooted after job is done so DO NOT spam jobs with
  this option.

- BKM is to use an interactive job and do all measurements within a
  single job. High node count jobs should be announced to
  crt-dc@intel.com.

Environment
-----------
Throughout this tutorial we assume that the user will be compiling
with the Intel toolchain and executing MPI applications with the Intel
MPI implementation.  To add these to your environment please execute the
following two commands in a bash shell:

    source /opt/intel/compiler/latest/bin/compilervars.sh intel64
    source /opt/intel/impi/latest/compilers_and_libraries/linux/mpi/intel64/bin/mpivars.sh

The latest GEOPM build is maintained by Christopher Cantalupo
<christopher.m.cantalupo@intel.com> and can be added to your
environment by executing the following command in a bash shell:

    source /home/cmcantal/geopm-env.sh

Note that in addition to setting up your paths and exporting variables
that can be used for compiling applications against GEOPM, this script
also adds all of the GEOPM man pages to your man path.  The overview
man page for geopm can be viewed with the following command:

    man geopm

All other geopm man pages are listed in the "SEE ALSO" section of the
overview page.

Building the tutorials
----------------------
A simple Makefile compiles the tutorial code, and there is a script
set up to build with the intel toolchain that uses this Makefile.  After
following the instructions above to set up your environment, simply execute
the intel build script to build the tutorials.

    ./tutorial_build_intel.sh

This will generate the binaries called tutorial_0, tutorial_1, and tutorial_2.

0. Profiling and Tracing an Unmodified Application
--------------------------------------------------
The first thing an HPC application user will want to do when
integrating their application with the GEOPM runtime is to analyze
performance of the application without modifying its source code.
This can be enabled by using the GEOPM launcher script to launch the
application:


    geopmlaunch impi \
                -ppn 4  \
                -n 8 \
                --geopm-report=tutorial_0.report \
                --geopm-trace=tutorial_0.trace \
                ./tutorial_0

The LD_PRELOAD environment variable is set when using the geopmlaunch
which enables the GEOPM library to interpose on MPI using the PMPI
interface.  Linking directly to libgeopm has the same effect, but this
is not done in the Makefile for tutorial_0 or tutorial_1.  See the
geopm(7) man page for a detailed description of the other environment
variables.

The tutorial_0.c application is an extremely simple MPI application.
It queries the size of the world communicator, prints it out from rank
0 and sleeps for 5 seconds.

Since the command above uses the default controller launch option
equivalent to specifying "--geopm-ctl=process" you will notice that
the MPI world communicator is reported to have one fewer rank per
compute node than the was requested when the job was submitted by the
launcher.  This is because the GEOPM controller is using one rank per
compute node to execute the runtime and has removed this rank from the
world communicator.  This is important to understand when launching
the controller in this way.

The summary report will be created in the file named

    tutorial_0.report

and one trace file will be output for each compute node and the name
of each trace file will be extended with the host name of the node it
describes:

    tutorial_0_trace-`hostname`

The report file will contain information about time and energy spent
in MPI regions and outside of MPI regions as well as the average CPU
frequency.

1. A slightly more realistic application
----------------------------------------
Tutorial 1 shows a slightly more realistic application.  This
application implements a loop that does a number of different types of
operations.  In addition to sleeping, the loop does a memory intensive
operation, then a compute intensive operation, then again does a
memory intensive operation followed by a communication intensive
operation.  In this example we are again using GEOPM without including
any GEOPM APIs in the application and using LD_PRELOAD to interpose
GEOPM on MPI.

2. Adding GEOPM mark up to the application
------------------------------------------
Tutorial 2 takes the application used in tutorial 1 and modifies it
with the GEOPM profiling markup.  This enables the report and trace to
contain region specific information.

3. Adding work imbalance to the application
-------------------------------------------
Tutorial 3 modifies tutorial 2 removing all but the compute intensive
region from the application and then adding work imbalance across the
MPI ranks.  This tutorial also uses a modified implementation of the
DGEMM region which does set up and shutdown once per application run
rather than once per main loop iteration.  In this way the main
application loop is focused entirely on the DGEMM operation.  Note an
MPI_Barrier has also been added to the loop.  The work imbalance is
done by assigning the first half of the MPI ranks 10% more work than
the second half.  In this example we also enable GEOPM to do control
in addition to simply profiling the application.  This is enabled
through the GEOPM_POLICY environment variable which refers to a json
formatted policy file.  This control is intended to synchronize the
run time of each rank to overcome this load imbalance.  The tutorial 3
script executes the application with two different policies.  The
first run enforces a uniform power budget of 150 Watts to each compute
node using the governing agent alone, and the second run enforces an
average power budget of 150 Watts across all compute nodes while
diverting power to the nodes which have more work to do using the
balancing agent.


4. Adding artificial imbalance to the application
-------------------------------------------------
Tutorial 4 enables artificial injection of imbalance.  This differs
from from tutorial by 3 having the application sleep for a period of
time proportional to the amount of work done rather than simply
increasing the amount of work done.  This type of modeling is useful
when the amount of work within cannot be easily scaled.  The imbalance
is controlled by a file who's path is given by the IMBALANCER_CONFIG
environment variable.  This file gives a list of hostnames and
imbalance injection fraction.  An example file might be:

    my-cluster-node3 0.25
    my-cluster-node11 0.15

which would inject 25% extra time on node with hostname
"my-cluster-node3" and 15% extra time on node "my-cluster-node11" for
each pass through the loop.  All nodes which have hostnames that are
not included in the configuration file will perform normally.  The
tutorial_4.sh script will create a configuration file called
"tutorial_3_imbalance.conf" if one does not exist, and one of the
nodes will have a 10% injection of imbalance.  The node is chosen
arbitrarily by a race if the configuration file is not present.

5. Using the progress interface
-------------------------------
A computational application may make use of the geopm_tprof_init()
and geopm_tprof_post() interfaces to report fractional progress
through a region to the controller.  These interfaces are documented
in the geopm_prof_c(3) man page.  In tutorial 5 we modify the stream
region to send progress updates though either the threaded or
unthreaded interface depending on if OpenMP is enabled at compile
time.  Note that the unmodified tutorial build scripts do enable
OpenMP, so the geopm_tprof\* interfaces will be used by default.  The
progress values recorded can be seen in the trace output.

6. The model application
------------------------
Tutorial 6 uses the geopmbench tool and configures it with the json
input file.  The geopmbench application is documented in the
geopmbench(1) man page and can be use to to a wide range of
experiments with GEOPM.  Note that geopmbench is used in most
of the GEOPM integration tests.

7. Agent and IOGroup extension
------------------------------
See agent and iogroup sub-directories and their enclosed README.md
files for information about how to extend the GEOPM runtime through
the development of plugins.

8. YouTube Videos
-----------------
A video demonstration of these tutorials is available online here:

https://www.youtube.com/playlist?list=PLwm-z8c2AbIBU-T7HnMi_Pux7iO3gQQnz

These videos do not reflect changes that have happened to GEOPM since
September 2016 when they were recorded.  In particular, the videos do
not use the geopmpy.launcher launch wrapper which was introduced prior
to the v0.3.0 alpha release.  The tutorial scripts have been updated
to use the launcher, but the videos have not.  These videos also use
the Decider/Platform/PlatformImp code path which are deprecated and
will be removed in the 1.0 release in favor of the
Agent/PlatformIO/IOGroup class relationship.
