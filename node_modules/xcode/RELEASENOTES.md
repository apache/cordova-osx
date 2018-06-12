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
# Cordova-node-xcode Release Notes

### 1.0.0 (Oct 4, 2017)
* Bump version to 1.0.0 to represent stability and follow semver more closely
* Fix null-access errors in `addTo/removeFrom*PbxGroup` methods
* Fix possible null-access error in `removeFromFrameworksPbxGroup`
* add check for `isArray` so that strings don't cause an error when calling `.filter`
* Updated License, Copyright, Contributors and repo url, in prep for contributing this project to Apache Cordova
