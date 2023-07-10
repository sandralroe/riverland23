<!--- license goes here --->
<cfinclude template="js.cfm">
<cfsavecontent variable="str"><cfoutput>
<link href="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/css/jquery/jquery.fileupload-ui.css?coreversion=#application.coreversion#" rel="stylesheet" type="text/css">
#session.dateKey#
<cfif rc.compactDisplay eq "true">
<script type="text/javascript">
jQuery(document).ready(function(){
    if (top.location != self.location) {
        if(jQuery("##ProxyIFrame").length){
            jQuery("##ProxyIFrame").load(
                function(){
                    frontEndProxy.post({cmd:'setWidth',width:'standard'});
                }
            );
        } else {
            frontEndProxy.post({cmd:'setWidth',width:'standard'});
        }
    }
});
</script>
</cfif>
</cfoutput>
</cfsavecontent>

<cfhtmlhead text="#str#">
<cfset rc.type="File">
<cfsilent>
<cfset rc.perm=application.permUtility.getnodePerm(rc.crumbdata)>

<cfset fileExt=''/>

</cfsilent>

<!--- check to see if the site has reached it's maximum amount of pages --->
<cfif (rc.rsPageCount.counter lt application.settingsManager.getSite(rc.siteid).getpagelimit() and  rc.contentid eq '') or rc.contentid neq ''>
<cfoutput>
<div class="mura-header">
    <h1>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.multifileupload")#</h1>

    <cfif rc.compactDisplay neq "true">

        <cfinclude template="dsp_secondary_menu.cfm">

        #$.dspZoom(crumbdata=rc.crumbdata,class="breadcrumb")#
    </cfif>
</div> <!-- /.mura-header -->


<div class="block block-constrain">
	<div class="block block-bordered">
	  <div class="block-content">

    <!--- <h2>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.multifileuploadinstructions")#</h2> --->
<div id="multi-file-upload">
    <!-- The file upload form used as target for the file upload widget -->
    <form id="fileupload" action="#application.configBean.getContext()##application.configBean.getAdminDir()#/" method="POST" enctype="multipart/form-data">
    	<!-- Creating a visual target for files. Doesn't actually do anything. Pure eye candy. -->
    	<div id="fileupload-target"><p><i class="mi-plus-circle"></i> Drag and drop files to upload</p></div>
        <!-- The fileupload-buttonbar contains buttons to add/delete files and start/cancel the upload -->
        <div class="fileupload-buttonbar">
            <div class="half">
                <!-- The fileinput-button span is used to style the file input field as button -->
                <span class="btn fileinput-button mura-file-add">
                    <i class="mi-plus"></i>
                    <span>Add files...</span>
                    <input type="file" name="files" multiple>
                </span>
                <button type="submit" class="btn start mura-file-start" style="display: none;">
                    <i class="mi-upload"></i>
                    <span>Upload</span>
                </button>
                <button type="reset" class="btn cancel mura-file-resets" style="display: none;">
                    <i class="mi-ban"></i>
                    <span>Cancel</span>
                </button>
                <!---
                <button type="button" class="btn btn-danger delete">
                    <i class="mi-trash icon-white"></i>
                    <span>Delete</span>
                </button>
                <input type="checkbox" class="toggle">
                --->
            </div>
            <!-- The global progress information -->
            <div class="fileupload-progress fade half">
                <!-- The global progress bar -->
                <div class="progress" id="progress-multi-global" style="display: none;">
                    <div class="progress-bar progress-bar-striped" role="progressbar" aria-valuemin="0" aria-valuemax="100" style="width:0%;"></div>
                </div>
                <!-- The extended global progress information -->
                <div class="progress-extended">&nbsp;</div>
            </div>
        </div>
        <!-- The loading indicator is shown during file processing
        <div class="fileupload-loading"></div>

        <br> -->
        <!-- The table listing the files available for upload/download -->
        <table role="presentation" class="mura-table-grid">
        <tbody class="files" data-toggle="modal-gallery" data-target="##modal-gallery"></tbody></table>
      <input type="hidden" name="muraAction" value="cArch.update"/>
      <input type="hidden" name="action" value="multifileupload"/>
      <input type="hidden" name="siteid" value="#esapiEncode('html_attr',rc.siteid)#"/>
      <input type="hidden" name="moduleid" value="#esapiEncode('html_attr',rc.moduleid)#"/>
      <input type="hidden" name="topid" value="#esapiEncode('html_attr',rc.topid)#"/>
      <input type="hidden" name="ptype" value="#esapiEncode('html_attr',rc.ptype)#"/>
      <input type="hidden" name="parentid" value="#esapiEncode('html_attr',rc.parentid)#"/>
      <input type="hidden" name="contentid" value=""/>
      <input type="hidden" name="type" value="File"/>
      <input type="hidden" name="subtype" value="Default"/>
      <input type="hidden" name="startrow" value="#rc.startrow#"/>
      <input type="hidden" name="orderno" value="0"/>
      <input type="hidden" name="approved" value="<cfif rc.perm eq 'editor'>1<cfelse>0</cfif>" />
      #rc.$.renderCSRFTokens(context=rc.parentid & 'multifileupload',format='form')#
    </form>
