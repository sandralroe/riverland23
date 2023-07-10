<!--- License goes here --->
<cfsilent>
	<cfscript>
		// custom tag groups may arrive via arguments.params
		if ( StructKeyExists(arguments, 'params') ) {
			if(IsJSON(arguments.params)){
				arguments.params=DeSerializeJSON(arguments.params);
			}
			StructAppend(arguments, arguments.params);
		}
		param name="arguments.parentID" default="";
	</cfscript>

	<cfset variables.tags=variables.$.getBean('contentGateway').getTagCloud(siteid=variables.$.event('siteID'),parentid=arguments.parentID,taggroup=arguments.taggroup) />
	<cfset variables.tagValueArray = ListToArray(ValueList(variables.tags.tagCount))>
	<cfset variables.max = ArrayMax(variables.tagValueArray)>
	<cfset variables.min = Arraymin(variables.tagValueArray)>
	<cfset variables.diff = variables.max - variables.min>
	<cfset variables.distribution = variables.diff>
	<cfset variables.rbFactory=getSite().getRbFactory()>

	<cfif not isDefined("arguments.filename")>
		<cfset arguments.filename=variables.$.event('currentFilenameAdjusted')>
	</cfif>
</cfsilent>
<cfoutput>
	<div id="svTagCloud" class="mura-tag-cloud #this.tagCloudWrapperClass#">
		<#variables.$.getHeaderTag('subHead1')#>#variables.$.rbKey('tagcloud.tagcloud')#</#variables.$.getHeaderTag('subHead1')#>
		<cfif variables.tags.recordcount>
			<ol>
				<cfloop query="variables.tags">
					<cfsilent>
						<cfif variables.tags.tagCount EQ variables.min>
							<cfset variables.class="not-popular" />
						<cfelseif variables.tags.tagCount EQ variables.max>
							<cfset variables.class="ultra-popular" />
						<cfelseif variables.tags.tagCount GT (variables.min + (variables.distribution/2))>
							<cfset variables.class="somewhat-popular" />
						<cfelseif variables.tags.tagCount GT (variables.min + variables.distribution)>
							<cfset variables.class="mediumTag" />
						<cfelse>
							<cfset variables.class="not-very-popular" />
						</cfif>
						<cfset variables.args = [] />
						<cfset variables.args[1] = variables.tags.tagcount />
					</cfsilent>
					<li class="#variables.class#">
						<span>
							<cfif variables.tags.tagcount gt 1>
								#variables.rbFactory.getResourceBundle().messageFormat(variables.$.rbKey('tagcloud.itemsare'), variables.args)#
							<cfelse>
								#variables.rbFactory.getResourceBundle().messageFormat(variables.$.rbKey('tagcloud.itemis'), variables.args)#
							</cfif>
						</span>
						<cfif len(arguments.taggroup)>
							<a href="#variables.$.createHREF(filename='#arguments.filename#/tag/#urlEncodedFormat(variables.tags.tag)#/_/taggroup/#urlEncodedFormat(arguments.taggroup)#')#" class="tag">#HTMLEditFormat(variables.tags.tag)#</a>
						<cfelse>
							<a href="#variables.$.createHREF(filename='#arguments.filename#/tag/#urlEncodedFormat(variables.tags.tag)#')#" class="tag">#HTMLEditFormat(variables.tags.tag)#</a>
						</cfif>
					</li>
				</cfloop>
			</ol>
		<cfelse>
			<p>#variables.$.rbKey('tagcloud.notags')#</p>
		</cfif>
	</div>
</cfoutput>