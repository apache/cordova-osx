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
Cordova OSX
=============================================================
CordovaLib is a framework that enables users to include Cordova in their OS X application projects easily, and also create new Cordova based OS X application projects.


Pre-requisites
-------------------------------------------------------------
Make sure you have installed the latest released OS X SDK which comes with Xcode 5. Download it at [http://developer.apple.com/downloads](http://developer.apple.com/downloads) or the [Mac App Store](http://itunes.apple.com/us/app/xcode/id497799835?mt=12).


Add the Cordova OSX Platform the a CLI project
-------------------------------------------------------------
1. Get a patched version of cordova CLI and Plugman
    1. checkout the master. see https://github.com/apache/cordova-cli#installing-from-master
    2. patch the 2 projects with the patches provided in the `patches` directory to
       enable the osx platform    

2. Follow the instructions in the [**Command-Line Usage** section](http://cordova.apache.org/docs/en/edge/guide_cli_index.md.html#The%20Command-line%20Interface) of the [Cordova Docs](http://cordova.apache.org/docs/en/edge)

3. add the osx platform:

    ````
    $ cordova platform add osx
    $ cordova run osx
    ````


You can also open the project in XCode:

    $ open platforms/osx/<yourproject>.xcodeproj

Create a Cordova OSX Standalone project
-------------------------------------------------------------

1. Download the source
2. execute the `create` command to setup an empty project:

    ````
    $ bin/create <path_to_new_project> <package_name> <project_name>
    ````
    
    for example
    
    ````
    $ bin/create ../Foo org.apache.foo FooBar
    ````

To use a **shared CordovaLib**, add as the first parameter "**--shared**" to the **bin/create** command.


Updating a CordovaLib subproject reference in your project
-------------------------------------------------------------

When you update to a new Cordova version, you may need to update the CordovaLib reference in an existing project. Cordova comes with a script that will help you to do this.

1. Launch **Terminal.app**
2. Go to the location where you installed Cordova, in the **bin** sub-folder
3. Run **"update_cordova_subproject [path/to/your/project/xcodeproj]"**  where the first parameter is the path to your project's .xcodeproj file



FAQ
---
None yet.


BUGS?
-----
File them at the [Cordova Issue Tracker](https://issues.apache.org/jira/browse/CB)      


MORE INFO
----------
* [http://cordova.apache.org/](http://cordova.apache.org/)
