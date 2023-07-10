<!--- license goes here --->

<cfset isMore=hasKids gt session.mura.nextN>

<cfif isMore>

<cfset nextN=application.utility.getNextN(hasKids,session.mura.nextN,rc.startRow,2)>
<!--- <cfset TotalRecords=rsNext.RecordCount>
<cfset RecordsPerPage=session.mura.nextN>
<cfset NumberOfPages=Ceiling(TotalRecords/RecordsPerPage)>
<cfset CurrentPageNumber=Ceiling(rc.StartRow/RecordsPerPage)> --->

<cfif application.settingsManager.getSite(rc.siteid).getlocking() neq 'all'>
<cfset numRows=8>
<cfelse>
<cfset numRows=4>
</cfif>

<cfsavecontent variable="pagelist"><cfoutput>
		<cfset args=arrayNew(1)>
		<cfset args[1]="#nextn.startrow#-#nextn.through#">
		<cfset args[2]=nextn.totalrecords>
		<div class="clearfix mura-results-wrapper">
		<p class="search-showing">
			#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"sitemanager.paginationmeta"),args)#
		</p>
			 <ul class="pagination">
			  <cfif nextN.currentpagenumber gt 1>
			  	<li>
			  	<a href="" onclick="return siteManager.loadSiteManager('#esapiEncode('javascript',rc.siteid)#','#esapiEncode('javascript',rc.topid)#','#esapiEncode('javascript',rc.moduleid)#','','','#esapiEncode('javascript',rc.ptype)#',#nextN.previous#);"><i class="mi-angle-left"></i></a>
			  	</li>
			  </cfif>
			  <cfloop from="#nextN.firstPage#"  to="#nextN.lastPage#" index="i">
			  <cfif nextN.currentpagenumber eq i>
			  		<li class="active"><a href="##">#i#</a></li>
			  <cfelse>
			  		<li>
			  			<a href="" onclick="return siteManager.loadSiteManager('#esapiEncode('javascript',rc.siteid)#','#esapiEncode('javascript',rc.topid)#','#esapiEncode('javascript',rc.moduleid)#','','','#esapiEncode('javascript',rc.ptype)#',#evaluate('(#i#*#nextN.recordsperpage#)-#nextN.recordsperpage#+1')#);">#i#</a>
			  		</li>
			  	</cfif>
		     </cfloop>
			 <cfif nextN.currentpagenumber lt nextN.NumberOfPages>
			 	<li>
			 		<a href="" onclick="return siteManager.loadSiteManager('#esapiEncode('javascript',rc.siteid)#','#esapiEncode('javascript',rc.topid)#','#esapiEncode('javascript',rc.moduleid)#','','','#esapiEncode('javascript',rc.ptype)#',#nextN.next#);"><i class="mi-angle-right"></i></a> 
			 	</li>
			 </cfif>
			</ul>
		</div>
</cfoutput>
</cfsavecontent>

</cfif>
