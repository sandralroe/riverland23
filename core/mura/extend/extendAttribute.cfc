<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false" hint="This provides extended attribute functionality">

	<cfset variables.instance.attributeID=0/>
	<cfset variables.instance.ExtendSetID=""/>
	<cfset variables.instance.siteID=""/>
	<cfset variables.instance.name=""/>
	<cfset variables.instance.hint=""/>
	<cfset variables.instance.type="TextBox"/>
	<cfset variables.instance.orderno=1/>
	<cfset variables.instance.isActive=1/>
	<cfset variables.instance.adminonly=0/>
	<cfset variables.instance.required="false"/>
	<cfset variables.instance.validation=""/>
	<cfset variables.instance.regex=""/>
	<cfset variables.instance.message=""/>
	<cfset variables.instance.label=""/>
	<cfset variables.instance.defaultValue=""/>
	<cfset variables.instance.optionList=""/>
	<cfset variables.instance.optionLabelList=""/>
	<cfset variables.instance.isNew=1/>
	<cfset variables.instance.errors=structnew() />

	<cffunction name="init" output="false">
		<cfargument name="configBean">
		<cfargument name="contentRenderer">

		<cfset variables.configBean=arguments.configBean />
		<cfset variables.contentRenderer=arguments.contentRenderer />
		<cfset variables.classExtensionManager=variables.configBean.getClassExtensionManager()>
		<cfreturn this />
	</cffunction>

	<cffunction name="set" output="false">
			<cfargument name="property" required="true">
			<cfargument name="propertyValue">

			<cfif not isDefined('arguments.data')>
				<cfif isSimpleValue(arguments.property)>
					<cfreturn setValue(argumentCollection=arguments)>
				</cfif>

				<cfset arguments.data=arguments.property>
			</cfif>

			<cfset var prop=""/>
			<cfset var tempFunc="">

			<cfif isquery(arguments.data)>

				<cfset setAttributeID(arguments.data.attributeID) />
				<cfset setSiteID(arguments.data.siteID) />
				<cfset setExtendSetID(arguments.data.ExtendSetID) />
				<cfset setName(arguments.data.name) />
				<cfset setHint(arguments.data.name) />
				<cfset setType(arguments.data.Type) />
				<cfset setOrderNo(arguments.data.orderno) />
				<cfset setIsActive(arguments.data.isActive) />
				<cfset setRequired(arguments.data.required) />
				<cfset setvalidation(arguments.data.validation) />
				<cfset setRegex(arguments.data.regex) />
				<cfset setMessage(arguments.data.Message) />
				<cfset setLabel(arguments.data.label) />
				<cfset setDefaultValue(arguments.data.DefaultValue) />
				<cfset setOptionList(arguments.data.optionList) />
				<cfset setOptionLabelList(arguments.data.optionLabelList) />

			<cfelseif isStruct(arguments.data)>
			<!--- <cfdump var="#arguments.data#"><cfabort> --->
				<cfloop collection="#arguments.data#" item="prop">
					<cfif isdefined("variables.instance.#prop#")>
						<cfset tempFunc=this["set#prop#"]>
						<cfset tempFunc(arguments.data['#prop#'])>
					</cfif>
				</cfloop>

			<!--- 	<cfif getType eq "radio" or getType() eq "select">
					<cfset setOptions(arguments.data)/>
				</cfif> --->

			</cfif>

			<cfset validate() />
			<cfreturn this>
	</cffunction>

	<cffunction name="validate" output="false">
		<cfset variables.instance.errors=structnew() />
		<cfreturn this>
	</cffunction>

	<cffunction name="getErrors" returnType="struct" output="false">
		<cfreturn variables.instance.errors />
	</cffunction>

	<cffunction name="getAttributeID" output="false">
		<cfreturn variables.instance.attributeID />
	</cffunction>

	<cffunction name="setAttributeID" output="false">
		<cfargument name="AttributeID" type="numeric" />
		<cfset variables.instance.AttributeID =arguments.AttributeID />
		<cfreturn this>
	</cffunction>

	<cffunction name="getSiteID" output="false">
		<cfreturn variables.instance.siteID />
	</cffunction>

	<cffunction name="setSiteID" output="false">
		<cfargument name="siteID" type="String" />
		<cfset variables.instance.siteID = trim(arguments.siteID) />
		<cfreturn this>
	</cffunction>

	<cffunction name="getExtendSetID" output="false">
		<cfreturn variables.instance.ExtendSetID />
	</cffunction>

	<cffunction name="setExtendSetID" output="false">
		<cfargument name="ExtendSetID" type="String" />
		<cfset variables.instance.ExtendSetID = trim(arguments.ExtendSetID) />
		<cfreturn this>
	</cffunction>

	<cffunction name="getName" output="false">
		<cfreturn variables.instance.name />
	</cffunction>

	<cffunction name="setName" output="false">
		<cfargument name="name" type="String" />
		<cfset variables.instance.name = trim(arguments.name) />
		<cfreturn this>
	</cffunction>

	<cffunction name="getHint" output="false">
		<cfreturn variables.instance.Hint />
	</cffunction>

	<cffunction name="setHint" output="false">
		<cfargument name="Hint" type="String" />
		<cfset variables.instance.Hint = trim(arguments.Hint) />
		<cfreturn this>
	</cffunction>

	<cffunction name="getType" output="false">
		<cfreturn variables.instance.Type />
	</cffunction>

	<cffunction name="setType" output="false">
		<cfargument name="Type" type="String" />
		<cfset variables.instance.Type = trim(arguments.Type) />
		<cfif variables.instance.Type eq "text">
			<cfset variables.instance.Type="TextBox">
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="getOrderNo" output="false">
		<cfreturn variables.instance.OrderNo />
	</cffunction>

	<cffunction name="setOrderNo" output="false">
		<cfargument name="OrderNo" />
		<cfif isNumeric(arguments.OrderNo)>
		<cfset variables.instance.OrderNo = arguments.OrderNo />
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="getAdminOnly" output="false">
		<cfreturn variables.instance.adminonly />
	</cffunction>

	<cffunction name="setAdminOnly" output="false">
		<cfargument name="adminonly" />
		<cfif isNumeric(arguments.adminonly)>
		<cfset variables.instance.adminonly = arguments.adminonly />
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="getIsActive" output="false">
		<cfreturn variables.instance.IsActive />
	</cffunction>

	<cffunction name="setIsActive" output="false">
		<cfargument name="IsActive" />
		<cfif isBoolean(arguments.IsActive)>
			<cfif arguments.IsActive>
				<cfset variables.instance.IsActive = 1 />
			<cfelse>
				<cfset variables.instance.IsActive = 0 />
			</cfif>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="getRequired" output="false">
		<cfreturn variables.instance.Required />
	</cffunction>

	<cffunction name="setRequired" output="false">
		<cfargument name="Required" type="String" />
		<cfset variables.instance.Required = trim(arguments.Required) />
		<cfreturn this>
	</cffunction>

	<cffunction name="getValidation" output="false">
		<cfreturn variables.instance.validation />
	</cffunction>

	<cffunction name="setValidation" output="false">
		<cfargument name="validation" type="String" />
		<cfset variables.instance.validation = trim(arguments.validation) />
		<cfreturn this>
	</cffunction>

	<cffunction name="getRegex" output="false">
		<cfreturn variables.instance.Regex />
	</cffunction>

	<cffunction name="setRegex" output="false">
		<cfargument name="Regex" type="String" />
		<cfset variables.instance.Regex = trim(arguments.Regex) />
		<cfreturn this>
	</cffunction>

	<cffunction name="getMessage" output="false">

		<cfreturn variables.instance.Message />

	</cffunction>

	<cffunction name="setMessage" output="false">
		<cfargument name="Message" type="String" />
		<cfset variables.instance.Message = trim(arguments.Message) />
		<cfreturn this>
	</cffunction>

	<cffunction name="getLabel" output="false">
		<cfif len(variables.instance.Label)>
		<cfreturn variables.instance.Label />
		<cfelse>
		<cfreturn variables.instance.name />
		</cfif>
	</cffunction>

	<cffunction name="setLabel" output="false">
		<cfargument name="Label" type="String" />
		<cfset variables.instance.Label = trim(arguments.Label) />
		<cfreturn this>
	</cffunction>

	<cffunction name="getDefaultValue" output="false">
		<cfreturn variables.instance.DefaultValue />
	</cffunction>

	<cffunction name="setDefaultValue" output="false">
		<cfargument name="DefaultValue" type="String" />
		<cfset variables.instance.DefaultValue = trim(arguments.DefaultValue) />
	</cffunction>

	<cffunction name="getOptionList" output="false">
		<cfreturn variables.instance.optionList />
	</cffunction>

	<cffunction name="setOptionList" output="false">
		<cfargument name="OptionList" type="String" />
		<cfset variables.instance.OptionList = trim(arguments.OptionList) />
		<cfreturn this>
	</cffunction>

	<cffunction name="getOptionLabelList" output="false">
		<cfreturn variables.instance.OptionLabelList />
	</cffunction>

	<cffunction name="setOptionLabelList" output="false">
		<cfargument name="OptionLabelList" type="String" />
		<cfset variables.instance.OptionLabelList = trim(arguments.OptionLabelList) />
		<cfreturn this>
	</cffunction>

	<cffunction name="getIsNew" output="false">
		<cfreturn variables.instance.isNew>
	</cffunction>

	<cffunction name="setIsNew" output="false">
		<cfargument name="isNew">
		<cfset variables.instance.isNew=arguments.isNew>
		<cfreturn this>
	</cffunction>

	<cffunction name="exists" output="false">
		<cfreturn not variables.instance.isNew>
	</cffunction>

	<cffunction name="load"  output="false">
	<cfset var rs=""/>
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
		select * from tclassextendattributes where
		<cfif getAttributeID()>
		attributeID=<cfqueryparam cfsqltype="cf_sql_numeric" value="#getAttributeID()#">
		<cfelse>
		extendSetID=<cfqueryparam cfsqltype="cf_sql_char" maxlength="35" value="#getExtendSetID()#">
		and name=<cfqueryparam cfsqltype="cf_sql_varchar" maxlength="50" value="#getName()#">
		</cfif>
		</cfquery>

		<cfif rs.recordcount>
			<cfset set(rs) />
			<cfset setIsNew(0)>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="save"  output="false">
	<cfset var rs=""/>


		<cfif getAttributeID()>

			<cfquery>
			update tclassextendattributes set
			ExtendSetID=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getExtendSetID() neq '',de('no'),de('yes'))#" value="#getExtendSetID()#">,
			siteID=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getSiteID() neq '',de('no'),de('yes'))#" value="#getSiteID()#">,
			name=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getName() neq '',de('no'),de('yes'))#" value="#getName()#">,
			hint=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getHint() neq '',de('no'),de('yes'))#" value="#getHint()#">,
			type=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getType() neq '',de('no'),de('yes'))#" value="#getType()#">,
			isActive=#getIsActive()#,
			orderno=#getOrderno()#,
			adminonly=#getAdminOnly()#,
			required=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getRequired() neq '',de('no'),de('yes'))#" value="#getRequired()#">,
			validation=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getvalidation() neq '',de('no'),de('yes'))#" value="#getvalidation()#">,
			regex=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getRegex() neq '',de('no'),de('yes'))#" value="#getRegex()#">,
			message=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getMessage() neq '',de('no'),de('yes'))#" value="#getMessage()#">,
			label=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getLabel() neq '',de('no'),de('yes'))#" value="#getLabel()#">,
			defaultValue=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getDefaultValue() neq '',de('no'),de('yes'))#" value="#Left(getDefaultValue(), 100)#">,
			optionList=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getOptionList() neq '',de('no'),de('yes'))#" value="#getOptionList()#">,
			optionLabelList=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getOptionLabelList() neq '',de('no'),de('yes'))#" value="#getOptionLabelList()#">
			where attributeID=<cfqueryparam cfsqltype="cf_sql_numeric"  value="#getAttributeID()#">
			</cfquery>

		<cfelse>

			<cflock name="addingAttribute#application.instanceID#" timeout="100">

				<cfquery>
				Insert into tclassextendattributes (ExtendSetID,siteID,name,hint,type,isActive,orderno,adminOnly,required,validation,regex,message,label,defaultValue,optionList,optionLabelList)
				values(
				<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getExtendSetID() neq '',de('no'),de('yes'))#" value="#getExtendSetID()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getSiteID() neq '',de('no'),de('yes'))#" value="#getSiteID()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getName() neq '',de('no'),de('yes'))#" value="#getName()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getHint() neq '',de('no'),de('yes'))#" value="#getHint()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getType() neq '',de('no'),de('yes'))#" value="#getType()#">,
				#getIsActive()#,
				#getOrderno()#,
				#getAdminOnly()#,
				<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getRequired() neq '',de('no'),de('yes'))#" value="#getRequired()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getvalidation() neq '',de('no'),de('yes'))#" value="#getvalidation()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getRegex() neq '',de('no'),de('yes'))#" value="#getRegex()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getMessage() neq '',de('no'),de('yes'))#" value="#getMessage()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getLabel() neq '',de('no'),de('yes'))#" value="#getLabel()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getDefaultValue() neq '',de('no'),de('yes'))#" value="#Left(getDefaultValue(), 100)#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getOptionList() neq '',de('no'),de('yes'))#" value="#getOptionList()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(getOptionLabelList() neq '',de('no'),de('yes'))#" value="#getOptionLabelList()#">
				)
				</cfquery>

				<cfquery name="rs"  datasource="#variables.configBean.getReadOnlyDatasource()#" username="#variables.configBean.getReadOnlyDbUsername()#" password="#variables.configBean.getReadOnlyDbPassword()#">
				select max(attributeID) as newID  from tclassextendattributes
				</cfquery>

				<cfset setAttributeID(rs.newID)/>

			</cflock>
		</cfif>

		<cfset variables.classExtensionManager.purgeDefinitionsQuery()>

		<cfreturn this>
		<!--- <cfset saveOptions() /> --->
	</cffunction>

	<cffunction name="delete">
	<cfset var fileManager=getBean("fileManager") />
	<cfset var rs =""/>

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
		select attributeValue,baseID from tclassextenddata
		inner join tclassextendattributes on (tclassextenddata.attributeID=tclassextendattributes.attributeID)
		where tclassextenddata.attributeID=<cfqueryparam cfsqltype="cf_sql_numeric"  value="#getAttributeID()#">
		and attributeValue is not null
		and tclassextendattributes.type='File'
		</cfquery>

		
		<cfset fileManager.deleteIfNotUsed(valueList(rs.attributeValue),rs.baseID,getSiteID()) />

		<cfquery>
		delete from tclassextenddata
		where attributeID=<cfqueryparam cfsqltype="cf_sql_numeric"  value="#getAttributeID()#">
		</cfquery>

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
		select attributeValue,baseID from tclassextenddatauseractivity
		inner join tclassextendattributes on (tclassextenddatauseractivity.attributeID=tclassextendattributes.attributeID)
		where tclassextenddatauseractivity.attributeID=<cfqueryparam cfsqltype="cf_sql_numeric"  value="#getAttributeID()#">
		and attributeValue is not null
		and tclassextendattributes.type='File'
		</cfquery>

		<cfset fileManager.deleteIfNotUsed(valueList(rs.attributeValue),rs.baseID,getSiteID()) />

		<cfquery>
		delete from tclassextenddatauseractivity
		where attributeID=<cfqueryparam cfsqltype="cf_sql_numeric"  value="#getAttributeID()#">
		</cfquery>

		<cfquery>
		delete from tclassextendattributes
		where attributeID=<cfqueryparam cfsqltype="cf_sql_numeric"  value="#getAttributeID()#">
		</cfquery>

		<cfset variables.classExtensionManager.purgeDefinitionsQuery()>
	</cffunction>

	<cffunction name="renderAttribute" output="false">
		<cfargument name="theValue" required="true" default="useMuraDefault"/>
		<cfargument name="bean" default=""/>
		<cfargument name="compactDisplay" default="false">
		<cfargument name="size" default="medium">
		<cfargument name="readonly" default="false">
		<cfset var renderValue= arguments.theValue />
		<cfset var optionValue= "" />
		<cfset var str=""/>
		<!---<cfset var key="ext#replace(getAttributeID(),'-','','ALL')#"/>--->
		<cfset var key=getName() />
		<cfset var o=0/>
		<cfset var optionlist=""/>
		<cfset var optionLabellist=""/>
		<cfset var renderInstanceValue=renderValue>
		<cfif renderValue eq "useMuraDefault">
			<cfset renderValue=variables.contentRenderer.setDynamicContent(getDefaultValue()) />
		</cfif>

		<cfif arguments.readonly>
			<cfreturn renderValue />
		</cfif>

		<cfswitch expression="#getType()#">
			<cfcase value="Hidden">
				<cfsavecontent variable="str"><cfoutput><input type="hidden" name="#key#" id="#key#" data-label="#XMLFormat(getlabel())#" value="#HTMLEditFormat(renderValue)#" /></cfoutput></cfsavecontent>
			</cfcase>
			<cfcase value="TextBox,Text">
				<cfif getValidation() neq 'datetime'>
					<cfif getValidation() eq "date">
						<cfset var sessionData=getSession()>
						<cfset renderValue=lsDateFormat(renderValue,sessionData.dateKeyFormat) />
					</cfif>
					<cfsavecontent variable="str">
						<cfoutput>
							<cfif getValidation() eq 'color'>

								<div class="input-group mura-colorpicker">
									<span class="input-group-addon"><i class="mura-colorpicker-swatch" style="background-color:#HTMLEditFormat(renderValue)#"></i></span>
									<input type="text" id="#key#" name="#key#" placeholder="Select Color" autocomplete="off"  value="#HTMLEditFormat(renderValue)#" data-label="#XMLFormat(getlabel())#" data-required="#getRequired()#"<cfif len(getMessage())> data-message="#XMLFormat(getMessage())#"</cfif>>
								</div>

							<cfelse>

								<input type="text" name="#key#" class="text<cfif getValidation() eq 'date'> datepicker</cfif>" id="#key#" data-label="#XMLFormat(getlabel())#" value="#HTMLEditFormat(renderValue)#" data-required="#getRequired()#"<cfif len(getvalidation())> data-validate="#getValidation()#"</cfif><cfif getvalidation() eq "Regex"> data-regex="#getRegex()#"</cfif><cfif len(getMessage())> data-message="#XMLFormat(getMessage())#"</cfif> />

							</cfif>	

							</cfoutput>
					</cfsavecontent>
				<cfelse>
					<cfsavecontent variable="str"><cfoutput><cf_datetimeselector name="#key#" datetime="#renderValue#" id="#key#" label="#getlabel()#" required="#getRequired()#" validation="#getValidation()#" regex="#getRegex()#" message="#getMessage()#"></cfoutput></cfsavecontent>
				</cfif>
			</cfcase>
			<cfcase value="TextArea,HTMLEditor,MarkdownEditor">
				<cfsavecontent variable="str"><cfoutput><textarea name="#key#" id="#key#" data-label="#XMLFormat(getlabel())#" data-height="150px" data-required="#getRequired()#"<cfif len(getMessage())> data-message="#XMLFormat(getMessage())#"</cfif><cfif getType() eq "HTMLEditor"> class="htmlEditor"<cfelseif getType() eq "MarkdownEditor"> class="markdownEditor markdown-lazy-init"</cfif><cfif len(getvalidation())> data-validate="#getValidation()#"</cfif><cfif getvalidation() eq "Regex"> data-regex="#getRegex()#"</cfif>>#HTMLEditFormat(renderValue)#</textarea></cfoutput></cfsavecontent>
			</cfcase>
			<cfcase value="SelectBox,MultiSelectBox">
				<cfset optionlist=variables.contentRenderer.setDynamicContent(getOptionList())/>
				<cfset optionLabellist=variables.contentRenderer.setDynamicContent(getOptionLabelList())/>
				<cfsavecontent variable="str"><cfoutput><cfif getType() EQ "MultiSelectBox"><input type="hidden" name="#key#" value="" /></cfif><select name="#key#" id="#key#" data-label="#XMLFormat(getlabel())#" data-required="#getRequired()#"<cfif len(getMessage())> data-message="#XMLFormat(getMessage())#"</cfif><cfif getType() eq "MultiSelectBox"> multiple="multiple"</cfif>><cfif listLen(optionlist,'^')><cfloop from="1" to="#listLen(optionlist,'^')#" index="o"><cfset optionValue=listGetAt(optionlist,o,'^') /><option value="#XMLFormat(optionValue)#"<cfif optionValue eq renderValue or listFind(renderValue,optionValue,"^") or listFind(renderValue,optionValue)> selected="selected"</cfif>><cfif len(optionlabellist)>#listGetAt(optionlabellist,o,'^')#<cfelse>#optionValue#</cfif></option></cfloop></cfif></select></cfoutput></cfsavecontent>
			</cfcase>
			<cfcase value="RadioGroup">
				<cfset optionlist=variables.contentRenderer.setDynamicContent(getOptionList())/>
				<cfset optionLabellist=variables.contentRenderer.setDynamicContent(getOptionLabelList())/>
				<cfsavecontent variable="str"><cfoutput><cfif listLen(optionlist,'^')><cfloop from="1" to="#listLen(optionlist,'^')#" index="o"><cfset optionValue=listGetAt(optionlist,o,'^') /><label class="radio inline"><input type="radio" id="#key#" name="#key#" value="#XMLFormat(optionValue)#"<cfif optionValue eq renderValue> checked="checked"</cfif> /> <cfif len(optionlabellist)>#listGetAt(optionlabellist,o,'^')#<cfelse>#optionValue#</cfif></label> </cfloop></cfif></cfoutput></cfsavecontent>
			</cfcase>
			<cfcase value="File">
				<cfif isObject(arguments.bean)>
					<cfsavecontent variable="str"><cfoutput><cf_fileselector name="#key#" property="#key#" id="#key#" label="#getlabel()#" required="#getRequired()#" validation="#getValidation()#" regex="#getRegex()#" message="#getMessage()#" bean="#arguments.bean#" compactDisplay="#arguments.compactDisplay#"  deleteKey="extDelete#getAttributeID()#" size="#arguments.size#" maxUploadFileSize="#application.configBean.getValue('maxuploadfilesize')#" ></cfoutput></cfsavecontent>
				<cfelse>
					<cfsavecontent variable="str"><cfoutput><input type="file" name="#key#" id="#key#" data-label="#XMLFormat(getlabel())#" value="" data-required="#getRequired()#"<cfif len(getvalidation())> data-validate="#getValidation()#"</cfif><cfif getvalidation() eq "Regex"> data-regex="#getRegex()#"</cfif><cfif len(getMessage())> data-message="#XMLFormat(getMessage())#"</cfif>/></cfoutput></cfsavecontent>
				</cfif>
			</cfcase>
		</cfswitch>

		<cfreturn str/>
	</cffunction>

	<cffunction name="getAllValues" ouput="false">
		<cfset var extensionData = duplicate(variables.instance) />
		<cfset structDelete(extensionData,"errors") />

		<cfreturn extensionData />
	</cffunction>

	<cffunction name="getAsXML" ouput="false" returntype="xml">
		<cfargument name="documentXML">
		<cfargument name="includeIDs" type="boolean" default="false" >

		<cfset var extensionData = {} />
		<cfset var item = "" />
		<cfset var i = 0 />

		<cfset var xmlAttributes = XmlElemNew( documentXML, "", "attribute" ) />

		<cfset extensionData = duplicate(variables.instance) />
		<cfset structDelete(extensionData,"errors") />
		<cfif not(arguments.includeIDs)>
			<cfset structDelete(extensionData,"extendsetID") />
		</cfif>

		<cfset structDelete(extensionData,"isNew") />
		<cfset structDelete(extensionData,"isActive") />
		<cfset structDelete(extensionData,"siteid") />
		<!--- Append the personality to the root. --->
		<cfloop collection="#extensionData#" item="item">
			<cfif isSimpleValue(extensionData[item])>
				<cfif arguments.includeIDs or item neq "attributeid">
					<cfset xmlAttributes.XmlAttributes[lcase(item)] = extensionData[item] />
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn xmlAttributes />

	</cffunction>

</cfcomponent>
