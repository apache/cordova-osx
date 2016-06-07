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
var cordova = require('cordova'),
        channel = require('cordova/channel'),
        utils = require('cordova/utils'),
        base64 = require('cordova/base64'),
        commandQueue = [], // Contains pending JS->Native messages.
        isInContextOfEvalJs = 0,
        failSafeTimerId = 0;


function massageMessageNativeToJs(message) {
    if (message.CDVType == 'ArrayBuffer') {
        var stringToArrayBuffer = function (str) {
            var ret = new Uint8Array(str.length);
            for (var i = 0; i < str.length; i++) {
                ret[i] = str.charCodeAt(i);
            }
            return ret.buffer;
        };
        var base64ToArrayBuffer = function (b64) {
            return stringToArrayBuffer(atob(b64));
        };
        message = base64ToArrayBuffer(message.data);
    }
    return message;
}

function convertMessageToArgsNativeToJs(message) {
    var args = [];
    if (!message || !message.hasOwnProperty('CDVType')) {
        args.push(message);
    } else if (message.CDVType == 'MultiPart') {
        message.messages.forEach(function (e) {
            args.push(massageMessageNativeToJs(e));
        });
    } else {
        args.push(massageMessageNativeToJs(message));
    }
    return args;
}

function massageArgsJsToNative(args) {
    if (!args || utils.typeName(args) != 'Array') {
        return args;
    }
    var ret = [];
    args.forEach(function (arg, i) {
        if (utils.typeName(arg) == 'ArrayBuffer') {
            ret.push({
                'CDVType': 'ArrayBuffer',
                'data': base64.fromArrayBuffer(arg)
            });
        } else {
            ret.push(arg);
        }
    });
    return ret;
}

function OSXExec() {

    var successCallback, failCallback, service, action, actionArgs, splitCommand;
    var callbackId = 'INVALID';

    successCallback = arguments[0];
    failCallback = arguments[1];
    service = arguments[2];
    action = arguments[3];
    actionArgs = arguments[4];

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

OSXExec.nativeFetchMessages = function () {
    // Stop listing for window detatch once native side confirms poke.
    if (failSafeTimerId) {
        clearTimeout(failSafeTimerId);
        failSafeTimerId = 0;
    }
    // Each entry in commandQueue is a JSON string already.
    if (!commandQueue.length) {
        return '';
    }
    var json = '[' + commandQueue.join(',') + ']';
    commandQueue.length = 0;
    return json;
};

OSXExec.nativeCallback = function (callbackId, status, message, keepCallback) {
    var success = status === 0 || status === 1;
    var args = convertMessageToArgsNativeToJs(message);
    cordova.callbackFromNative(callbackId, success, status, args, keepCallback);
};

OSXExec.nativeEvalAndFetch = function (func) {
    // This shouldn't be nested, but better to be safe.
    isInContextOfEvalJs++;
    try {
        func();
        return iOSExec.nativeFetchMessages();
    } finally {
        isInContextOfEvalJs--;
    }
};
//module.exports = OSXExec;

// Proxy the exec for bridge changes. See CB-10106

function cordovaExec() {
    var cexec = require('cordova/exec');
    var cexec_valid = (typeof cexec.nativeFetchMessages === 'function') && (typeof cexec.nativeEvalAndFetch === 'function') && (typeof cexec.nativeCallback === 'function');
    return (cexec_valid && execProxy !== cexec) ? cexec : OSXExec;
}

function execProxy() {
    cordovaExec().apply(null, arguments);
};

execProxy.nativeFetchMessages = function () {
    return cordovaExec().nativeFetchMessages.apply(null, arguments);
};

execProxy.nativeEvalAndFetch = function () {
    return cordovaExec().nativeEvalAndFetch.apply(null, arguments);
};

execProxy.nativeCallback = function () {
    return cordovaExec().nativeCallback.apply(null, arguments);
};

module.exports = execProxy;
