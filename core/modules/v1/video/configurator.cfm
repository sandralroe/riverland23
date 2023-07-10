<cf_objectconfigurator>

    <cfscript>
        param name="objectparams.videoplatform" default="";
        param name="objectparams.videoid" default="";//
        param name="objectparams.displaytype" default="inline";//inline,modal
        param name="objectparams.modalsize" default='default';
        param name="objectparams.showheader" default=false;
        param name="objectparams.modaltitle" default='';
        param name="objectparams.showfooter" default=false;
        param name="objectparams.bodypadding" default="0";//1rem,15px,etc.
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
    
    <cfoutput>
    <div class="container">
    
        <!--- Video Platform --->
        <div class="mura-control-group">
            <label>Video Platform</label>
            <select class="objectparam" name="videoplatform">
                <option value="">Select Your Video Platform</option>
                <cfloop list="youtube,vidyard,vimeo,wistia" item="i">
                <option <cfif objectparams.videoplatform eq i>selected </cfif>value="#i#">#i#</option>
                </cfloop>
            </select>
        </div>
    
        <!--- Video ID --->
        <div class="mura-control-group">
            <label>Video ID</label>
            <input type="text" name="videoid" class="objectparam" value="#esapiEncode('html_attr',objectparams.videoid)#"/>
        </div>

        <!--- Autoplay --->
        <div class="mura-control-group">
            <label>Autoplay</label>
            <div class="radio-group">
            <label class="radio"><input type="radio" class="objectparam" name="autoplay" value="true" <cfif objectparams.autoplay> checked</cfif>/>Yes</label>
            <label class="radio"><input type="radio" class="objectparam" name="autoplay" value="false" <cfif !objectparams.autoplay> checked</cfif>/>No</label>
            </div>
        </div>
    
        <!--- Display Type --->
        <div class="mura-control-group">
            <label>Display Type</label>
            <select class="objectparam" name="displaytype">
                <option value="">Select Your Display Type</option>
                <cfloop list="modal,inline" item="i">
                <option <cfif objectparams.displaytype eq i>selected </cfif>value="#i#">#i#</option>
                </cfloop>
            </select>
        </div>
    
        <!--- Modal CTA Type --->
        <div class="mura-control-group">
            <label>Modal CTA</label>
            <select class="objectparam" name="modalcta">
                <option value="">Select CTA Type</option>
                <cfloop list="button,thumbnail,text" item="i">
                <option <cfif objectparams.modalcta eq i>selected </cfif>value="#i#">#i#</option>
                </cfloop>
            </select>
        </div>
    
        <div id="panel-video-object" class="mura-panel-group">
            <div class="panel mura-panel">
                <div class="mura-panel-heading">
                    <h4 class="mura-panel-title">
                        <a class="collapse collapsed" data-toggle="collapse" data-parent="##panel-video-object" href="##panel-modal-options">Modal</a>
                    </h4>
                </div>
                <div id="panel-modal-options" class="panel-collapse collapse">
                    <div class="mura-panel-body">
    
                        <!--- Modal Size --->
                        <div class="mura-control-group">
                            <label>Modal Size</label>
                            <select class="objectparam" name="modalsize">
                                <option value="">Select Modal Size</option>
                                <cfloop list="Small|sm,Default|default,Large|lg,Extra Large|xl" item="i">
                                <option <cfif objectparams.modalsize eq listgetat(i,2,"|")>selected </cfif>value="#listgetat(i,2,"|")#">#listgetat(i,1,"|")#</option>
                                </cfloop>
                            </select>
                        </div>
    
                        <!--- Modal Body Padding --->
                        <div class="mura-control-group">
                            <label>Modal Body Padding</label>
                            <input type="text" name="bodypadding" class="objectparam" value="#esapiEncode('html_attr',objectparams.bodypadding)#"/>
                        </div>
                        
                        <!--- Show Modal Header --->
                        <div class="mura-control-group">
                            <label>Show Modal Header</label>
                            <div class="radio-group">
                            <label class="radio"><input type="radio" class="objectparam" name="showheader" value="true" <cfif objectparams.showheader> checked</cfif>/>Yes</label>
                            <label class="radio"><input type="radio" class="objectparam" name="showheader" value="false" <cfif !objectparams.showheader> checked</cfif>/>No</label>
                            </div>
                        </div>
    
                        <!--- Modal Title --->
                        <div class="mura-control-group">
                            <label>Modal Title</label>
                            <input type="text" name="modaltitle" class="objectparam" value="#esapiEncode('html_attr',objectparams.modaltitle)#"/>
                        </div>
    
                        <!--- Show Modal Footer --->
                        <div class="mura-control-group">
                            <label>Show Modal Footer</label>
                            <div class="radio-group">
                            <label class="radio"><input type="radio" class="objectparam" name="showfooter" value="true" <cfif objectparams.showfooter> checked</cfif>/>Yes</label>
                            <label class="radio"><input type="radio" class="objectparam" name="showfooter" value="false" <cfif !objectparams.showfooter> checked</cfif>/>No</label>
                            </div>
                        </div>
    
                    </div><!--/mura-panel-body-->
                </div><!--/panel-collapse-->
    
                <div class="mura-panel-heading">
                    <h4 class="mura-panel-title">
                        <a class="collapse collapsed" data-toggle="collapse" data-parent="##panel-video-object" href="##panel-thumbnail-options">Thumbnail</a>
                    </h4>
                </div>
                <div id="panel-thumbnail-options" class="panel-collapse collapse">
                    <div class="mura-panel-body">
    
                            <!--- Thumbnail File Selector --->    
                            <div class="mura-control-group">
                                <label>Select File</label>
                                <input name="thumbnailsrc" class="objectparam" value="#esapiEncode('html_attr',objectparams.thumbnailsrc)#"><br/>
                                <button type="button" class="btn mura-ckfinder" data-target="thumbnailsrc" data-completepath=false>Select File</button>
                            </div>
    
                            <!--- Show Thumbnail Play Icon --->
                            <div class="mura-control-group">
                                <label>Show Play Icon</label>
                                <div class="radio-group">
                                <label class="radio"><input type="radio" class="objectparam" name="showthumbnailplayicon" value="true" <cfif objectparams.showthumbnailplayicon> checked</cfif>/>Yes</label>
                                <label class="radio"><input type="radio" class="objectparam" name="showthumbnailplayicon" value="false" <cfif !objectparams.showthumbnailplayicon> checked</cfif>/>No</label>
                                </div>
                            </div>
    
                            <!--- Thumbnail Play Icon Size --->
                            <div class="mura-control-group">
                                <label>Play Icon Size</label>
                                <select class="objectparam" name="thumbnailplayiconsize">
                                    <option value="">Select Play Icon Size</option>
                                    <cfloop list="1x,2x,3x,5x,7x,9x" item="i">
                                    <option <cfif objectparams.thumbnailplayiconsize eq i>selected </cfif>value="#i#">#i#</option>
                                    </cfloop>
                                </select>
                            </div>
    
                            <!--- Modal Play Icon Color
                            <div class="mura-control-group">
                                <label>Play Icon Color</label>
                                <select class="objectparam" name="thumbnailplayiconcolor">
                                    <option value="">Select Play Icon Color</option>
                                    <cfloop list="blue,purple,red,yellow,green,orange,gray,white,black" item="i">
                                    <option <cfif objectparams.thumbnailplayiconcolor eq i>selected </cfif>value="#i#">#i#</option>
                                    </cfloop>
                                </select>
                            </div> --->
    
                            <div class="mura-control-group">
                                <label>Play Icon Color</label>
                                <div class="input-group mura-colorpicker colorpicker-element">
                                    <span class="input-group-addon"><i class="mura-colorpicker-swatch"></i></span>
                                    <input type="text" id="thumbnailplayiconcolor" name="thumbnailplayiconcolor" class="objectparam" placeholder="Select Color" autocomplete="off" value="#objectparams.thumbnailplayiconcolor#">
                                </div>
                            </div>
    
                    </div>
                </div>           
    
                <div class="mura-panel-heading">
                    <h4 class="mura-panel-title">
                        <a class="collapse collapsed" data-toggle="collapse" data-parent="##panel-video-object" href="##panel-button-options">Button Options</a>
                    </h4>
                </div>
                <div id="panel-button-options" class="panel-collapse collapse">
                    <div class="mura-panel-body">
    
                        <!--- Button Class --->
                        <div class="mura-control-group">
                            <label>Button Class</label>
                            <select class="objectparam" name="buttonclass">
                                <option value="">Select Button Class</option>
                                <cfloop list="primary,secondary,success,warning,danger,info,light,dark,link" item="i">
                                <option <cfif objectparams.buttonclass eq i>selected </cfif>value="#i#">#i#</option>
                                </cfloop>
                            </select>
                        </div>
                        <!--- Button Text --->
                        <div class="mura-control-group">
                            <label>Button Text</label>
                            <input type="text" name="buttonctatext" class="objectparam" value="#esapiEncode('html_attr',objectparams.buttonctatext)#"/>
                        </div>
                        <!--- Show Button Play Icon --->
                        <div class="mura-control-group">
                            <label>Show Play Icon</label>
                            <div class="radio-group">
                            <label class="radio"><input type="radio" class="objectparam" name="showbuttonplayicon" value="true" <cfif objectparams.showbuttonplayicon> checked</cfif>/>Yes</label>
                            <label class="radio"><input type="radio" class="objectparam" name="showbuttonplayicon" value="false" <cfif !objectparams.showbuttonplayicon> checked</cfif>/>No</label>
                            </div>
                        </div>
                        <!--- Button Play Icon Size --->
                        <div class="mura-control-group">
                            <label>Play Icon Size</label>
                            <select class="objectparam" name="buttonplayiconsize">
                                <option value="">Select Play Icon Size</option>
                                <cfloop list="1x,2x,3x,5x,7x,9x" item="i">
                                <option <cfif objectparams.buttonplayiconsize eq i>selected </cfif>value="#i#">#i#</option>
                                </cfloop>
                            </select>
                        </div>
                        <!---Button Text--->
                        <!---Button Icon (Yes/No)--->
    
                    </div>
                </div>
    
                <div class="mura-panel-heading">
                    <h4 class="mura-panel-title">
                        <a class="collapse collapsed" data-toggle="collapse" data-parent="##panel-video-object" href="##panel-text-options">Text CTA Options</a>
                    </h4>
                </div>
                <div id="panel-text-options" class="panel-collapse collapse">
                    <div class="mura-panel-body">
    
                        <!--- CTA Text Wrapper --->
                        <div class="mura-control-group">
                            <label>CTA Text Wrapper</label>
                            <select class="objectparam" name="ctatextwrapper">
                                <option value="">Select CTA Text Wrapper</option>
                                <cfloop list="h1,h2,h3,h4,h5,h6,p" item="i">
                                <option <cfif objectparams.ctatextwrapper eq i>selected </cfif>value="#i#">#i#</option>
                                </cfloop>
                            </select>
                        </div>
                        <!--- Text CTA Text --->
                        <div class="mura-control-group">
                            <label>CTA Text</label>
                            <input type="text" name="textctatext" class="objectparam" value="#esapiEncode('html_attr',objectparams.textctatext)#"/>
                        </div>
                        <!--- Show Text CTA Play Icon --->
                        <div class="mura-control-group">
                            <label>Show Play Icon</label>
                            <div class="radio-group">
                            <label class="radio"><input type="radio" class="objectparam" name="showtextplayicon" value="true" <cfif objectparams.showtextplayicon> checked</cfif>/>Yes</label>
                            <label class="radio"><input type="radio" class="objectparam" name="showtextplayicon" value="false" <cfif !objectparams.showtextplayicon> checked</cfif>/>No</label>
                            </div>
                        </div>
                        <!--- Text CTA Icon Size --->
                        <div class="mura-control-group">
                            <label>Play Icon Size</label>
                            <select class="objectparam" name="textplayiconsize">
                                <option value="">Select Play Icon Size</option>
                                <cfloop list="1x,2x,3x,5x,7x,9x" item="i">
                                <option <cfif objectparams.textplayiconsize eq i>selected </cfif>value="#i#">#i#</option>
                                </cfloop>
                            </select>
                        </div>
    
                    </div>
                </div>
    
            </div><!--/panel-->
        </div><!--/panel-group-->
    </div>
    </cfoutput>
</cf_objectconfigurator>