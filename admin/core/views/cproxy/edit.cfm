<cfparam name="rc.proxyid" default="">
<cfset isEditor=listFindNoCase('editor,module',rc.$.getBean('permUtility').getModulePermType('00000000000000000000000000000000020',rc.siteid))>

<cfif not len(rc.proxyid)>
  <cfset rc.proxyid=createUUID()>
</cfif>

<cfif not isdefined('rc.bean') or not isObject(rc.bean)>
    <cfset rc.bean=$.getBean('proxy').loadBy(proxyid=rc.proxyid)/>
</cfif>
<cfoutput>
<div class="mura-header">
  <cfif not rc.bean.exists()>
	<h1>Add API Proxy</h1>
  <cfelse>
	<h1>Edit API Proxy</h1>
  </cfif>

  <div class="nav-module-specific btn-group">
      <a class="btn" href="./?muraAction=cproxy.list&siteid=&#esapiEncode('url',rc.siteid)#"><i class="mi-arrow-circle-left"></i>  Back to API Proxies</a>
  </div>
</div> <!-- /.mura-header -->

<cfif not structIsEmpty(rc.bean.getErrors())>
  <div class="alert alert-error"><span>#application.utility.displayErrors(rc.bean.getErrors())#</span></div>
<cfelseif rc.muraAction eq "core:cproxy.save">
    <div class="alert alert-success"><span>This API Proxy has been saved.</span></div>
</cfif>

