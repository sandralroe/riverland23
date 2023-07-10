<!--- license goes here --->
<cfcomponent extends="mura.bean.bean" output="false" hint="This provides CRUD functionality to legacy config.xml display objects">
	<cfproperty name="objectID" type="string" default="" required="true">
	<cfproperty name="moduleID" type="string" default="" required="true">
	<cfproperty name="name" type="string" default="" required="true">
	<cfproperty name="location" type="string" default="" required="true">
	<cfproperty name="displayMethod" type="string" default="" required="true">
	<cfproperty name="displayMethodFile" type="string" default="" required="true">
	<cfproperty name="doCache" type="string" default="false" required="true">
	<cfproperty name="configuratorInit" type="string" default="false" required="true">
	<cfproperty name="configuratorJS" type="string" default="false" required="true">

	<cfscript>

	function init() output=false {
		super.init(argumentCollection=arguments);
		variables.instance.objectID="";
		variables.instance.moduleID="";
		variables.instance.name="";
		variables.instance.location="global";
		variables.instance.displayMethod="";
		variables.instance.displayObjectFile="";
		variables.instance.docache="false";
		variables.instance.configuratorInit="";
		variables.instance.configuratorJS="";
		return this;
	}

	function setConfigBean(configBean) output=false {
		variables.configBean=arguments.configBean;
		return this;
	}

	function getObjectID() output=false {
		if ( !len(variables.instance.objectID) ) {
			variables.instance.objectID = createUUID();
		}
		return variables.instance.objectID;
	}

	function setObjectID(String objectID) output=false {
		variables.instance.objectID = trim(arguments.objectID);
		return this;
	}

	function getModuleID() output=false {
		return variables.instance.moduleID;
	}

	function setModuleID(String moduleID) output=false {
		variables.instance.moduleID = trim(arguments.moduleID);
		return this;
	}

	function getName() output=false {
		return variables.instance.name;
	}

	function setName(String name) output=false {
		variables.instance.name = trim(arguments.name);
		return this;
	}

	function getDisplayObjectFile() output=false {
		return variables.instance.displayObjectFile;
	}

	function setDisplayObjectFile(String displayObjectFile) output=false {
		variables.instance.displayObjectFile = trim(arguments.displayObjectFile);
		return this;
	}

	function getDisplayMethod() output=false {
		return variables.instance.displayMethod;
	}

	function setDisplayMethod(String displayMethod) output=false {
		variables.instance.displayMethod = trim(arguments.displayMethod);
		return this;
	}

	function getLocation() output=false {
		return variables.instance.location;
	}

	function setLocation(String location) output=false {
		if ( len(arguments.location) ) {
			variables.instance.location = trim(arguments.location);
		}
		return this;
	}

	function getDoCache() output=false {
		return variables.instance.docache;
	}

	function setDoCache(String docache) output=false {
		if ( isBoolean(arguments.docache) ) {
			variables.instance.docache = arguments.docache;
		}
		return this;
	}

	function getConfiguratorInit() output=false {
		return variables.instance.configuratorInit;
	}

	function setConfiguratorInit(String configuratorInit) output=false {
		variables.instance.configuratorInit = trim(arguments.configuratorInit);
		return this;
	}

	function getconfiguratorJS() output=false {
		return variables.instance.configuratorJS;
	}

	function setconfiguratorJS(String configuratorJS) output=false {
		variables.instance.configuratorJS = trim(arguments.configuratorJS);
		return this;
	}

	function load() output=false {
		set(getQuery());
		return this;
	}
	</cfscript>


	<cffunction name="loadByName"  output="false">
		<cfset var rs=""/>
		<cfquery name="rs" datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
			select objectID,moduleID,name,location,displayobjectfile,displaymethod, docache, configuratorInit, configuratorJS
			from tplugindisplayobjects
			where moduleID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getModuleID()#">
			and name=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getName()#">
		</cfquery>

		<cfset set(rs) />
		<cfreturn this>
	</cffunction>

	<cffunction name="getQuery"  output="false">
		<cfset var rs=""/>
		<cfquery name="rs" datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
			select objectID,moduleID,name,location,displayobjectfile,displaymethod, docache, configuratorInit, configuratorJS
			from tplugindisplayobjects
			where objectID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getObjectID()#">
		</cfquery>

		<cfreturn rs/>
	</cffunction>

	<cffunction name="delete">
		<cfquery datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
			delete from tplugindisplayobjects
			where objectID=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#getObjectID()#">
		</cfquery>
	</cffunction>

	<cffunction name="save"  output="false">
		<cfset var rs=""/>
		<cfset var rsLocation=""/>
		<cfset var pluginXML=""/>

		<cfif not len(getLocation())>
			<cfquery name="rsLocation" datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
				select location from tplugindisplayobjects
				where moduleID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getModuleID()#">
			</cfquery>

			<cfif len(rsLocation.location)>
				<cfset setLocation(rsLocation.location)>
			<cfelse>
				<cfset pluginXML=getBean('pluginManager').getPluginXML(getModuleID())/>
				<cfif structKeyExists(pluginXML.plugin.displayobjects.xmlAttributes,"location")>
					<cfset setLocation(pluginXML.plugin.displayobjects.xmlAttributes.location) />
				<cfelse>
					<cfset setLocation("global") />
				</cfif>
			</cfif>
		</cfif>

		<cfif getQuery().recordcount>

			<cfquery datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
			update tplugindisplayobjects set
				moduleID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getModuleID()#">,
				name=<cfqueryparam cfsqltype="cf_sql_varchar" value="#left(getName(),50)#">,
				location=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getLocation()#">,
				displayObjectFile=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getDisplayObjectFile()#">,
				displayMethod=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getDisplayMethod()#">,
				docache=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getDoCache()#">,
				configuratorInit=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getConfiguratorInit()#">,
				configuratorJS=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getconfiguratorJS()#">
			where objectID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getObjectID()#">
			</cfquery>

		<cfelse>

			<cfquery datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
				insert into tplugindisplayobjects (objectID,moduleID,name,location,displayobjectfile,displaymethod,docache,configuratorInit,configuratorJS) values (
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#getObjectID()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#getModuleID()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#left(getName(),50)#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#getLocation()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#getDisplayObjectFile()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#getDisplayMethod()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#getDoCache()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#getConfiguratorInit()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#getconfiguratorJS()#">
				)
			</cfquery>

		</cfif>
		<cfreturn this>
	</cffunction>

</cfcomponent>
