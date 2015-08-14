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

/*jshint node: true*/

var Q = require('q'),
    nopt  = require('nopt'),
    path  = require('path'),
    build = require('./build'),
    spawn = require('./spawn');

var projectPath = path.join(__dirname, '..', '..');

module.exports.run = function (argv) {

    // parse args here
    // --debug and --release args not parsed here
    // but still valid since they can be passed down to build command 
    var args  = nopt({
        // "archs": String,     // TODO: add support for building different archs
        'nobuild': Boolean
    }, {}, argv);

    return Q.resolve()
    .then(function () {
        if (!args.nobuild) {
            return build.run(argv);
        } else {
            return Q.resolve();
        }
    }).then(function () {
        return build.findXCodeProjectIn(projectPath);
    }).then(function (projectName) {
        var appPath = path.join(projectPath, 'build', projectName + '.app');
        return runApp(appPath, projectName);
    });
};

/**
 * runs the app
 * @return {Promise}        Resolves when run succeeds otherwise rejects
 */
function runApp(appDir, appName) {
    var binPath = path.join(appDir, 'Contents', 'MacOS', appName);
    console.log('Starting: %s', binPath);
    return spawn(binPath);
}

module.exports.help = function () {
    console.log('\nUsage: run [ --debug | --release | --nobuild ]');
    // TODO: add support for building different archs
    // console.log('           [ --archs="<list of target architectures>" ] ');
    console.log('    --debug       : Builds project in debug mode. (Passed down to build command, if necessary)');
    console.log('    --release     : Builds project in release mode. (Passed down to build command, if necessary)');
    console.log('    --nobuild     : Uses pre-built package, or errors if project is not built.');
    // TODO: add support for building different archs
    // console.log('    --archs       : Specific chip architectures (`anycpu`, `arm`, `x86`, `x64`).');
    console.log('');
    console.log('Examples:');
    console.log('    run');
    console.log('    run --nobuild');
    console.log('');
    process.exit(0);
};