<!--- license goes here --->
<cfcomponent output="false" extends="mura.baseobject" hint="This provides a utility to property bind an query attribute">

	<cfset variables.relationship="" />
	<cfset variables.field="" />
	<cfset variables.dataType="" />
	<cfset variables.condition="" />
	<cfset variables.criteria="" />
	<cfset variables.orderBy="" />
	<cfset variables.isValid=true />
	<cfset variables.grouprelationships="(,and (,or (,),and not (,or not (,openGrouping,orOpenGrouping,andOpenGrouping,closeGrouping">

	<cffunction name="init">
		<cfargument name="relationship" default="">
		<cfargument name="field" default="">
		<cfargument name="dataType" default="">
		<cfargument name="condition" default="Equals">
		<cfargument name="criteria" default="">

		<cfset setIsValid(true) />
		<cfif isDefined('arguments.column')>
			<cfset setField(arguments.column) />
		<cfelse>
			<cfset setField(arguments.Field) />
		</cfif>
		<cfset setRelationship(arguments.relationship) />
		<cfset setDataType(arguments.dataType) />
		<cfset setCondition(arguments.condition) />
		<cfset setCriteria(arguments.criteria,arguments.condition) />

		<cfset validate()>
		<cfreturn this>
	</cffunction>

	<cffunction name="setRelationship">
		<cfargument name="relationship">
		<cfif listFindNoCase("or,and," & variables.grouprelationships,arguments.relationship)>
			<cfset variables.relationship=arguments.relationship />
		</cfif>
	</cffunction>

	<cffunction name="getRelationship">
		<cfreturn variables.relationship />
	</cffunction>

	<cffunction name="setField">
		<cfargument name="field">

		<cfset arguments.field=rereplacenocase(arguments.field, '[^\w\.$]+', '', 'all')>

		<cfif arguments.field eq '' or arguments.field eq 'Select Field'>
			<cfset variables.field=""/>
			<cfset setIsValid(false) />
		<cfelse>
			<cfset variables.field=arguments.field />
		</cfif>
	</cffunction>

	<cffunction name="setColumn">
		<cfargument name="column">

		<cfset setField(arguments.column) />
	</cffunction>

	<cffunction name="getField">
		<cfreturn variables.field />
	</cffunction>

	<cffunction name="getFieldStatement">
		<cfif variables.condition eq 'like' and application.configBean.getDbCaseSensitive()>
			<cfset var result="upper(" & REReplace(variables.field,"[^0-9A-Za-z\._,\- ]\*","","all") & ")"/>
		<cfelse>
			<cfset var result=REReplace(variables.field,"[^0-9A-Za-z\._,\- ]\*","","all") />
		</cfif>
		<cfif find('$',result)>
			<cfset var column=listFirst(result,'$')>
			<cfset column=left(column,len(column)-1)>
			<cfswitch expression="# application.configBean.getDbType()#">
				<cfcase value="mssql,oracle">
					<cfreturn "json_value(#column#,'$#listRest(result,"$")#')">
				</cfcase>
				<cfcase value="mysql">
					<!--- Not using  ->> for mariadb support --->
					<cfreturn "json_unquote(json_extract(#column#,'$#listRest(result,"$")#'))">
				</cfcase>
				<cfcase value="postgresql">
					<cfreturn "#column#::json->>'#listRest(result,"$")#'">
				</cfcase>
			</cfswitch>
			
		<cfelse>
			<cfreturn result />
		</cfif>
	</cffunction>

	<cffunction name="getColumn">
		<cfreturn getField() />
	</cffunction>

	<cffunction name="getColumnStatment">
		<cfreturn getFieldStatement() />
	</cffunction>

	<cffunction name="setCondition">
		<cfargument name="condition">

		<cfswitch expression="#arguments.condition#">
			<cfcase value="Equals,EQ,IS,=">
				<cfset variables.condition="=" />
			</cfcase>
			<cfcase value="GT,>">
				<cfset variables.condition=">" />
			</cfcase>
			<cfcase value="IN">
				<cfset variables.condition="in" />
			</cfcase>
			<cfcase value="NOTIN,NOT IN">
				<cfset variables.condition="not in" />
			</cfcase>
			<cfcase value="NEQ,!=">
				<cfset variables.condition="!=" />
			</cfcase>
			<cfcase value="GTE,>=">
				<cfset variables.condition=">=" />
			</cfcase>
			<cfcase value="LT,<">
				<cfset variables.condition="<" />
			</cfcase>
			<cfcase value="LTE,<=">
				<cfset variables.condition="<=" />
			</cfcase>
			<cfcase value="Begins,BeginsWith,Contains,ContainsValue,Like,Ends,EndsWith">
				<cfif listFindNoCase("varchar,longvarchar",getDataType()) >
					<cfset variables.condition="like" />
				<cfelse>
					<cfset variables.condition="=" />
				</cfif>
			</cfcase>
		</cfswitch>

	</cffunction>

	<cffunction name="getCondition">
		<cfif variables.criteria eq "null">
			<cfif variables.condition eq "=">
				<cfreturn "is">
			<cfelseif variables.condition eq "!=">
				<cfreturn "is not">
			</cfif>
		<cfelse>
			<cfreturn variables.condition />
		</cfif>
	</cffunction>

	<cffunction name="getAllValues" output="false">
		<cfreturn variables>
	</cffunction>

	<cffunction name="setCriteria">
		<cfargument name="criteria">
		<cfargument name="condition">
		<cfset var tmp="" />

		<cftry>
			<cfset tmp=getContentRenderer().setDynamicContent(arguments.criteria) />
		<cfcatch><cfset tmp=arguments.criteria /></cfcatch>
		</cftry>

		<cfif not len(getDataType()) and len(tmp) and (LSIsDate(tmp) or IsDate(tmp))>
			<cfset setDataType('datetime') />
		</cfif>

		<cfif tmp eq "null">
			<cfset variables.criteria="null">
		<cfelse>
			<cfswitch expression="#getDataType()#">
			<cfcase value="varchar,longvarchar">
				<cfswitch expression="#arguments.condition#">
					<cfcase value="Begins,BeginsWith" >
						<cfset variables.criteria="#tmp#%" />
					</cfcase>
					<cfcase value="Ends,EndsWith" >
						<cfset variables.criteria="%#tmp#" />
					</cfcase>
					<cfcase value="Contains,ContainsValue,Like" >
						<cfset variables.criteria="%#tmp#%" />
					</cfcase>
					<cfdefaultcase>
						<cfset variables.criteria="#tmp#" />
					</cfdefaultcase>
				</cfswitch>
			</cfcase>
			<cfcase value="bit">
				<cfif isBoolean(tmp)>
					<cfset variables.criteria=tmp />
				<cfelse>
					<cfset variables.criteria="" />
					<cfset setIsValid(false) />
				</cfif>
			</cfcase>
			<cfcase value="date" >
				<cfif lsIsDate(tmp)>
					<cfset tmp=lsParseDateTime(tmp)>
					<cfset variables.criteria=createODBCDate(createDate(year(tmp),month(tmp),day(tmp))) />
				<cfelseif isDate(tmp)>
					<cfset tmp=parseDateTime(tmp)>
					<cfset variables.criteria=createODBCDate(createDate(year(tmp),month(tmp),day(tmp))) />
				<cfelse>
					<cfset variables.criteria="" />
					<cfset setIsValid(false) />
				</cfif>
			</cfcase>
			<cfcase value="timestamp,datetime">
				<cfif lsIsDate(tmp)>
					<cftry>
						<cfset tmp=lsParseDateTime(tmp)>
						<cfcatch><!--- already parsed ---></cfcatch>
					</cftry>
					<cfset variables.criteria=createODBCDateTime(tmp) />
				<cfelseif isDate(tmp)>
					<cftry>
						<cfset tmp=parseDateTime(tmp)>
						<cfcatch><!--- already parsed ---></cfcatch>
					</cftry>
					<cfset variables.criteria=createODBCDateTime(tmp) />
				<cfelse>
					<cfset variables.criteria="" />
					<cfset setIsValid(false) />
				</cfif>
			</cfcase>
			<cfcase value="time" >
				<cfif isDate(tmp)>
					<cfset variables.criteria=createODBCDateTime(tmp) />
				<cfelse>
					<cfset variables.criteria="" />
					<cfset setIsValid(false) />
				</cfif>
			</cfcase>
			<cfcase value="numeric" >
				<cfif isNumeric(tmp)>
					<cfset variables.criteria=tmp />
				<cfelse>
					<cfset variables.criteria="" />
					<cfset setIsValid(false) />
				</cfif>
			</cfcase>
			</cfswitch>
		</cfif>
	</cffunction>

	<cffunction name="getCriteria">
		<cfif variables.condition eq 'like' and application.configBean.getDbCaseSensitive()>
			<cfreturn ucase(variables.criteria) />
		<cfelse>
			<cfreturn variables.criteria />
		</cfif>
	</cffunction>

	<cffunction name="setDataType">
		<cfargument name="dataType">

		<cfif arguments.datatype eq 'datetime'>
			<cfset arguments.datatype="timestamp">
		<cfelseif arguments.datatype eq 'boolean'>
			<cfset arguments.datatype="bit">
		<cfelse>
			<cfset arguments.datatype=rereplacenocase(arguments.datatype, '\W', '', 'all')>
		</cfif>

		<cfset variables.dataType=arguments.dataType />
	</cffunction>

	<cffunction name="getDataType">
		<cfset var fieldArray=listToArray(variables.field,".")>
		<cfif not len(variables.dataType) and arrayLen(fieldArray) gte 2 and fieldArray[2] neq "$">
			<cfset variables.dataType=getBean("dbUtility").columnParamType(column=fieldArray[2],table=fieldArray[1])>
		</cfif>
		<cfreturn variables.dataType />
	</cffunction>

	<cffunction name="setIsValid">
		<cfargument name="IsValid">
		<cfset variables.isValid=arguments.isValid />
	</cffunction>

	<cffunction name="getIsValid">
		<cfreturn variables.isValid />
	</cffunction>

	<cffunction name="isGroupingParam" output="false">
		<cfreturn listFindNoCase(variables.grouprelationships,getRelationship()) >
	</cffunction>

	<cffunction name="validate">
		<cfif not isGroupingParam()
			and (variables.field eq '' or variables.field eq 'Select Field')>
			<cfset variables.field=""/>
			<cfset setIsValid(false) />
		<cfelse>
			<cfset setIsValid(true) />
		</cfif>
	</cffunction>

	<cffunction name="getContentRenderer" output="false">
		<cfset var sessionData=getSession()>
		<cfif structKeyExists(request,"servletEvent")>
			<cfreturn request.servletEvent.getContentRenderer()>
		<cfelseif structKeyExists(request,"event")>
			<cfreturn request.event.getContentRenderer()>
		<cfelseif isdefined('sessionData.siteID') and len(sessionData.siteID)>
			<cfreturn getBean("$").init(sessionData.siteID).getContentRenderer()>
		<cfelse>
			<cfreturn getBean("contentRenderer")>
		</cfif>

	</cffunction>

	<cffunction name="isListParam" output="false">
		<cfreturn listFindNoCase("IN,NOT IN",getCondition())>
	</cffunction>

	<cffunction name="getExtendedIDList" output="false">
		<cfargument name="table">
		<cfargument name="siteid">
		<cfargument name="tableModifier" default="">
		<cfset var maxrows=2100>
		<cfset var rs="">
		<cfset var castfield="attributeValue">

		<cfif application.configBean.getDbType() eq 'Oracle'>
			<cfset maxrows=990>
		</cfif>

		<cfset var isList=isListParam()>

		<cfquery attributeCollection="#application.configBean.getReadOnlyQRYAttrs(name='rs',maxrows=maxrows)#">
				select #arguments.table#.baseID from #arguments.table# #arguments.tableModifier#
				<cfif isNumeric(getField())>
					where #arguments.table#.attributeID=<cfqueryparam cfsqltype="cf_sql_numeric" value="#getField()#">
				<cfelse>
					inner join tclassextendattributes on (#arguments.table#.attributeID = tclassextendattributes.attributeID)
					where tclassextendattributes.siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#">
					and tclassextendattributes.name=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getField()#">
				</cfif>
				and
				<cfif variables.condition neq "like">
					<cfset castfield=application.configBean.getClassExtensionManager().getCastString(getField(),arguments.siteid)>
				</cfif>
				<cfif variables.condition eq "like" and application.configBean.getDbCaseSensitive()>
					upper(#castfield#)
				<cfelse>
					#castfield#
				</cfif>
				#getCondition()#
				<cfif isList>
					(
				</cfif>
				<cfqueryparam cfsqltype="cf_sql_#getDataType()#" value="#getCriteria()#" list="#iif(isList,de('true'),de('false'))#" null="#iif(getCriteria() eq 'null',de('true'),de('false'))#">
				<cfif isList>
					)
				</cfif>
		</cfquery>

		<cfreturn valuelist(rs.baseid)>
	</cffunction>

	<cffunction name="setOrderBy">
		<cfargument name="orderby">
		<cfset variables.orderby=arguments.orderby />
	</cffunction>

	<cffunction name="getOrderBy" output="false">
		<cfreturn variables.orderby />
	</cffunction>

</cfcomponent>
