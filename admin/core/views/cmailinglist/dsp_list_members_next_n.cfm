<!--- license goes here --->

 <cfif rc.nextN.numberofpages gt 1>
 <cfoutput>
	<cfset args=arrayNew(1)>
	<cfset args[1]="#rc.nextn.startrow#-#rc.nextn.through#">
	<cfset args[2]=rc.nextn.totalrecords>
	<div class="mura-results-wrapper">
		<p class="clearfix search-showing">
			#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"sitemanager.paginationmeta"),args)#
		</p>
		<ul class="pagination">
		<cfif rc.nextN.currentpagenumber gt 1> 
			<li>
				<a href="./?muraAction=cMailingList.listmembers&mlid=#rc.mlid#&startrow=#rc.nextN.previous#&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-angle-left"></i></a>
			</li>
		</cfif>	
		<cfloop from="1"  to="#rc.nextN.lastPage#" index="i">
			<cfif rc.nextN.currentpagenumber eq i> 
				<li class="active"><a href="##">#i#</a></li> 
			<cfelse> 
				<li>
				<a href="./?muraAction=cMailingList.listmembers&mlid=#rc.mlid#&startrow=#evaluate('(#i#*#rc.nextN.recordsperpage#)-#rc.nextN.recordsperpage#+1')#&siteid=#esapiEncode('url',rc.siteid)#">#i#</a> 
				</li>
			</cfif>
		</cfloop>
		<cfif rc.nextN.currentpagenumber lt rc.nextN.NumberOfPages>
			<li><a href="./?muraAction=cMailingList.listmembers&mlid=#rc.mlid#&startrow=#rc.nextN.next#&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-angle-right"></i></a></li>
		</cfif> 
		</ul>
	</div>		
</cfoutput>
</cfif>