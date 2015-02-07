<!--
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#  KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
-->
### This is a fork of the official cordova-osx platform

This fork includes many fixes and small improvemts. Hopefully it will be merged with the official version one day.

It is may also by necessary for forks of related plugins.

- cordova file API [cordova-plugin-file](https://github.com/onflapp/cordova-plugin-file)
- chrome socket API [chrome-cordova](https://github.com/onflapp/mobile-chrome-apps/tree/master/chrome-cordova/plugins/chrome.socket)

Cordova OSX
=============================================================
CordovaLib is a framework that enables users to include Cordova in their OS X application projects easily, and also create new Cordova based OS X application projects.

Pre-requisites
-------------------------------------------------------------
Make sure you have installed the latest released OS X SDK which comes with Xcode 5. Download it at [http://developer.apple.com/downloads](http://developer.apple.com/downloads) or the [Mac App Store](http://itunes.apple.com/us/app/xcode/id497799835?mt=12).

You will also need to install the [nodejs](http://nodejs.org).

Register OSX platform in the cordova
-------------------------------------------------------------

### 1 Install cordova itself

```
$ sudo npm install -g cordova
```

### 2 Clone this repository

```
$ git clone https://github.com/onflapp/cordova-osx.git
```

### 3 Patch the cordova

You can use patches in the *patches* directory or if you are lazy, do the following:

```
$ sudo cp patched-files/src/cordova/platform.js /usr/local/lib/node_modules/cordova/node_modules/cordova-lib/src/cordova
$ sudo cp patched-files/src/cordova/platforms.js /usr/local/lib/node_modules/cordova/node_modules/cordova-lib/src/cordova

$ sudo cp patched-files/src/plugman/platforms.js /usr/local/lib/node_modules/cordova/node_modules/cordova-lib/src/plugman
$ sudo cp patched-files/src/plugman/platforms/osx.js /usr/local/lib/node_modules/cordova/node_modules/cordova-lib/src/plugman/platforms
```

*NOTE: you will be executing these commads as root, you should backup the original files first.*

### 4 Verify the patch worked

```
$ cordova platform ls
```

Use this fork intead of the official cordova-osx
-------------------------------------------------------------

Patching cordova as described above will get you the official OSX platform support.
This may or may not be what you want. If you are interested in *this* fork, you'll need to take additional steps.

Copy the *content* of the entire project (*cordova-osx*) to *~/.cordova/lib/osx/cordova/master*

```
$ mkdir -p ~/.cordova/lib/osx/cordova/master
$ cp -R ./cordova-osx/* ~/.cordova/lib/osx/cordova/master
```

If this directory exists already, you may have to remove it.

NOTE: you should be able to find '~/.cordova/lib/osx/cordova/master/package.json' in there.
If you see ~/.cordova/lib/osx/cordova/master/cordova-osx, this is wrong. 
It must be the *content* of the cordova-osx that is copied into the master

There is probably a better way to use a fork then this, I just didn't find a simpler way.

Add OS X platform to your project
-------------------------------------------------------------

### 1 Create a project

```
$ cordova create hello com.example.hello HelloWorld
```

### 2 Add platform

```
$ cd ./hello
$ cordova platform add osx
```

Useful options 
--------------

In the `config.xml` you can use following configuration parameters

```<preference name="EnableDebugMode" value="false" />```

The debug modes enables WebKit's Inspector. The inspector is accessible via right-click.

```<preference name="HideCursor" value="false" />```

Hides the cursor. This option is very usefull for touchscreens using mouse emulation.

```<preference name="KioskMode" value="false" />```

Kiosk Mode will make the app run in full screen mode and disables application switching.

Loading resources (JS/CSS) directly from your project's source directory. 
```$ defaults write com.xxx.yyy write SourceBaseDir /Users/blah/myproject```

This option is very usefull for rapid JS/CSS development because you do do not have to rebuild the entire application,
just reload the page - EnableDebugMode may have to be enabled.
`SourceBaseDir` should point to where your `www` folder is.

More Info
----------
* [http://cordova.apache.org/](http://cordova.apache.org/)
