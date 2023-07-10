<cfoutput>
	#Mura.dspObject(
		object="header",
		objectParams=urlDecode(Mura.content('headerParams')),
		targetattr='headerParams'
	)#
	this is page template
    #Mura.dspObjects(2)#<!---Pre-Content Display Region--->
	<div class="container mt-3">
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
                    <div class="mura-asset mb-4">
                        <img class="mura-meta-image" src="#img#" alt="#esapiEncode('html_attr', Mura.content('title'))#">
                    </div>
                </cfif>
            <!--- /Primary Associated Image --->
			#Mura.renderEditableAttribute(attribute="body",type="htmlEditor")#
			</div>
		</div>
	</div>
	#Mura.dspObjects(3)#<!---Pre-Footer Display Region--->
</cfoutput>
