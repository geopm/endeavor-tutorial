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

Known Issues
------------
GEOPM requires access to some Model Specific Registers (MSRs).  This
is typically enabled through the msr-safe kernel driver:

    https://github.com/LLNL/msr-safe

Access to this driver on endeavor at the time of this writing can be
made available on a limited basis on some nodes for specific users.
Please contact Christopher Cantalupo
<christopher.m.cantalupo@intel.com> for information about getting
access to msr-safe on endeavor.

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

Profiling and Tracing an Unmodified Application
-----------------------------------------------
The first thing an HPC application user will want to do when
integrating their application with the GEOPM runtime is to analyze
performance of the application without modifying its source code.
This can be enabled by using the GEOPM launcher script to launch the
application while specifying the --geopm-preload option:


    geopmlaunch impi \
                -ppn 4  \
                -n 8 \
                --geopm-preload \
                --geopm-report=tutorial_0.report \
                --geopm-trace=tutorial_0.trace \
                ./tutorial_0

The LD_PRELOAD environment variable set when using the --geopm-preload
option enables the GEOPM library to interpose on MPI using the PMPI
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

A slightly more realistic application
-------------------------------------
Tutorial 1 shows a slightly more realistic application.  This
application implements a loop that does a number of different types of
operations.  In addition to sleeping, the loop does a memory intensive
operation, then a compute intensive operation, then again does a
memory intensive operation followed by a communication intensive
operation.  In this example we are again using GEOPM without including
any GEOPM APIs in the application and using LD_PRELOAD to interpose
GEOPM on MPI.

Adding GEOPM mark up to the application
---------------------------------------
Tutorial 2 takes the application used in tutorial 1 and modifies it
with the GEOPM profiling markup.  This enables the report and trace to
contain region specific information.

Using the Energy Efficient Agent
--------------------------------
There are several GEOPM Agent algorithms to choose from, but in this
tutorial for Endeavor we have highlighted the energy_efficient Agent.
In this demonstration the energy_efficient Agent is run in with two
different policies.  One policy the maximum frequency control is set
to the sticker frequency of the processor and kept there throughout
the run (maximum and minimum frequency in the policy are both set to
sticker).  In the other policy the energy_efficient Agent is allowed
to reduce the frequency by up to 400 MHz or until a 10% degradation in
performance is detected.  In the reports generated, the one named
"efficient.report" should show an energy savings when compared against
the values in the "fixed.report" file.

Agent and IOGroup extension
---------------------------
See agent and iogroup sub-directories and their enclosed README.md
files for information about how to extend the GEOPM runtime through
the development of plugins.

