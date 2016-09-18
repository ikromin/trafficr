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

// Request authentication if not set
if (!isset($_SERVER['REMOTE_USER'])) {
	header('WWW-Authenticate: Basic realm="Trafficr"');
	http_response_code(401);
	echo 'Not authorized';
	exit;
}
else {
	$upfile = current($_FILES);

	if ($upfile['type'] == 'image/jpeg' && $upfile['name'] == $fileNameStub.$fileNameExt) {
		// move the uploaded file into the 0-index
		$updfile = $fileNameStub . '0' . $fileNameExt;
		if (move_uploaded_file($upfile["tmp_name"], $updfile)) {
			/*
			Files are copied like this (by index):
				0 -> 1
				1 -> 2
				...
				n -> n+1
			Moving of files starts at index n-1 and continues to index 0 in 
			reverse order.
			The file with the highest starting index gets dropped off as a result.
			*/
			for ($i = $totalFiles - 1; $i >= 0; $i--) {
				$ni = $i + 1;
				$fromFile = $fileNameStub . $i . $fileNameExt;
				$toFile = $fileNameStub . $ni . $fileNameExt;
			
				if (file_exists($fromFile)) {
					copy($fromFile, $toFile);
				}
			}
			echo 'OK';
		}
	}
	else {
		http_response_code(400);
		echo 'Invalid request';
	}
}

?>