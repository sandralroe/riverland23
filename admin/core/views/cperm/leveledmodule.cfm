<!--- License goes here --->
<cfset rc.groups=application.permUtility.getGroupList(rc) />
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
		  <form novalidate="novalidate" method="post" name="form1" action="./?muraAction=cPerm.updateleveledmodule&contentid=#esapiEncode('url',rc.contentid)#">
		    <h2>#application.rbFactory.getKeyValue(session.rb,'user.adminusergroups')#</h2>
		    <p>#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"permissions.nodetext"),rc.rscontent.title)#</p>

		    <cfif rc.rslist.recordcount>
                <table class="mura-table-grid<cfif rc.rslist.recordcount lt 2> no-stripe</cfif>">
                    <tr>
                        <th>#application.rbFactory.getKeyValue(session.rb,'permissions.editor')#</th>
                        <th>#application.rbFactory.getKeyValue(session.rb,'permissions.readonly')#</th>
                        <th>#application.rbFactory.getKeyValue(session.rb,'permissions.deny')#</th>
                        <th class="var-width">#application.rbFactory.getKeyValue(session.rb,'permissions.group')#</th>
                    </tr>
                    <cfloop query="rc.rslist">
                        <cfsilent>
                            <cfset perm=application.permUtility.getGroupPerm(rc.rslist.userid,rc.contentid,rc.siteid)/>
                        </cfsilent>
                        <tr>
                            <td><input name="p#replacelist(rc.rslist.userid,"-","")#" type="radio" class="checkbox" value="editor" <cfif listFindNoCase('module,editor',perm)>checked</cfif>></td>
                            <td><input name="p#replacelist(rc.rslist.userid,"-","")#" type="radio" class="checkbox" value="read" <cfif perm eq 'Read'>checked</cfif>></td>
                            <td><input name="p#replacelist(rc.rslist.userid,"-","")#" type="radio" class="checkbox" value="none" <cfif not listFindNoCase('editor,read',perm)>checked</cfif>></td>
                            <td nowrap class="var-width">#esapiEncode('html',rc.rslist.GroupName)#</td>
                        </tr>
                    </cfloop>
                </table>
		    <cfelse>
		        <div class="help-block-empty">#application.rbFactory.getKeyValue(session.rb,'permissions.nogroups')#</div>
		    </cfif>

		    <cfset rc.rslist=rc.groups.publicGroups />
		    <h2>#application.rbFactory.getKeyValue(session.rb,'user.membergroups')#</h2>
		    <cfif rc.rslist.recordcount>
                <table class="mura-table-grid<cfif rc.rslist.recordcount lt 2> no-stripe</cfif>">
                    <tr>
                        <th>#application.rbFactory.getKeyValue(session.rb,'permissions.editor')#</th>
                        <th>#application.rbFactory.getKeyValue(session.rb,'permissions.readonly')#</th>
                        <th>#application.rbFactory.getKeyValue(session.rb,'permissions.deny')#</th>
                        <th class="var-width">#application.rbFactory.getKeyValue(session.rb,'permissions.group')#</th>
                    </tr>
                    <cfloop query="rc.rslist">
                        <cfsilent>
                            <cfset perm=application.permUtility.getGroupPerm(rc.rslist.userid,rc.contentid,rc.siteid)/>
                        </cfsilent>
                        <tr>
                            <td><input name="p#replacelist(rc.rslist.userid,"-","")#" type="radio" class="checkbox" value="editor" <cfif perm eq 'Editor'>checked</cfif>></td>
                            <td><input name="p#replacelist(rc.rslist.userid,"-","")#" type="radio" class="checkbox" value="read" <cfif perm eq 'Read'>checked</cfif>></td>
                            <td><input name="p#replacelist(rc.rslist.userid,"-","")#" type="radio" class="checkbox" value="none" <cfif not listFindNoCase('editor,read',perm)>checked</cfif>></td>
                            <td nowrap class="var-width">#esapiEncode('html',rc.rslist.GroupName)#</td>
                        </tr>
                    </cfloop>
                </table>
		    <cfelse>
		        <div class="help-block-empty"> #application.rbFactory.getKeyValue(session.rb,'permissions.nogroups')#</div>
		    </cfif>
      
            <div class="mura-actions">
                <div class="form-actions no-offset">
                <button class="btn mura-primary" onclick="submitForm(document.forms.form1);"><i class="mi-check-circle"></i>#application.rbFactory.getKeyValue(session.rb,'permissions.update')#</button>
                </div>
              </div>
        
              <input type="hidden" name="router" value="#esapiEncode('html_attr',cgi.HTTP_REFERER)#">
              <input type="hidden" name="siteid" value="#esapiEncode('html_attr',rc.siteid)#">
              <input type="hidden" name="moduleid" value="#esapiEncode('html_attr',rc.moduleid)#">
              #rc.$.renderCSRFTokens(context=rc.moduleid,format="form")#
		</form>
    </div> <!-- /.block-content -->
  </div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
</cfoutput>
