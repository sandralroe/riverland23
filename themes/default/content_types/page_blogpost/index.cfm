<cfoutput>
    #Mura.dspObject(
        object="header",
        objectParams=urlDecode(Mura.content('headerParams')),
        targetattr='headerParams'
    )#
   <div class="container bg-danger"><h2>this is display object 2</h2> #Mura.dspObjects(2)#<!---Pre-Content Display Region---></div>
    <div class="container my-5 bg-info">
        <div class="row justify-content-center">
            <div class="col-10 content">
                #Mura.renderEditableAttribute(attribute="body",type="htmlEditor")#
            </div>
        </div>
    </div>
   <div class="container bg-warning"><h2>this is display object 3</h2> #Mura.dspObjects(3)#<!---Pre-Footer Display Region---></div>
</cfoutput>
