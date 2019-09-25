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

TUTORIAL_BIN = tutorial_0 \
               tutorial_1 \
               tutorial_2 \
               # end

CC ?= gcc
CXX ?= g++
MPICC ?= mpicc
MPICXX ?= mpicxx

all: $(TUTORIAL_BIN)

tutorial_0.o: tutorial_0.c
	$(MPICC) $(CFLAGS) -c $^ -o $@

tutorial_0: tutorial_0.o
	$(MPICC) $(LDFLAGS) $^ -o $@

tutorial_1.o: tutorial_1.c
	$(MPICC) $(CFLAGS) -c $^ -o $@

tutorial_1: tutorial_1.o tutorial_region.o
	$(MPICC) $(LDFLAGS) $^ -o $@

tutorial_2.o: tutorial_2.c
	$(MPICC) $(CFLAGS) -c $^ -o $@

tutorial_2: tutorial_2.o tutorial_region.o
	$(MPICC) $(LDFLAGS) -lgeopm $^  -o $@

tutorial_region.o: tutorial_region.c tutorial_region.h
	$(MPICC) $(CFLAGS) -c tutorial_region.c -o $@

clean:
	rm -f $(TUTORIAL_BIN) *.o

.PHONY: all clean
