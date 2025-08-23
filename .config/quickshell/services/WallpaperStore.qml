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

    function classifyWallpapers() {
        searchFiles.running = true;
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
        console.log(list);
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

    function processNextColor() {
        if (colorQueue.length === 0) {
            console.log('Finished');
            return;
        }
        const nextPath = colorQueue.shift();
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

        db.readTransaction(function (tx) {
            const rs = tx.executeSql("SELECT monitor, path FROM monitor_wallpapers");

            for (let i = 0; i < rs.rows.length; i++) {
                const row = rs.rows.item(i);
                result[row.monitor] = row.path;
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

        const quotedPaths = paths.map(p => `'${p}'`).join(" ");

        const cmd = `/usr/bin/magick montage ${quotedPaths} -tile x1 -geometry +0+0 PNG32:${outputPath}`;
        combineWallpapersProc.command = ["sh", "-c", cmd];
        combineWallpapersProc.running = true;
    }

    function generateTags(path) {
        var completed = {
            tags: false,
            colors: false
        };

        function checkDone() {
            if (completed.tags && completed.colors) {
                console.log(`Tags: ${completed.tags}, Colors ${completed.colors}`);
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
            console.log(path);
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

    function generateColorPalette(path) {
        var file = JSON.parse(jsonFile.text());
        const db = getDb();
        db.readTransaction(function (tx) {
            const rs = tx.executeSql("SELECT id FROM wallpapers WHERE path = ?", [path]);
            if (rs.rows.length > 0) {
                const wallpaperId = rs.rows.item(0).id;
                db.transaction(function (tx2) {
                    for (var key in file) {
                        if (file.hasOwnProperty(key) && file[key]) {
                            const n_match = Scripts.getHexColorName(file[key]);
                            const n_rgb = n_match[0]; // RGB value of closest match
                            const n_name = n_match[1]; // Text string: Color name

                            tx2.executeSql("INSERT INTO wallpaper_colors (wallpaper_id, color, tag, colorGroup, colorNameGroup) VALUES (?, ?, ?, ?, ?)", [wallpaperId, file[key], key, n_rgb, n_name]);
                        }
                    }
                    if (getColorPallete.onFinished)
                        getColorPallete.onFinished();
                });
            } else {
                if (getColorPallete.onFinished)
                    getColorPallete.onFinished();
            }
        });
    }

    Process {
        id: getColorPallete
        property string path
        property var onFinished
        stdout: StdioCollector {
            onStreamFinished: {
                jsonFile.reload();
                generateColorPalette(getColorPallete.path);
            }
        }
    }

    FileView {
        id: jsonFile
        preload: false
        path: Qt.resolvedUrl('/tmp/colors.json').toString().replace("file://", "")
    }

    Process {
        id: combineWallpapersProc
        command: []
        onRunningChanged: {
            if (!running) {
                generateTheme.running = true;
            }
        }
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
                const lines = text.trim().split("\n");
                const allWallpapers = [];

                root.landscapeWallpapers = [];
                root.portraitWallpapers = [];

                for (const line of lines) {
                    const match = line.trim().match(/^(\d+)\s+(\d+)\s+(.+)$/);
                    if (!match)
                        continue;

                    const w = parseInt(match[1]);
                    const h = parseInt(match[2]);
                    const path = match[3];

                    const item = {
                        width: w,
                        height: h,
                        path
                    };
                    allWallpapers.push(item);

                    const orientation = w > h ? "landscape" : "portrait";
                    if (orientation === "landscape")
                        root.landscapeWallpapers.push(path);
                    else
                        root.portraitWallpapers.push(path);

                    const db = getDb();
                    db.transaction(function (tx) {
                        tx.executeSql(`
                        INSERT OR REPLACE INTO wallpapers (path, width, height, orientation)
                        VALUES (?, ?, ?, ?)`, [path, w, h, orientation]);
                    });

                    colorQueue = allWallpapers.map(item => item.path);
                    processNextColor();
                }

                cacheWallpapers(allWallpapers);
            }
        }
    }

    function getUniqueColorGroups(callback) {
        const db = getDb();

        db.transaction(function (tx) {
            // Select rows where colorGroup is unique
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

            console.log(`✅ Retrieved ${uniqueColors.length} unique color groups.`);
            callback(uniqueColors);
        });
    }

    Component.onCompleted: {
        // resetDatabase(); // 💣 Wipe it clean — start from zero
        // initWallpaperDb(); // 🖥️ Setup per-monitor wallpaper tracking

        // initializeDb(); // 🧱 Create core tables for wallpapers
        loadWallpapers(); // 📦 Load wallpapers from DB into memory

        // classifyWallpapers(); // 🎨 Analyze colors for all wallpapers

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
