<!--- license goes here --->

<cfoutput>


<div class="mura-header">
  <h1>Change Set Content List</h1>
  <cfinclude template="dsp_secondary_menu.cfm">
</div> <!-- /.mura-header -->


      <cfset csrftokens=rc.$.renderCSRFTokens(context=rc.changesetid,format='url')>
      <cfif rc.changeset.getPublished()>
      <div class="alert alert-info"><span>#application.rbFactory.getKeyValue(session.rb,'changesets.publishednotice')#</span></div>
      <cfelse>
        <cfset hasPendingApprovals=rc.changeset.hasPendingApprovals()>
        <cfif hasPendingApprovals>
          <div class="alert alert-error"><span>#application.rbFactory.getKeyValue(session.rb,'changesets.haspendingapprovals')#</span></div>
        </cfif>
        <cfset hasAttachedExperience=rc.changeset.hasAttachedExperience()>
        <cfif hasAttachedExperience>
          <div class="alert alert-info"><span>#application.rbFactory.getKeyValue(session.rb,'changesets.hasAttachedExperience')#</span></div>
        </cfif>
      </cfif>

      <cfif not rc.changeset.getPublished() and isDate(rc.changeset.getCloseDate())>
        <div class="alert alert-info"><span>#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"changesets.hasclosedate"),LSDateFormat(rc.changeset.getCloseDate(),session.dateKeyFormat))#</span></div>
      </cfif>


      <div class="block-content">

      <div class="block block-constrain">
          <div class="block block-bordered">
      <!--- <h2>#application.rbFactory.getKeyValue(session.rb,'changesets.name')#</h2> --->
      <h2>#esapiEncode('html',rc.changeset.getName())#</h2>

      <cfif not rc.changeset.getPublished()>
      <p><i class="mi-link"></i> <a title="#esapiEncode('html_attr',rc.changeset.getName())#" href="#esapiEncode('html_attr',rc.previewLink)#" onclick="return preview('#esapiEncode('javascript',rc.previewLink)#','');">#esapiEncode('html',rc.previewLink)#</a></p><br/>
      </cfif>

      <form class="form-inline separate" novalidate="novalidate" id="assignmentSearch" name="assignmentSearch" method="get">
    	<input name="keywords" placeholder="Keywords" value="#esapiEncode('html_attr',rc.keywords)#" type="text" class="text" maxlength="50" />
    	<input type="button" class="btn" onclick="return submitForm(document.forms.assignmentSearch);" value="#application.rbFactory.getKeyValue(session.rb,'changesets.filterview')#" />
    	<input type="hidden" name="muraAction" value="cChangesets.assignments">
    	<input type="hidden" name="siteid" value="#esapiEncode('html_attr',rc.siteid)#">
    	<input type="hidden" name="changesetID" value="#esapiEncode('html_attr',rc.changesetID)#">
      </form>
      <br/>
      <!---
      <h3>#application.rbFactory.getKeyValue(session.rb,'changesets.filterview')#</h3>
      <p>#application.rbFactory.getKeyValue(session.rb,'changesets.filterviewnotice')#</p>
      --->

      <!--- <h3>#application.rbFactory.getKeyValue(session.rb,'changesets.previewlink')#</h3> --->

      <h3>#application.rbFactory.getKeyValue(session.rb,'changesets.sitearchitecture')#</h3>
 <table class="mura-table-grid">
    <tr>
      <th class="actions"></th>
      <th class="var-width"> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.title')#</th>
      <th> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.status')#</th>
    </tr>
    <cfif rc.siteAssignments.hasNext()>
     <cfloop condition="rc.siteAssignments.hasNext()">
		<cfsilent>
      <cfset item=rc.siteAssignments.next()>
			<cfset crumbdata=application.contentManager.getCrumbList(item.getContentID(), rc.siteid,false,item.getPath())/>
			<cfset verdict=application.permUtility.getnodePerm(crumbdata)/>
		</cfsilent>
        <tr>
     		  <td class="actions">
            <a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
            <div class="actions-menu hide">
          		<ul class="actions-list">
                <cfif verdict neq 'none'>
                  <li class="edit"><a href="./?muraAction=cArch.edit&contenthistid=#item.getContentHistID()#&contentid=#item.getContentID()#&type=#esapiEncode('javascript',item.gettype())#&parentid=#item.getparentID()#&topid=#esapiEncode('url',item.getcontentID())#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#item.getmoduleid()#&startrow=#esapiEncode('url',rc.startrow)#&return=changesets"> <i class="mi-pencil"></i>Edit</a></li>
                	 <li class="preview"><a href="##" onclick="return preview('#item.getURL(complete=1,queryString="previewid=#item.getContentHistID()#")#');"><i class="mi-globe"></i>Preview</a></li>
                   <li class="version-history"><a href="./?muraAction=cArch.hist&contentid=#item.getContentID()#&type=#item.gettype()#&parentid=#item.getparentID()#&topid=#item.getcontentID()#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#item.getmoduleID()#&startrow=#esapiEncode('url',rc.startrow)#"><i class="mi-history"></i>Version History</a></li>
                <cfelse>
                  <!--- <li class="edit disabled"><i class="mi-edit"></i></li> --->
                  <li class="preview"><a href="##" onclick="return preview('#item.getURL(complete=1,queryString="previewid=#item.getContentHistID()#")#');"><i class="mi-globe"></i></a></li>
                  <li class="version-history disabled"><i class="mi-history"></i>Preview</li>
                </cfif>
            		<li class="delete"><a href="./?muraAction=cChangesets.removeItem&contentHistId=#item.getcontentHistID()#&siteid=#esapiEncode('url',rc.siteid)#&changesetID=#esapiEncode('url',item.getchangesetID())#&keywords=#esapiEncode('html',rc.keywords)##csrftokens#" onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,'changesets.removeitemconfirm'),item.getmenutitle()))#',this.href)"><i class="mi-trash"></i>Delete</a></li>
        		</ul>
         </div>
  		  </td>
          <td class="title var-width">#$.dspZoom(crumbdata)#</td>
           <td>
            <cfif len(item.getapprovalStatus())>
              #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.#item.getapprovalStatus()#')#
            <cfelseif item.getapproved() and item.getactive()>
               #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.published')#
            <cfelseif item.getapproved()>
                 #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.archived')#
            <cfelse>
              #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.queued')#
            </cfif>
          </td>
  		</tr>
   		</cfloop>
      <cfelse>
      <tr>
        <td colspan="3" class="results">Your search returned no results.</td>
      </tr>
    </cfif>
      </table>


      <cfset rc.rslist=rc.componentAssignments.getQuery()>
      <h3>#application.rbFactory.getKeyValue(session.rb,'changesets.components')#</h3>
 <table class="mura-table-grid">
    <tr>
      <th class="actions"></th>
      <th class="var-width"> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.title')#</th>
      <th> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.status')#</th>
    </tr>
    <cfif rc.rslist.recordcount>
     <cfloop query="rc.rslist">
    <cfsilent>
      <cfset crumbdata=application.contentManager.getCrumbList(rc.rslist.contentid, rc.siteid,false,rc.rslist.path)/>
      <cfset verdict=application.permUtility.getnodePerm(crumbdata)/>
      <cfset editlink="./?muraAction=cArch.edit&contenthistid=#rc.rsList.ContentHistID#&contentid=#rc.rsList.ContentID#&type=#rc.rsList.type#&parentid=#rc.rsList.parentID#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#rc.rslist.moduleid#&startrow=#esapiEncode('url',rc.startrow)#&return=changesets">
    </cfsilent>
        <tr>
 		     <td class="actions">
          <a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
          <div class="actions-menu hide">
        		<ul class="actions-list">
        		<cfif verdict neq 'none'>
                    <li class="edit"><a href="#editlink#"><i class="mi-pencil"></i>Edit</a></li>
              		  <li class="version-history"><a href="./?muraAction=cArch.hist&contentid=#rc.rsList.ContentID#&type=#esapiEncode('url',rc.rsList.type)#&parentid=#rc.rsList.parentID#&&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#rc.rslist.moduleID#&startrow=#esapiEncode('url',rc.startrow)#"><i class="mi-history"></i>Version History</a></li>
