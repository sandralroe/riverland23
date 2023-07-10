<cfscript>
    param name="objectparams.videoplatform" default="";
    param name="objectparams.videoid" default="";
    param name="objectparams.displaytype" default="inline";//inline,modal
    param name="objectparams.modalsize" default='default';
    param name="objectparams.showheader" default=false;
    param name="objectparams.modaltitle" default='';
    param name="objectparams.showfooter" default=false;
    param name="objectparams.bodypadding" default="0";//1rem
    param name="objectparams.modalcta" default="button";//button,thumbnail,text
    param name="objectparams.buttonclass" default="secondary";//primary,secondary,success,warning,danger,info,light,dark,link
    param name="objectparams.thumbnailsrc" default="";
    param name="objectparams.showthumbnailplayicon" default=false;
    param name="objectparams.showbuttonplayicon" default=false;
    param name="objectparams.showtextplayicon" default=false;
    param name="objectparams.thumbnailplayiconsize" default="5x";
    param name="objectparams.buttonplayiconsize" default="1x";
    param name="objectparams.textplayiconsize" default="1x";
    param name="objectparams.thumbnailplayiconcolor" default="##E24B3C";
    param name="objectparams.buttonctatext" default="Watch video";
    param name="objectparams.textctatext" default="Watch video";
    param name="objectparams.ctatextwrapper" default="p";
    param name="objectparams.autoplay" default="false";
