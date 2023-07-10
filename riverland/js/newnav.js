$(document).ready(function () {
    var mql = window.matchMedia("screen and (max-width: 767px)")
    mediaqueryresponse(mql)
    mql.addListener(mediaqueryresponse)

    function mediaqueryresponse(mql) {
        if (mql.matches) {
            $('#menu-top').removeClass('in');
        } else {
            $('#menu-top').addClass('in');
        }
    }
});