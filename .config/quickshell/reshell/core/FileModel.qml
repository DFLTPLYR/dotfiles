import QtQuick

ListModel {
    id: model
    signal saved(var arr)
    signal synced

    property list<var> sources: []
    onSourcesChanged: sync()

    function save() {
        const list = [];
        for (let i = 0; i < count; i++) {
            const object = model.get(i);
            list.push(JSON.parse(JSON.stringify(object)));
        }
        model.saved(list);
    }

    function sync() {
        model.clear();
        for (const i in model.sources) {
            model.append(sources[i]);
        }
        model.synced();
    }
}
