<!--- license goes here --->
<cfcomponent extends="mura.bean.bean" output="false" entityName="imageSize" table="timagesizes" hint="Site custom inage size bean">
	<cfproperty name="siteID" type="string" default="" required="true">
	<cfproperty name="sizeID" type="string" default="" required="true">
	<cfproperty name="name" type="string" default="" required="true">
	<cfproperty name="height" type="string" default="AUTO" required="true">
	<cfproperty name="width" type="string" default="AUT0" required="true">
	<cfproperty name="isNew" type="numeric" default="1" required="true">

	<cfscript>

	function init() output=false {
		super.init(argumentCollection=arguments);
		variables.instance.siteID="";
		variables.instance.name="";
		variables.instance.sizeID=createUUID();
		variables.instance.width="AUTO";
		variables.instance.height="AUTO";
		variables.instance.isNew=1;
		variables.primaryKey = 'sizeid';
		variables.entityName = 'imageSize';
		return this;
	}

	function setConfigBean(configBean) output=false {
		variables.configBean=arguments.configBean;
		return this;
	}

	function setName(name) output=false {
		variables.instance.name=getBean('contentUtility').formatFilename(arguments.name);
	}

	function setHeight(height) output=false {
		if ( isNumeric(arguments.height) || arguments.height == "AUTO" ) {
			variables.instance.height=arguments.height;
		}
		return this;
	}

	function setWidth(width) output=false {
		if ( isNumeric(arguments.width) || arguments.width == "AUTO" ) {
			variables.instance.width=arguments.width;
		}
		return this;
	}

	function loadBy(sizeID, name, siteID="#variables.instance.siteID#") output=false {
		if ( isDefined('arguments.name') ) {
			arguments.name=getBean('contentUtility').formatFilename(arguments.name);
		}
		variables.instance.isNew=1;
		var rs=getQuery(argumentCollection=arguments);
		if ( rs.recordcount ) {
			set(rs);
			variables.instance.isNew=0;
		}
		return this;
	}

	function parseName() output=false {
		var param=listFirst(getValue('name'),'-');
		if ( left(param,1) == 'H' ) {
			param=right(param,len(param)-1);
			if ( isNumeric(param) ) {
				setValue('height',param);
			}
		} else if ( left(param,1) == 'W' ) {
			param=right(param,len(param)-1);
			if ( isNumeric(param) ) {
				setValue('width',param);
			}
		}
		param=listLast(getValue('name'),'-');
		if ( left(param,1) == 'H' ) {
			param=right(param,len(param)-1);
			if ( isNumeric(param) ) {
				setValue('height',param);
			}
		} else if ( left(param,1) == 'W' ) {
			param=right(param,len(param)-1);
			if ( isNumeric(param) ) {
				setValue('width',param);
			}
		}
	}
	</cfscript>

	<cffunction name="getQuery" output="false">
		<cfset var rs=""/>
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs',cachedwithin=createTimeSpan(0, 0, 0, 1))#">
			select * from timagesizes
			where
			<cfif structKeyExists(arguments,'sizeid')>
			sizeid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sizeID#">
			<cfelseif structKeyExists(arguments,"name") and structKeyExists(arguments,"siteid")>
			name=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">
			and
			siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#">
			<cfelse>
			sizeid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.sizeID#">
			</cfif>
		</cfquery>

		<cfreturn rs/>
	</cffunction>

	<cffunction name="save"  output="false">
		<cfset var rs=""/>

		<cfif getQuery().recordcount>

			<cfquery>
			update timagesizes set
			siteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.siteID#">,
			name=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.name#">,
			height=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.height#">,
			width=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.width#">
			where sizeid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.sizeID#">
			</cfquery>

		<cfelse>

			<cfquery>
			insert into timagesizes (sizeid,siteid,name,height,width) values(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.sizeID#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.siteID#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.name#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.height#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.width#">
			)
			</cfquery>

		</cfif>

		<cfset variables.instance.isNew=0/>

		<cfreturn this>
	</cffunction>

	<cffunction name="delete"  output="false">
		<cfquery>
			delete from timagesizes
			where sizeid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.instance.sizeID#">
		</cfquery>

		<cfset variables.instance.isNew=1/>

		<cfreturn this>
	</cffunction>

</cfcomponent>
