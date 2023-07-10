<!--- license goes here --->
<cfset request.layout=false>
<cfparam name="rc.keywords" default="">
<cfparam name="rc.isNew" default="1">
<cfset counter=0 />
<cfoutput>
<div id="contentSearch" class="form-inline">
	<div class="mura-input-set">
	<input id="parentSearch" name="parentSearch" value="#esapiEncode('html_attr',rc.keywords)#" type="text" maxlength="50" placeholder="Search Content" onclick="return false;"> 
	<input type="button" class="btn" onclick="feedManager.loadSiteParents('#rc.siteid#','#rc.parentid#',document.getElementById('parentSearch').value,0);" value="#application.rbFactory.getKeyValue(session.rb,'collections.search')#">
	</div>
</div>
</cfoutput>

<cfif not rc.isNew>
<cfset rc.rsList=application.contentManager.getPrivateSearch(rc.siteid,rc.keywords)/>
 <table class="mura-table-grid">
    <thead>
    <tr> 
	  <th class="actions"></th>
    <th class="var-width"><cfoutput>#application.rbFactory.getKeyValue(session.rb,'collections.selectnewsection')#</cfoutput></th>
    </tr>
    </thead>
    <cfif rc.rslist.recordcount>
    <tbody>
	<tr class="alt"><cfoutput>  
	  <td class="actions"><input type="radio" name="parentid" value="#esapiEncode('html_attr',rc.parentid)#" checked="checked"></td>
		<cfif rc.parentID neq ''>
		<cfset parentCrumb=application.contentManager.getCrumbList(rc.parentid, rc.siteid)/>
         <td class="var-width">#$.dspZoomNoLinks(parentCrumb)#</td>
		 <cfelse>
		  <td class="var-width">#application.rbFactory.getKeyValue(session.rb,'collections.noneselected')#</td>
		 </cfif>
		</tr></cfoutput>
     <cfoutput query="rc.rslist" startrow="1" maxrows="100">
		<cfset crumbdata=application.contentManager.getCrumbList(rc.rslist.contentid, rc.siteid)/> 
		<cfset verdict=application.permUtility.getnodePerm(crumbdata)/>
		<cfif verdict neq 'none'  and rc.parentID neq  rc.rslist.contentid>	
			<cfset counter=counter+1/>
		<tr <cfif not(counter mod 2)>class="alt"</cfif>>  
		  <td class="actions"><input type="radio" name="parentid" value="#rc.rslist.contentid#"></td>
      <td class="var-width">#$.dspZoomNoLinks(crumbdata)#</td>
		</tr>
	 </cfif>
       </cfoutput>
	 	<cfelse>
		<tr class="alt"><cfoutput>  
		  <td class="noResults" colspan="2">#application.rbFactory.getKeyValue(session.rb,'collections.nosearchresults')#<input type="hidden" name="parentid" value="#esapiEncode('html_attr',rc.parentid)#" /> </td>
		</tr></cfoutput>
		</cfif>
		</tbody>
  </table>
<cfelse>
<cfoutput><input type="hidden" name="parentid" value="#esapiEncode('html_attr',rc.parentid)#" /></cfoutput>
</cfif>