/*
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
*/

var Trafficr = Trafficr || {

	frameTimeout: 250,
	newFrameTimeout: 30000,
	
	statusDiv: null,
	frameCanvas: null,
	numFrames: -1,
	frames: new Array(),
	loadedFrames: 0,
	cycleIndex: 0,
	frameStr: '',
	lastMTime: null,

	loadFrames: function() {
		if (Trafficr.statusDiv == null) {
			Trafficr.statusDiv = document.getElementById('trafficr_status');
		}
		
		if (Trafficr.frameCanvas == null) {
			Trafficr.frameCanvas = document.getElementById('trafficr_canvas');
		}
		
		if (Trafficr.statusDiv == null || Trafficr.frameCanvas == null) {
			console.error('Required elements not found: trafficr_status or trafficr_canvas');
		}
		
		Trafficr._clearStatus();
		Trafficr._appendStatus('Loading frames...');
		
		Trafficr._getNumFrames(function() {
			Trafficr.loadedFrames = 0;
			for (i = 0; i < Trafficr.numFrames; i++) {
				Trafficr._loadFrame(i);
			}
		});
	},
	
	_cycleFrame: function() {
		if (Trafficr.frameCanvas == null) {
			return;
		}
		
		ctx = Trafficr.frameCanvas.getContext('2d');
		ctx.drawImage(Trafficr.frames[Trafficr.cycleIndex], 0, 0);
		
		Trafficr._clearStatus();
		
		var startIdx = Trafficr.numFrames - Trafficr.cycleIndex ;
		Trafficr._appendStatus('[' + Trafficr.frameStr.substr(startIdx, Trafficr.numFrames) + '] ' + (Trafficr.cycleIndex + 1));

		Trafficr.cycleIndex++;
		if (Trafficr.cycleIndex >= Trafficr.numFrames) { Trafficr.cycleIndex = 0;}
		
		setTimeout(Trafficr._cycleFrame, Trafficr.frameTimeout);
	},
	
	_loadFrame: function(frameIndex) {
		Trafficr._appendStatus('&rsaquo;');
		var frameNumber = frameIndex + 1;
		Trafficr.frames[frameIndex] = new Image();
		Trafficr.frames[frameIndex].onload = function() {
			Trafficr.loadedFrames++;
			if (Trafficr.loadedFrames == Trafficr.numFrames) {
				Trafficr._clearStatus();
				Trafficr._appendStatus('All frames loaded');
			
				Trafficr.frames.reverse();
				Trafficr.cycleIndex = 0;
			
				Trafficr._cycleFrame();
				Trafficr._getLastMTime();
			}
			else {
				Trafficr._appendStatus('&lsaquo;');
			}
		};
		Trafficr.frames[frameIndex].onerror = Trafficr._frameError;
		Trafficr.frames[frameIndex].src = 'frame.php?f=' + frameNumber + '&t=' + (new Date()).getTime();
	},
	
	_frameError: function() {
		Trafficr._clearStatus();
		Trafficr._appendStatus('Could not load all frames, webcam not ready');
	},
	
	_getLastMTime: function() {
		var xmlhttp = new XMLHttpRequest();

		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == XMLHttpRequest.DONE) {
				if (xmlhttp.status == 200) {
					if (!isNaN(xmlhttp.responseText)) {
						var mtime = parseInt(xmlhttp.responseText);
						if (Trafficr.lastMTime == null) {
							Trafficr.lastMTime = mtime;
						}
						else if (mtime > Trafficr.lastMTime) {
							Trafficr.lastMTime = mtime;
							
							var newFrame = new Image();
							newFrame.onload = function() {
								Trafficr._clearStatus();
								Trafficr._appendStatus('New frame loaded');

								// shift frames over
								Trafficr.frames.push(newFrame);
								Trafficr.frames.shift();
							};
							newFrame.src = 'frame.php?f=1&t=' + (new Date()).getTime();
						}
					}
				}
				
				setTimeout(Trafficr._getLastMTime, Trafficr.newFrameTimeout);
			}
		};

		xmlhttp.open('GET', 'frame.php?l=1', true);
		xmlhttp.send();
	},
	
	_getNumFrames: function(callback) {
		var xmlhttp = new XMLHttpRequest();

		xmlhttp.onreadystatechange = function() {
			if (xmlhttp.readyState == XMLHttpRequest.DONE) {
				if (xmlhttp.status == 200) {
					if (!isNaN(xmlhttp.responseText)) {
						Trafficr.numFrames = parseInt(xmlhttp.responseText);
						
						Trafficr.frameStr = '|';
						for (i = 0; i < Trafficr.numFrames; i++) {
							Trafficr.frameStr += '-';
							Trafficr.frameStr = '-' + Trafficr.frameStr;
						}
					}
				}
				
				if (Trafficr.numFrames == -1) {
					Trafficr._clearStatus();
					Trafficr._appendStatus('Could not load frame count from server');
				}
				else {
					Trafficr._appendStatus(' ' + Trafficr.numFrames + ' total ');
					if (callback != undefined) {
						callback();
					}
				}
			}
		};

		xmlhttp.open('GET', 'frame.php?q=1', true);
		xmlhttp.send();
	},
	
	_clearStatus: function() {
		if (Trafficr.statusDiv == null) {
			return;
		}
		
		Trafficr.statusDiv.innerHTML = '';
	},
	
	_appendStatus: function(status) {
		if (Trafficr.statusDiv == null) {
			return;
		}
		
		Trafficr.statusDiv.innerHTML += status;
	}

};