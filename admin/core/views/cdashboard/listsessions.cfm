 <!--- license goes here --->
<!--- license goes here --->

<cfsilent>
<cfif rc.spanType eq 'n'>
<cfset spanLabel='Minutes' />
<cfelse>
<cfif rc.span eq 1>
	<cfset spanLabel='Day' />
<cfelse>
	<cfset spanLabel='Days' />
</cfif>
</cfif>
</cfsilent>

<div class="mura-header">
	<cfoutput>
		<h1><cfif rc.membersOnly>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.membersessions")#<cfelse>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.allsessions")#</cfif>
		<span>
		(<cfif rc.spanType eq 'n'>#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"dashboard.spannow"),rc.span)#<cfelse>#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"dashboard.spannow"),rc.span)#</cfif>)
		</span>
		</h1>

	<cfinclude template="dsp_secondary_menu.cfm">

</div> <!-- /.mura-header -->

<div class="block block-constrain">
	<div class="block block-bordered">
	  <div class="block-content">

			<h2>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.totalsessions")#: <strong>#rc.rslist.recordcount#</strong></h2>
			<div>
			<cfif rc.contentid neq ''>

			<cfset crumbdata=application.contentManager.getCrumbList(rc.contentid, rc.siteid)/>

			<h3>#$.dspZoom(crumbdata,'breadcrumb')#</h3>
			</cfif>

			<table class="mura-table-grid"> 
			<tr>
				<th class="actions"></th>
				<th>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.user")#</th>
				<th>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.locale")#</th>
				<th>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.lastrequest")#</th>
				<th>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.views")#</th>
				<th>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.lengthofvisit")#</th>
			</tr>
			<cfif rc.rslist.recordcount>
			<cfset rc.nextN=application.utility.getNextN(rc.rsList,20,rc.startrow)/>
			<cfset endrow=(rc.startrow+rc.nextN.recordsperpage)-1/>
			<cfloop query="rc.rslist" startrow="#rc.startRow#" endrow="#endRow#">
			<tr>
				<td class="actions">
					<a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
					<div class="actions-menu hide">	
						<ul class="one actions-list">
							<li class="viewDetails"><a href="./?muraAction=cDashboard.viewSession&urlToken=#esapiEncode('url',rc.rslist.urlToken)#&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-pencil"></i>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.view")#</a></li>
						</ul>
					</div>	
				</td>
				<td><a title="#application.rbFactory.getKeyValue(session.rb,"dashboard.session.view")#" href="./?muraAction=cDashboard.viewSession&urlToken=#esapiEncode('url',rc.rslist.urlToken)#&siteid=#esapiEncode('url',rc.siteid)#"><cfif rc.rslist.fname eq ''>Anonymous<cfelse>#esapiEncode('html',rc.rslist.fname)# #esapiEncode('html',rc.rslist.lname)#<cfif rc.rslist.company neq ''> (#esapiEncode('html',rc.rslist.company)#)</cfif></cfif></a></td>
				<td>#esapiEncode('html',rc.rslist.locale)#</td>
				<td>#LSDateFormat(rc.rslist.lastRequest,session.dateKeyFormat)# #LSTimeFormat(rc.rslist.lastRequest,"short")#</td>
				<td>#rc.rslist.views#</td>
				<td>#application.dashboardManager.getTimespan(rc.rslist.firstRequest,rc.rslist.lastRequest)#</td>
			</tr></cfloop>
			<cfelse>
			<tr>
			<td class="noResults"colspan="6">#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"dashboard.session.spannoresults"),"#rc.span# #spanLabel#")#.</td>
			</tr>
			</cfif>
			</table>

			<cfif rc.rslist.recordcount and rc.nextN.numberofpages gt 1>
			#application.rbFactory.getKeyValue(session.rb,"dashboard.session.moreresults")#: <cfif rc.nextN.currentpagenumber gt 1> <a href="./?muraAction=cDashboard.listSessions&startrow=#rc.nextN.previous#&siteid=#esapiEncode('url',rc.siteid)#&direction=#rc.direction#&orderBy=#rc.orderBy#&spanType=#rc.spanType#&span=#rc.span#">&laquo;&nbsp;#application.rbFactory.getKeyValue(session.rb,"dashboard.session.prev")#</a></cfif>
			<cfloop from="#rc.nextN.firstPage#"  to="#rc.nextN.lastPage#" index="i">
				<cfif rc.nextN.currentpagenumber eq i> #i# <cfelse> <a href="./?muraAction=cDashBoard.listSessions&startrow=#evaluate('(#i#*#rc.nextN.recordsperpage#)-#rc.nextN.recordsperpage#+1')#&siteid=#esapiEncode('url',rc.siteid)#&direction=#rc.direction#&orderBy=#rc.orderBy#&spanType=#rc.spanType#&span=#rc.span#">#i#</a> </cfif></cfloop>
				<cfif rc.nextN.currentpagenumber lt rc.nextN.NumberOfPages><a href="./?muraAction=cDashboard.listSessions&startrow=#rc.nextN.next#&siteid=#esapiEncode('url',rc.siteid)#&direction=#rc.direction#&orderBy=#rc.orderBy#&spanType=#rc.spanType#&span=#rc.span#">#application.rbFactory.getKeyValue(session.rb,"dashboard.session.next")#&nbsp;&raquo;</a></cfif> 

			</cfif>	  
			</div>

		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->

</cfoutput>