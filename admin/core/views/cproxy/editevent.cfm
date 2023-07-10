<cfparam name="rc.eventid" default="">
<cfset isEditor=listFindNoCase('editor,module',rc.$.getBean('permUtility').getModulePermType('00000000000000000000000000000000020',rc.siteid))>

<cfif not len(rc.eventid)>
    <cfset rc.eventid=createUUID()>
</cfif>

<cfif not isdefined('rc.bean') or not isObject(rc.bean)>
    <cfset rc.bean=$.getBean('proxyEvent').loadBy(eventid=rc.eventid)/>
</cfif>
<cfoutput>
<div class="mura-header">
<cfif not rc.bean.exists()>
    <h1>Add API Event</h1>
<cfelse>
    <h1>Edit API Event</h1>
</cfif>

<div class="nav-module-specific btn-group">
    <a class="btn" href="./?muraAction=cproxy.edit&proxyid=#esapiEncode('url',rc.proxyid)#&siteid=&#esapiEncode('url',rc.siteid)#"><i class="mi-arrow-circle-left"></i>  Back to API Proxy</a>
</div>
</div> <!-- /.mura-header -->

<cfif not structIsEmpty(rc.bean.getErrors())>
<div class="alert alert-error"><span>#application.utility.displayErrors(rc.bean.getErrors())#</span></div>
</cfif>

<form novalidate="novalidate" action="./?muraAction=cproxy.saveevent" method="post" name="form1" onsubmit="return validateForm(this);">
<div class="block block-constrain">
    <div class="block block-bordered">
    <div class="block-content">
        <span id="token-container"></span>
        <div class="mura-control-group">
            <label>Name</label>
            <input name="name" type="text" required="true" message="The Name attribute is required." value="#esapiEncode('html_attr',rc.bean.getName())#" maxlength="200">
        </div>

        <cfif isEditor>
        <div class="mura-actions">
            <div class="form-actions">
                <cfif not rc.bean.exists()>
                <button class="btn mura-primary" type="button" onclick="submitForm(document.forms.form1,'add');"><i class="mi-check-circle"></i> Add</button>
                <cfelse>
                <button class="btn" type="button" onclick="confirmDialog('Delete API Event?','./?muraAction=cproxy.deleteevent&proxyid=#rc.bean.getproxyid()#&eventid=#rc.bean.geteventid()#&siteid=#esapiEncode('url',rc.bean.getSiteID())##rc.$.renderCSRFTokens(context=rc.bean.geteventid(),format="url")#');"><i class="mi-trash"></i> Delete</button>
                <button class="btn mura-primary" type="button" onclick="submitForm(document.forms.form1,'save');"><i class="mi-check-circle"></i> Update</button>
                </cfif>
                <input type="hidden" name="siteid" value="#esapiEncode('html_attr',rc.bean.getSiteID())#">
                <input type="hidden" name="proxyid" value="#esapiEncode('html_attr',rc.proxyid)#">
                <input type="hidden" name="eventid" value="#esapiEncode('html_attr',rc.bean.geteventid())#">
                #rc.$.renderCSRFTokens(context=rc.bean.geteventid(),format="form")#
            </div>
        </div>
        </cfif>

    </div> <!-- /.block-content -->
</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
</form>
</cfoutput>
