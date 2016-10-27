<?php
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

require "config.php";

// Set no caching headers
header('Expires: Sat, 26 Jul 1997 05:00:00 GMT');
header('Cache-Control: no-store, no-cache, must-revalidate');
header('Cache-Control: post-check=0, pre-check=0', false); 
header('Pragma: no-cache'); 

// Check if frame is requested
if (isset($_GET['f']) && is_numeric($_GET['f'])) {
	$n = intval($_GET['f']);
	if ($n > 0 && $n <= $totalFiles) {
		$imgFile = $fileNameStub . $n . $fileNameExt;
		
		if (file_exists($imgFile)) {
			$imgData = file_get_contents($imgFile);

			header('Content-Length: '.strlen($imgData));
			header('Content-Type: image/jpeg');
			header('Content-Disposition: attachment; filename="' . $fileNameStub . time() . $fileNameExt . '"');

			echo $imgData;
			exit;
		}
	}
}
// Check if total frame count is requested
else if (isset($_GET['q'])) {
	echo $totalFiles;
	exit;
}
// Check if last modified date is requested
else if (isset($_GET['l'])) {
	$imgFile = $fileNameStub . '1' . $fileNameExt;
	if (file_exists($imgFile)) {
		echo filemtime($imgFile);
	}
	exit;
}

http_response_code(400);
echo 'Invalid request';

?>