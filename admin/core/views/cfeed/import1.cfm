<!--- license goes here --->
<cfset rc.formatsupported=true>
<style type="text/css">
	.mura-import-item img{
		max-width: 200px !important;
		margin-top: .5em !important;
	}
	.mura-import-item br:first-child,
	.mura-import-item br:first-child + br{
		display: none;
	}
</style>


<cfoutput>
<div class="mura-header">
	<h1>#application.rbFactory.getKeyValue(session.rb,'collections.remotefeedimportselection')#</h1>
	<cfinclude template="dsp_secondary_menu.cfm">
	</div> <!-- /.mura-header -->

	<div class="block block-constrain">
			<div class="block block-bordered">
				<div class="block-content">	

					<form novalidate="novalidate" action="./?muraAction=cFeed.import2&feedid=#esapiEncode('url',rc.feedid)#&siteid=#esapiEncode('url',rc.siteid)#" method="post" name="contentForm" onsubmit="return false;">
						<cfset feedBean=application.feedManager.read(rc.feedID) />
						<h2>#feedBean.getName()#</h2>
							</cfoutput>
							
						<CFHTTP url="#feedBean.getChannelLink()#" method="GET" resolveurl="Yes" throwOnError="Yes" />
						<cfset xmlFeed=xmlParse( REReplace( CFHTTP.FileContent, "^[^<]*", "", "all" ) )/>
						<cfswitch expression="#feedBean.getVersion()#">
							<cfcase value="RSS 0.920,RSS 2.0">
								
								<cfset items = xmlFeed.rss.channel.item> 
								<cfset maxItems=arrayLen(items) />
								
								<cfif maxItems gt feedBean.getMaxItems()>
									<cfset maxItems=feedBean.getMaxItems()/>
								</cfif>
							
					<cfloop from="1" to="#maxItems#" index="i">
							<cfsilent>
							<cftry>
								<cfset remoteID=hash(left(items[i].guid.xmlText,255)) />
								<cfcatch>
									<cfset remoteID=hash(left(items[i].link.xmlText,255)) />
								</cfcatch>
							</cftry>
							 
							<cfset rc.newBean=application.contentManager.getActiveByRemoteID(remoteID,rc.siteid) />
							
							</cfsilent>
							<cfif not (not rc.newBean.getIsNew() and (items[i].pubDate.xmlText eq rc.newBean.getRemotePubDate())) >
							<cfset rc.rsCategoryAssign = application.contentManager.getCategoriesByHistID(rc.newBean.getcontenthistID()) />
							
								<cfoutput>
									<div class="mura-layout-row mura-import-item clearfix">
										<div class="mura-12">	
											<label><input name="remoteID" value="#esapiEncode('html_attr',remoteID)#" type="checkbox" checked>&nbsp;&nbsp;#application.rbFactory.getKeyValue(session.rb,'collections.import')#&nbsp;&nbsp;</label>
											<label><strong><a href="#esapiEncode('html_attr',items[i].link.xmlText)#" target="_blank">#esapiEncode('html',items[i].title.xmlText)#<cfif not rc.newBean.getIsNew()> [#application.rbFactory.getKeyValue(session.rb,'collections.update')#]</cfif></a></strong></label>
										</div>
										<div class="mura-12">#items[i].description.xmlText#</div>
									</div>

								</cfoutput>		
							</cfif>
							</cfloop>
							
							</cfcase>
							<cfcase value="atom">
								<cfset rc.formatsupported=false>
								<cfoutput><p>#application.rbFactory.getKeyValue(session.rb,'collections.formatnotsupport')#</p></cfoutput>
							</cfcase>
						</cfswitch>
						<cfif rc.formatsupported>
						<div class="mura-actions">
							<div class="form-actions">
							<cfoutput><button class="btn mura-primary" onclick="feedManager.confirmImport();"><i class="mi-sign-in"></i>#application.rbFactory.getKeyValue(session.rb,'collections.import')#</button></cfoutput>
							</div>
						</div>
						<input type="hidden" name="action" value="import" />
						</cfif>
					</form>

				<div class="clearfix"></div>
			</div> <!-- /.block-content -->
		</div> <!-- /.block-bordered -->
	</div> <!-- /.block-constrain -->