</div>
</div>

<script id="template-upload" type="text/x-tmpl">
{% for (var i=0, file; file=o.files[i]; i++) {
     var fileext=$(file.name.split(".")).get(-1).toUpperCase();
     var isImageFile=fileext=='JPEG' || fileext=='JPG' || fileext=='GIF' || fileext=='PNG'  || fileext=='WEBP';
    %}
    <tr class="template-upload fade">
        <td class="file-preview">
            <span class="preview">
			</span>
        </td>
        <td class="var-width form-horizontal">
        	<div class="mura-control-group">
	            <label>File name</label>
        		<div class="name">{%=file.name%}</div>
			</div>
	        <div class="mura-control-group">
	           	<label>Title</label>
           		<div class="editable nolinebreaks" data-attribute="title" contenteditable="true">{%=file.name%}</div>
	        </div>
	        <div class="mura-control-group">
	            <label>Summary/Caption</label>
				<div id="summaryinstance"
                class="editable" data-attribute="summary" contenteditable="true"></div>
	        </div>
	        <div class="mura-control-group">
	        	<label>Credits</label>
                {% if(isImageFile){  %}
        		 <div id="creditsinstance"
                    class="editable htmlEditor" data-attribute="credits" contenteditable="true"></div>
                 {% } else { %}
                 <div id="creditsinstance"
                    class="editable" data-attribute="credits" contenteditable="true"></div>
                {% } %}
	        </div>
            {% if(isImageFile){  %}
	        <div class="mura-control-group">
	        	<label>Alt Text</label>
        		<div class="editable nolinebreaks" data-attribute="alttext" contenteditable="true"></div>
			</div>
            {% } %}
            {% if (file.error) { %}
                <div><span class="label label-important">Error</span> {%=file.error%}</div>
            {% } %}
        </td>
        <td>

            {% if (!o.files.error) { %}
                <div class="progress">
                    <div class="progress-bar progress-bar-striped active" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0" style="width:0%;"></div>
                </div>
                <p class="size">{%=o.formatFileSize(file.size)%}</p>
            {% } %}
        </td>
        <td>
        	<div class="mura-input-set">
            {% if (!o.files.error && !i && !o.options.autoUpload) { %}
                <button class="btn start">
                    <i class="mi-upload"></i><span> Upload</span>
                </button>
            {% } %}
            {% if (!i) { %}
                <button class="btn cancel">
                    <i class="mi-ban"></i><span> Cancel</span>
                </button>
            {% } %}
			</div>
        </td>
    </tr>
{% } %}
</script>

