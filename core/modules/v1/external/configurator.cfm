<cfscript>
	objectparams.render='client';
	objectparams.async=false;
	configuratorMarkup='';

	if(isValid("url", objectConfig.configurator)){
		httpService=application.configBean.getHTTPService();
		httpService.setMethod("get");
		httpService.setCharset("utf-8");
		httpService.setURL(objectConfig.configurator);
		configuratorMarkup=httpService.send().getPrefix().filecontent;
	} else {
		configuratorMarkup=objectConfig.configurator;
	}

	if(isJSON(configuratorMarkup)){
		configuratorMarkup=deserializeJSON(configuratorMarkup);
	}
</cfscript>
<cfif isArray(configuratorMarkup) or isSimpleValue(configuratorMarkup) and len(configuratorMarkup)>
		<cf_objectconfigurator params="#objectparams#">
			
			<cfif isArray(configuratorMarkup)>
				<cfimport prefix="ui" taglib="../../../mura/customtags/configurator/ui">
				<cfloop from="1" to="#arrayLen(configuratorMarkup)#" index="idx">
					<cfif structKeyExists(configuratorMarkup[idx],'name') and configuratorMarkup[idx].name neq 'label'>
						<cfset params=duplicate(configuratorMarkup[idx])>
						<cfset params.instanceid=objectparams.instanceid>
						<cfset params.contentid=Mura.content('contentid')>
						<cfset params.contenthistid=Mura.content('contenthistid')>
						<cfset params.siteid=Mura.content('siteid')>
						<cfif structKeyExists(objectparams,params.name)>
							<cfset params.value=objectparams[params.name]>
						<cfelseif structKeyExists(params,'default')>
							<cfset params.value=params.default>
						</cfif>
						<ui:param attributecollection="#params#">
					</cfif>
				</cfloop>
				<cfloop from="1" to="#arrayLen(configuratorMarkup)#" index="idx">
					<cfif structKeyExists(configuratorMarkup[idx],'name') and configuratorMarkup[idx].name neq 'label'>
					<cfinclude template="#$.siteConfig().lookupDisplayObjectFilePath('object/configurator.cfm')#">
					<cfbreak>
					</cfif>
				</cfloop>
			<cfelse>
				<cfoutput>#configuratorMarkup#</cfoutput>
			</cfif>
			<script>
			Mura(function(){
				siteManager.requestDisplayObjectParams(function(params){},'sidebar');
			});
			</script>
		</cf_objectconfigurator>
<cfelse>
	<cf_objectconfigurator basictab=false>
	</cf_objectconfigurator>
</cfif>
