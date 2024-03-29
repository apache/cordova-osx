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

const fs = require('fs');
const path = require('path');
const shell = require('shelljs');
const events = require('cordova-common').events;
const CordovaError = require('cordova-common').CordovaError;

// These frameworks are required by cordova-osx by default. We should never add/remove them.
const keep_these_frameworks = [
    'MobileCoreServices.framework',
    'CoreGraphics.framework',
    'AssetsLibrary.framework'
];

const handlers = {
    'source-file': {
        install: function (obj, plugin, project, options) {
            installHelper('source-file', obj, plugin.dir, project.projectDir, plugin.id, options, project);
        },
        uninstall: function (obj, plugin, project, options) {
            uninstallHelper('source-file', obj, project.projectDir, plugin.id, options, project);
        }
    },
    'header-file': {
        install: function (obj, plugin, project, options) {
            installHelper('header-file', obj, plugin.dir, project.projectDir, plugin.id, options, project);
        },
        uninstall: function (obj, plugin, project, options) {
            uninstallHelper('header-file', obj, project.projectDir, plugin.id, options, project);
        }
    },
    'resource-file': {
        install: function (obj, plugin, project, options) {
            const src = obj.src;
            const srcFile = path.resolve(plugin.dir, src);
            const destFile = path.resolve(project.resources_dir, path.basename(src));
            if (!fs.existsSync(srcFile)) throw new CordovaError('cannot find "' + srcFile + '" osx <resource-file>');
            if (fs.existsSync(destFile)) throw new CordovaError('target destination "' + destFile + '" already exists');
            project.xcode.addResourceFile(path.join('Resources', path.basename(src)));
            shell.cp('-R', srcFile, project.resources_dir);
        },
        uninstall: function (obj, plugin, project, options) {
            const src = obj.src;
            const destFile = path.resolve(project.resources_dir, path.basename(src));
            project.xcode.removeResourceFile(path.join('Resources', path.basename(src)));
            shell.rm('-rf', destFile);
        }
    },
    framework: { // CB-5238 custom frameworks only
        install: function (obj, plugin, project, options) {
            const src = obj.src;
            const custom = obj.custom;

            if (!custom) {
                if (keep_these_frameworks.indexOf(src) < 0) {
                    project.xcode.addFramework(src, { weak: obj.weak });
                    project.frameworks[src] = (project.frameworks[src] || 0) + 1;
                }
                return;
            }

            const srcFile = path.resolve(plugin.dir, src);
            const targetDir = path.resolve(project.plugins_dir, plugin.id, path.basename(src));
            if (!fs.existsSync(srcFile)) throw new CordovaError('cannot find "' + srcFile + '" osx <framework>');
            if (fs.existsSync(targetDir)) throw new CordovaError('target destination "' + targetDir + '" already exists');
            shell.mkdir('-p', path.dirname(targetDir));
            shell.cp('-R', srcFile, path.dirname(targetDir)); // frameworks are directories
            const project_relative = path.relative(project.projectDir, targetDir);
            const pbxFile = project.xcode.addFramework(project_relative, { customFramework: true });
            if (pbxFile) {
                project.xcode.addToPbxEmbedFrameworksBuildPhase(pbxFile);
            }
        },
        uninstall: function (obj, plugin, project, options) {
            const src = obj.src;

            if (!obj.custom) {
                if (keep_these_frameworks.indexOf(src) < 0) {
                    project.frameworks[src] -= (project.frameworks[src] || 1) - 1;
                    if (project.frameworks[src] < 1) {
                        // Only remove non-custom framework from xcode project
                        // if there is no references remains
                        project.xcode.removeFramework(src);
                        delete project.frameworks[src];
                    }
                }
                return;
            }

            const targetDir = path.resolve(project.plugins_dir, plugin.id, path.basename(src));
            const pbxFile = project.xcode.removeFramework(targetDir, { customFramework: true });
            if (pbxFile) {
                project.xcode.removeFromPbxEmbedFrameworksBuildPhase(pbxFile);
            }
            shell.rm('-rf', targetDir);
        }
    },
    'lib-file': {
        install: function (obj, plugin, project, options) {
            events.emit('verbose', 'lib-file.install is not supported for osx');
        },
        uninstall: function (obj, plugin, project, options) {
            events.emit('verbose', 'lib-file.uninstall is not supported for osx');
        }
    },
    asset: {
        install: function (obj, plugin, project, options) {
            if (!obj.src) {
                throw new CordovaError('<asset> tag without required "src" attribute. plugin=' + plugin.dir);
            }
            if (!obj.target) {
                throw new CordovaError('<asset> tag without required "target" attribute');
            }

            const www = options.usePlatformWww ? project.platformWww : project.www;

            copyFile(plugin.dir, obj.src, www, obj.target);
        },
        uninstall: function (obj, plugin, project, options) {
            const target = obj.target;

            if (!target) {
                throw new Error('<asset> tag without required "target" attribute');
            }

            const www = options.usePlatformWww ? project.platformWww : project.www;

            removeFile(www, target);
            removeFileF(path.resolve(project.www, 'plugins', plugin.id));
        }
    },
    'js-module': {
        install: function (obj, plugin, project, options) {
            // Copy the plugin's files into the www directory.
            const moduleSource = path.resolve(plugin.dir, obj.src);
            const moduleName = plugin.id + '.' + (obj.name || path.parse(obj.src).name);

            // Read in the file, prepend the cordova.define, and write it back out.
            let scriptContent = fs.readFileSync(moduleSource, 'utf-8').replace(/^\ufeff/, ''); // Window BOM
            if (moduleSource.match(/.*\.json$/)) {
                scriptContent = 'module.exports = ' + scriptContent;
            }
            scriptContent = 'cordova.define("' + moduleName + '", function(require, exports, module) {\n' + scriptContent + '\n});\n';

            const www = options.usePlatformWww ? project.platformWww : project.www;
            const moduleDestination = path.resolve(www, 'plugins', plugin.id, obj.src);
            shell.mkdir('-p', path.dirname(moduleDestination));
            fs.writeFileSync(moduleDestination, scriptContent, 'utf-8');
        },
        uninstall: function (obj, plugin, project, options) {
            const pluginRelativePath = path.join('plugins', plugin.id, obj.src);
            const www = options.usePlatformWww ? project.platformWww : project.www;
            removeFileAndParents(www, pluginRelativePath);
        }
    }
};

