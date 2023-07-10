<!--- license goes here --->
<cfsavecontent variable="rc.ajax">
<cfoutput>
</script>

<div id="newContentMenu" class="addNew hide">
  <ul id="newCategoryOptions">
    <li id="newPage"><a href="" id="newCategoryLink" <!---ontouchstart="this.onclick();"--->><i class="mi-plus"></i> <cfoutput>#application.rbFactory.getKeyValue(session.rb,'categorymanager.addsubcategory')#</cfoutput></a></li>
 </ul>
</div>
</cfoutput>
</cfsavecontent>
