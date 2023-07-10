<!--- license goes here --->
<cfset event=request.event>
<cfsavecontent variable="rc.ajax">

<cfif listLast(rc.muraAction,".") eq 'edit'>
	<script type="text/javascript">
	  summaryLoaded=false;
	</script>

<cfset rsPluginScripts=application.pluginManager.getScripts("onHTMLEditHeader",rc.siteID)>
<cfif rsPluginScripts.recordcount>
	<cfset variables.pluginEvent=createObject("component","mura.event").init(event.getAllValues())/>
	<cfoutput>#application.pluginManager.renderScripts("onHTMLEditHeader",rc.siteid,pluginEvent,rsPluginScripts)#</cfoutput>
<cfelse>
<cfoutput>
	<script type="text/javascript">

	 summaryLoaded=true;

	 editSummary = function(){
	 		<cfif application.configBean.getValue("htmlEditorType") neq "none">
	 		if(!summaryLoaded){
			     if(jQuery('##summary').html()==''){
			     	jQuery('##summary').html('<p></p>');
			     }
		     	jQuery('##summary').ckeditor(
		     		{ toolbar:'Summary',
		     		  customConfig : 'config.js.cfm'},
		     		htmlEditorOnComplete
		     	);
	    		summaryLoaded=true;
			}
			</cfif>
		}
  </script>
 </cfoutput>
</cfif>
</cfif>
</cfsavecontent>
