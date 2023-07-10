<cfoutput>
	#Mura.dspObject(
		object="header",
		objectParams=urlDecode(Mura.content('headerParams')),
		targetattr='headerParams'
    )#
   <div class="container bg-danger"><h2>This is display object 2</h2> #Mura.dspObjects(2)#<!---Pre-Content Display Region---></div>
    <div class="container mt-3" style="background-color: ##cccccc;">
        <div class="row">
            <div class="col content">
            <!--- Primary Associated Image --->
                <cfif Mura.content().hasImage(usePlaceholder=false)>
                    <cfscript>
                        img = Mura.content().getImageURL(
                            size = 'hero' // small, medium, large, custom, or any other pre-defined image size
                            ,complete = false // set to true to include the entire URL, not just the absolute path (default)
                        );
                    </cfscript>
                    <div class="mura-asset mb-4 bg-success">
                        <img class="mura-meta-image" src="#img#" alt="#esapiEncode('html_attr', Mura.content('title'))#">
                    </div>
                </cfif>
            <!--- /Primary Associated Image --->
            #Mura.renderEditableAttribute(attribute="body",type="htmlEditor")#
            </div>
        </div>
    </div>
 <div class="container bg-warning"> <h2>This is display object 3 </h2>  #Mura.dspObjects(3)#<!---Pre-Footer Display Region--->
</cfoutput>
