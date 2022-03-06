/*
    #define CORDOVA_VERSION_MIN_REQUIRED __CORDOVA_7_0_0
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

#define __CORDOVA_OSX__

#define __CORDOVA_4_0_0 40000
#define __CORDOVA_NA 99999      /* not available */

/*
 #if CORDOVA_VERSION_MIN_REQUIRED >= __CORDOVA_4_0_0
    // do something when its at least 4.0.0
 #else
    // do something else (non 4.0.0)
 #endif
 */
#ifndef CORDOVA_VERSION_MIN_REQUIRED
    #define CORDOVA_VERSION_MIN_REQUIRED __CORDOVA_4_0_0
#endif


/* Return the string version of the decimal version */
#define CDV_VERSION [NSString stringWithFormat:@"%d.%d.%d", \
        (CORDOVA_VERSION_MIN_REQUIRED / 10000),             \
        (CORDOVA_VERSION_MIN_REQUIRED % 10000) / 100,       \
        (CORDOVA_VERSION_MIN_REQUIRED % 10000) % 100]

#ifdef __clang__
    #define CDV_DEPRECATED(version, msg) __attribute__((deprecated("Deprecated in Cordova " #version ". " msg)))
#else
    #define CDV_DEPRECATED(version, msg) __attribute__((deprecated()))
#endif

// Enable this to log all exec() calls.
#define CDV_ENABLE_EXEC_LOGGING 0
#if CDV_ENABLE_EXEC_LOGGING
    #define CDV_EXEC_LOG NSLog
#else
    #define CDV_EXEC_LOG(...) do {} while (NO)
#endif
#define __CORDOVA_5_0_0 50000
#define __CORDOVA_6_0_0 60000
#define __CORDOVA_7_0_0 70000
