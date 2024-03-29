/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

const { promisify } = require('util');
const path = require('path');
const shell = require('shelljs');
const spawn = require('./spawn');
const check_reqs = require('./check_reqs');
const fs = require('fs');

const events = require('cordova-common').events;

const projectPath = path.join(__dirname, '..', '..');
let projectName = null;

module.exports.run = function (buildOpts) {
    buildOpts = buildOpts || {};

    if (buildOpts.debug && buildOpts.release) {
        return Promise.reject('Only one of "debug"/"release" options should be specified');
    }

    if (buildOpts.device && buildOpts.emulator) {
        return Promise.reject('Only one of "device"/"emulator" options should be specified');
    }

    if (buildOpts.buildConfig) {
        if (!fs.existsSync(buildOpts.buildConfig)) {
            return Promise.reject('Build config file does not exist:' + buildOpts.buildConfig);
        }
        events.emit('log', 'Reading build config file:', path.resolve(buildOpts.buildConfig));
        const buildConfig = JSON.parse(fs.readFileSync(buildOpts.buildConfig, 'utf-8'));
        if (buildConfig.osx) {
            const buildType = buildOpts.release ? 'release' : 'debug';
            const config = buildConfig.osx[buildType];
            if (config) {
                ['codeSignIdentity', 'codeSignResourceRules', 'provisioningProfile'].forEach(
                    function (key) {
                        buildOpts[key] = buildOpts[key] || config[key];
                    });
            }
        }
    }

    return check_reqs.run().then(function () {
        return findXCodeProjectIn(projectPath);
    }).then(function (name) {
        projectName = name;
        let extraConfig = '';
        if (buildOpts.codeSignIdentity) {
            extraConfig += 'CODE_SIGN_IDENTITY = ' + buildOpts.codeSignIdentity + '\n';
        }
        if (buildOpts.codeSignResourceRules) {
            extraConfig += 'CODE_SIGN_RESOURCE_RULES_PATH = ' + buildOpts.codeSignResourceRules + '\n';
        }
        if (buildOpts.provisioningProfile) {
            extraConfig += 'PROVISIONING_PROFILE = ' + buildOpts.provisioningProfile + '\n';
        }
        return promisify(fs.writeFile)(path.join(__dirname, '..', 'build-extras.xcconfig'), extraConfig, 'utf-8');
    }).then(function () {
        const configuration = buildOpts.release ? 'Release' : 'Debug';

        events.emit('log', 'Building project  : ' + path.join(projectPath, projectName + '.xcodeproj'));
        events.emit('log', '\tConfiguration : ' + configuration);

        const xcodebuildArgs = getXcodeArgs(projectName, projectPath, configuration);
        return spawn('xcodebuild', xcodebuildArgs, projectPath);
    });
};

/**
 * Searches for first XCode project in specified folder
 * @param  {String} projectPath Path where to search project
 * @return {Promise}            Promise either fulfilled with project name or rejected
 */
function findXCodeProjectIn (projectPath) {
    // 'Searching for Xcode project in ' + projectPath);
    const xcodeProjFiles = shell.ls(projectPath).filter(function (name) {
        return path.extname(name) === '.xcodeproj';
    });

    if (xcodeProjFiles.length === 0) {
        return Promise.reject('No Xcode project found in ' + projectPath);
    }
    if (xcodeProjFiles.length > 1) {
        events.emit('warn', 'Found multiple .xcodeproj directories in \n' +
            projectPath + '\nUsing first one');
    }

    const projectName = path.basename(xcodeProjFiles[0], '.xcodeproj');
    return Promise.resolve(projectName);
}

module.exports.findXCodeProjectIn = findXCodeProjectIn;

/**
 * Returns array of arguments for xcodebuild
 * @param  {String}  projectName   Name of xcode project
 * @param  {String}  projectPath   Path to project file. Will be used to set CWD for xcodebuild
 * @param  {String}  configuration Configuration name: debug|release
 * @return {Array}                 Array of arguments that could be passed directly to spawn method
 */
function getXcodeArgs (projectName, projectPath, configuration) {
    return [
        '-xcconfig', path.join(__dirname, '..', 'build-' + configuration.toLowerCase() + '.xcconfig'),
        '-project', projectName + '.xcodeproj',
        '-target', projectName,
        '-configuration', configuration,
        'build',
        'CONFIGURATION_BUILD_DIR=' + path.join(projectPath, 'build'),
        'SHARED_PRECOMPS_DIR=' + path.join(projectPath, 'build', 'sharedpch')
    ];
}

// help/usage function
/* eslint-disable no-useless-escape */
module.exports.help = function help () {
    console.log('');
    console.log('Usage: build [--debug | --release]');
    console.log('             [--codeSignIdentity=\"<identity>\"]');
    console.log('             [--codeSignResourceRules=\"<resourcerules path>\"]');
    console.log('             [--provisioningProfile=\"<provisioning profile>\"]');
    console.log('    --help                  : Displays this dialog.');
    console.log('    --debug                 : Builds project in debug mode. (Default)');
    console.log('    --release               : Builds project in release mode.');
    console.log('    -r                      : Shortcut :: builds project in release mode.');
    console.log('    --codeSignIdentity      : Type of signing identity used for code signing.');
    console.log('    --codeSignResourceRules : Path to ResourceRules.plist.');
    console.log('    --provisioningProfile   : UUID of the profile.');
    console.log('    --noSign                : Builds project without application signing.');
    console.log('');
    console.log('examples:');
    console.log('    build ');
    console.log('    build --debug');
    console.log('    build --release');
    console.log('    build --codeSignIdentity="Mac Distribution" --provisioningProfile="926c2bd6-8de9-4c2f-8407-1016d2d12954"');
    console.log('');
    process.exit(0);
};
