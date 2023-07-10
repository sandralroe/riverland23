<cfparam name="rc.providerid" default="">
<cfset providersList = "Google,Facebook,GitHub,Microsoft"/>
<cfset providersAdded=$.getFeed('oauthProvider').setSiteID(session.siteid).getIterator()>
<cfset providersAddedList = ""/>
<cfloop condition="providersAdded.hasNext()">
    <cfset providerAdded=providersAdded.next()>
    <cfset providersAddedList = listAppend(providersAddedList, providerAdded.getName())/>
</cfloop>

<cfif not len(rc.providerid)>
  <cfset rc.providerid=createUUID()>
</cfif>

<cfif not isdefined('rc.bean') or not isObject(rc.bean)>
    <cfset rc.bean=$.getBean('oauthprovider').loadBy(providerid=rc.providerid)/>
</cfif>
<cfoutput>
<div class="mura-header">
  <cfif not rc.bean.exists()>
	<h1>Add OAuth Provider</h1>
  <cfelse>
	<h1>Edit OAuth Provider</h1>
  </cfif>

  <div class="nav-module-specific btn-group">
      <a class="btn" href="./?muraAction=coauthprovider.list&siteid=&#esapiEncode('url',rc.siteid)#"><i class="mi-arrow-circle-left"></i>  Back to OAuth Providers</a>
  </div>
</div> <!-- /.mura-header -->

<cfif not structIsEmpty(rc.bean.getErrors())>
  <div class="alert alert-error"><span>#application.utility.displayErrors(rc.bean.getErrors())#</span></div>
<cfelseif rc.muraAction eq "core:coauthprovider.save">
    <div class="alert alert-success"><span>This OAuth Provider has been saved.</span></div>
</cfif>

<form novalidate="novalidate" action="./?muraAction=coauthprovider.save" method="post" name="form1" onsubmit="return validateForm(this);">
<div class="block block-constrain">
    <div class="block block-bordered">
      <div class="block-content">
        <span id="token-container"></span>
        <div class="mura-control-group">
            <label>Provider</label>
            <cfif rc.bean.getIsNew()>
                <select name="name" required="true" message="The Name attribute is required.">
                    <option></option>
                    <cfloop list="#providersList#" index="providerIndex">
                        <cfif not listFindNoCase(providersAddedList, providerIndex)>
                            <option value="#providerIndex#">#providerIndex#</option>
                        </cfif>
                    </cfloop>
                </select>
            <cfelse>
                <input name="name" type="text" required="true" message="The Provider attribute is required." value="#esapiEncode('html_attr',rc.bean.getName())#" maxlength="50" readonly="readonly">
            </cfif>
        </div>

        <div class="mura-control-group">
            <label>Client Id</label>
            <input name="clientid" type="text" required="true" message="The Client Id attribute is required." value="#esapiEncode('html_attr',rc.bean.getClientId())#" maxlength="150">
        </div>

        <div class="mura-control-group">
            <label>Client Secret</label>
            <input name="clientsecret" type="text" required="true" message="The Client Secret attribute is required." value="#esapiEncode('html_attr',rc.bean.getClientSecret())#" maxlength="150">
        </div>

        <div class="mura-actions">
            <div class="form-actions">
                <cfif not rc.bean.exists()>
                <button class="btn mura-primary" type="button" onclick="submitForm(document.forms.form1,'add');"><i class="mi-check-circle"></i> Add</button>
                <cfelse>
                <button class="btn" type="button" onclick="confirmDialog('Delete OAuth Provider?','./?muraAction=coauthprovider.delete&providerid=#rc.bean.getproviderid()#&siteid=#esapiEncode('url',rc.bean.getSiteID())##rc.$.renderCSRFTokens(context=rc.bean.getprovideriD(),format="url")#');"><i class="mi-trash"></i> Delete</button>
                <button class="btn mura-primary" type="button" onclick="submitForm(document.forms.form1,'save');"><i class="mi-check-circle"></i> Update</button>
                </cfif>
                <input type="hidden" name="siteid" value="#rc.bean.getSiteID()#">
                <input type="hidden" name="providerid" value="#rc.bean.getprovideriD()#">
                #rc.$.renderCSRFTokens(context=rc.bean.getproviderid(),format="form")#
            </div>
        </div>
        <br/><br/>
    </div> <!-- /.block-content -->
  </div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
</form>
</cfoutput>
