pragma Singleton
import QtQuick

import Quickshell
import Quickshell.Io

Item {
    id: root
    // prevents spawning multiple backend processes
    property bool backendStarting: false
    property var pendingRequest: null
    property int pollAttempts: 0
    property int pollMaxAttempts: 10
    property int pollIntervalMs: 1000

    Timer {
        id: backendPollTimer
        interval: pollIntervalMs
        repeat: true
        running: false
        onTriggered: {
            tryHttpRequest(function (status) {
                if (status === 200) {
                    backendPollTimer.stop();
                    backendStarting = false;
                    pollAttempts = 0;
                    // perform the originally requested call
                    if (pendingRequest) {
                        TodoBackend._performRequest(pendingRequest.endpoint, pendingRequest.callback, pendingRequest.method, pendingRequest.body, pendingRequest.headers);
                        pendingRequest = null;
                    }
                } else {
                    pollAttempts++;
                    if (pollAttempts >= pollMaxAttempts) {
                        backendPollTimer.stop();
                        backendStarting = false;
                        pollAttempts = 0;
                        if (pendingRequest && pendingRequest.callback) {
                            pendingRequest.callback(status, null);
                            pendingRequest = null;
                        }
                    }
                }
            });
        }
    }

    function startBackendDetached() {
        if (backendStarting)
            return;
        backendStarting = true;
        var wd = Qt.resolvedUrl('./').toString().replace("file://", "");
        Quickshell.execDetached({
            command: ["bun", "run", "dev"],
            workingDirectory: wd
        });
        pollAttempts = 0;
        backendPollTimer.start();
    }

    function tryHttpRequest(callback) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    console.log("HTTP Response from Bun:", xhr.responseText);
                } else {
                    console.log("HTTP request failed. Status:", xhr.status);
                }
                if (callback)
                    callback(xhr.status);
            }
        };
        xhr.open("GET", "http://localhost:6969/");
        xhr.send();
    }

    function _performRequest(endpoint, callback, method, body, headers) {
        var url = "http://localhost:6969" + endpoint;
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (callback)
                    callback(xhr.status, xhr.responseText);
            }
        };
        xhr.open(method, url);

        if (headers) {
            for (var h in headers) {
                if (headers.hasOwnProperty(h))
                    xhr.setRequestHeader(h, headers[h]);
            }
        }

        if (body !== null && body !== undefined) {
            if (typeof body !== "string") {
                if (!headers || !headers["Content-Type"])
                    xhr.setRequestHeader("Content-Type", "application/json");
                xhr.send(JSON.stringify(body));
            } else {
                xhr.send(body);
            }
        } else {
            xhr.send();
        }
    }

    // public API: requestWithCheck(endpoint, callback, method = "GET", body = null, headers = {})
    function requestWithCheck(endpoint, callback, method, body, headers) {
        method = method || "GET";
        body = (typeof body === "undefined") ? null : body;
        headers = headers || {};

        tryHttpRequest(function (status) {
            if (status === 200) {
                // server reachable, perform request immediately
                TodoBackend._performRequest(endpoint, callback, method, body, headers);
            } else {
                // server not reachable: attempt to start it (only once) and queue this request
                pendingRequest = {
                    endpoint: endpoint,
                    callback: callback,
                    method: method,
                    body: body,
                    headers: headers
                };
                startBackendDetached();
            }
        });
    }

    Component.onCompleted: {
        tryHttpRequest(function (status) {
            if (status === 200) {
                return;
            } else {
                root.startBackendDetached();
            }
        });
    }
}