<!---             <cfelse>
              	   <li class="edit disabled"><i class="mi-pencil"></i></li>
                    <li class="version-history disabled"><a><i class="mi-history"></i></a></li> --->
            </cfif>
              		<li class="delete"><a href="./?muraAction=cChangesets.removeItem&contentHistId=#rc.rsList.contentHistID#&siteid=#esapiEncode('url',rc.siteid)#&changesetID=#esapiEncode('url',rc.rslist.changesetID)#&keywords=#esapiEncode('html',rc.keywords)##csrftokens#" onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,'changesets.removeitemconfirm'),rc.rslist.menutitle))#',this.href)"><i class="mi-trash"></i>Delete</a></li>
        		</ul>
          </div>
      	</td>
          <td class="title var-width">#$.dspZoom(crumbdata)#</td>
          <td>
            <cfif len(rc.rslist.approvalStatus)>
              #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.#rc.rslist.approvalStatus#')#
            <cfelseif rc.rslist.approved and rc.rslist.active>
               #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.published')#
            <cfelseif rc.rslist.approved>
                 #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.archived')#
            <cfelse>
              #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.queued')#
            </cfif>
          </td>
		    </tr>
   		</cfloop>
      <cfelse>
      <tr>
        <td colspan="3" class="results">Your search returned no results.</td>
      </tr>
    </cfif>
      </table>


      <cfset rc.rslist=rc.formAssignments.getQuery()>
      <h3>#application.rbFactory.getKeyValue(session.rb,'changesets.forms')#</h3>
 <table class="mura-table-grid">
    <tr>
      <th class="actions"></th>
      <th class="var-width"> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.title')#</th>
      <th> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.status')#</th>
    </tr>
    <cfif rc.rslist.recordcount>
     <cfloop query="rc.rslist">
    <cfsilent>
      <cfset crumbdata=application.contentManager.getCrumbList(rc.rslist.contentid, rc.siteid,false,rc.rslist.path)/>
      <cfset verdict=application.permUtility.getnodePerm(crumbdata)/>
      <cfset editlink="./?muraAction=cArch.edit&contenthistid=#rc.rsList.ContentHistID#&contentid=#rc.rsList.ContentID#&type=#rc.rsList.type#&parentid=#rc.rsList.parentID#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#rc.rslist.moduleid#&startrow=#esapiEncode('url',rc.startrow)#&return=changesets">
    </cfsilent>
        <tr>
           <td class="actions">
            <a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
            <div class="actions-menu hide">
            <ul class="actions-list">
              <cfif verdict neq 'none'>
              <li class="edit"><a href="#editlink#"><i class="mi-pencil"></i>Edit</a></li>
              <li class="version-history"><a href="./?muraAction=cArch.hist&contentid=#rc.rsList.ContentID#&type=#esapiEncode('url',rc.rsList.type)#&parentid=#rc.rsList.parentID#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#rc.rslist.moduleID#&startrow=#esapiEncode('url',rc.startrow)#"><i class="mi-history"></i>Version History</a></li>