</cfscript>
<cfif this.SSR>
<cfoutput>
    <cfif !len(objectparams.videoplatform)>
        <div class="alert alert-warning">Please select a video platform.</div>
    </cfif>
    <cfif len(objectparams.videoplatform) AND !len(trim(objectparams.videoid))>
        <div class="alert alert-warning">Please enter a video id.</div>
        <!---SHOULD ADD SREENSHOTS/INSTRUCTIONS HERE TO SHOW HOW TO GET THE ID FOR THE SELECTED PLATFORM--->
    </cfif>

    <!--- EMBED CODE --->
    <cfif len(objectparams.videoplatform) AND len(trim(objectparams.videoid))>
        <cfswitch expression="#esapiEncode('html',objectparams.videoplatform)#">
            <cfcase value="wistia">
                <!---WISTIA--->
                <cfset autoplay=''/>
                <cfif objectParams.autoplay>
                    <cfset autoplay='&autoplay=true&muted=true'/>
                </cfif>
                <cfset wistiaiframe = '<iframe src="//fast.wistia.net/embed/iframe/#esapiEncode('html',trim(objectparams.videoid))#?videoFoam=true&#autoplay#" allowtransparency="true" frameborder="0" scrolling="no" class="wistia_embed" name="wistia_embed" allowfullscreen mozallowfullscreen webkitallowfullscreen oallowfullscreen msallowfullscreen style="height:100%;width:100%"></iframe>'>
                <cfsavecontent variable="videoEmbed">
                    <div class="wistiaWrapper" id="player-#esapiEncode('html',objectparams.instanceid)#"><cfif objectParams.displaytype neq 'modal'>#wistiaiframe#</cfif></div>
                    <script>
                        Mura(function(m) {
                            m.loader()
                                .loadjs('https://fast.wistia.net/assets/external/E-v1.js',
                                    '//fast.wistia.com/embed/medias/#esapiEncode('html',trim(objectparams.videoid))#.jsonp',
                                    function() {
                                        $('##videoModal_#esapiEncode('javascript',objectparams.instanceid)#').on('show.bs.modal', function () {
                                            if ($('##player-#esapiEncode('javascript',objectparams.instanceid)#').is(':empty')){
                                                $('##player-#esapiEncode('javascript',objectparams.instanceid)#').html('#wistiaiframe#');
                                            }
                                        });
                                        $('##videoModal_#esapiEncode('javascript',objectparams.instanceid)#').on('hidden.bs.modal', function () {
                                            $('##player-#esapiEncode('javascript',objectparams.instanceid)#').html('');
                                        });
                                    }
                                );
                        });
                    </script>
                </cfsavecontent>
                <!---/WISTIA--->
            </cfcase>
            <cfcase value="vidyard">
                <!---vidyard--->
                <cfset autoplay=''/>
                <cfif objectParams.autoplay>
                    <cfset autoplay=' data-autoplay="1" data-muted="1"'/>
                </cfif>
                <cfset vidyardiframe = '<iframe id="vidyard_iframe_#esapiEncode('html',trim(objectparams.videoid))#" class="vidyard_iframe" src="//play.vidyard.com/#esapiEncode('html',trim(objectparams.videoid))#?v=3.1&amp;type=inline&amp;autoplay=1&amp;marketo_id=id%253A922-ZEZ-237%2526token%253A_mch-nvoicepay.com-1573492811083-52558&amp;referring_url=https%253A%252F%252Fcontent.nvoicepay.com%252Fcustomer-stories&amp;" title="Video" aria-label="Video" scrolling="no" allowtransparency="true" allowfullscreen="" allow="autoplay" style="opacity: 1; background-color: transparent; position: absolute; right: 0px; top: 0px;" width="100%" height="100%" frameborder="0"></iframe>'>
                <cfsavecontent variable="videoEmbed">
                <!---div id="player-#esapiEncode('html',objectparams.instanceid)#" class="vidyard-player-embed" data-uuid="#esapiEncode('html',trim(objectparams.videoid))#" data-v="4" data-type="lightbox" data-autoplay="1"></div--->
                <img id="player-#esapiEncode('html',objectparams.instanceid)#" class="vidyard-player-embed" data-uuid="#esapiEncode('html',trim(objectparams.videoid))#" data-v="4" data-type="inline"#autoplay# />
                <script>
                    Mura(function(m) {
                    m.loader()
                        .loadjs('https://play.vidyard.com/embed/v4.js',
                                Mura.rootpath + '/core/modules/v1/video/js/video_module.js')
                    });
                </script>
                </cfsavecontent>
                <!---/vidyard--->
            </cfcase>
            <cfcase value="youtube">
                <!---YOUTUBE--->
                <cfset autoplay=''/>
                <cfif objectParams.autoplay>
                    <cfset autoplay='&autoplay=1&mute=1'/>
                </cfif>
                <!---Set youtube iframe code--->
                <cfset youtubeiframe = '<iframe width="1920" height="1080" src="//www.youtube.com/embed/#esapiEncode('html',trim(objectparams.videoid))#?rel=0#autoplay#&vq=hd1080&controls=0" frameborder="0" allowfullscreen></iframe>'>
                <cfsavecontent variable="videoEmbed">
                    <div class="youtubeWrapper" id="player-#esapiEncode('html',objectparams.instanceid)#">
                        #youtubeiframe#
                    </div>
                    <script type="text/javascript">
                        Mura(function(m) {
                            m.loader()
                                .loadjs(
                                    Mura.rootpath + '/core/modules/v1/video/js/video_module.js',
                                    function() {
                                        $('##videoModal_#esapiEncode('javascript',objectparams.instanceid)#').on('show.bs.modal', function () {
                                            if ($('##player-#esapiEncode('javascript',objectparams.instanceid)#').is(':empty')){
                                                $('##player-#esapiEncode('javascript',objectparams.instanceid)#').html('#youtubeiframe#');
                                            }
                                        });
                                        $('##videoModal_#esapiEncode('javascript',objectparams.instanceid)#').on('hidden.bs.modal', function () {
                                            $('##player-#esapiEncode('javascript',objectparams.instanceid)#').html('');
                                        });
                                    }
                                );
                        });
                    </script>
                </cfsavecontent>
                <!---/YOUTUBE--->
            </cfcase>
            <cfcase value="vimeo">
                <!---VIMEO--->
                <cfset autoplay=''/>
                <cfif objectParams.autoplay>
                    <cfset autoplay='autoplay=1&muted=1'/>
                </cfif>
                <cfset vimeoiframe = '<iframe src="https://player.vimeo.com/video/#esapiEncode('url',trim(objectparams.videoid))#?#autoplay#" width="960" height="540" frameborder="0" allow="autoplay; fullscreen" allowfullscreen></iframe>'>
                <cfsavecontent variable="videoEmbed">
                    <!---Set vimeo iframe code--->
                    <div class="vimeoWrapper" id="player-#esapiEncode('html',objectparams.instanceid)#"><cfif objectParams.displaytype neq 'modal'>#vimeoiframe#</cfif></div>
                    <script>
                        Mura(function(m) {
                            m.loader()
                                .loadjs(
                                    Mura.rootpath + '/core/modules/v1/video/js/video_module.js',
                                    function() {
                                        jQuery('##videoModal_#esapiEncode('javascript',objectparams.instanceid)#').on('show.bs.modal', function () {
                                            if (jQuery('##player-#esapiEncode('javascript',objectparams.instanceid)#').is(':empty')){
                                                jQuery('##player-#esapiEncode('javascript',objectparams.instanceid)#').html('#vimeoiframe#');
                                            }
                                        });
                                        jQuery('##videoModal_#esapiEncode('javascript',objectparams.instanceid)#').on('hidden.bs.modal', function () {
                                            jQuery('##player-#esapiEncode('javascript',objectparams.instanceid)#').html('');
                                        });
                                    }
                                );
                        });
                    </script>
                </cfsavecontent>
                <!---/VIMEO--->
            </cfcase>
            <cfdefaultcase>
                <cfsavecontent variable="videoEmbed">
                    
                </cfsavecontent>
            </cfdefaultcase>
        </cfswitch>
        <!--- DISPLAY --->
        <cfswitch expression="#objectparams.displaytype#">
            <cfcase value="inline">
                #videoEmbed#
            </cfcase>
            <cfcase value="modal">
                <!-- Modal CTA -->
                <cfswitch expression="#objectparams.modalcta#">
                    <cfcase value="button">
                        <cfif objectparams.videoplatform eq "vidyard">
                            <button type="button" onclick="openVidyardLightbox('#esapiEncode('html',trim(objectparams.videoid))#'); return false;" class="btn btn-#esapiEncode('html_attr',objectparams.buttonclass)#">
                                <cfif objectparams.showbuttonplayicon><i class="fas fa-play fa-#esapiEncode('html_attr',objectparams.buttonplayiconsize)# align-middle"></i></cfif> #esapiEncode('html',objectparams.buttonctatext)#
                            </button>
                        <cfelse>
                            <button type="button" class="btn btn-#esapiEncode('html_attr',objectparams.buttonclass)#" data-toggle="modal" data-target="##videoModal_#esapiEncode('html_attr',objectparams.instanceid)#">
                                <cfif objectparams.showbuttonplayicon><i class="fas fa-play fa-#esapiEncode('html_attr',objectparams.buttonplayiconsize)# align-middle"></i></cfif> #esapiEncode('html',objectparams.buttonctatext)#
                            </button>
                        </cfif>
                    </cfcase>
                    <cfcase value="thumbnail">
                        <cfif objectparams.videoplatform eq "vidyard">
                            <a href="##" onclick="openVidyardLightbox('#esapiEncode('html',trim(objectparams.videoid))#'); return false;"<cfif objectparams.showthumbnailplayicon> class="hasicon fa-#esapiEncode('html_attr',objectparams.thumbnailplayiconsize)#"</cfif> style="color:#esapiEncode('html_attr',objectparams.thumbnailplayiconcolor)#;">
                                <img src="#esapiEncode('html_attr',objectparams.thumbnailsrc)#" class="img-fluid">
                            </a>
                        <cfelse>
                            <a href="##videoModal_#esapiEncode('html_attr',objectparams.instanceid)#" data-toggle="modal"<cfif objectparams.showthumbnailplayicon> class="hasicon fa-#esapiEncode('html_attr',objectparams.thumbnailplayiconsize)#"</cfif> style="color:#esapiEncode('html_attr',objectparams.thumbnailplayiconcolor)#;">
                                <img src="#esapiEncode('html_attr',objectparams.thumbnailsrc)#" class="img-fluid">
                            </a>
                        </cfif>
                    </cfcase>
                    <cfcase value="text">
                        <cfif objectparams.videoplatform eq "vidyard">
                            <#esapiEncode('html_attr',objectparams.ctatextwrapper)#><a href="##" onclick="openVidyardLightbox('#esapiEncode('html',trim(objectparams.videoid))#'); return false;"><cfif objectparams.showtextplayicon><i class="fas fa-play fa-#esapiEncode('html_attr',objectparams.textplayiconsize)# align-middle"></i></cfif> #esapiEncode('html',objectparams.textctatext)#
                            </a></#esapiEncode('html_attr',objectparams.ctatextwrapper)#>
                        <cfelse>
                            <#esapiEncode('html_attr',objectparams.ctatextwrapper)#><a href="##videoModal_#esapiEncode('url',objectparams.instanceid)#" data-toggle="modal"><cfif objectparams.showtextplayicon><i class="fas fa-play fa-#esapiEncode('html_attr',objectparams.textplayiconsize)# align-middle"></i></cfif> #esapiEncode('html',objectparams.textctatext)#
                            </a></#esapiEncode('html_attr',objectparams.ctatextwrapper)#>
                        </cfif>
                    </cfcase>
                </cfswitch>
                
                <!-- Modal -->
                <cfif objectparams.videoplatform eq "vidyard">
                    <div class="d-none">
                        #videoEmbed#
                    </div>               
                <cfelse>
                    <!-- Modal -->
                    <div class="modal fade" id="videoModal_#esapiEncode('html_attr',objectparams.instanceid)#" tabindex="-1" role="dialog" aria-labelledby="videoModalLabel_#esapiEncode('html_attr',objectparams.instanceid)#" aria-hidden="true">
                        <!---Show close button if header and footer are false--->
                        <cfif !objectparams.showheader AND !objectparams.showfooter>
                            <button type="button" class="btn btn-link text-white position-absolute" style="top:15px; right:15px;" data-dismiss="modal"><i class="fas fa-times-circle fa-2x"></i></button>
                        </cfif>

                        <div class="modal-dialog modal-#esapiEncode('html_attr',objectparams.modalsize)# modal-dialog-centered" role="document">
                            <div class="modal-content">
                                <cfif objectparams.showheader>
                                    <div class="modal-header">
                                    <h5 class="modal-title" id="videoModalLabel_#esapiEncode('html_attr',objectparams.instanceid)#">#esapiEncode('html',objectparams.modaltitle)#</h5>
                                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                        <span aria-hidden="true">&times;</span>
                                    </button>
                                    </div>
                                </cfif>
                                <div class="modal-body" style="padding:#esapiEncode('html_attr',objectparams.bodypadding)#">
                                    #videoEmbed#
                                </div>
                                <cfif objectparams.showfooter>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                    </div>
                                </cfif>
                            </div>
                        </div>
                    </div>
                </cfif>
            </cfcase>
        </cfswitch>
        </cfif> 
    <script type="text/javascript">
        Mura(function(m) {
            m.loader()
                .loadcss(Mura.rootpath + '/core/modules/v1/video/css/video_module.css')
                .loadjs('https://kit.fontawesome.com/55f08b2674.js');
        });
    </script>
</cfoutput>
<cfelse>
    <cfset objectParams.render="client">
</cfif>