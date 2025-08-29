// WallpaperStore.qml (Singleton)

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.LocalStorage
import Quickshell.Hyprland

import qs
import qs.utils

Singleton {
    id: root

    property var currentWallpapers
    property var landscapeWallpapers: []
    property var portraitWallpapers: []

    property var availableColors: []
    property var availableTags: []

    // With these orientation-specific properties
    property var landscapeColors: []
    property var portraitColors: []
    property var landscapeTags: []
    property var portraitTags: []

    property var colorQueue: []

    property bool processing: false
    property int processingTotal: 0
    property int processingDone: 0
    property real processingProgress: 0.0

    function _updateProcessingProgress() {
        processingProgress = processingTotal > 0 ? processingDone / processingTotal : 0.0;
    }

    function classifyWallpapers() {
        searchFiles.running = true;
        console.log('Searching');
    }

    function getDb() {
        return LocalStorage.openDatabaseSync("WallpaperCache", "1.0", "Wallpaper DB", 10000);
    }

    function resetDatabase() {
        const db = getDb();
        db.transaction(function (tx) {
            tx.executeSql("DROP TABLE IF EXISTS wallpapers");
            tx.executeSql("DROP TABLE IF EXISTS wallpaper_colors");
            tx.executeSql("DROP TABLE IF EXISTS tags");
            tx.executeSql("DROP TABLE IF EXISTS monitor_wallpapers");
            console.log("🧨 Dropped wallpapers table");
        });
    }

    function initializeDb() {
        const db = getDb();
        db.transaction(function (tx) {
            tx.executeSql(`
                CREATE TABLE IF NOT EXISTS wallpapers (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                path TEXT UNIQUE,
                width INTEGER,
                height INTEGER,
                orientation TEXT
                )
            `);

            tx.executeSql(`
                CREATE TABLE IF NOT EXISTS wallpaper_colors (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                wallpaper_id INTEGER,
                color TEXT,
                tag TEXT,
                colorGroup TEXT,
                colorNameGroup TEXT,
                FOREIGN KEY(wallpaper_id) REFERENCES wallpapers(id)
                )
            `);

            tx.executeSql(`
                CREATE TABLE IF NOT EXISTS tags (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                wallpaper_id INTEGER,
                tag TEXT,
                FOREIGN KEY(wallpaper_id) REFERENCES wallpapers(id)
                )
            `);
        });
    }

    function cacheWallpapers(list) {
        const db = getDb();
        db.transaction(function (tx) {
            for (const item of list) {
                const orientation = item.width > item.height ? "landscape" : "portrait";
                tx.executeSql(`
                    INSERT OR REPLACE INTO wallpapers (path, width, height, orientation)
                    VALUES (?, ?, ?, ?)
                `, [item.path, item.width, item.height, orientation]);
            }
        });
        processNextColor();
    }

    function loadWallpapers() {
        const db = getDb();
        root.landscapeWallpapers = [];
        root.portraitWallpapers = [];
        db.readTransaction(function (tx) {
            const rs = tx.executeSql("SELECT * FROM wallpapers");
            for (let i = 0; i < rs.rows.length; i++) {
                const row = rs.rows.item(i);

                // Get all colors for this wallpaper
                const colorRs = tx.executeSql("SELECT color, tag, colorGroup, colorNameGroup FROM wallpaper_colors WHERE wallpaper_id = ?", [row.id]);
                row.colors = [];
                for (let j = 0; j < colorRs.rows.length; j++) {
                    row.colors.push({
                        color: colorRs.rows.item(j).color,
                        tag: colorRs.rows.item(j).tag,
                        colorGroup: colorRs.rows.item(j).colorGroup,
                        colorNameGroup: colorRs.rows.item(j).colorNameGroup
                    });
                }

                // Get all tags for this wallpaper
                const tagRs = tx.executeSql("SELECT tag FROM tags WHERE wallpaper_id = ?", [row.id]);
                row.tags = [];
                for (let j = 0; j < tagRs.rows.length; j++) {
                    row.tags.push(tagRs.rows.item(j).tag);
                }

                // If no colors or tags, push to colorQueue
                if (row.colors.length === 0 || row.tags.length === 0) {
                    colorQueue.push(row.path);
                }

                if (row.orientation === "landscape")
                    root.landscapeWallpapers.push(row);
                else
                    root.portraitWallpapers.push(row);
            }

            // initialize progress tracker
            processingTotal = colorQueue.length;
            processingDone = 0;
            processing = processingTotal > 0;
            _updateProcessingProgress();

            // Start processing if there are wallpapers to process
            if (colorQueue.length > 0) {
                processNextColor();
            }
        });
    }

    function getAllUniqueTagsByOrientation(orientation, callback) {
        const db = getDb();

        db.transaction(function (tx) {
            // Join with wallpapers table to filter by orientation
            const rs = tx.executeSql(`
                            SELECT DISTINCT t.tag
                            FROM tags t
                            JOIN wallpapers w ON t.wallpaper_id = w.id
                            WHERE w.orientation = ?
                            ORDER BY t.tag
                        `, [orientation]);

            const tags = [];
            for (let i = 0; i < rs.rows.length; i++) {
                tags.push(rs.rows.item(i).tag);
            }

            callback(tags);
        });
    }

    function getAllUniqueColorsByOrientation(orientation, callback) {
        const db = getDb();

        db.transaction(function (tx) {
            // Join with wallpapers table to filter by orientation
            const rs = tx.executeSql(`
                            SELECT wc.color, wc.tag, wc.colorGroup, wc.colorNameGroup
                            FROM wallpaper_colors wc
                            JOIN wallpapers w ON wc.wallpaper_id = w.id
                            WHERE w.orientation = ?
                            GROUP BY wc.colorGroup
                            ORDER BY wc.colorGroup
                        `, [orientation]);

            const colors = [];
            for (let i = 0; i < rs.rows.length; i++) {
                colors.push({
                    color: rs.rows.item(i).color,
                    tag: rs.rows.item(i).tag,
                    colorGroup: rs.rows.item(i).colorGroup,
                    colorNameGroup: rs.rows.item(i).colorNameGroup
                });
            }

            callback(colors);
        });
    }

    function asciiProgress(done, total, width) {
        width = width || 20;
        var fillChar = "█";
        var emptyChar = "▓";
        if (total <= 0) {
            return "[" + emptyChar.repeat(width) + "] 0% (0/0)";
        }
        var pct = Math.round((done / total) * 100);
        var filled = Math.round((pct / 100) * width);
        var bar = "[" + fillChar.repeat(Math.max(0, filled)) + emptyChar.repeat(Math.max(0, width - filled)) + "] " + pct + "% (" + done + "/" + total + ")";
        return bar;
    }

    function processNextColor() {
        if (colorQueue.length === 0) {
            processing = false;
            processingDone = processingTotal;
            _updateProcessingProgress();
            console.log("WallpaperStore: processing finished", asciiProgress(processingDone, processingTotal, 25));
            return;
        }

        if (processingTotal <= 0) {
            processingTotal = colorQueue.length;
            processingDone = 0;
            processing = true;
            _updateProcessingProgress();
        }

        // mark active and log ascii progress
        const nextPath = colorQueue.shift();
        console.log("WallpaperStore:", asciiProgress(processingDone, processingTotal, 25));

        generateTags(nextPath);
    }

    function initWallpaperDb() {
        const db = getDb();
        db.transaction(function (tx) {
            tx.executeSql(`
                CREATE TABLE IF NOT EXISTS monitor_wallpapers (
                monitor TEXT PRIMARY KEY,
                path TEXT
            )
            `);
        });
    }

    function setWallpaper(monitor, wallpaperPath) {
        // Set the wallpaper using swww
        Hyprland.dispatch(`exec swww img --outputs '${monitor}' '${wallpaperPath}' --transition-type grow --transition-duration 0.5`);

        // Save to DB
        const db = getDb();
        db.transaction(function (tx) {
            tx.executeSql(`
                INSERT OR REPLACE INTO monitor_wallpapers (monitor, path)
                VALUES (?, ?)
            `, [monitor, wallpaperPath]);
        });

        getCurrentMonitorWallpapers(function (wallpaperMap) {
            generateCombinedWallpaperImage(wallpaperMap);
            root.currentWallpapers = wallpaperMap;
        });

        return GlobalState.toggleDrawer("wallpaper");
    }

    function restoreWallpapers() {
        const db = getDb();
        db.readTransaction(function (tx) {
            const rs = tx.executeSql("SELECT monitor, path FROM monitor_wallpapers");
            for (let i = 0; i < rs.rows.length; i++) {
                const row = rs.rows.item(i);
                console.log("🔁 Restoring", row.monitor, "→", row.path);
                Hyprland.dispatch(`exec swww img --outputs '${row.monitor}' '${row.path}' --transition-type grow --transition-duration 0.5`);
            }
        });
    }

    function getCurrentMonitorWallpapers(callback) {
        const db = getDb();
        const result = {};

        // build array of available monitor names from Quickshell.screens
        var available_monitors = [];
        try {
            if (Quickshell && Quickshell.screens) {
                available_monitors = Quickshell.screens.map(s => (s && s.name) ? s.name : String(s));
            }
        } catch (e) {
            available_monitors = [];
        }

        db.readTransaction(function (tx) {
            for (var i = 0; i < available_monitors.length; ++i) {
                var mon = available_monitors[i];
                var rs = tx.executeSql("SELECT path FROM monitor_wallpapers WHERE monitor = ?", [mon]);
                if (rs.rows.length > 0) {
                    result[mon] = rs.rows.item(0).path;
                }
            }

            callback(result);
        });
    }

    function generateCombinedWallpaperImage(monitorToPathMap) {
        const paths = Object.values(monitorToPathMap);
        const outputPath = "/tmp/combined_wallpaper.png";

        if (paths.length === 0) {
            console.warn("⚠️ No wallpapers to combine");
            return;
        }

        // quote with single-quotes (escape any single-quote inside)
        const quotedPaths = paths.map(p => "'" + p.replace(/'/g, "'\\''") + "'").join(" ");
        const quotedOutput = "'" + outputPath.replace(/'/g, "'\\''") + "'";
        const cols = paths.length;

        // build a robust one-liner that logs, runs montage, checks file, then runs wallust
        const cmd = [
            // find the minimum height among all quotedPaths
            "MINH=$(identify -format '%h\n' " + quotedPaths + " | sort -n | head -1)",

            // echo for debugging
            "echo \"CMD: /usr/bin/magick montage " + quotedPaths + " -resize x$MINH\\> -tile " + cols + "x1 -geometry +0+0 -background none PNG32:" + quotedOutput + " && wallust run " + quotedOutput + "\"",

            // run montage (shrink only, never upscale)
            "/usr/bin/magick montage " + quotedPaths + " -resize x$MINH\\> -tile " + cols + "x1 -geometry +0+0 -background none PNG32:" + quotedOutput,

            // check if file was created
            "[ -f " + quotedOutput + " ] && echo CREATED || echo MISSING",

            // run wallust
            "wallust run " + quotedOutput].join(" && ");

        Quickshell.execDetached({
            command: ["sh", "-c", cmd]
        });
    }

    function generateTags(path) {
        var completed = {
            tags: false,
            colors: false
        };

        function checkDone() {
            if (completed.tags && completed.colors) {
                processingDone = Math.min(processingTotal, processingDone + 1);
                _updateProcessingProgress();
                processNextColor();
            }
        }

        // Insert tags
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://localhost:6969/image");
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    insertTagsForWallpaper(path, xhr.responseText, function () {
                        completed.tags = true;
                        checkDone();
                    });
                } else {
                    completed.tags = true;
                    checkDone();
                }
            }
        };
        xhr.send(JSON.stringify({
            path: path
        }));

        // Insert colors (palette)
        getColorPallete.command = ["wallust", "--config-dir", Qt.resolvedUrl('./').toString().replace("file://", ""), "run", path];
        getColorPallete.path = path;
        getColorPallete.running = true;

        getColorPallete.onFinished = function () {
            completed.colors = true;
            checkDone();
        };
    }

    function insertTagsForWallpaper(path, tagsJson, callback) {
        var tagsObj = JSON.parse(tagsJson);
        const db = getDb();
        db.readTransaction(function (tx) {
            const rs = tx.executeSql("SELECT id FROM wallpapers WHERE path = ?", [path]);
            if (rs.rows.length > 0) {
                const wallpaperId = rs.rows.item(0).id;
                db.transaction(function (tx2) {
                    for (var tag in tagsObj) {
                        if (tagsObj.hasOwnProperty(tag)) {
                            tx2.executeSql("INSERT INTO tags (wallpaper_id, tag) VALUES (?, ?)", [wallpaperId, tag]);
                        }
                    }
                    if (callback) {
                        callback();
                    }
                });
            } else {
                if (callback) {
                    callback();
                }
            }
        });
    }

    Process {
        id: getColorPallete
        property string path
        property var onFinished
        property string _stdoutText: ""
        stdout: StdioCollector {
            onStreamFinished: {
                // stash stdout and start polling the file until it contains valid JSON
                getColorPallete._stdoutText = text;
                // try immediate reload then start poll
                try {
                    jsonFile.reload();
                } catch (e) {}
                jsonFilePoll.attempts = 0;
                jsonFilePoll.start();
            }
        }
    }

    Timer {
        id: jsonFilePoll
        interval: 80
        repeat: true
        property int attempts: 0
        property int maxAttempts: 30 // ~2.4s total
        onTriggered: {
            attempts++;
            // try reload (may be async) then read
            try {
                jsonFile.reload();
            } catch (e) {}
            Qt.callLater(function () {
                var fileText = "";
                try {
                    fileText = jsonFile.text();
                } catch (e) {
                    fileText = "";
                }
                // strip ANSI escapes
                var cleaned = fileText.replace(/\x1b\[[0-9;]*m/g, "").trim();
                if (cleaned.length > 0) {
                    // try parse
                    try {
                        JSON.parse(cleaned);
                        // success: stop and call generator with file present
                        jsonFilePoll.stop();
                        Qt.callLater(function () {
                            generateColorPalette(getColorPallete.path);
                        });
                        return;
                    } catch (e) {}
                }

                // if exhausted attempts, fall back to parsing stdout (if present), or call generator anyway
                if (attempts >= jsonFilePoll.maxAttempts) {
                    jsonFilePoll.stop();
                    console.log("generateColorPalette: file not ready, falling back to stdout or empty");
                    // pass stdout into generateColorPalette by making it read jsonFile (no change) -
                    // we can temporarily write stdout into jsonFile via setText if available
                    if (getColorPallete._stdoutText && getColorPallete._stdoutText.trim().length > 0) {
                        try {
                            // write stdout into jsonFile so existing generateColorPalette reads it
                            jsonFile.setText(getColorPallete._stdoutText);
                        } catch (e) {
                            console.log("generateColorPalette: jsonFile.setText failed", e);
                        }
                    }
                    Qt.callLater(function () {
                        generateColorPalette(getColorPallete.path);
                    });
                }
            });
        }
    }

    FileView {
        id: jsonFile
        preload: true
        path: "/tmp/colors.json"
        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                console.log("[Colors] File not found, creating new file.");
                jsonFile.setText("");
            }
        }
    }

    function generateColorPalette(path) {
        // read raw file content
        var raw = "";
        try {
            raw = jsonFile.text();
        } catch (e) {
            raw = "";
        }
        var cleaned = raw.replace(/\x1b\[[0-9;]*m/g, "").trim();

        var file = null;
        try {
            file = JSON.parse(cleaned);
        } catch (e) {
            // try to find a JSON object or array inside the text
            var objMatch = cleaned.match(/(\{[\s\S]*\})/);
            var arrMatch = cleaned.match(/(\[[\s\S]*\])/);
            var found = objMatch ? objMatch[1] : (arrMatch ? arrMatch[1] : null);
            if (found) {
                try {
                    file = JSON.parse(found);
                } catch (e2) {
                    file = {};
                }
            } else {
                file = {};
            }
        }

        const db = getDb();
        db.readTransaction(function (tx) {
            // normalize path variants to improve match chances
            var rawPath = path ? path.toString() : "";
            var norm = rawPath.replace(/^file:\/\//, "").trim();
            try {
                norm = decodeURI(norm);
            } catch (e) {}

            // try exact match against raw and normalized forms
            var rs = tx.executeSql("SELECT id, path FROM wallpapers WHERE path = ? OR path = ?", [rawPath, norm]);
            var wallpaperId = null;

            if (rs.rows.length > 0) {
                wallpaperId = rs.rows.item(0).id;
            } else {
                // fallback: try matching by basename
                var base = norm.replace(/^.*\//, "");
                var rs2 = tx.executeSql("SELECT id, path FROM wallpapers WHERE path LIKE ?", ["%" + base + "%"]);
                if (rs2.rows.length > 0) {
                    wallpaperId = rs2.rows.item(0).id;
                    console.log("generateColorPalette: fallback matched", rs2.rows.item(0).path);
                }
            }

            if (!wallpaperId) {
                console.log("generateColorPalette: no wallpaper found for", path);
                if (getColorPallete.onFinished)
                    getColorPallete.onFinished();
                return;
            }

            db.transaction(function (tx2) {
                for (var key in file) {
                    if (file.hasOwnProperty(key) && file[key]) {
                        var n_match = Scripts.getHexColorName(file[key]);
                        var n_rgb = n_match[0];
                        var n_name = n_match[1];

                        tx2.executeSql("INSERT INTO wallpaper_colors (wallpaper_id, color, tag, colorGroup, colorNameGroup) VALUES (?, ?, ?, ?, ?)", [wallpaperId, file[key], key, n_rgb, n_name]);
                    }
                }
                if (getColorPallete.onFinished)
                    getColorPallete.onFinished();
            });
        });
    }

    Process {
        id: generateTheme
        command: ["sh", "-c", "select-wallpaper.zsh --regen"]
    }

    Process {
        id: searchFiles
        running: false
        command: ["sh", "-c", `
                    find ~/Pictures/wallpaper -type f \\( -iname '*.jpg' -o -iname '*.png' \\) -print0 |
                    xargs -0 identify -format '%w %h %i\\n'
                    `]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = (text || "").trim().split("\n").filter(l => l.trim().length > 0);
                const found = [];

                for (const line of lines) {
                    const match = line.trim().match(/^(\d+)\s+(\d+)\s+(.+)$/);
                    if (!match)
                        continue;
                    const w = parseInt(match[1]);
                    const h = parseInt(match[2]);
                    const path = match[3];
                    found.push({
                        width: w,
                        height: h,
                        path
                    });
                }

                // read existing DB paths
                const db = getDb();
                const existingPaths = Object.create(null);
                db.readTransaction(function (tx) {
                    const rs = tx.executeSql("SELECT path FROM wallpapers");
                    for (let i = 0; i < rs.rows.length; i++) {
                        existingPaths[rs.rows.item(i).path] = true;
                    }
                });

                // determine new items (not present in DB)
                const newItems = found.filter(item => !existingPaths[item.path]);
                if (newItems.length === 0) {
                    console.log("WallpaperStore: no new wallpapers to process");
                } else {
                    console.log("WallpaperStore: new wallpapers found:", newItems.length);
                    // insert new items into DB and queue them for processing
                    db.transaction(function (tx) {
                        for (const it of newItems) {
                            const orientation = it.width > it.height ? "landscape" : "portrait";
                            tx.executeSql(`
INSERT OR REPLACE INTO wallpapers (path, width, height, orientation)
VALUES (?, ?, ?, ?)
`, [it.path, it.width, it.height, orientation]);
                        }
                    });

                    // append new paths to colorQueue for processing
                    root.colorQueue = (root.colorQueue || []).concat(newItems.map(i => i.path));

                    // update processing counters if needed
                    processingTotal = Math.max(processingTotal, root.colorQueue.length);
                    processing = root.colorQueue.length > 0;
                    _updateProcessingProgress();

                    // start processing if not already running
                    if (root.colorQueue.length > 0 && !processing) {
                        processNextColor();
                    } else {
                        // if processing already running, ensure it continues
                        if (!processing)
                            processNextColor();
                    }
                }

                // update visible lists (show all found wallpapers; DB now contains new entries)
                root.landscapeWallpapers = found.filter(f => f.width > f.height).map(f => f.path);
                root.portraitWallpapers = found.filter(f => f.width <= f.height).map(f => f.path);

                // optionally cache all found entries in memory (keeps the previously used behaviour)
                // root.cacheWallpapers(found);
            }
        }
    }

    function getUniqueColorGroups(callback) {
        const db = getDb();

        db.transaction(function (tx) {
            const rs = tx.executeSql(`
                                    SELECT wc.color, wc.tag, wc.colorGroup, wc.colorNameGroup
                                    FROM wallpaper_colors wc
                                    GROUP BY wc.colorGroup
                                    ORDER BY wc.colorGroup
                                `);

            const uniqueColors = [];
            for (let i = 0; i < rs.rows.length; i++) {
                uniqueColors.push({
                    color: rs.rows.item(i).color,
                    tag: rs.rows.item(i).tag,
                    colorGroup: rs.rows.item(i).colorGroup,
                    colorNameGroup: rs.rows.item(i).colorNameGroup
                });
            }

            callback(uniqueColors);
        });
    }

    Component.onCompleted: {
        // resetDatabase(); // 💣 Wipe it clean — start from zero
        // initWallpaperDb(); // 🖥️ Setup per-monitor wallpaper tracking

        // initializeDb(); // 🧱 Create core tables for wallpapers
        loadWallpapers(); // 📦 Load wallpapers from DB into memory

        classifyWallpapers(); // 🎨 Analyze colors for all wallpapers

        getCurrentMonitorWallpapers(e => {
            root.currentWallpapers = e;
        });

        // Load orientation-specific data
        getAllUniqueColorsByOrientation("landscape", function (colors) {
            root.landscapeColors = colors;
        });

        getAllUniqueColorsByOrientation("portrait", function (colors) {
            root.portraitColors = colors;
        });

        getAllUniqueTagsByOrientation("landscape", function (tags) {
            root.landscapeTags = tags;
        });

        getAllUniqueTagsByOrientation("portrait", function (tags) {
            root.portraitTags = tags;
        });
    }
}
