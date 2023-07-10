<cfimport prefix="ui" taglib="../../../mura/customtags/configurator/ui">
<cfscript>
    param name="objectparams.pdfurl" default="";
    param name="objectparams.pdffilename" default="";
</cfscript>
<cf_objectconfigurator>
    <div class="mura-control-group">
        <label class="mura-control-label">PDF URL</label>
        <cfoutput><input type="text" id="pdfurl" name="pdfurl" class="objectParam" value="#esapiEncode('html_attr',objectparams.pdfurl)#"/></cfoutput>
        <button type="button" class="btn mura-finder" data-target="pdfurl" data-completepath="false"><i class="mi-file-pdf-o"></i> Select PDF</button>
    </div>
    <div class="mura-control-group">
        <label class="mura-control-label">Filename (optional)</label>
        <cfoutput><input type="text" name="pdffilename" class="objectParam" value="#esapiEncode('html_attr',objectparams.pdffilename)#"/></cfoutput>
    </div>
</cf_objectconfigurator>
