<!--- license goes here --->
<cfset event=request.event>
<cfinclude template="js.cfm">
<cfoutput>
  <div class="mura-header">
  <h1><cfif rc.categoryID neq ''>#application.rbFactory.getKeyValue(session.rb,'categorymanager.editcontentcategory')#<cfelse>#application.rbFactory.getKeyValue(session.rb,'categorymanager.addcontentcategory')#</cfif></h1>
  <cfinclude template="dsp_secondary_menu.cfm">
</div> <!-- /.mura-header -->

<cfif not structIsEmpty(rc.categoryBean.getErrors())>
  <div class="alert alert-error"><span>#application.utility.displayErrors(rc.categoryBean.getErrors())#</span></div>
</cfif>

<div class="block block-constrain">
    <div class="block block-bordered">
      <div class="block-content">

      <cfif len(trim(application.pluginManager.renderEvent("onCategoryEditMessageRender", event)))>
        <span id="msg">#application.pluginManager.renderEvent("onCategoryEditMessageRender", event)#</span>
      </cfif>

      <form novalidate="novalidate" action="./?muraAction=cCategory.update&siteid=#esapiEncode('url',rc.siteid)#" method="post" name="form1" onsubmit="return validate(this);">
      #$.renderEvent("onCategoryBasicTopRender")#

      <div class="mura-control-group">
        <label>#application.rbFactory.getKeyValue(session.rb,'categorymanager.name')#</label>
        <input type="text" name="name" required="true" message="#application.rbFactory.getKeyValue(session.rb,'categorymanager.namerequired')#" value="#esapiEncode('html_attr',rc.categoryBean.getName())#" maxlength="50">
      </div>

      <div class="mura-control-group">
        <label>#application.rbFactory.getKeyValue(session.rb,'categorymanager.urltitle')#</label>
    <input type="text" name="urltitle" value="#esapiEncode('html_attr',rc.categoryBean.getURLTitle())#" maxlength="255">
  </div>

      <div class="mura-control-group">
      <label>#application.rbFactory.getKeyValue(session.rb,'categorymanager.parentcategory')#</label>
    <select name="parentID">
      <option value="">#application.rbFactory.getKeyValue(session.rb,'categorymanager.primary')#</option>
     <cf_dsp_parents siteID="#rc.siteID#" categoryID="#rc.categoryID#" parentID="" actualParentID="#rc.parentID#" nestLevel="1" >
      </select>
    </div>

      <div class="mura-control-group">
        <label>CategoryID</label>
    <cfif len(rc.categoryID) and len(rc.categoryBean.getCategoryID())>
      #rc.categoryBean.getCategoryID()#
    <cfelse>
      #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.notavailable')#
    </cfif>
  </div>

      <div class="mura-control-group">
        <label>#application.rbFactory.getKeyValue(session.rb,'categorymanager.isinterestgroup')#</label>
  	<label class="radio inline" for="isInterestGroupYes">
      <input name="isInterestGroup" id="isInterestGroupYes" type="radio" value="1" <cfif rc.categoryBean.getIsInterestGroup()>checked</cfif>>
      #application.rbFactory.getKeyValue(session.rb,'categorymanager.yes')#
    </label>
    <label class="radio inline" for="isInterestGroupNo">
      <input name="isInterestGroup" id="isInterestGroupNo" type="radio" value="0" <cfif not rc.categoryBean.getIsInterestGroup()>checked</cfif>>
      #application.rbFactory.getKeyValue(session.rb,'categorymanager.no')#
    </label>
      </div>

      <div class="mura-control-group">
        <label>#application.rbFactory.getKeyValue(session.rb,'categorymanager.allowcontentassignments')#</label>
  	<label class="radio inline" for="isOpenYes">
      <input name="isOpen" id="isOpenYes" type="radio" value="1" <cfif rc.categoryBean.getIsOpen()>checked</cfif>> #application.rbFactory.getKeyValue(session.rb,'categorymanager.yes')#
    </label>
    <label class="radio inline" for="isOpenNo">
     <input name="isOpen" id="isOpenNo" type="radio" value="0" <cfif not rc.categoryBean.getIsOpen()>checked</cfif>> #application.rbFactory.getKeyValue(session.rb,'categorymanager.no')#
    </label>
      </div>

      <div class="mura-control-group">
        <label>#application.rbFactory.getKeyValue(session.rb,'categorymanager.isfeatureable')#</label>
  	<label class="radio inline" for="isfeatureableYes">
      <input name="isfeatureable" id="isfeatureableYes" type="radio" value="1" <cfif rc.categoryBean.getIsfeatureable()>checked</cfif>>
      #application.rbFactory.getKeyValue(session.rb,'categorymanager.yes')#
    </label>
    <label class="radio inline" for="isfeatureableNo">
      <input name="isfeatureable" id="isfeatureableNo" type="radio" value="0" <cfif not rc.categoryBean.getIsfeatureable()>checked</cfif>>
      #application.rbFactory.getKeyValue(session.rb,'categorymanager.no')#
    </label>
      </div>

      <div class="mura-control-group">
        <label>Active?</label>
    <label class="radio inline" for="isActiveYes">
      <input name="isActive" id="isActiveYes" type="radio" value="1" <cfif rc.categoryBean.getIsActive()>checked</cfif>>
      #application.rbFactory.getKeyValue(session.rb,'categorymanager.yes')#
    </label>
    <label class="radio inline" for="isActiveNo">
      <input name="isActive" id="isActiveNo" type="radio" value="0" <cfif not rc.categoryBean.getIsActive()>checked</cfif>>
      #application.rbFactory.getKeyValue(session.rb,'categorymanager.no')#
    </label>
      </div>

      <div class="mura-control-group">
        <label>#application.rbFactory.getKeyValue(session.rb,'categorymanager.restrictaccess')#</label>
    	<select name="restrictgroups" size="8" multiple="multiple" id="restrictGroups">
	       <optgroup label="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.globalsettings'))#">
	       <option value="" <cfif rc.categoryBean.getrestrictgroups() eq ''>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.allowall')#</option>
	       <option value="RestrictAll" <cfif rc.categoryBean.getrestrictgroups() eq 'RestrictAll'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.restrictall')#</option>
	       </optgroup>
	       <cfquery dbtype="query" name="rsGroups">select * from rc.rsrestrictgroups where isPublic=1</cfquery>
      	<cfif rsGroups.recordcount>
      	<optgroup label="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'user.membergroups'))#">
      	<cfloop query="rsGroups">
      	<option value="#rsGroups.groupname#" <cfif listFindNoCase(rc.categoryBean.getrestrictgroups(),rsGroups.groupname)>Selected</cfif>>#rsGroups.groupname#</option>
      	</cfloop>
      	</optgroup>
      	</cfif>
      	<cfquery dbtype="query" name="rsGroups">select * from rc.rsrestrictgroups where isPublic=0</cfquery>
      	<cfif rsGroups.recordcount>
      	<optgroup label="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'user.adminusergroups'))#">
      	<cfloop query="rsGroups">
      	<option value="#rsGroups.groupname#" <cfif listFindNoCase(rc.categoryBean.getrestrictgroups(),rsGroups.groupname)>Selected</cfif>>#rsGroups.groupname#</option>
      	</cfloop>
      	</optgroup>
      	</cfif>
	   </select>
	</div>

      	<div class="mura-control-group">
      	  <label>
	    #application.rbFactory.getKeyValue(session.rb,'categorymanager.notes')#
	  </label>
	    <textarea name="notes" rows="8">#esapiEncode('html',rc.categoryBean.getNotes())#</textarea>
	  </div>

   #$.renderEvent("onCategoryBasicBottomRender")#
    <div class="mura-actions">
      <div class="form-actions">
        <cfif rc.categoryID eq ''>
          <button type="button" class="btn mura-primary" onclick="submitForm(document.forms.form1,'add');"><i class="mi-check-circle"></i>#application.rbFactory.getKeyValue(session.rb,'categorymanager.add')#</button>
          <input type=hidden name="categoryID" value="#rc.categoryBean.getCategoryID()#">
          <input type="hidden" name="action" value="add">
        <cfelse>
          <button type="button" class="btn" onclick="submitForm(document.forms.form1,'delete','#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'categorymanager.deleteconfirm'))#');"><i class="mi-trash"></i>#application.rbFactory.getKeyValue(session.rb,'categorymanager.delete')#</button>
          <button class="btn mura-primary" onclick="submitForm(document.forms.form1,'update');"><i class="mi-check-circle"></i>#application.rbFactory.getKeyValue(session.rb,'categorymanager.update')#</button>
          <input type=hidden name="categoryID" value="#rc.categoryBean.getCategoryID()#">
          <input type="hidden" name="action" value="update">
        </cfif>

        #rc.$.renderCSRFTokens(context=rc.categoryBean.getCategoryID(),format="form")#
      </div>
    </div>
      </form>
      </cfoutput>

      </div> <!-- /.block-content -->
    </div> <!-- /.block-bordered -->
  </div> <!-- /.block-constrain -->
