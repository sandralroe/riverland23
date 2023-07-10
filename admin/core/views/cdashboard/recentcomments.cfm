 <!--- license goes here --->
<cfinclude template="js.cfm">
<cfoutput>
<h1>#application.rbFactory.getKeyValue(session.rb,"dashboard.comments")#</h1>

<cfinclude template="dsp_secondary_menu.cfm">

<cfparam name="rc.page" default="1">
<cfset comments=application.contentManager.getRecentCommentsIterator(rc.siteID,100,false) />
<cfset comments.setNextN(20)>
<cfset comments.setPage(rc.page)>

<h3>#application.rbFactory.getKeyValue(session.rb,"dashboard.comments.last100")#</h3>
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
					<li class="preview"><a href="##" onclick="return preview('#esapiEncode('javascript',content.getURL(complete=1,queryString='##comment-#comment.getCommentID()#'))#','#content.getTargetParams()#');"><i class="mi-globe"></i></a>#application.rbFactory.getKeyValue(session.rb,"dashboard.view")#</li>
				</ul>
			</div>
		</td>
		<td class="var-width">#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"dashboard.comments.description"),args)#</td>
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

<cfif comments.recordCount() and comments.pageCount() gt 1>
	<ul class="pagination">
		<cfif comments.getPageIndex() gt 1> 
			<a href="./?muraAction=cDashboard.recentComments&page=#evaluate('comments.getPageIndex()-1')#&siteid=#esapiEncode('url',rc.siteid)#"><li><i class="mi-angle-left"></i></a></li>
			</cfif>
		<cfloop from="1"  to="#comments.pageCount()#" index="i">
			<cfif comments.getPageIndex() eq i>
				<li class="active"> <a href="##">#i#</a></li> 
			<cfelse> 
				<li><a href="./?muraAction=cDashBoard.recentComments&page=#i#&siteid=#esapiEncode('url',rc.siteid)#">#i#</a>
				</li>
			</cfif>
		</cfloop>
		<cfif comments.getPageIndex() lt comments.pageCount()>
			<li><a href="./?muraAction=cDashboard.recentComments&page=#evaluate('comments.getPageIndex()+1')#&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-angle-right"></i></a></li>
		</cfif>
	</ul>
</cfif>	
</cfoutput>



