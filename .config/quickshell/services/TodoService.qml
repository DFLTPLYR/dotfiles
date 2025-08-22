pragma Singleton
import QtQuick

QtObject {
    id: root

    property string baseUrl: "http://localhost:6969/todos"

    // Get all todos
    function getAllTodos(callback) {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", baseUrl);
        xhr.setRequestHeader("Content-Type", "application/json");

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        callback(response, null);
                    } catch (e) {
                        callback(null, "Failed to parse response: " + e.message);
                    }
                } else {
                    callback(null, "Request failed: " + xhr.status + " " + xhr.statusText);
                }
            }
        };

        xhr.send();
    }

    // Create a new todo
    function createTodo(todo, callback) {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", baseUrl);
        xhr.setRequestHeader("Content-Type", "application/json");

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        callback(response, null);
                    } catch (e) {
                        callback(null, "Failed to parse response: " + e.message);
                    }
                } else {
                    try {
                        var errorResponse = JSON.parse(xhr.responseText);
                        callback(null, errorResponse.error || "Request failed");
                    } catch (e) {
                        callback(null, "Request failed: " + xhr.status + " " + xhr.statusText);
                    }
                }
            }
        };

        xhr.send(JSON.stringify(todo));
    }

    // Update a todo by ID
    function updateTodo(id, todo, callback) {
        var xhr = new XMLHttpRequest();
        xhr.open("PUT", baseUrl + "/" + id);
        xhr.setRequestHeader("Content-Type", "application/json");

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        callback(response, null);
                    } catch (e) {
                        callback(null, "Failed to parse response: " + e.message);
                    }
                } else {
                    try {
                        var errorResponse = JSON.parse(xhr.responseText);
                        callback(null, errorResponse.error || "Request failed");
                    } catch (e) {
                        callback(null, "Request failed: " + xhr.status + " " + xhr.statusText);
                    }
                }
            }
        };

        xhr.send(JSON.stringify(todo));
    }

    // Delete a todo by ID
    function deleteTodo(id, callback) {
        var xhr = new XMLHttpRequest();
        xhr.open("DELETE", baseUrl + "/" + id);
        xhr.setRequestHeader("Content-Type", "application/json");

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        callback(response, null);
                    } catch (e) {
                        callback(null, "Failed to parse response: " + e.message);
                    }
                } else {
                    try {
                        var errorResponse = JSON.parse(xhr.responseText);
                        callback(null, errorResponse.error || "Request failed");
                    } catch (e) {
                        callback(null, "Request failed: " + xhr.status + " " + xhr.statusText);
                    }
                }
            }
        };

        xhr.send();
    }

    // Nuke all todos (delete from both databases)
    function nukeAllTodos(callback) {
        var xhr = new XMLHttpRequest();
        xhr.open("DELETE", baseUrl + "/nuke");
        xhr.setRequestHeader("Content-Type", "application/json");

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        callback(response, null);
                    } catch (e) {
                        callback(null, "Failed to parse response: " + e.message);
                    }
                } else {
                    try {
                        var errorResponse = JSON.parse(xhr.responseText);
                        callback(null, errorResponse.error || "Request failed");
                    } catch (e) {
                        callback(null, "Request failed: " + xhr.status + " " + xhr.statusText);
                    }
                }
            }
        };

        xhr.send();
    }
}
