<!--- license goes here --->

<cfset subType = application.classExtensionManager.getSubTypeByID(rc.subTypeID)>
<cfset rcsBean = $.getBean('relatedContentSet').loadBy(relatedContentSetID=rc.relatedContentSetID)>


<cfoutput>
<div class="mura-header">
	<h1><cfif len(rc.relatedContentSetID)>Edit<cfelse>Add</cfif> Related Content Set</h1>

	<div class="nav-module-specific btn-group">
	<a class="btn" href="./?muraAction=cExtend.listSubTypes&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-arrow-circle-left"></i> Back to Class Extensions</a>
	<a class="btn" href="./?muraAction=cExtend.listSets&subTypeID=#esapiEncode('url',rc.subTypeID)#&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-arrow-circle-left"></i> Back to Extension Overview</a>
	</div>

</div> <!-- /.mura-header -->

<div class="block block-constrain">
	<div class="block block-bordered">
	  <div class="block-content">

		<h2><i class="#subtype.getIconClass(includeDefault=true)# mi-lg"></i> #application.classExtensionManager.getTypeAsString(subType.getType())# / #esapiEncode('html',subType.getSubType())#</h2>

		<form novalidate="novalidate" name="form1" method="post" action="index.cfm" onsubit="return validateForm(this);">
			<div class="mura-control-group">
			<label>Related Content Set Name</label>
			<input name="name" type="text" value="#esapiEncode('html_attr',rcsBean.getName())#" required="true"/>
			</div>
			<cfset entities=$.getFeed('entity').where().prop('name').isNEQ('content').sort('displayName').getIterator()>
			<div class="mura-control-group">
			<label>Entity Type</label>
			<select name="entitytype" class="select">
				<option value="content"<cfif not len(rcsBean.getEntityName()) or rcsBean.getEntityName() eq 'content'>selected</cfif>>Site Content</option>
				<!---
				<option value="component"<cfif rcsBean.getEntityName() eq 'component'>selected</cfif>>Component</option>
				<option value="form"<cfif rcsBean.getEntityName() eq 'form'>selected</cfif>>Form</option>
				<option value="variation"<cfif rcsBean.getEntityName() eq 'form'>selected</cfif>>Variation</option>
				--->
				<cfloop condition="entities.hasNext()">
						<cfset entity=entities.next()>
						<cfif entity.getName() neq "content">
							<option value="#esapiEncode('html_attr',entity.getName())#"<cfif rcsBean.getEntityType() eq entity.getName()>selected</cfif>>#esapiEncode('html_attr',entity.getDisplayName())#</option>
						</cfif>
				</cfloop>
			</select>
			</div>
			<div class="entityname__content" style="display:none;">
				<cfset rsSubTypes=application.classExtensionManager.getSubTypes(siteID=rc.siteID,activeOnly=true) />
				<div class="mura-control-group availableSubTypesContainer" >
					<label>Allow users to add only specific subtypes?</label>
						<label class="radio inline" ><input name="hasAvailableSubTypes" type="radio" class="radio inline" value="1" <cfif len(rcsBean.getAvailableSubTypes())>checked </cfif>onclick="javascript:toggleDisplay2('rg',true);">Yes</label>
						<label class="radio inline"><input name="hasAvailableSubTypes" type="radio" class="radio inline" value="0" <cfif not len(rcsBean.getAvailableSubtypes())>checked </cfif>
						onclick="javascript:toggleDisplay2('rg',false);">No</label>
				</div>
				<div class="mura-control-group" id="rg"<cfif not len(rcsBean.getAvailableSubTypes())> style="display:none;"</cfif>>
						<label>Select Subtypes</label>
					<select name="availableSubTypes" size="8" multiple="multiple" class="multiSelect" id="availableSubTypes">
					<cfloop list="Page,Folder,Calendar,Gallery,File,Link" index="i">
						<option value="#i#/Default" <cfif listFindNoCase(rcsBean.getAvailableSubTypes(),'#i#/Default')> selected</cfif>>#i#/Default</option>
						<cfquery name="rsItemTypes" dbtype="query">
						select * from rsSubTypes where lower(type)='#lcase(i)#' and lower(subtype) != 'default'
						</cfquery>
						<cfset _AvailableSubTypes=rcsBean.getAvailableSubTypes()>
						<cfloop query="rsItemTypes">
						<option value="#i#/#rsItemTypes.subType#" <cfif listFindNoCase(_AvailableSubTypes,'#i#/#rsItemTypes.subType#')> selected</cfif>>#i#/#rsItemTypes.subType#</option>
						</cfloop>
					</cfloop>
					</select>
				</div>
			</div>

			<div class="mura-actions">
				<div class="form-actions">
					<cfif not len(rc.relatedContentSetID)>
						<cfset rc.relatedContentSetID=createUUID()>
						<button class="btn mura-primary" type="button" onclick="submitForm(document.forms.form1,'add');"><i class="mi-check-circle"></i>Add</button>
						<input type=hidden name="relatedContentSetID" value="#rc.relatedContentSetID#">
					<cfelse>
						<button class="btn" type="button" onclick="submitForm(document.forms.form1,'delete','Delete Related Content Set?');"><i class="mi-trash"></i>Delete</button>
						<button class="btn mura-primary" type="button" onclick="submitForm(document.forms.form1,'update');"><i class="mi-check-circle"></i>Update</button>
						<input type=hidden name="relatedContentSetID" value="#esapiEncode('html_attr',rcsBean.getRelatedContentSetID())#">
					</cfif>
				</div>
			</div>

			<input type="hidden" name="action" value="">
			<input name="muraAction" value="cExtend.updateRelatedContentSet" type="hidden">
			<input name="siteID" value="#esapiEncode('html_attr',rc.siteid)#" type="hidden">
			<input name="subTypeID" value="#subType.getSubTypeID()#" type="hidden">
			#rc.$.renderCSRFTokens(context=rc.relatedContentSetID,format="form")#
		</form>

		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->


<script>
	Mura(function(){

		function handleEntityChange(){
			if(Mura('select[name="entityname"]').val() == 'content'){
				Mura('.entityname__content').show();
			} else {
				Mura('.entityname__content').hide();
			}
		}

		Mura('select[name="entityname"]').change(handleEntityChange);

		handleEntityChange();
	})
</script>
</cfoutput>
