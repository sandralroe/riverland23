component extends="mura.baseobject" {
    function onUnitTestNormal($){
        $.event('response','success');
    }

    function onUnitTestRender($){
        return 'success';
    }
}
