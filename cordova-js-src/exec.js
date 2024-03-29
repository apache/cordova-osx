/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

/**
 * Creates a gap bridge used to notify the native code about commands.

 * @private
 */
const cordova = require('cordova');
const utils = require('cordova/utils');
const base64 = require('cordova/base64');

function massageMessageNativeToJs (message) {
    if (message.CDVType === 'ArrayBuffer') {
        const stringToArrayBuffer = function (str) {
            const ret = new Uint8Array(str.length);
            for (let i = 0; i < str.length; i++) {
                ret[i] = str.charCodeAt(i);
            }
            return ret.buffer;
        };
        const base64ToArrayBuffer = function (b64) {
            return stringToArrayBuffer(atob(b64));
        };
        message = base64ToArrayBuffer(message.data);
    }
    return message;
}

function convertMessageToArgsNativeToJs (message) {
    const args = [];
    if (!message || !Object.prototype.hasOwnProperty.call(message, 'CDVType')) {
        args.push(message);
    } else if (message.CDVType === 'MultiPart') {
        message.messages.forEach(function (e) {
            args.push(massageMessageNativeToJs(e));
        });
    } else {
        args.push(massageMessageNativeToJs(message));
    }
    return args;
}

function massageArgsJsToNative (args) {
    if (!args || utils.typeName(args) !== 'Array') {
        return args;
    }
    const ret = [];
    args.forEach(function (arg, i) {
        if (utils.typeName(arg) === 'ArrayBuffer') {
            ret.push({
                CDVType: 'ArrayBuffer',
                data: base64.fromArrayBuffer(arg)
            });
        } else {
            ret.push(arg);
        }
    });
    return ret;
}

function OSXExec () {
    let callbackId = 'INVALID';

    const successCallback = arguments[0];
    const failCallback = arguments[1];
    const service = arguments[2];
    const action = arguments[3];
    let actionArgs = arguments[4];

    // Register the callbacks and add the callbackId to the positional
    // arguments if given.
    if (successCallback || failCallback) {
        callbackId = service + cordova.callbackId++;
        cordova.callbacks[callbackId] =
        { success: successCallback, fail: failCallback };
    }

    actionArgs = massageArgsJsToNative(actionArgs);

    if (window.cordovabridge && window.cordovabridge.exec) {
        window.cordovabridge.exec(callbackId, service, action, actionArgs);
    } else {
        alert('window.cordovabridge binding is missing.');
    }
}

OSXExec.nativeCallback = function (callbackId, status, message, keepCallback) {
    const success = status === 0 || status === 1;
    const args = convertMessageToArgsNativeToJs(message);
    cordova.callbackFromNative(callbackId, success, status, args, keepCallback);
};

module.exports = OSXExec;
