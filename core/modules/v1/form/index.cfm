<cfparam name="objectparams._p" default="1" >
<cfparam name="objectParams.followupurl" default="">
<cfset objectParams.render = "server" />
<cfset objectParams.async = "true"/>
<cfset variables.event.setValue('objectparams',objectparams)>
<cfif len(arguments.objectid)>
	<cfif IsValid('uuid', arguments.objectid)>
		<cfset local.formBean = $.getBean('content').loadBy( contentid=arguments.objectid ) />
	<cfelse>
		<cfset local.formBean = $.getBean('content').loadBy( title=arguments.objectid, type='Form') />
	</cfif>
	<cfset $.event('formBean',local.formBean)>
	<cfif local.formBean.getIsOnDisplay()>
		<cfset variables.formOutput=application.pluginManager.renderEvent("onForm#local.formBean.getSubType()#BodyRender",variables.event)>
		<cfset safesubtype=REReplace(local.formBean.getSubType(), "[^a-zA-Z0-9_]", "", "ALL")>
		<cfif not len(variables.formOutput)>
			<cfset variables.formOutput=$.dspObject_include(theFile='extensions/dsp_Form_' & safesubtype & ".cfm",throwError=false)>
		</cfif>
		<cfif not len(variables.formOutput)>
			<cfset filePath=$.siteConfig().lookupContentTypeFilePath('form/index.cfm')>
			<cfif len(filePath)>
				<cfsavecontent variable="variables.formOutput">
					<cfinclude template="#filepath#">
				</cfsavecontent>
				<cfset variables.formOutput=trim(variables.formOutput)>
			</cfif>
		</cfif>
		<cfif not len(variables.formOutput)>
			<cfset filePath=$.siteConfig().lookupContentTypeFilePath(lcase('form_#safesubtype#/index.cfm'))>
			<cfif len(filePath)>
				<cfsavecontent variable="variables.formOutput">
					<cfinclude template="#filepath#">
				</cfsavecontent>
				<cfset variables.formOutput=trim(variables.formOutput)>
			</cfif>
		</cfif>
		<cfif len(variables.formOutput)>
			<cfoutput>#variables.formOutput#</cfoutput>
		<cfelse>
			<cfif isJSON( local.formBean.getBody())>
				<cfset objectparams.objectid=local.formBean.getContentID()>

				<cfset local.formJSON = deserializeJSON( local.formBean.getBody() )>

				<cftry>
					<!---<cfif structKeyExists(local.formJSON.form.formattributes,"muraormentities") and local.formJSON.form.formattributes.muraormentities eq true>--->
					<cfset objectParams.render = "client" />
					<cfset objectParams.async = "true"/>
					<cfparam name="objectParams.view" default="form"/>
					<cfparam name="objectParams.followupurl" default=""/>

					<cfif len($.event('saveform'))>
						<cfset $.event('fields','')>
						<cfset objectParams.followupurl=trim(objectParams.followupurl)>
						<cfset objectParams.errors=$.getBean('dataCollectionBean')
							.set($.event().getAllValues())
							.submit($).getErrors()>

						<cfif not structCount(objectParams.errors)>
							<cfset objectParams.responsemessage=$.renderEvent(eventName="onFormSubmitResponseRender",objectid=local.formBean.getContentID())>
						<cfif not len(objectParams.responsemessage)>
							<cfset objectParams.responsemessage=$.renderEvent(eventName="onSubmitResponseRender",objectid=local.formBean.getContentID())>
						</cfif>

						<cfif len($.event('redirect_url'))>
							<cfset $.event('redirect_url',variables.$.getBean('utility').sanitizeHref($.event('redirect_url')))>
							<cfif request.muraFrontEndRequest>
								<cflocation addtoken="false" url="#$.event('redirect_url')#">
							<cfelse>
								<cfset request.muraJSONRedirectURL=$.event('redirect_url')>
							</cfif>
						<cfelseif len(objectParams.followupurl)>
							<cfif request.muraFrontEndRequest>
								<cflocation addtoken="false" url="#objectParams.followupurl#">
							<cfelse>
								<cfset request.muraJSONRedirectURL=objectParams.followupurl>
							</cfif>
						</cfif>

						<cfif not len(objectParams.responsemessage)>
							<cfif local.formBean.getResponseChart()>
								<cfset objectParams.responsemessage=trim($.dspObject_Include(thefile='datacollection/dsp_poll.cfm'))>
							</cfif>
							<cfset objectParams.responsemessage=objectParams.responsemessage & $.setDynamicContent(local.formBean.getResponseMessage())>
						</cfif>
					</cfif>

					<cfloop collection="#objectParams#" item="local.param">
						<cfif listLast(local.param,'_') eq 'attachment' and not isValid('uuid',objectParams[local.param])>
							<cfset structDelete(objectParams,local.param)>
						</cfif>
					</cfloop>

					<cfelseif len($.event('validateform'))>
						<cfparam name="objectparams.fields" default="">
						<cfset objectParams.errors=$.getBean('dataCollectionBean')
						.set($.event().getAllValues())
						.validate($,$.event('fields')).getErrors()>
					<cfelseif request.muraApiRequest>
						<cfscript>
							objectParams.render = "client";
							objectParams.async = "true";

							if(not arguments.RenderingAsRegion){
								if(isdefined('local.formJSON.form.fields')){
									for(b in local.formJSON.form.fields){
										field=local.formJSON.form.fields[b];
										if(structKeyExists(field,'value')){
											local.formJSON.form.fields[b].value=$.setDynamicContent(field.value);
										}

										if(isDefined('field.fieldtype.isdata') && field.fieldtype.isdata==1){
											local.formJSON.datasets['#field.datasetid#']=$.getBean('formBuilderManager').processDataset( $, local.formJSON.datasets['#field.datasetid#'] );
										}
									}
								}

								request.cffpJS=true;
								
								objectParams.def=serializeJSON(local.formJSON);

								objectParams.ishuman=$.dspObject_Include(thefile='form/dsp_form_protect.cfm');
							}

							if(!this.layoutmanager && local.formBean.getDisplayTitle() > 0){
								objectParams.label=local.formBean.get('title');
							}

							objectParams.filename=local.formBean.get('filename');
							objectParams.name=local.formBean.get('title');
							objectParams.responsemessage=local.formBean.get('responseMessage');
							objectParams.responsechart=local.formBean.get('responsechart');
						</cfscript>
					</cfif>
					<cfcatch>
						<cfdump var="#cfcatch#">
						<cfabort>
					</cfcatch>
				</cftry>
			<cfelse>
				<cfset objectParams.render = "server" />
				<cfoutput>#$.dspObject_include(thefile='datacollection/index.cfm',objectid=arguments.objectid,params=objectparams)#</cfoutput>
			</cfif>
		</cfif>
	<cfelse>
		<!-- Form not on display -->
	</cfif>
<cfelse>
	<cfset objectParams.render = "server" />
	<cfset objectParams.async = "true"/>
</cfif>
