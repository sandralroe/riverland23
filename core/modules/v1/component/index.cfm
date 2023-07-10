<!--- license goes here --->
<cfsilent>
	<cfif isValid("UUID",arguments.objectID)>
		<cfset bean = variables.$.getBean("content").loadBy(contentID=arguments.objectID,siteID=arguments.siteID)>
	<cfelse>
		<cfset bean = variables.$.getBean("content").loadBy(title=arguments.objectID,siteID=arguments.siteID,type='Component')>
	</cfif>

	<cfset variables.rsTemplate=bean.getAllValues()>
	<cfset variables.event.setValue("component",variables.rsTemplate)>

	<cfset variables.rsTemplate.isOnDisplay=variables.rsTemplate.display eq 1 or
			(
				variables.rsTemplate.display eq 2 and variables.rsTemplate.DisplayStart lte now()
				AND (variables.rsTemplate.DisplayStop gte now() or variables.rsTemplate.DisplayStop eq "")
			)
			and listFind(variables.rsTemplate.moduleAssign,'00000000000000000000000000000000000')>
</cfsilent>
<cfif bean.exists()>
	<cfset objectparams.objectid=bean.getContentID()>

	<cfif variables.rsTemplate.isOnDisplay>
		<cfset variables.componentOutput=application.pluginManager.renderEvent("onComponent#bean.getSubType()#BodyRender",variables.event)>
		<cfset safesubtype=REReplace(bean.getSubType(), "[^a-zA-Z0-9_]", "", "ALL")>
		<cfif not len(variables.componentOutput)>
			<cfset variables.componentOutput=$.dspObject_include(theFile='extensions/dsp_Component_' & safesubtype & ".cfm",throwError=false)>
		</cfif>
		<cfif not len(variables.componentOutput)>
			<cfset filePath=$.siteConfig().lookupContentTypeFilePath('component/index.cfm')>
			<cfif len(filePath)>
				<cfsavecontent variable="variables.componentOutput">
					<cfinclude template="#filepath#">
				</cfsavecontent>
				<cfset variables.componentOutput=trim(variables.componentOutput)>
			</cfif>
		</cfif>
		<cfif not len(variables.componentOutput)>
			<cfset filePath=$.siteConfig().lookupContentTypeFilePath(lcase('component_#safesubtype#/index.cfm'))>
			<cfif len(filePath)>
				<cfsavecontent variable="variables.componentOutput">
					<cfinclude template="#filepath#">
				</cfsavecontent>
				<cfset variables.componentOutput=trim(variables.componentOutput)>
			</cfif>
		</cfif>
		<cfif len(variables.componentOutput)>
			<cfoutput>#variables.componentOutput#</cfoutput>
		<cfelse>
			<cfif len(variables.rsTemplate.template) and fileExists("#getSite().getTemplateIncludeDir()#/components/#variables.rsTemplate.template#")>
				<cfset variables.componentBody=variables.rsTemplate.body>
				<cfinclude template="#getSite().getTemplateIncludePath()#/components/#variables.rsTemplate.template#">
			<cfelse>
				<cfoutput>#variables.$.setDynamicContent(variables.rsTemplate.body)#</cfoutput>
			</cfif>
		</cfif>
	<cfelse>
		<cfoutput><!-- component {title:"#esapiEncode("html", variables.rsTemplate.title)#", contentid:"#esapiEncode("html", variables.rsTemplate.contentid)#"} offline -->
		<script>
			Mura(function(){
				if(!Mura.editing){
					var textMod=Mura('div.mura-object[data-instanceid="#objectparams.instanceid#"]').closest('div.mura-object[data-object="text"]');
					if(textMod.length){
						textMod.hide();
					}
				}
			})
		</script>
		</cfoutput>
	</cfif>
	<cfif not variables.rsTemplate.doCache>
		<cfset request.cacheItem=variables.rsTemplate.doCache/>
	</cfif>
<cfelseif listFindNoCase('author,editor',variables.$.event('r').perm)>
	<p></p>
<cfelse>
	<cfset request.muraValidObject=false>
</cfif>