<form novalidate="novalidate" action="./?muraAction=cproxy.save" method="post" name="form1" onsubmit="return validateForm(this);">
<div class="block block-constrain">
    <div class="block block-bordered">
      <div class="block-content">
        <span id="token-container"></span>
        <div class="mura-control-group">
            <label>Name</label>
            <input name="name" type="text" required="true" message="The Name attribute is required." value="#esapiEncode('html_attr',rc.bean.getName())#" maxlength="200">
        </div>
        <div class="mura-control-group">
            <label>Resource</label>
            <input name="resource" type="text" required="true" message="The Resource attribute is required." value="#esapiEncode('html_attr',rc.bean.getResource())#" maxlength="200">
        </div>
        <cfset apiEndpointJSON="#rc.$.siteConfig().getApi('json','v1').getEndpoint(mode='json')#proxy/">
        <cfset apiEndpointREST="#rc.$.siteConfig().getApi('json','v1').getEndpoint(mode='rest')#proxy/">
        <div class="mura-control-group">
            <label>JSON API Entry Point</label>
            <div class="exampleAPIEndpointJSON">
                <a target="_blank" href="#esapiEncode('html_attr','#apiEndpointJSON##rc.bean.getResource()#')#">#esapiEncode('html','#apiEndpointJSON##rc.bean.getResource()#')#</a>
            </div>
        </div>
        <div class="mura-control-group">
            <label>REST API Entry Point</label>
            <div class="exampleAPIEndpointREST">
                <a target="_blank" href="#esapiEncode('html_attr','#apiEndpointREST##rc.bean.getResource()#')#">#esapiEncode('html','#apiEndpointREST##rc.bean.getResource()#')#</a>
            </div>
        </div>
        <script>
            Mura(function(){
                var apiEndpointJSON="#esapiEncode('javascript', apiEndpointJSON)#";
                var apiEndpointREST="#esapiEncode('javascript', apiEndpointREST)#";
                Mura('input[name="resource"]').on("keyup",
                function(){
                    var resource=Mura(this).val();
                    Mura(".exampleAPIEndpointJSON").each(function(){
                        var example=Mura(this).find('a');
                        var api=apiEndpointJSON + resource;
                        example.attr("href",api).text(api);
                    });
                    Mura(".exampleAPIEndpointREST").each(function(){
                        var example=Mura(this).find('a');
                        var api=apiEndpointREST + resource;
                        example.attr("href",api).text(api);
                    })
                })
            });
        </script>
        <div class="mura-control-group">
            <label>Proxied API Endpoint</label>
            <input name="endpoint" type="text" required="true" message="The API Endpoint attribute is required." value="#esapiEncode('html_attr',rc.bean.getEndpoint())#" maxlength="200">
        </div>

        <div class="mura-control-group boolean">
            <label for="restricted" class="checkbox"><input name="restricted" id="restricted" type="checkbox" value="1"  onclick="javascript: this.checked?toggleDisplay2('rg',true):toggleDisplay2('rg',false);" <cfif rc.bean.getrestricted() eq 1>checked </cfif> class="checkbox">
            #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.restrictaccess')#
            </label>
        </div>

        <script>
                Mura(function(){
                    Mura('##restricted').on('change',function(){
                        if(Mura(this).is(":checked")){
                            Mura('##rg').show();
                        } else {
                            Mura('##rg').hide();
                        }
                    })
                })
        </script>

        <div class="mura-control-group" id="rg"<cfif rc.bean.getrestricted() NEQ 1> style="display:none;"</cfif>>
            <div class="mura-control justify">
                <cfset rc.rsRestrictGroups=rc.$.getBean('contentUtility').getRestrictGroups(rc.siteid,true)>
                <select name="restrictgroups" size="8" multiple="multiple" class="multiSelect" id="restrictGroups">
                <optgroup label="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.globalsettings'))#">
                <option value="" <cfif rc.bean.getrestrictgroups() eq ''>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.allowall')#</option>
                <option value="RestrictAll" <cfif rc.bean.getrestrictgroups() eq 'RestrictAll'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.restrictall')#</option>
                </optgroup>
                <cfquery dbtype="query" name="rsGroups">select * from rc.rsrestrictgroups where isPublic=1</cfquery>
                <cfif rsGroups.recordcount>
                    <optgroup label="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'user.membergroups'))#">
                    <cfloop query="rsGroups">
                        <option value="#esapiEncode('html_attr',rsGroups.userid)#" <cfif listfind(rc.bean.getrestrictgroups(),rsGroups.groupname) or listfind(rc.bean.getrestrictgroups(),rsGroups.userid)>Selected</cfif>>#esapiEncode('html',rsGroups.groupname)#</option>
                    </cfloop>
                    </optgroup>
                </cfif>
                <cfquery dbtype="query" name="rsGroups">select * from rc.rsrestrictgroups where isPublic=0</cfquery>
                <cfif rsGroups.recordcount>
                    <optgroup label="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'user.adminusergroups'))#">
                    <cfloop query="rsGroups">
                        <option value="#esapiEncode('html_attr',rsGroups.userid)#" <cfif listfind(rc.bean.getrestrictgroups(),rsGroups.groupname) or listfind(rc.bean.getrestrictgroups(),rsGroups.userid)>Selected</cfif>>#esapiEncode('html',rsGroups.groupname)#</option>
                    </cfloop>
                    </optgroup>
                </cfif>
                </select>
          </div> <!--- /end mura-control justify --->	
      </div> <!--- /end mura-control-group --->

        <cfif rc.bean.exists()>
            <h2>
                Credentials  
                <cfif isEditor>
                    <a class="btn" href="./?muraAction=cproxy.editcredential&proxyid=#esapiEncode('url',rc.proxyid)#&siteid=&#esapiEncode('url',rc.siteid)#"><i class="mi-plus-circle"></i>  Add API Credential</a>
                </cfif>
            </h2>
            <cfset credentials=rc.bean.getCredentials()>
            <cfif not credentials.hasNext()>
                <div class="help-block-empty">There currently are no api credentials configured for this proxy.</div>
            <cfelse>
                <table class="mura-table-grid">
                <thead>
                    <tr>
                        <th class="actions"></th>
                        <th class="var-width">Name</th>
                        <th class="var-width">Type</th>
                        <th class="var-width">Value</th>
                        <th>Last Update</th>
                    </tr>
                </thead>
                <tbody class="nest">
                    <cfloop condition="credentials.hasNext()">
                        <cfset credential=credentials.next()>
                        <tr>
                            <td class="actions">
                                <a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
                                <div class="actions-menu hide">
                                    <ul class="actions-list">
                                        <li class="edit">
                                            <a href="./?muraAction=cproxy.editcredential&proxyid=#credential.getproxyid()#&credentialid=#credential.getcredentialid()#&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-pencil"></i>Edit</a>
                                        </li>
                                        <cfif isEditor>
                                        <li class="delete">
                                            <a href="./?muraAction=cproxy.deletecredential&proxyid=#credential.getproxyid()#&credentialid=#credential.getcredentialid()#&siteid=#esapiEncode('url',rc.siteid)##rc.$.renderCSRFTokens(context=credential.getcredentialid(),format='url')#" onClick="return confirmDialog('Delete Credential?',this.href)"><i class="mi-trash"></i>Delete</a>
                                        </li>
                                        </cfif>
                                    </ul>
                                </div>
                            </td>
                            <td class="var-width">
                                <a title="Edit" href="./?muraAction=cproxy.editcredential&proxyid=#credential.getproxyid()#&credentialid=#credential.getcredentialid()#&siteid=#esapiEncode('url',rc.siteid)#">#esapiEncode('html',credential.getName())#</a>
                            </td>
                            <td class="var-width">
                                <a title="Edit" href="./?muraAction=cproxy.editcredential&proxyid=#credential.getproxyid()#&credentialid=#credential.getcredentialid()#&siteid=#esapiEncode('url',rc.siteid)#">#esapiEncode('html',credential.getType())#</a>
                            </td>
                            <td class="var-width">
                                <a title="Edit" href="./?muraAction=cproxy.editcredential&proxyid=#credential.getproxyid()#&credentialid=#credential.getcredentialid()#&siteid=#esapiEncode('url',rc.siteid)#"><cfif isJSON(credential.getData())>[JSON Object]<cfelse>#esapiEncode('html',credential.getData())#</cfif></a>
                            </td>
                            <td>
                                <a title="Edit" href="./?muraAction=cproxy.editcredential&proxyid=#credential.getproxyid()#&credentialid=#credential.getcredentialid()#&siteid=#esapiEncode('url',rc.siteid)#">#LSDateFormat(credential.getLastUpdate(),session.dateKeyFormat)# #LSTimeFormat(credential.getLastUpdate(),"medium")#</a>
                            </td>
                        </tr>
                    </cfloop>
                </tbody>
                </table>
            </cfif>

            <h2>
                Listener Events
                <cfif isEditor>
                    <a class="btn" href="./?muraAction=cproxy.editevent&proxyid=#esapiEncode('url',rc.proxyid)#&siteid=&#esapiEncode('url',rc.siteid)#"><i class="mi-plus-circle"></i>  Add API Event</a>
                </cfif>
            </h2>
            <div class="help-block">Any changes to mapping listener events will take effect after the next application reload.</div>
            <cfset events=rc.bean.getEvents()>
            <cfif not events.hasNext()>
                <div class="help-block-empty">There currently are no events configured for this proxy.</div>
            <cfelse>
                <table class="mura-table-grid">
                <thead>
                    <tr>
                        <th class="actions"></th>
                        <th class="var-width">Event Name</th>
                        <th>Last Update</th>
                    </tr>
                </thead>
                <tbody class="nest">
                    <cfloop condition="events.hasNext()">
                        <cfset event=events.next()>
                        <tr>
                            <td class="actions">
                                <a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
                                <div class="actions-menu hide">
                                    <ul class="actions-list">
                                        <li class="edit">
                                            <a href="./?muraAction=cproxy.editevent&proxyid=#event.getproxyid()#&eventid=#event.geteventid()#&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-pencil"></i>Edit</a>
                                        </li>
                                        <cfif isEditor>
                                        <li class="delete">
                                            <a href="./?muraAction=cproxy.deleteevent&proxyid=#event.getproxyid()#&eventid=#event.geteventid()#&siteid=#esapiEncode('url',rc.siteid)##rc.$.renderCSRFTokens(context=event.geteventid(),format='url')#" onClick="return confirmDialog('Delete API Event?',this.href)"><i class="mi-trash"></i>Delete</a>
                                        </li>
                                        </cfif>
                                    </ul>
                                </div>
                            </td>
                            <td class="var-width">
                                <a title="Edit" href="./?muraAction=cproxy.editevent&proxyid=#rc.bean.getproxyid()#&eventid=#event.geteventid()#&siteid=#esapiEncode('url',rc.siteid)#">#esapiEncode('html',event.getName())#</a>
                            </td>
                            <td>
                                <a title="Edit" href="./?muraAction=cproxy.editevent&proxyid=#rc.bean.getproxyid()#&eventid=#event.geteventid()#&siteid=#esapiEncode('url',rc.siteid)#">#LSDateFormat(event.getLastUpdate(),session.dateKeyFormat)# #LSTimeFormat(event.getLastUpdate(),"medium")#</a>
                            </td>
                        </tr>
                    </cfloop>
                </tbody>
                </table>
            </cfif>

        </cfif>

        <cfif isEditor>
        <div class="mura-actions">
            <div class="form-actions">
                <cfif not rc.bean.exists()>
                <button class="btn mura-primary" type="button" onclick="submitForm(document.forms.form1,'add');"><i class="mi-check-circle"></i> Add</button>
                <cfelse>
                <button class="btn" type="button" onclick="confirmDialog('Delete API Proxy?','./?muraAction=cproxy.delete&proxyid=#rc.bean.getProxyid()#&siteid=#esapiEncode('url',rc.bean.getSiteID())##rc.$.renderCSRFTokens(context=rc.bean.getProxyID(),format="url")#');"><i class="mi-trash"></i> Delete</button>
                <button class="btn mura-primary" type="button" onclick="submitForm(document.forms.form1,'save');"><i class="mi-check-circle"></i> Update</button>
                </cfif>
                <input type="hidden" name="siteid" value="#rc.bean.getSiteID()#">
                <input type="hidden" name="proxyid" value="#rc.bean.getProxyID()#">
                #rc.$.renderCSRFTokens(context=rc.bean.getProxyid(),format="form")#
            </div>
        </div>
        </cfif>
        <br/><br/>
    </div> <!-- /.block-content -->
  </div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
</form>
</cfoutput>
