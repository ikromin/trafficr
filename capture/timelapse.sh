#!/bin/bash

# Copyright 2016 Igor Kromin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARCH_DIR=/Volumes/Ext_Data/Photos/TrafficCam
WORK_DIR=.

# Create temporary archive directory
mkdir -p "$WORK_DIR/_tl"

# Copy files to archive directory
for i in `find $ARCH_DIR -name "arch_20??????0000??.jpeg"`; do cp $i "$WORK_DIR/_tl"; done;
