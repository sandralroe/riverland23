<!--- License goes here --->
<cfset rc.rslist=rc.groups.privateGroups />
<cfoutput>
<div class="mura-header">
  <h1>#rc.rscontent.title# #application.rbFactory.getKeyValue(session.rb,'permissions')#</h1>
  <div class="nav-module-specific btn-group">
    <a class="btn" href="##" title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.back'))#" onclick="window.history.back(); return false;"><i class="mi-arrow-circle-left"></i> #esapiEncode('html',application.rbFactory.getKeyValue(session.rb,'sitemanager.back'))#</a>
  </div>
</div> <!-- /.mura-header -->

<div class="block block-constrain">
    <div class="block block-bordered">
      <div class="block-content">

      <div class="help-block">#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"permissions.moduletext"),rc.rscontent.title)#</div>
      <form novalidate="novalidate"  method="post" name="form1" action="./?muraAction=cPerm.updatemodule&contentid=#esapiEncode('url',rc.contentid)#">
        <div class="block-content">
        <h2>#application.rbFactory.getKeyValue(session.rb,'user.adminusergroups')#</h2>

      <cfif rc.rslist.recordcount>
          <table class="mura-table-grid">
            <tr>
              <th>#application.rbFactory.getKeyValue(session.rb,'permissions.allow')#</th>
              <th class="var-width">#application.rbFactory.getKeyValue(session.rb,'permissions.group')#</th>
            </tr>
              <cfloop query="rc.rslist">
                    <tr>
                      <td><input type="checkbox" name="groupid" value="#rc.rslist.userid#"<cfif application.permUtility.getGroupPermVerdict(rc.contentid,rc.rslist.userid,'module',rc.siteid) eq 'module'>checked</cfif>></td>
                <td class="var-width" nowrap>#rc.rslist.GroupName#</td>
              </tr>
         </cfloop>
         </table>
    <cfelse>
        <div class="help-block-empty">#application.rbFactory.getKeyValue(session.rb,'permissions.nogroups')#</div>
   </cfif>

      </div><!-- /.block-content -->
      <cfset rc.rslist=rc.groups.publicGroups />
      <div class="block-content">
 <h2>#application.rbFactory.getKeyValue(session.rb,'user.membergroups')#</h2>
  <div class="help-block">#application.rbFactory.getKeyValue(session.rb,'permissions.memberpermscript')#</div>

  <cfif rc.rslist.recordcount>
      <table class="mura-table-grid">
         <tr>
             <th>#application.rbFactory.getKeyValue(session.rb,'permissions.allow')#</th>
             <th class="var-width">#application.rbFactory.getKeyValue(session.rb,'permissions.group')#</th>
         </tr>
        <cfloop query="rc.rslist">
            <tr>
                <td><input type="checkbox" name="groupid" value="#rc.rslist.userid#"<cfif application.permUtility.getGroupPermVerdict(rc.contentid,rc.rslist.userid,'module',rc.siteid) eq 'module'>checked</cfif>></td>
            <td class="var-width" nowrap>#esapiEncode('html',rc.rslist.GroupName)#</td>
      </tr>
     </cfloop>
      </table>
  <cfelse>
        <div class="help-block-empty">#application.rbFactory.getKeyValue(session.rb,'permissions.nogroups')#</div>
  </cfif>


      <div class="mura-actions">
        <div class="form-actions no-offset">
        <button class="btn mura-primary" onclick="submitForm(document.forms.form1);"><i class="mi-check-circle"></i>#application.rbFactory.getKeyValue(session.rb,'permissions.update')#</button>
        </div>
      </div>

      <input type="hidden" name="router" value="#esapiEncode('html_attr',cgi.HTTP_REFERER)#">
      <input type="hidden" name="siteid" value="#esapiEncode('html_attr',rc.siteid)#">
      <input type="hidden" name="topid" value="#esapiEncode('html_attr',rc.topid)#">
      <input type="hidden" name="moduleid" value="#esapiEncode('html_attr',rc.moduleid)#">
      #rc.$.renderCSRFTokens(context=rc.moduleid,format="form")#
      </form>

      </div> <!-- /.block-content -->
    </div> <!-- /.block-bordered -->
  </div> <!-- /.block-constrain -->

</cfoutput>
