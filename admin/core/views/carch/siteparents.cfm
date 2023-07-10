 <!--- license goes here --->
<cfset request.layout=false>
<cfparam name="rc.keywords" default="">
<cfparam name="rc.isNew" default="1">
<cfset counter=0 />
<cfset hasParentID=false />
<cfoutput>
<div class="form-inline">
<h2>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.searchforcontent')#</h2>
<div class="mura-input-set">
	<input id="parentSearch" name="parentSearch" value="" type="text" class="text" maxlength="50" onclick="return false;">
	<input id="parentSearchSubmit" type="button" class="btn" onclick="siteManager.loadSiteParents('#rc.siteid#','#rc.contentid#','#rc.parentid#',document.getElementById('parentSearch').value,0);return false;" value="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.search')#">
</div>
</cfoutput>
</div>
<cfif not rc.isNew>
<cfset parentBean=application.serviceFactory.getBean("content").loadBy(contentID=rc.parentID,siteID=rc.siteID)>
<cfset rc.rsList=application.contentManager.getPrivateSearch(siteid=rc.siteid,keywords=rc.keywords,moduleid=parentBean.getModuleID())/>
<cfif not parentBean.getIsNew()>
<cfset parentCrumb=application.contentManager.getCrumbList(rc.parentid, rc.siteid)/>
</cfif>
 <table class="mura-table-grid">
  <cfif not parentBean.getIsNew()>
		<tr>
		  <th class="actions"></th>
	    <th class="var-width"><cfoutput>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectnewcontentparent')#</cfoutput></th>
    </tr>
	</cfif>
	<cfif rc.rslist.recordcount or listFind('00000000000000000000000000000000003,00000000000000000000000000000000004,00000000000000000000000000000000099',parentBean.getModuleID())>
		<cfif not parentBean.getIsNew() and not listFind('00000000000000000000000000000000003,00000000000000000000000000000000004,00000000000000000000000000000000099',rc.parentid)>
			<tr class="alt"><cfoutput>
				<td class="actions"><input type="radio" name="parentid" value="#esapiEncode('html_attr',rc.parentid)#" checked="checked"></td>
				 <td class="var-width">#$.dspZoomNoLinks(parentCrumb)#</td>
			</tr></cfoutput>
			<cfset hasParentID=true />
		</cfif>
		<cfif listFind('00000000000000000000000000000000003,00000000000000000000000000000000004,00000000000000000000000000000000099',parentBean.getModuleID())>
			<cfset rstop=application.serviceFactory.getBean('contentGateway').getTop(siteid=rc.siteid,topid=parentBean.getModuleID())>
			<cfif reFindNoCase(rc.keywords,rstop.title)>
				<tr class="alt"><cfoutput>
					<td class="actions"><input type="radio" name="parentid" value="#esapiEncode('html_attr',parentBean.getModuleID())#" <cfif rc.parentid eq parentBean.getModuleID()>checked="checked"</cfif>></td>
					 <td class="var-width"><ul class="navZoom"><li class="mi-cog "> #esapiEncode('html',rstop.title)#</li></ul></td>
				</tr></cfoutput>
				<cfset hasParentID=true />
				<cfset counter=counter+1/>
			</cfif>
		</cfif>
    	<cfoutput query="rc.rslist" startrow="1" maxrows="150">
				<cfif rc.rslist.contentid neq rc.parentid>
					<cfset crumbdata=application.contentManager.getCrumbList(rc.rslist.contentid, rc.siteid)/>
			    <cfset verdict=application.permUtility.getnodePerm(crumbdata)/>
					<cfif verdict neq 'none' and arrayLen(crumbdata) and structKeyExists(crumbdata[1],"parentArray") and not listFind(arraytolist(crumbdata[1].parentArray),rc.contentid)>
						<cfset counter=counter+1/>
						<cfset hasParentID=true />
						<tr <cfif not(counter mod 2)>class="alt"</cfif>>
						  <td class="actions"><input type="radio" name="parentid" value="#rc.rslist.contentid#"></td>
			        <td class="var-width">#$.dspZoomNoLinks(crumbdata)#</td>
						</tr>
				 	</cfif>
				</cfif>
      </cfoutput>
	 	</cfif>
	 	<cfif not counter>
			<tr class="alt"><cfoutput>
			  <td class="noResults" colspan="2">#application.rbFactory.getKeyValue(session.rb,'sitemanager.noresults')#</td>
			</tr></cfoutput>
		</cfif>
  </table>
</td></tr></table>
<cfif not hasParentID>
	<cfoutput><input type="hidden" id="parentid" name="parentid" value="#esapiEncode('html_attr',rc.parentid)#" /></cfoutput>
</cfif>
<cfelse>
<cfoutput><input type="hidden" id="parentid" name="parentid" value="#esapiEncode('html_attr',rc.parentid)#" /></cfoutput>
</cfif>

<script type="text/javascript">
	$(document).ready(function(){	
		$('#parentSearch').on('keypress',function(e){
			if(e.which == 13) {
				var pval = $(this).val();
				$('#parentSearchSubmit').trigger('click');
				setTimeout(function(){						
				$('#parentSearch').focus();	
				},'250')	
				return false;
		  	}
		})
	})
</script>