<!---               <cfelse>
                <li class="edit disabled"><i class="mi-pencil"></i></li>
               <li class="version-history disabled"><a><i class="mi-history"></i></a></li> --->
              </cfif>
              <li class="delete"><a href="./?muraAction=cChangesets.removeItem&contentHistId=#rc.rsList.contentHistID#&siteid=#esapiEncode('url',rc.siteid)#&changesetID=#esapiEncode('url',rc.rslist.changesetID)#&keywords=#esapiEncode('html',rc.keywords)##csrftokens#" onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,'changesets.removeitemconfirm'),rc.rslist.menutitle))#',this.href)"><i class="mi-trash"></i>Delete</a></li>
              </ul>
            </div>
          </td>
          <td class="title var-width">#$.dspZoom(crumbdata)#</td>
           <td>
            <cfif len(rc.rslist.approvalStatus)>
              #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.#rc.rslist.approvalStatus#')#
            <cfelseif rc.rslist.approved and rc.rslist.active>
               #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.published')#
            <cfelseif rc.rslist.approved>
                 #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.archived')#
            <cfelse>
              #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.queued')#
            </cfif>
           </td>

        </tr>
      </cfloop>
      <cfelse>
      <tr>
        <td colspan="3" class="results">Your search returned no results.</td>
      </tr>
    </cfif>
      </table>

      <cfif application.configBean.getValue(property='variations',defaultValue=false)>
  <cfset rc.rslist=rc.variationAssignments.getQuery()>
      <h3>#application.rbFactory.getKeyValue(session.rb,'changesets.variations')#</h3>
 <table class="mura-table-grid">
    <tr>
      <th class="actions"></th>
      <th class="var-width"> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.title')#</th>
      <th> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.status')#</th>
    </tr>
    <cfif rc.rslist.recordcount>
     <cfloop query="rc.rslist">
    <cfsilent>
      <cfset crumbdata=application.contentManager.getCrumbList(rc.rslist.contentid, rc.siteid,false,rc.rslist.path)/>
      <cfset verdict=application.permUtility.getnodePerm(crumbdata)/>
      <cfset editlink="./?muraAction=cArch.edit&contenthistid=#rc.rsList.ContentHistID#&contentid=#rc.rsList.ContentID#&type=#rc.rsList.type#&parentid=#rc.rsList.parentID#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#rc.rslist.moduleid#&startrow=#esapiEncode('url',rc.startrow)#&return=changesets">
    </cfsilent>
        <tr>
           <td class="actions">
            <a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
            <div class="actions-menu hide">
              <ul class="actions-list">
              <cfif verdict neq 'none'>
                <li class="edit"><a title="Edit" href="#editlink#"><i class="mi-pencil"></i></a></li>
                <li class="version-history"><a title="Version History" href="./?muraAction=cArch.hist&contentid=#rc.rsList.ContentID#&type=#esapiEncode('url',rc.rsList.type)#&parentid=#rc.rsList.parentID#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#rc.rslist.moduleID#&startrow=#esapiEncode('url',rc.startrow)#"><i class="mi-history"></i></a></li>
                 <li class="preview"><a title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.view")#" href="##" onclick="return preview('#rc.rslist.remoteurl#?previewid=#rc.rslist.contenthistid#');"><i class="mi-globe"></i></a></li>
                <cfelse>
