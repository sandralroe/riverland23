<!--- license goes here --->
<cfif variables.$.siteConfig('dataCollection')>
	<cfsilent>
    <!---<cfset request.muraAsyncEditableObject=true>--->

		<cfif isValid("UUID",arguments.objectID)>
			<cfset bean = variables.$.getBean("content").loadBy(contentID=arguments.objectID,siteID=arguments.siteID)>
		<cfelse>
			<cfset bean = variables.$.getBean("content").loadBy(title=arguments.objectID,siteID=arguments.siteID,type='Form')>
		</cfif>

		<cfset variables.event.setValue("formBean",bean)>
	</cfsilent>

	<cfoutput>
    <cfif this.asyncObjects and (isJson(bean.getBody()) or this.layoutmanager)>
        <cfif this.layoutmanager>
          <cfset objectparams.responsechart=bean.getResponseChart()>
          <cfset objectparams.async=true>
        <cfelse>
          <div class="mura-async-object"
            data-object="form"
						data-sam="spade"
            data-objectname="Form"
            data-objectid="#esapiEncode('html_attr',bean.getContentID())#"
            data-responsechart="#esapiEncode('html_attr',bean.getResponseChart())#"
            data-objectparams=#serializeJSON(objectParams)#>
          </div>
        </cfif>

    <cfelse>
        <cfif not bean.getIsNew()>
        	<cfif bean.getIsOnDisplay()>
					<cfset $.event('objectid',bean.getContentid())>
					<cfset $.event('formid',bean.getContentid())>
	    		<cfset variables.rsForm=bean.getAllValues()>
		          #$.getBean('dataCollectionBean')
		            .set($.event().getAllValues())
		            .render($)#
					</cfif>
			<cfelseif listFindNoCase('author,editor',variables.$.event('r').perm)>
				<p></p>
		  <cfelse>
		    <cfset request.muraValidObject=false>
		  </cfif>
    </cfif>
	</cfoutput>
</cfif>
