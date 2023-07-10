 <!--- license goes here --->
<cfsilent>
	<cfset request.layout=false>
	<cfparam name="rc.layoutmanager" default="false">
	<cfparam name="rc.contentid" default="">
	<cfparam name="rc.parentid" default="">
	<cfparam name="rc.contenthistid" default="">
	<cfparam name="rc.objectid" default=""/>
	<cfset contentRendererUtility=rc.$.getBean('contentRendererUtility')>
	<cfset $=rc.$>
	<cfset m=rc.$>
	<cfset Mura=rc.$>

	<cfset $.event('contentBean',$.getBean('content').loadBy(contenthistid=rc.contenthistid))>
	<cfset request.$=$>

</cfsilent>

<cfswitch expression="#rc.classid#">
	<cfcase value="component">
		<cfinclude template="objectclass/legacy/dsp_components.cfm">
	</cfcase>
	<cfcase value="mailingList">
		<cfinclude template="objectclass/legacy/dsp_mailinglists.cfm">
	</cfcase>
	<cfcase value="system">
		<cfinclude template="objectclass/legacy/dsp_system.cfm">
	</cfcase>
	<cfcase value="navigation">
		<cfinclude template="objectclass/legacy/dsp_navigation.cfm">
	</cfcase>
	<cfcase value="form">
		<cfinclude template="objectclass/legacy/dsp_forms.cfm">
	</cfcase>
	<cfcase value="adzone">
		<cfinclude template="objectclass/legacy/dsp_adzones.cfm">
	</cfcase>
	<cfcase value="Folder">
		<cfinclude template="objectclass/legacy/dsp_Folders.cfm">
	</cfcase>
	<cfcase value="calendar">
		<cfinclude template="objectclass/legacy/dsp_calendars.cfm">
	</cfcase>
	<cfcase value="gallery">
		<cfinclude template="objectclass/legacy/dsp_galleries.cfm">
	</cfcase>
	<cfcase value="localFeed">
		<cfinclude template="objectclass/legacy/dsp_localfeeds.cfm">
	</cfcase>
	<cfcase value="slideshow">
		<cfinclude template="objectclass/legacy/dsp_slideshows.cfm">
	</cfcase>
	<cfcase value="remoteFeed">
		<cfinclude template="objectclass/legacy/dsp_remotefeeds.cfm">
	</cfcase>
	<cfcase value="plugins">
		<cfinclude template="objectclass/legacy/dsp_plugins.cfm">
	</cfcase>
	<cfcase value="plugin">
		<cfinclude template="objectclass/legacy/dsp_plugin_configurator.cfm">
	</cfcase>
</cfswitch>

<cfif not rc.layoutmanager>
	<cfif fileExists("#application.configBean.getWebRoot()#/#rc.siteid#/includes/display_objects/custom/admin/dsp_objectClass.cfm")>
		<cfinclude template="/#application.configBean.getWebRootMap()#/#rc.siteID#/includes/display_objects/custom/admin/dsp_objectClass.cfm">
	</cfif>
</cfif>