module.exports.getInstaller = function (type) {
    if (handlers[type] && handlers[type].install) {
        return handlers[type].install;
    }

    events.emit('warn', '<' + type + '> is not supported for osx plugins');
};

module.exports.getUninstaller = function (type) {
    if (handlers[type] && handlers[type].uninstall) {
        return handlers[type].uninstall;
    }

    events.emit('warn', '<' + type + '> is not supported for osx plugins');
};

function installHelper (type, obj, plugin_dir, project_dir, plugin_id, options, project) {
    const srcFile = path.resolve(plugin_dir, obj.src);
    const targetDir = path.resolve(project.plugins_dir, plugin_id, obj.targetDir || '');
    const destFile = path.join(targetDir, path.basename(obj.src));

    let project_ref;
    const link = !!(options && options.link);
    if (link) {
        const trueSrc = fs.realpathSync(srcFile);
        // Create a symlink in the expected place, so that uninstall can use it.
        copyNewFile(plugin_dir, trueSrc, project_dir, destFile, link);

        // Xcode won't save changes to a file if there is a symlink involved.
        // Make the Xcode reference the file directly.
        // Note: Can't use path.join() here since it collapses 'Plugins/..', and xcode
        // library special-cases Plugins/ prefix.
        project_ref = 'Plugins/' + fixPathSep(path.relative(fs.realpathSync(project.plugins_dir), trueSrc));
    } else {
        copyNewFile(plugin_dir, srcFile, project_dir, destFile, link);
        project_ref = 'Plugins/' + fixPathSep(path.relative(project.plugins_dir, destFile));
    }

    if (type === 'header-file') {
        project.xcode.addHeaderFile(project_ref);
    } else if (obj.framework) {
        const opt = { weak: obj.weak };
        const project_relative = path.join(path.basename(project.xcode_path), project_ref);
        project.xcode.addFramework(project_relative, opt);
        project.xcode.addToLibrarySearchPaths({ path: project_ref });
    } else {
        project.xcode.addSourceFile(project_ref, obj.compilerFlags ? { compilerFlags: obj.compilerFlags } : {});
    }
}

