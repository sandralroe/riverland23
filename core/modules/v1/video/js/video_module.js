function openVidyardLightbox(videoid) {
    var target=Mura('div[data-uuid="' + videoid + '"]' );
    VidyardV4.api.renderPlayer({
        uuid: target.data('uuid'),
        container: target.node,
        type: 'lightbox',
        //vydata: encodeURIComponent(JSON.stringify({location: 'here', more: 'yes'}),
    }).then(function(player){
        player.showLightbox();
    });
}