<!--- license goes here --->

<cfset subType=application.classExtensionManager.getSubTypeByID(rc.subTypeID)>
<cfset extendSetBean=subType.loadSet(rc.extendSetID) />
<cfoutput>

<div class="mura-header">
	<h1><cfif len(rc.extendSetID)>Edit<cfelse>Add</cfif> Attribute Set</h1>

	<div class="nav-module-specific btn-group">
		<div class="btn-group">
		  <a class="btn dropdown-toggle" data-toggle="dropdown" href="##"><i class="mi-arrow-circle-left"></i> Back <span class="caret"></span></a>
		   <ul class="dropdown-menu">
		      <li><a href="./?muraAction=cExtend.listSubTypes&siteid=#esapiEncode('url',rc.siteid)#">Back to Class Extensions</a></li>
		      <li><a href="./?muraAction=cExtend.listSets&subTypeID=#esapiEncode('url',rc.subTypeID)#&siteid=#esapiEncode('url',rc.siteid)#">Back to Class Extension Overview</a></li>
		   </ul>
		</div>
	</div>

</div> <!-- /.mura-header -->

<div class="block block-constrain">
		<div class="block block-bordered">
		  <div class="block-content">

			<h2><i class="#subtype.getIconClass(includeDefault=true)# mi-lg"></i> #application.classExtensionManager.getTypeAsString(subType.getType())# / #subType.getSubType()#</h2>

			<form novalidate="novalidate" name="form1" method="post" action="index.cfm" onsubit="return validateForm(this);">


			<div class="mura-control-group">
				<label>Attribute Set Name</label>
	<input name="name" type="text" value="#esapiEncode('html_attr',extendSetBean.getName())#" required="true"/>
	</div>

			<cfif subType.getType() neq "Custom">
				<div class="mura-control-group">
					<label>Container (Tab)</label>
			<select name="container">
				<option value="Default">Extended Attributes</option>
				<cfif listFindNoCase('Page,Folder,File,Gallery,Calender,Link,Base',subType.getType())>
					<cfloop list="#application.contentManager.getTabList()#" index="t">
					<cfif t neq 'Extended Attributes' and t neq 'SEO'>
					<option value="#t#"<cfif extendSetBean.getContainer() eq t> selected</cfif>>
					</cfif>
	      			#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.tabs.#REreplace(t, "[^\\\w]", "", "all")#")#
	      			</option>
	      		</cfloop>
	      		<cfelseif listFindNoCase('Component,Form',subType.getType())>
					<cfloop list="Basic,Categorization" index="t">
					<option value="#t#"<cfif extendSetBean.getContainer() eq t> selected</cfif>>
	      			#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.tabs.#REreplace(t, "[^\\\w]", "", "all")#")#
	      			</option>
	      		</cfloop>
	      		<cfelseif subType.getType() neq 'site'>
					<option value="Basic"<cfif extendSetBean.getContainer() eq "Basic"> selected</cfif>>Basic Tab</option>
				</cfif>
				<option value="Custom"<cfif extendSetBean.getContainer() eq "Custom"> selected</cfif>>Custom UI</option>
			</select>
		</div>
			<cfelse>
	<input name="container" value="Custom" type="hidden"/>
			</cfif>

		<div class="mura-actions">
			<div class="form-actions">
				<cfif not len(rc.extendSetID)>
					<cfset rc.extendSetID=createuuid()>
					<button class="btn mura-primary" type="button" onclick="submitForm(document.forms.form1,'add');"><i class="mi-check-circle"></i>Add</button>
					<input type=hidden name="extendSetID" value="#esapiEncode('html_attr',rc.extendSetID)#">
				<cfelse>
					<button class="btn" type="button" onclick="submitForm(document.forms.form1,'delete','Delete Attribute Set?');"><i class="mi-trash"></i>Delete</button>
					<button class="btn mura-primary" type="button" onclick="submitForm(document.forms.form1,'update');"><i class="mi-check-circle"></i>Update</button>
					<input type=hidden name="extendSetID" value="#esapiEncode('html_attr',extendSetBean.getExtendSetID())#">
				</cfif>
			</div>
		</div>

			<input type="hidden" name="action" value="">
			<input name="muraAction" value="cExtend.updateSet" type="hidden">
			<input name="siteID" value="#esapiEncode('html_attr',rc.siteid)#" type="hidden">
			<input name="subTypeID" value="#esapiEncode('html_attr',subType.getSubTypeID())#" type="hidden">
			#rc.$.renderCSRFTokens(context=rc.extendSetID,format="form")#
			</form>

		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
</cfoutput>
