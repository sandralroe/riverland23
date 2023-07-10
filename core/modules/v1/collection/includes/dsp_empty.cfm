<!--- license goes here --->
<cfif listFindNoCase('calendar,children',objectParams.sourceType) or listFindNoCase('author,editor',$.event('r').perm)>
    <cfoutput>
    <p class="mura-no-content-notice">#$.rbkey('collection.nomatchingcontent')#</p>
    </cfoutput>
</cfif>
