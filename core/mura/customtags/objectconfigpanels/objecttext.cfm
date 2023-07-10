<cfoutput>
<div class="mura-control-group flex-container-object breakpointtoggle" id="#attributes.name#textid" data-toggle="bp-tabs">

    <div class="bp-tabs">
    <cfloop list="xs,sm,md,lg,xl" index="size">
        <div class="bp-tab bp-tab-<cfoutput>#size#</cfoutput><cfif size eq 'xl'> bp-current</cfif>" data-breakpoint="#size#" style="display:<cfif size eq 'xl'>block<cfelse>none</cfif>;">
        <cfif size eq 'xl'>
            <cfset nameAndSize="#attributes.name#">
        <cfelse>
            <cfset nameAndSize="#attributes.name#_#size#_">
        </cfif>
        <label>Text Color</label>
        <div class="input-group mura-colorpicker">
            <span class="input-group-addon"><i class="mura-colorpicker-swatch"></i></span>
            <input type="text" id="#nameAndSize#color" name="color" class="#nameAndSize#Style" placeholder="Select Color" autocomplete="off" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].color)#">
        </div>
        </div>
    </cfloop>
    </div>
</div>
</cfoutput>