<!-- The template to display files available for download -->
<script id="template-download" type="text/x-tmpl">
{% for (var i=0, file; file=o.files[i]; i++) { %}
    <tr class="template-download fade">
        <td class="file-preview">
            <span class="preview">
                {% if (file.thumbnail_url) { %}
                    <a href="{%=file.url%}" title="{%=file.title%}" class="gallery" download="{%=file.filename%}"><img src="{%=file.thumbnail_url%}"></a>
                {% } else { %}
                    <i class="mi-file-text-o"></i>
                {% } %}
                <span class="badge">{%=$(file.filename.split(".")).get(-1).toUpperCase()%}</span>
            </span>
        </td>
        <td class="var-width form-horizontal">
            <div class="mura-control-group">
                <label>File name</label>
                <div class="name">{%=file.filename%}</div>
            </div>
            {% if (file.error) { %}
                <div><span class="label label-important">Error</span> {%=file.error%}</div>
            {% }  else { %}
                <div class="mura-control-group">
                    <label>Title</label>
                    <div data-attribute="title">{%=file.title%}</div>
                </div>
                 {% if (file.summary) { %}
                <div class="mura-control-group">
                    <label>Summary/Caption</label>
                    <div data-attribute="summary">{%##file.summary%}</  div>
                    </div>
                </div>
                {% } %}
                {% if (file.credits) { %}
                <div class="mura-control-group">
                    <label>Credits</label>
                    <div data-attribute="credits">{%##file.credits%}</div>
                </div>
                {% } %}
                {% if (file.thumbnail_url && file.alttext) { %}
                <div class="mura-control-group">
                    <label>Alt Text</label>
                    <div data-attribute="alttext">{%=file.alttext%}</div>
                </div>
                 {% } %}
            {% } %}
        </td>
        <td><div class="progress">
                <div class="progress-bar complete" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0" style="width:100%;"></div>
            </div>
            <span class="size complete">{%=o.formatFileSize(file.size)%}</span>
        </td>
        <td>
        {% if (file.edit_url !='') { %}
        <a class="btn mura-edit-file" onclick="confirmDialog('Would you like to edit this file?','{%=file.edit_url%}','','Edit File');"><i class="mi-pencil"></i> Edit</a>
         {% } %}
        <!---
            <button class="btn btn-danger delete" data-type="{%=file.delete_type%}" data-url="{%=file.delete_url%}"{% if (file.delete_with_credentials) { %} data-xhr-fields='{"withCredentials":true}'{% } %}>
                <i class="mi-trash icon-white"></i>
                <span>Delete</span>
            </button>
            <input type="checkbox" name="delete" value="1" class="toggle">
        --->
        </td>
    </tr>
{% } %}
</script>
<!-- The Templates plugin is included to render the upload/download listings -->
<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/jquery/tmpl.min.js?coreversion=#application.coreversion#"></script>
<!-- The Load Image plugin is included for the preview images and image resizing functionality -->
<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/jquery/load-image.min.js?coreversion=#application.coreversion#"></script>
<!-- The Canvas to Blob plugin is included for image resizing functionality -->
<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/jquery/canvas-to-blob.min.js?coreversion=#application.coreversion#"></script>

<!-- blueimp Gallery script
<script src="#application.settingsManager.getSite(rc.siteid).getScheme()#://blueimp.github.io/Gallery/js/blueimp-gallery.min.js"></script>
-->
<!-- The Iframe Transport is required for browsers without support for XHR file uploads -->
<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/jquery/jquery.iframe-transport.js?coreversion=#application.coreversion#"></script>
<!-- The basic File Upload plugin -->
<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/jquery/jquery.fileupload.js?coreversion=#application.coreversion#"></script>
<!-- The File Upload processing plugin -->
<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/jquery/jquery.fileupload-process.js?coreversion=#application.coreversion#"></script>
<!-- The File Upload image preview & resize plugin -->
<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/jquery/jquery.fileupload-image.js?coreversion=#application.coreversion#"></script>
<!-- The File Upload audio preview plugin -->
<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/jquery/jquery.fileupload-audio.js?coreversion=#application.coreversion#"></script>
<!-- The File Upload video preview plugin -->
<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/jquery/jquery.fileupload-video.js?coreversion=#application.coreversion#"></script>
<!-- The File Upload validation plugin -->
<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/jquery/jquery.fileupload-validate.js?coreversion=#application.coreversion#"></script>
<!-- The File Upload user interface plugin -->
<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/jquery/jquery.fileupload-ui.js?coreversion=#application.coreversion#"></script>
<!-- The localization script -->
<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/jquery/jquery.fileupload.locale.js?coreversion=#application.coreversion#"></script>

<!-- The main application script -->
<script>

var fileIndex=0;

$(function () {
    'use strict';

    $.blueimp.fileupload.prototype._renderPreviews= function (data) {
            data.context.find('.preview').each(function (index, elm) {
                var fileext=$(data.files[index].name.split(".")).get(-1).toUpperCase();
                if(fileext=='JPEG' || fileext=='JPG' || fileext=='GIF' || fileext=='PNG' || fileext=='WEBP'){
                    $(elm).append(data.files[index].preview);
                    $(elm).append('<span class="badge">' + fileext + '</span>' )
                } else {
                    $(elm).append('<i class="mi-file-text-o"></i><span class="badge">' + fileext + '</span>' );
                }
            });
        }

    $.blueimp.fileupload.prototype._renderUpload= function (files) {

            var ret= this._renderTemplate(
                this.options.uploadTemplate,
                files
            );

            fileIndex++;

            var id="summaryid" + fileIndex;

            ret.find('div[data-attribute="summary"]').attr("id",id);

            id="creditsid" + fileIndex;

            ret.find('div[data-attribute="credits"]').attr("id",id);

            return ret;
        }

    $.blueimp.fileupload.prototype._renderDownload= function (files) {
            return this._renderTemplate(
                this.options.downloadTemplate,
                files
            ).find('a[download]').each(this._enableDragToDesktop).end();
        }

    // Initialize the jQuery File Upload widget:
    $('##fileupload').fileupload(
        {url:'#application.configBean.getContext()##application.configBean.getAdminDir()#/',
        getFilesFromResponse: function (data) {
                if (data.result && $.isArray(data.result.files)) {
                    return data.result.files;
                }
                return [];
            },
        limitConcurrentUploads: 4
        }
    ).bind('fileuploadsubmit', function (e, data) {

        var extraParams={};

        data.formData=$('##fileupload').serializeArray();

        $(data.context).find('.editable').each(
            function(){
             extraParams[$(this).attr('data-attribute')]=$(this).html();
            }
        );

        data.formData.push({name:'extraParams',value:JSON.stringify(extraParams)});

        //alert(data.formData.extraParams);
        //return false;

    })
    .bind('fileuploadadded',function(e,data){

        var id="summaryid" + fileIndex;

        $('##progress-multi-global').show();
        $('.fileupload-buttonbar .mura-file-start').show();
        $('.fileupload-buttonbar .mura-file-resets').show();

        if(CKEDITOR.instances[id]){
            CKEDITOR.instances[id].destroy();
        }

        CKEDITOR.inline(
                document.getElementById(id),
                {
                    toolbar: 'Basic',
                    width: "75%",
                    customConfig: 'config.js.cfm'
                }
            );

        id="creditsid" + fileIndex;

        if(CKEDITOR.instances[id]){
            CKEDITOR.instances[id].destroy();
        }

        if($("##" + id).hasClass('htmlEditor')){
            CKEDITOR.inline(
                    document.getElementById(id),
                    {
                        toolbar: 'Basic',
                        width: "75%",
                        customConfig: 'config.js.cfm'
                    }
                );
        }

        $(document).on('click', '.mura-file-resets', function(e){
            $('##progress-multi-global').hide();
            $('.fileupload-buttonbar .mura-file-start').hide();
            $('.fileupload-buttonbar .mura-file-resets').hide();

        })

        $(document).on('keypress', '.editable.nolinebreaks', function(e){

            if(e.which == 13){
                e.preventDefault();
                $(this).next('.editable').focus();
            }
        });
    });

});
</script>
</cfoutput>
<cfelse>
<div>
<cfinclude template="form/dsp_full.cfm">
</div>
</cfif>
</div> <!-- /.block-content -->
</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
