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

# Load configuration from external file
source "`pwd`/config.sh"

export PATH=$FFMPEG_HOME:$CONVERT_HOME:$PATH
PWD_FILE="`pwd`/htpasswd.txt"

function checkCmd {
	command -v $1 >/dev/null 2>&1 || {
		echo >&2 "$1 not available, aborting";
		exit 1
	}
}

# Check for password file
if [ "$UPLOAD_FRAME" == true ] && [ ! -f $PWD_FILE ]; then
	echo "Can't find password file"
	exit 2;
fi

# Check all the tools exist
checkCmd v4l2-ctl
checkCmd ffmpeg
checkCmd convert
checkCmd curl

# Set webcam to do automatic compensation and exposure
echo "Configuring webcam"
v4l2-ctl -c backlight_compensation=1
v4l2-ctl -c white_balance_temperature_auto=1
v4l2-ctl -c exposure_auto=1

# Make sure archive directory exists
mkdir -p $ARCH_DIR

# Capture a single frame from the webcam at full resolution
echo "Capturing frame"
rm -f "$WORK_DIR/frame_o.png"
ffmpeg -v 24 -y -f v4l2 -input_format yuyv422 -video_size "${CAM_CAPTURE_SZ_X}x${CAM_CAPTURE_SZ_Y}" -i $CAM -vframes 1 "$WORK_DIR/frame_o.png"

# Make sure we've captured something
if [ ! -f "$WORK_DIR/frame_o.png" ]; then
	echo "Could not capture frame from webcam"
	exit 3
fi

# Scale down, convert to JPEG and archive
echo "Scaling and converting image to JPEG"
convert "$WORK_DIR/frame_o.png" -adaptive-resize "${FRAME_SZ_X}x${FRAME_SZ_Y}"\> -unsharp 2 "$WORK_DIR/frame_o.jpeg"

echo "Archiving frame"
cp -v "$WORK_DIR/frame_o.jpeg" "$ARCH_DIR"/arch_`date +"%Y%m%d%H%M%S"`.jpeg

# Sharpen image
echo "Sharpening image"
convert "$WORK_DIR/frame_o.jpeg" -sharpen 0x.4 "$WORK_DIR/frame_s.jpeg"

# Add watermarking
echo "Adding watermarking"
DRAW_CMD="\
gravity south-west fill '$FRAME_TEXT_RECT_COLOR' \
rectangle $FRAME_TEXT_RECT \
fill '$FRAME_TEXT_COLOR1' text $FRAME_TEXT_OFFSET_X2,$FRAME_TEXT_OFFSET_Y2 '$FRAME_TEXT' \
fill '$FRAME_TEXT_COLOR2' text $FRAME_TEXT_OFFSET_X,$FRAME_TEXT_OFFSET_Y '$FRAME_TEXT' \
gravity south-east \
fill '$FRAME_TEXT_COLOR1' text $FRAME_TEXT_OFFSET_X2,$FRAME_TEXT_OFFSET_Y2 '$FRAME_TIME' \
fill '$FRAME_TEXT_COLOR2' text $FRAME_TEXT_OFFSET_X,$FRAME_TEXT_OFFSET_Y '$FRAME_TIME'"
convert "$WORK_DIR/frame_s.jpeg" -font "$FRAME_FONT" -pointsize $FRAME_FONT_SIZE -draw "$DRAW_CMD" "$WORK_DIR/frame.jpeg"

if [ "$UPLOAD_FRAME" == true ]; then
	echo "Uploading frame"
	HTTP_AUTH=$(<$PWD_FILE)
	curl -v -u "$HTTP_AUTH" -k -F filedata=@"$WORK_DIR/frame.jpeg" $CAM_NEWFRAME_URL
else
	echo "Skipping frame upload"
fi