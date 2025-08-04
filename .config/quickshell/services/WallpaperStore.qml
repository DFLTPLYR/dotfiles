// WallpaperStore.qml (Singleton)
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.LocalStorage
import Quickshell.Hyprland

import qs

Singleton {
    id: root

    property var landscapeWallpapers: []
    property var portraitWallpapers: []
    property var colorQueue: []

    function classifyWallpapers() {
        console.log('Classifying');
        searchFiles.running = true;
    }

    function resetDatabase() {
        const db = getDb();
        db.transaction(function (tx) {
            tx.executeSql("DROP TABLE IF EXISTS wallpapers");
            console.log("🧨 Dropped wallpapers table");
        });
    }

    function initializeDb() {
        const db = getDb();
        db.transaction(function (tx) {
            tx.executeSql(`
                CREATE TABLE IF NOT EXISTS wallpapers (
                path TEXT PRIMARY KEY,
                width INTEGER,
                height INTEGER,
                orientation TEXT,
                color TEXT,
                brightness TEXT
                )
            `);

            // 🔥 Remove duplicate rows (in case of schema change or old data)
            tx.executeSql(`
                DELETE FROM wallpapers
                WHERE rowid NOT IN (
                SELECT MIN(rowid)
                FROM wallpapers
                GROUP BY path
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
                INSERT INTO wallpapers (path, width, height, orientation)
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
            const rs = tx.executeSql("SELECT * FROM wallpapers ORDER BY color ASC");

            for (let i = 0; i < rs.rows.length; i++) {
                const row = rs.rows.item(i);
                if (row.orientation === "landscape")
                    root.landscapeWallpapers.push({
                        path: row.path,
                        color: row.color,
                        brightness: row.brightness
                    });
                else
                    root.portraitWallpapers.push({
                        path: row.path,
                        color: row.color,
                        brightness: row.brightness
                    });
            }
        });
    }

    function getDb() {
        return LocalStorage.openDatabaseSync("WallpaperCache", "1.0", "Wallpaper DB", 10000);
    }

    function processNextColor() {
        if (colorQueue.length === 0)
            return;
        console.log(colorAnalyzer.running);
        const nextPath = colorQueue.shift();
        colorAnalyzer.path = nextPath;
        colorAnalyzer.running = true;
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

    function generateCombinedWallpaperImage(monitorToPathMap, outputPath = "/tmp/combined_wallpaper.png") {
        const paths = Object.values(monitorToPathMap);
        if (paths.length === 0) {
            console.warn("⚠️ No wallpapers to combine");
            return;
        }
        const quotedPaths = paths.map(p => `'${p}'`).join(" ");

        const cmd = `/usr/bin/magick montage ${quotedPaths} -tile x1 -geometry +0+0 PNG32:${outputPath}`;
        combineWallpapersProc.command = ["sh", "-c", cmd];
        combineWallpapersProc.running = true;
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

    // ColorQuantizer {
    //     id: colorQuantizer
    //     depth: 4
    //     source: "file://tmp/combined_wallpaper.png"
    //     rescaleSize: 128
    //     onColorsChanged: {
    //         Colors.genTheme = colors;
    //         console.log(colors);
    //     }
    // }

    // FileView {
    //     id: jsonFile
    //     path: "file:///tmp/combined_wallpaper.png"
    //     watchChanges: true
    //     onFileChanged: console.log(this)
    // }

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

    Process {
        id: colorAnalyzer
        property string path
        running: false

        command: ["sh", "-c", `magick "${path}" -resize 1x1\\! -format '%[pixel:u.p{0,0}]' info:- | awk -F'[(),]' '{ r=$2; g=$3; b=$4; lum=0.2126*r + 0.7152*g + 0.0722*b; tag=(lum > 128 ? "light" : "dark"); printf "#%02x%02x%02x %s\\n", r, g, b, tag }'`]

        stdout: StdioCollector {
            onStreamFinished: {
                const result = text.trim();
                const [color, brightness] = result.split(" ");

                console.log("🎨", colorAnalyzer.path, "→", color, "/", brightness);

                const db = getDb();
                db.transaction(function (tx) {
                    tx.executeSql("UPDATE wallpapers SET color = ?, brightness = ? WHERE path = ?", [color, brightness, colorAnalyzer.path]);
                });

                processNextColor();
            }
        }
    }

    Component.onCompleted: {
        // resetDatabase(); // 💣 Wipe it clean — start from zero
        initializeDb(); // 🧱 Create core tables for wallpapers
        loadWallpapers(); // 📦 Load wallpapers from DB into memory
        initWallpaperDb(); // 🖥️ Setup per-monitor wallpaper tracking
        // classifyWallpapers(); // 🎨 Analyze colors for all wallpapers
    }
}
