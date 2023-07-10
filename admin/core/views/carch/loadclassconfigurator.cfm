 <!--- license goes here --->
<cfsilent>
	<cfset request.layout=false>
	<cfparam name="rc.layoutmanager" default="false">
	<cfparam name="rc.container" default="">
	<cfparam name="rc.contentid" default="">
	<cfparam name="rc.parentid" default="">
	<cfparam name="rc.contenthistid" default="">
	<cfparam name="rc.objectid" default=""/>
	<cfparam name="rc.configuratorMode" default="frontend">

	<cfset contentRendererUtility=rc.$.getBean('contentRendererUtility')>
	<cfset rc.classid=listLast(replace(rc.classid, "\", "/", "ALL"),"/")>
	<cfset rc.container=listLast(replace(rc.container, "\", "/", "ALL"),"/")>
	<cfparam name="form.params" default="">
	<cfset form.params=urlDecode(form.params)>
	<cfif isJSON(form.params)>
		<cfset objectParams=deserializeJSON(form.params)>
	<cfelse>
		<cfset objectParams={}>
	</cfif>

	<cfif not (isDefined("objectParams.cssstyles") and isStruct(objectParams.cssstyles))>
		<cfif isDefined("objectParams.cssstyles") and isJSON(objectParams.cssstyles)>
			<cfset objectParams.cssstyles=deserializeJSON(objectParams.cssstyles)>
		<cfelse>
			<cfset objectParams.cssstyles={}>
		</cfif>
	</cfif>

	<cfif not (isDefined("objectParams.metacssstyles") and isStruct(objectParams.metacssstyles))>
		<cfif isDefined("objectParams.metacssstyles") and isJSON(objectParams.metacssstyles)>
			<cfset objectParams.metacssstyles=deserializeJSON(objectParams.metacssstyles)>
		<cfelse>
			<cfset objectParams.metacssstyles={}>
		</cfif>
	</cfif>
	<cfif not (isDefined("objectParams.contentcssstyles") and isStruct(objectParams.contentcssstyles))>
		<cfif isDefined("objectParams.contentcssstyles") and isJSON(objectParams.contentcssstyles)>
			<cfset objectParams.contentcssstyles=deserializeJSON(objectParams.contentcssstyles)>
		<cfelse>
			<cfset objectParams.contentcssstyles={}>
		</cfif>
	</cfif>

	<cfloop collection="#objectParams#" item="prop" >
        <cfif isJSON(objectParams['#prop#'])>
			<cfset objectParams['#prop#']=deserializeJSON(objectParams['#prop#'])>
		</cfif>  
	</cfloop>

	<cfset data=structNew()>
	<cfset filefound=false>
	<cfset $=rc.$>
	<cfset m=rc.$>
	<cfset Mura=rc.$>

	<cfset $.event('contentBean',$.getBean('content').loadBy(contenthistid=rc.contenthistid))>
	<cfset request.$=$>

	<cfif rc.classid eq "category_summary" and not application.configBean.getValue(property='allowopenfeeds',defaultValue=false)>
		<cfset rc.classid='nav'>
	</cfif>

	<cfif rc.classid eq 'form_responses'>
		<cfset rc.classid='form'>
	<cfelseif rc.classid eq 'mailing_list_master'>
		<cfset rc.classid='mailing_list'>
	<cfelseif listFindNoCase('comments,favorites,forward_email,event_reminder_form,rater,payPalCart,user_tools,goToFirstChild',rc.classid)>
		<cfset rc.classid='system'>
	<cfelseif listFindNoCase('sub_nav,peer_nav,standard_nav,portal_nav,folder_nav,multilevel_nav,seq_nav,top_nav,calendar_nav,archive_nav,tag_cloud,category_summary,calendar_nav',rc.classid)>
		<cfset rc.classid='nav'>
	</cfif>

	<cfif rc.container eq 'layout'>
		<cfset configFileSuffix="#rc.classid#/layout/index.cfm">
	<cfelse>
		<cfset objectConfig=rc.$.siteConfig().getDisplayObject(rc.classid)>

		<cfif isDefined('objectConfig.external') and objectConfig.external>
			<cfset configFileSuffix="external/configurator.cfm">
		<cfelse>
			<cfset configFileSuffix="#rc.classid#/configurator.cfm">
		</cfif>
	</cfif>

	<cfset configFile=rc.$.siteConfig().lookupDisplayObjectFilePath(configFileSuffix)>
</cfsilent>

<cfif len(configFile)>
	<cfinclude template="#configFile#">
<cfelse>
	<cfswitch expression="#rc.classid#">
		<cfcase value="feed">
			<cfinclude template="objectclass/legacy/dsp_feed_configurator.cfm">
		</cfcase>
		<cfcase value="feed_slideshow">
			<cfinclude template="objectclass/legacy/dsp_slideshow_configurator.cfm">
		</cfcase>
		<cfcase value="related_content,related_section_content">
			<cfinclude template="objectclass/legacy/dsp_related_content_configurator.cfm">
		</cfcase>
		<cfdefaultcase>
			<cfif rc.$.useLayoutManager()>
				<cf_objectconfigurator basictab=false></cf_objectconfigurator>
			<cfelse>
				<cfoutput>
					<div class="help-block-empty">This display object is not configurable.</div>
				</cfoutput>
			</cfif>
		</cfdefaultcase>
	</cfswitch>
</cfif>

<cfif not isDefined('request.objectconfiguratortag')>
<script>
	setTimeout(
		function(){
			window.configuratorInited=true;
			window.configuratorBgInited=true;
			window.configuratorLMInited=true;
		},
		1000
	);
</script>
</cfif>
