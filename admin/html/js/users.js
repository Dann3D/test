function post(url, body, callback) {
    fetch(url, {
        method: 'POST',
        headers: {
            "Content-Type": "application/json;charset=utf8"
        },
        body: JSON.stringify(body || {})
    })
    .then(res => res.json())
    .then(res => {
        callback(res);
    });
}

const main = new Vue({
    el: '#main',
    data: {
        banned: [],
        warns: [],
        toasts: []
    },
    methods: {
        showErrorMessage(msg) {
            this.toasts.push({message: msg, show: false});
            setTimeout(() => {
                main.toasts[this.toasts.length - 1].show = true;
            }, 150);
            setTimeout(function () {
                main.toasts.pop();
            }, 4750);
        },
        getBannedPlayers() {
            post('/admin/getBannedPlayers', {},
            (data) => {
                if (data.executed) {
                    main.banned = data.banned;
                    main.$forceUpdate();
                } else main.showErrorMessage(data.message || "Error");
            });
        },
        getWarnList() {
            post('/admin/getWarnings', {},
            (data) => {
                if (data.executed) {
                    main.warns = data.warns;
                    main.$forceUpdate();
                } else main.showErrorMessage(data.message || "Error");
            })
        },
        unban(index) {
            let player = this.banned[index];
            post('/admin/unban', {
                identifier: player.identifier
            }, (data) => {
                if (data.executed) {
                    for (const index in main.banned) {
                        let ban = main.banned[index]
                        if (ban.identifier == data.identifier) {
                            main.$delete(main.bans, index)
                        }
                    }
                    main.$forceUpdate();
                } else main.showErrorMessage(data.message || "Error");
            })
        },
        unbanAll(){
            post('/admin/globalUnban', {},
            (data) => {
                if (!data.executed) main.showErrorMessage(data.message || "Error");
            })
        },
        removeWarn(index) {
            let warn = this.warns[index];
            post('/admin/removeWarn', {
                id: warn.id
            }, (data) => {
                if (data.executed) {
                    for (const index in main.warns) {
                        let warn = main.warns[index]
                        if (warn.id == data.id) {
                            main.$delete(main.warns, index)
                        }
                    }
                    main.$forceUpdate();
                } else main.showErrorMessage(data.message || "Error");
            })
        },
        editWarn(index) {
            let warn = this.warns[index];
            if (!warn.editing) warn.editing = true
            else {
                warn.editing = false;
                post('/admin/editWarn', {
                    id: warn.id,
                    reason: warn.reason
                }, (data) => {
                    if (!data.executed) main.showErrorMessage(data.message || "Error");
                });
            }
            this.$forceUpdate();
        }
    }
})

window.onload = function() {
    main.getBannedPlayers();
    main.getWarnList();
}