<!---                   <li class="edit disabled"><i class="mi-pencil"></i></li> --->
                  <cfif rc.rstop.type eq 'Variation'>
                     <li class="preview"><a href="##" onclick="return preview('#rc.rslist.remoteurl#?previewid=#rc.rslist.contenthistid#');"><i class="mi-globe"></i>#application.rbFactory.getKeyValue(session.rb,"sitemanager.view")#</a></li>
                   </cfif>
<!---                    <li class="version-history disabled"><a><i class="mi-history"></i></a></li> --->
                  </cfif>
                    <li class="delete"><a href="./?muraAction=cChangesets.removeItem&contentHistId=#rc.rsList.contentHistID#&siteid=#esapiEncode('url',rc.siteid)#&changesetID=#esapiEncode('url',rc.rslist.changesetID)#&keywords=#esapiEncode('html',rc.keywords)##csrftokens#" onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,'changesets.removeitemconfirm'),rc.rslist.menutitle))#',this.href)"><i class="mi-trash"></i>Delete</a></li>
              </ul>
             </div>
          </td>
          <td class="title var-width"><a href="#editlink#">#$.dspZoom(crumbdata)#</a></td>
           <td>
            <cfif len(rc.rslist.approvalStatus)>
              #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.#rc.rslist.approvalStatus#')#
            <cfelseif rc.rslist.approved and rc.rslist.active>
               #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.published')#
            <cfelseif rc.rslist.approved>
                 #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.archived')#
            <cfelse>
              #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.queued')#
            </cfif>
           </td>

        </tr>
      </cfloop>
      <cfelse>
      <tr>
        <td colspan="3" class="results">Your search returned no results.</td>
      </tr>
    </cfif>
      </table>
      </cfif>

    </div> <!-- /.block-content -->
  </div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
</cfoutput>
