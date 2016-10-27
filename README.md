# Trafficr

A collections of scripts to set up your time lapse web site quickly. Geared towards setting up traffic cams.

![alt text](https://github.com/ikromin/trafficr/raw/master/ScreenShot20161027.png "ScreenShot20161027")

## Features

  * Video4Linux based capture of webcam images
  * Configurable image scaling and watermarking
  * Secure frame upload to web site
  * Frame archival

# Requirements

  * Linux with Bash installed
  * Video4Linux
  * FFMPEG
  * cURL
  * ImageMagick

# Installation

Installing Trafficr is a two-part process. It is assumed that the web cam and the web site where the webcam frames are located are two different servers. Hence, the installation requires setting up the webcam frame capture server and then the website scripts.

**Step 1** - Copy files in the *web* directory to your website and edit *config.php* to adjust any parameters e.g. how many frames to keep.

**Step 2** - Configure a web user for new frame uploads, see the *Securing Uploads* section below.

**Step 3** - Copy files in the *capture* directory to the server that has your webcam connected and edit *config.sh* to adjust any parameters.

**Step 4** - Create a *cron* job to upload new frames at scheduled intervals, see the *Automating Uploads* section below.

The web page will not display frames until it has a full set of frames available. For example if you set *totalFiles* to *5* in *config.php*, you will need to have 5 frame files before any frames will be displayed. This can be done by either manually running the *trafficr.sh* script to upload new frames or waiting until the automatic uploads have uploaded enough frames to the web site.

# Scripts

This is a short description of what each of the scripts is used for.

  * **capture/** - webcam capture scripts
    * **config.sh** - capture configuration
    * **trafficr.sh** - main script to caputure and upload a new frame
    * **trafficr_cron.sh** - *cron* wrapper for *trafficr.sh*
  * **web/** - website
    * **.htaccess** - Apache security configuration
    * **config.php** - website configuration
    * **frame.php** - frame delivery, serves frame files
    * **newframe.php** - new frame uploader
    * **index.html** - example Trafficr web page
    * **trafficr.js** - JavaScript frame load and cycle implementation

# Securing Uploads

The uploader script tries to authenticate to the web server for an upload. For this to work, the following must be added to the *.htaccess* file on your web site (assuming Apache is your web server).

```
<FilesMatch "newframe\.php|frame.*\.jpeg">
AuthName "Authorised Access"
AuthType Basic
AuthUserFile /path/to/.htpasswd
require valid-user
</FilesMatch>
```

You will also need to create a *.htpasswd* file that stores the user and password used to authenticate. Use the absolute path to this file in the *AuthUserFile* directive and keep that file outside the web server document root directory.

After that is set up, create a *htpasswd.txt* file in the same directory as *traffic_cam.sh* on your webcam server with cURL compatible authentication details e.g.

```
user:password
```

# Automating Uploads

Set up a *cron* job to automate capture and upload of new frames to your web site. Below is a sample configuration for the cron wrapper script. Make sure you edit this script with absolute paths pointing to your Trafficr directory.

```
*/2 * * * * /mnt/Stage1/TrafficCam/trafficr_cron.sh
```

# Archived Frames

Every frame that is captured is also archived (without any watermarking) in the archiving directory (Archive by default). The frames are stored in subdirectories split up by year, month and day.

The archive directory will have a structure like this:

```
Archive
|
+-- 2016
|   |
|   +-- 09
|   |   |
|   |   +-- 18
|   |   |   |
|   |   |   +-- arch_20160918133805.jpeg
|   |   |   +-- ...
|   |   |   +-- arch_20160918150405.jpeg
|   |   |   +-- ...
|   |   +-- 19
...
```