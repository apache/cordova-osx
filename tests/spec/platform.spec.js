/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

var shell = require('shelljs');

var path = require('path');
var util = require('util');
var fs = require('fs');

var spec = __dirname;

var test_projectPath = path.join(spec, '../', 'cdv-test-project');

var test_platformPath = path.join(test_projectPath, 'platforms', 'osx');

function initProject () {
    // remove existing folder
    var pPath = path.join(test_projectPath, 'platforms');
    shell.rm('-rf', pPath);
}

describe('platform add', function () {

    beforeEach(function () {
        initProject();

        shell.cd(test_projectPath);
        var command = 'cordova platform add ../../';
        console.log('executing "%s" in "%s"', command, shell.pwd());
        var return_code = shell.exec(command, { silent: false }).code;
        expect(return_code).toBe(0);
    });

    it('should have a config.xml', function () {
        var configXmlPath = path.join(test_platformPath, 'HelloCordova', 'config.xml');
        expect(fs.existsSync(configXmlPath)).toBe(true);
    });

    it('should have the correct icons', function () {

        var platformIcons = [
            {name: 'icon-16x16.png', width: 16, height: 16},
            {name: 'icon-32x32.png', width: 32, height: 32},
            {name: 'icon-64x64.png', width: 64, height: 64},
            {name: 'icon-128x128.png', width: 128, height: 128},
            {name: 'icon-256x256.png', width: 256, height: 256},
            {name: 'icon-512x512.png', width: 512, height: 512},
            {name: 'icon-1024x1024.png', width: 1024, height: 1024}
        ];

        var appIconsPath = path.join(test_platformPath, 'HelloCordova', 'Images.xcassets', 'AppIcon.appiconset');
        var srcIcon = path.join(test_projectPath, 'res', 'test-64x64.png');
        platformIcons.forEach(function (iconDef) {
            var iconPath = path.join(appIconsPath, iconDef.name);
            expect(fs.existsSync(iconPath)).toBe(true);

            // check if the icons are the same as the one specified in the config.xml
            var cmd = util.format('cmp "%s" "%s"', srcIcon, iconPath);
            var return_code = shell.exec(cmd, { silent: false }).code;
            expect(return_code).toBe(0);

        });
    });

});