function uninstallHelper (type, obj, project_dir, plugin_id, options, project) {
    const targetDir = path.resolve(project.plugins_dir, plugin_id, obj.targetDir || '');
    const destFile = path.join(targetDir, path.basename(obj.src));

    let project_ref;
    const link = !!(options && options.link);
    if (link) {
        const trueSrc = fs.readlinkSync(destFile);
        project_ref = 'Plugins/' + fixPathSep(path.relative(fs.realpathSync(project.plugins_dir), trueSrc));
    } else {
        project_ref = 'Plugins/' + fixPathSep(path.relative(project.plugins_dir, destFile));
    }

    shell.rm('-rf', targetDir);

    if (type === 'header-file') {
        project.xcode.removeHeaderFile(project_ref);
    } else if (obj.framework) {
        const project_relative = path.join(path.basename(project.xcode_path), project_ref);
        project.xcode.removeFramework(project_relative);
        project.xcode.removeFromLibrarySearchPaths({ path: project_ref });
    } else {
        project.xcode.removeSourceFile(project_ref);
    }
}

const pathSepFix = new RegExp(path.sep.replace(/\\/, '\\\\'), 'g');
function fixPathSep (file) {
    return file.replace(pathSepFix, '/');
}

function copyFile (plugin_dir, src, project_dir, dest, link) {
    src = path.resolve(plugin_dir, src);
    if (!fs.existsSync(src)) throw new CordovaError('"' + src + '" not found!');

    // check that src path is inside plugin directory
    const real_path = fs.realpathSync(src);
    const real_plugin_path = fs.realpathSync(plugin_dir);
    if (real_path.indexOf(real_plugin_path) !== 0) { throw new CordovaError('"' + src + '" not located within plugin!'); }

    dest = path.resolve(project_dir, dest);

    // check that dest path is located in project directory
    if (dest.indexOf(project_dir) !== 0) { throw new CordovaError('"' + dest + '" not located within project!'); }

    shell.mkdir('-p', path.dirname(dest));

    if (link) {
        fs.symlinkSync(path.relative(path.dirname(dest), src), dest);
    } else if (fs.statSync(src).isDirectory()) {
        // XXX shelljs decides to create a directory when -R|-r is used which sucks. http://goo.gl/nbsjq
        shell.cp('-Rf', src + '/*', dest);
    } else {
        shell.cp('-f', src, dest);
    }
}

// Same as copy file but throws error if target exists
function copyNewFile (plugin_dir, src, project_dir, dest, link) {
    const target_path = path.resolve(project_dir, dest);
    if (fs.existsSync(target_path)) { throw new CordovaError('"' + target_path + '" already exists!'); }

    copyFile(plugin_dir, src, project_dir, dest, !!link);
}

// checks if file exists and then deletes. Error if doesn't exist
function removeFile (project_dir, src) {
    const file = path.resolve(project_dir, src);
    shell.rm('-Rf', file);
}

// deletes file/directory without checking
function removeFileF (file) {
    shell.rm('-Rf', file);
}

function removeFileAndParents (baseDir, destFile, stopper) {
    stopper = stopper || '.';
    const file = path.resolve(baseDir, destFile);
    if (!fs.existsSync(file)) return;

    removeFileF(file);

    // check if directory is empty
    let curDir = path.dirname(file);

    while (curDir !== path.resolve(baseDir, stopper)) {
        if (fs.existsSync(curDir) && fs.readdirSync(curDir).length === 0) {
            fs.rmdirSync(curDir);
            curDir = path.resolve(curDir, '..');
        } else {
            // directory not empty...do nothing
            break;
        }
    }
}
