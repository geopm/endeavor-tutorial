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

if [ $# -eq 1 ] && [ $1 == '--help' ]; then
    echo "test-msr-safe: Test existance and permissions of msr_safe devices on Endeavor."
    exit 0
fi

ls -l /dev/cpu/*/msr_safe /dev/cpu/msr_batch > ls-msr.out
err=$?
if [ $err -ne 0 ]; then
    echo "Error: test-msr-safe: All device files for msr_safe are not present" 1>&2
    exit $err
fi

KEY='^crw-rw---- 1 root msr_safe'
NUM_BAD_LINES=$(grep -v "$KEY" ls-msr.out | wc -l)
if [ $NUM_BAD_LINES -ne 0 ]; then
    grep -v "$KEY" ls-msr.out 1>&2
    echo "Error: test-msr-safe: Permissions incorrectly set for some msr_safe device files" 1>&2
    exit -1
fi

rm ls-msr.out
echo "Success: test-msr-safe"
exit 0
