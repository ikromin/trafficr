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

# Edit parameters below to suit your needs

CAM="/dev/video0"
CAM_CAPTURE_SZ_X=1280
CAM_CAPTURE_SZ_Y=960

FRAME_SZ_X=640
FRAME_SZ_Y=480
FRAME_FONT="DejaVu-Sans"
FRAME_FONT_SIZE="13"

FRAME_TEXT="Trafficr Cam © YourServer.com"
FRAME_TIME="Time: `date`"
FRAME_TEXT_OFFSET_X=10
FRAME_TEXT_OFFSET_X2=11
FRAME_TEXT_OFFSET_Y=7
FRAME_TEXT_OFFSET_Y2=8
FRAME_TEXT_RECT="0,480 640,450"
FRAME_TEXT_RECT_COLOR="#00000090"
FRAME_TEXT_COLOR1="black"
FRAME_TEXT_COLOR2="white"

WORK_DIR="`pwd`"
ARCH_DIR="$WORK_DIR"/Archive/`date +"%Y"`/`date +"%m"`/`date +"%d"`

CAM_NEWFRAME_URL="https://your.server/newframe.php"

FFMPEG_HOME="/usr/bin"
CONVERT_HOME="/usr/bin"

UPLOAD_FRAME=true