<!--- license goes here --->
<cfcomponent extends="mura.bean.bean" output="false" hint="This provides plugin config xml event handling registration">
	<cfproperty name="scriptID" type="string" default="" required="true">
	<cfproperty name="moduleID" type="string" default="" required="true">
	<cfproperty name="runAt" type="string" default="" required="true">
	<cfproperty name="scriptFile" type="string" default="" required="true">
	<cfproperty name="doCache" type="boolean" default="false" required="true">

	<cfscript>
	function init() output=false {
		super.init(argumentCollection=arguments);
		variables.instance.scriptID="";
		variables.instance.moduleID="";
		variables.instance.runat="";
		variables.instance.scriptfile="";
		variables.instance.docache="false";
		return this;
	}

	function setConfigBean(configBean) output=false {
		variables.configBean=arguments.configBean;
		return this;
	}

	function getScriptID() output=false {
		if ( !len(variables.instance.scriptID) ) {
			variables.instance.scriptID = createUUID();
		}
		return variables.instance.scriptID;
	}

	function setDoCache(String docache) output=false {
		if ( isBoolean(arguments.docache) ) {
			variables.instance.docache = arguments.docache;
		}
	}

	function load() output=false {
		set(getQuery());
	}
	</cfscript>

	<cffunction name="getQuery"  output="false">
		<cfset var rs=""/>
		<cfquery name="rs" datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
			select scriptID, moduleID, scriptfile, runat, docache from tpluginscripts where scriptID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getScriptID()#">
		</cfquery>

		<cfreturn rs/>
	</cffunction>

	<cffunction name="delete">
		<cfquery datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
			delete from tpluginscripts
			where scriptID=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#getScriptID()#">
		</cfquery>
	</cffunction>

	<cffunction name="save"  output="false">
		<cfset var rs=""/>
		<cfset var rsLocation=""/>
		<cfset var pluginXML=""/>

		<cfif getQuery().recordcount>
			<cfquery datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
				update tpluginscripts set
				moduleID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.moduleID#">,
				runat=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.runAt#">,
				scriptFile=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.scriptFile#">,
				docache=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.doCache#">
				where scriptID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getScriptID()#">
			</cfquery>
		<cfelse>
			<cfquery datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
				insert into tpluginscripts (scriptID,moduleID,runat,scriptfile,docache) values (
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#getScriptID()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.moduleID#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.runAt#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.scriptFile#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.doCache#">
				)
			</cfquery>
		</cfif>
	</cffunction>

</cfcomponent>
