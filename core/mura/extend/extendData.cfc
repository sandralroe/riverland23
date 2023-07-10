<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false" hint="This provides access to an extended instance's custom data">

	<cfset variables.instance.data="">
	<cfset variables.instance.baseID="">
	<cfset variables.instance.dataTable="tclassextenddata">
	<cfset variables.instance.type="">
	<cfset variables.instance.subType="">
	<cfset variables.instance.siteID="">
	<cfset variables.instance.definitionsQuery="">
	<cfset variables.instance.contentRenderer="">
	<cfset variables.instance.sourceIterator="">
	<cfset variables.instance.idLookUp=structNew()>
	<cfset variables.instance.nameLookUp=structNew()>

	<cffunction name="init" output="false">
		<cfargument name="configBean">
		<cfargument name="baseID"/>
		<cfargument name="dataTable" required="true" default="tclassextenddata"/>
		<cfargument name="type"/>
		<cfargument name="subType"/>
		<cfargument name="siteID"/>
		<cfargument name="sourceIterator" default=""/>

		<cfset variables.configBean=arguments.configBean />
		<cfset setBaseID(arguments.baseID)/>
		<cfset setDataTable(arguments.dataTable)/>
		<cfset setDefinitions(arguments.configBean.getClassExtensionManager().getDefinitionsQuery())>

		<cfif structKeyExists(arguments,"type")>
			<cfset setType(arguments.type)/>
		</cfif>
		<cfif structKeyExists(arguments,"subType")>
			<cfset setSubType(arguments.subType)/>
		</cfif>
		<cfif structKeyExists(arguments,"siteID")>
			<cfset setSiteID(arguments.siteID)/>
		</cfif>

		<cfset setSourceIterator(arguments.sourceIterator)/>

		<cfset loadData()/>

		<cfreturn this />
	</cffunction>

	<cffunction name="getBaseID" output="false">
		<cfreturn variables.instance.BaseID />
	</cffunction>

	<cffunction name="setBaseID" output="false">
		<cfargument name="BaseID" type="String" />
		<cfset variables.instance.BaseID = trim(arguments.BaseID) />
	</cffunction>

	<cffunction name="getDefinitionsQuery" output="false">
		<cfreturn variables.instance.definitions />
	</cffunction>

	<cffunction name="setDefinitions" output="false">
		<cfargument name="definitions" />
		<cfset variables.instance.definitions= arguments.definitions />
	</cffunction>

	<cffunction name="setSourceIterator" output="false">
		<cfargument name="sourceIterator" />
		<cfset variables.instance.sourceIterator= arguments.sourceIterator />
	</cffunction>


	<cffunction name="getDataTable" output="false">
		<cfreturn variables.instance.dataTable />
	</cffunction>

	<cffunction name="setDataTable" output="false">
		<cfargument name="dataTable" type="String" />
		<cfset variables.instance.dataTable = trim(arguments.dataTable) />
	</cffunction>

	<cffunction name="getType" output="false">
		<cfreturn variables.instance.type />
	</cffunction>

	<cffunction name="setType" output="false">
		<cfargument name="type" type="String" />
		<cfset variables.instance.type = trim(arguments.type) />
	</cffunction>

	<cffunction name="getSubType" output="false">
		<cfreturn variables.instance.subType />
	</cffunction>

	<cffunction name="setSubType" output="false">
		<cfargument name="subType" type="String" />
		<cfset variables.instance.subType = trim(arguments.subType) />
	</cffunction>

	<cffunction name="getSiteID" output="false">
		<cfreturn variables.instance.siteID />
	</cffunction>

	<cffunction name="setSiteID" output="false">
		<cfargument name="siteID" type="String" />
		<cfset variables.instance.siteID = trim(arguments.siteID) />
	</cffunction>

	<cffunction name="getAttribute" output="false">
		<cfargument name="key">
		<cfargument name="useMuraDefault" type="boolean" required="true" default="false">
		<cfset var rs="" />
		<cfset var tempDate="">
		<cfset var index=0>
		<cfset var nameKey="name_" & hash(lcase(arguments.key))>
		<cfset var idKey="id_" & arguments.key>

		<cfif structKeyExists(variables.instance.nameLookUp,nameKey)>
			<cfset index=variables.instance.nameLookUp[nameKey]>
		<cfelseif structKeyExists(variables.instance.idLookUp,idKey)>
			<cfset index=variables.instance.idLookUp[idKey]>
		</cfif>

		<cfif index>
			<cfif len(variables.instance.data.baseID[index])>
				<cfif listFindNoCase("date,datetime",variables.instance.data.validation[index])>
					<cfset tempDate=variables.instance.data.attributeValue[index]>
					<cftry>
						<cfreturn parseDateTime(tempDate) />
						<cfcatch><cfreturn variables.instance.data.attributeValue[index] /></cfcatch>
					</cftry>
				<cfelse>
					<cfreturn variables.instance.data.attributeValue[index] />
				</cfif>
			<cfelse>
				<cfreturn getContentRenderer().setDynamicContent(variables.instance.data.defaultValue[index]) />
			</cfif>
		<cfelseif arguments.useMuraDefault>
			<cfreturn "useMuraDefault" />
		<cfelse>
			<cfreturn "" />
		</cfif>

	</cffunction>

	<cffunction name="loadData" output="false">
		<cfset var rsExtendedAttributes=""/>
		<cfset var rsCombine=""/>
		<cfset var rsPreValue=""/>
		<cfset var dataTable=getDataTable() />
		<cfset var rsDefinitions=getDefinitionsQuery()>
		<cfset var tableModifier="">
		<cfset var rsExtended="">
		<cfset var rsPage="">

		<cfif variables.configBean.getDbType() eq "MSSQL">
			<cfset tableModifier="with (nolock)">
		</cfif>

		<cfset var saveEmptyExtendedValues=variables.configBean.getValue(property='saveEmptyExtendedValues',default=true)>

		<cfif isObject(variables.instance.sourceIterator) and (
			variables.instance.sourceIterator.getNextN() lte 2000
			or (
				not variables.instance.sourceIterator.getNextN()
				and variables.instance.sourceIterator.getRecordCount() lte 2000
				)
		)>

			<cfif not isQuery(variables.instance.sourceIterator.getPageQuery("page_extended#variables.instance.sourceIterator.getPageIndex()#"))>
				<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsPage')#">
					select #getDataTable()#.baseid, tclassextendattributes.name, tclassextendattributes.type, tclassextendattributes.validation,
					<cfif variables.configBean.getDBType() eq "oracle">
						to_char(tclassextendattributes.label) as label
					<cfelse>
						tclassextendattributes.label
					</cfif>,
					tclassextendattributes.attributeID,tclassextendattributes.defaultValue,tclassextendattributes.extendSetID,

					#getDataTable()#.attributeValue, #dataTable#.datetimevalue

					from #getDataTable()# #tableModifier#
					inner join tclassextendattributes #tableModifier# On (#getDataTable()#.attributeID=tclassextendattributes.attributeID)
					<cfif variables.instance.sourceIterator.getRecordIdField() eq 'contentid'>
						inner join tcontent #tableModifier# On (#getDataTable()#.baseid=tcontent.contenthistid)
						where
						tcontent.contentid
						in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#variables.instance.sourceIterator.getPageIDList()#">)
						and tcontent.siteid=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#getSiteID()#">
						and tcontent.active=1
					<cfelse>
						where #getDataTable()#.baseID
						in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#variables.instance.sourceIterator.getPageIDList()#">)
					</cfif>
					<cfif not saveEmptyExtendedValues>
						and #getDataTable()#.attributeValue is not null
					</cfif>
				</cfquery>

				<cfset variables.instance.sourceIterator.setPageQuery("page_extended#variables.instance.sourceIterator.getPageIndex()#",rsPage)>
			<cfelse>
				<cfset rsPage=variables.instance.sourceIterator.getPageQuery("page_extended#variables.instance.sourceIterator.getPageIndex()#")>
			</cfif>

			<cfquery name="rsExtended" dbtype="query">
				select * from rsPage
				where baseID='#getBaseID()#'
			</cfquery>
		<cfelse>
			<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsExtended')#">
				select #dataTable#.baseid, tclassextendattributes.name, tclassextendattributes.type, tclassextendattributes.validation,
				<cfif variables.configBean.getDBType() eq "oracle">
					to_char(tclassextendattributes.label) as label
				<cfelse>
					tclassextendattributes.label
				</cfif>,
				tclassextendattributes.attributeID,tclassextendattributes.defaultValue,tclassextendattributes.extendSetID,

				#dataTable#.attributeValue, #dataTable#.datetimevalue

				from #dataTable# #tableModifier#
				inner join tclassextendattributes #tableModifier# On (#dataTable#.attributeID=tclassextendattributes.attributeID)
				where #dataTable#.baseID=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#getBaseID()#">
				<cfif len(getSiteID())>
					and tclassextendattributes.siteid=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#getSiteID()#">
				</cfif>
				<cfif not saveEmptyExtendedValues>
					and #dataTable#.attributeValue is not null
				</cfif>
			</cfquery>
		</cfif>

		<cfif len(getType()) and len(getSubType()) and len(getSiteID())>
			<cfquery name="rsCombine" dbtype="query">
				select baseID, name, type, validation, label, attributeID, defaultValue, extendSetID<cfif variables.configBean.getDBType() neq "oracle">, attributeValue</cfif>
				from rsExtended

				union all

				select '' baseID, attributename as name, type, validation, label, attributeID, defaultValue, extendSetID<cfif variables.configBean.getDBType() neq "oracle">, '' attributeValue</cfif>
				from rsDefinitions
				where siteID=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#getSiteID()#">
				and (
					type=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#getType()#">
					<cfif not listFindNoCase("1,2,User,Group,Address,Site,Component,Form",getType())>
						or type='Base'
					</cfif>
					)
				and (
					<cfif getSubType() neq "Default">
					subtype=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#getSubType()#">

					or
					</cfif>
					subtype='Default'
					)
				<cfif rsExtended.recordcount>
				and attributeID not in (#ListQualify(ValueList(rsExtended.attributeid), "'", ",", "char")#)
				</cfif>

			</cfquery>

			<cfset queryAddColumn(rsCombine,"datetimevalue","cf_sql_Timestamp",arrayNew(1))>
			<cfloop query='rsExtended'>
				<cfloop query='rsCombine'>
					<cfif rsExtended.attributeID eq rsCombine.attributeID>
						<cfset querySetCell(rsCombine, "datetimevalue", rsExtended.datetimevalue, rsCombine.currentrow)>
						<cfbreak>
					</cfif>
				</cfloop>
			</cfloop>

			<!--- Can't union in clob attribute value so they are manually added after the fact --->
			<cfif variables.configBean.getDBType() eq "oracle">
				<cfset queryAddColumn(rsCombine,"attributeValue","cf_sql_varchar",arrayNew(1))>

				<cfloop query='rsExtended'>
					<cfloop query='rsCombine'>
						<cfif rsExtended.attributeID eq rsCombine.attributeID>
							<cfset querySetCell(rsCombine, "attributeValue", rsExtended.attributeValue, rsCombine.currentrow)>
							<cfbreak>
						</cfif>
					</cfloop>
				</cfloop>

			</cfif>

			<cfset rsExtended=rsCombine>

		</cfif>

		<cfloop query='rsExtended'>
			<cfset variables.instance.idLookup['id_' & rsExtended.attributeID]=rsExtended.currentRow>
			<cfset variables.instance.nameLookup["name_" & hash(lcase(rsExtended.name))]=rsExtended.currentRow>
		</cfloop>

		<cfset variables.instance.data=rsExtended />

	</cffunction>

	<cffunction name="setAllValues" output="false">
		<cfargument name="instance">
		<cfset variables.instance=arguments.instance/>
	</cffunction>

	<cffunction name="getAllValues" returntype="struct" output="false">
			<cfreturn variables.instance />
	</cffunction>

	<cffunction name="getAllExtendSetData" returntype="struct" output="false">
		<cfset var extData=structNew() />
		<cfreturn convertDataToStruct(variables.instance.data)/>
		<cfreturn extData/>
	</cffunction>

	<!---
	<cffunction name="getExtendSetDataByAttributeName" returntype="struct" output="false">
		<cfargument name="key">
		<cfset var rsExtendSetDataByAttributeName="" />

		<cfquery name="rsExtendSetDataByAttributeName" dbType="query">
			select baseID, extendSetID, name, defaultValue, attributeValue, validation from variables.instance.data
			where lower(name)=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#lcase(key)#">
			<cfif isNumeric(arguments.key)>
				or attributeID=<cfqueryparam cfsqltype="cf_sql_numeric"  value="#key#">
			</cfif>
		</cfquery>

		<cfreturn convertDataToStruct(rsExtendSetDataByAttributeName)/>

	</cffunction>
	--->

	<cffunction name="convertDataToStruct" output="false">
		<cfargument name="rs">
		<cfset var extData=structNew() />
		<cfif arguments.rs.recordcount>
			<cfset extData.extendSetID=valueList(arguments.rs.extendSetID)>
			<cfset extData.data=structNew()>

			<cfloop query="arguments.rs">
				<cfif len(arguments.rs.baseID)>
					<cfif listFindNoCase("date,datetime",arguments.rs.validation) and (len(arguments.rs.attributeValue) or len(arguments.rs.dateTimeValue))>
						<cftry>
							<cfset extData.data['#arguments.rs.name#']=parseDateTime(arguments.rs.datetimeValue)>
							<cfcatch>
								<cftry>
									<cfset extData.data['#arguments.rs.name#']=parseDateTime(arguments.rs.attributeValue)>
									<cfcatch>
										<cfset extData.data['#arguments.rs.name#']=arguments.rs.attributeValue>
									</cfcatch>
								</cftry>
							</cfcatch>
						</cftry>
					<cfelse>
						<cfset extData.data['#arguments.rs.name#']=arguments.rs.attributeValue>
					</cfif>
				<cfelse>
					<cftry>
						<cfset extData.data['#arguments.rs.name#']=getContentRenderer().setDynamicContent(arguments.rs.defaultValue)>
						<cfcatch><cfset extData.data['#arguments.rs.name#']=''></cfcatch>
					</cftry>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn extData>
	</cffunction>

	<cffunction name="getContentRenderer" output="false">
		<cfif not isObject(variables.instance.contentRenderer)>
			<cfif structKeyExists(request,"servletEvent")>
				<cfset variables.instance.contentRenderer=request.servletEvent.getContentRenderer()>
			<cfelseif structKeyExists(request,"event")>
				<cfset variables.instance.contentRenderer=request.event.getContentRenderer()>
			<cfelseif len(getSiteID())>
				<cfset variables.instance.contentRenderer=getBean("$").init(getSiteID()).getContentRenderer()>
			<cfelse>
				<cfset variables.instance.contentRenderer=getBean("contentRenderer")>
			</cfif>
		</cfif>

		<cfreturn variables.instance.contentRenderer>
	</cffunction>

	<cffunction name="getAttributesByType" output="false">
		<cfargument name="type">
		<cfset var rsImageAttributes="">

		<cfquery name="rsImageAttributes" dbtype="query">
			select * from variables.instance.data where type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.type#">
		</cfquery>
		<cfreturn rsImageAttributes>
	</cffunction>

</cfcomponent>
