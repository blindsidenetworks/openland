var Ticker = (function () {

    var instance;

    function init() {
        var ticker;

        return {
            start: function (_function, _interval) {
                if( !this.ticker ) {
                    this.ticker = window.setInterval (_function ,_interval);
                }
            },
            stop: function () {
                if( !!this.ticker ) {
                    window.clearInterval (this.ticker);
                }
            }
        };
    };

    return {
        getInstance: function () {
            if ( !instance ) {
                instance = init();
            }
            return instance;
        }
    };

})();
