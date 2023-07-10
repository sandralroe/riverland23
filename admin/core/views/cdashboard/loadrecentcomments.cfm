<!--- license goes here --->
<cfset request.layout="false">
<cfinclude template="act_defaults.cfm">
<cfset comments=application.contentManager.getRecentCommentsIterator(rc.siteID,5,false) />
<cfoutput>
<table class="mura-table-grid">
	<thead>
	<tr>
		<th class="actions"></th>
		<th class="var-width">#application.rbFactory.getKeyValue(session.rb,"dashboard.comments")#</th>
		<th class="dateTime">#application.rbFactory.getKeyValue(session.rb,"dashboard.comments.posted")#</th>
	</tr>
	</thead>
	<tbody>
	<cfif comments.hasNext()>
	<cfloop condition="comments.hasNext()">
		<cfset comment=comments.next()>
		<!---
		<cfset crumbdata=application.contentManager.getCrumbList(comment.getCommentID(),comment.getSiteID())/>
		<cfset verdict=application.permUtility.getnodePerm(crumbdata)/>
		--->
		<cfset content=application.serviceFactory.getBean("content").loadBy(contentID=comment.getContentID(),siteID=session.siteID)>
		<tr>
			<cfset args=arrayNew(1)>
			<cfset args[1]="<strong>#esapiEncode('html',comment.getName())#</strong>">
			<cfset args[2]="<strong>#esapiEncode('html',content.getMenuTitle())#</strong>">
			<td class="actions">
				<a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
				<div class="actions-menu hide">
					<ul class="actions-list">
						<li class="preview"><a href="##" onclick="return preview('#esapiEncode('javascript',content.getURL(complete=1,queryString='##comment-#comment.getCommentID()#'))#','#esapiEncode('javascript',content.getTargetParams())#');"><i class="mi-globe"></i>#application.rbFactory.getKeyValue(session.rb,"dashboard.view")#</a></li>
					</ul>
				</div>		
			</td>
			<td class="var-width">#left(application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"dashboard.comments.description"),args),116)#</td>
			<td class="dateTime">#LSDateFormat(comment.getEntered(),session.dateKeyFormat)# #LSTimeFormat(comment.getEntered(),"short")#</td>
		</tr>
		</cfloop>
		<cfelse>
		<tr>
		<td class="noResults" colspan="3">#application.rbFactory.getKeyValue(session.rb,"dashboard.comments.nocomments")#</td>
		</tr>
		</cfif>
	</tbody>
	</table>
</cfoutput>