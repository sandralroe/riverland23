<!--- license goes here --->
<cfscript>
	if(server.coldfusion.productname != 'ColdFusion Server'){
		backportdir='';
		include "/mura/backport/backport.cfm";
	} else {
		backportdir='/mura/backport/';
		include "#backportdir#backport.cfm";
	}
</cfscript>
<cfset typeList="TextBox,TextArea,HTMLEditor,MarkdownEditor,SelectBox,MultiSelectBox,RadioGroup,File,Hidden"/>
<cfoutput>


<ul class="nav nav-pills">

<cfif attributes.action eq "add">
<li>
<a href="javascript:;" id="#esapiEncode('html_attr',attributes.formName)#open" class="btn" onclick="$('###esapiEncode('html',attributes.formName)#container').slideDown();this.style.display='none';$('###esapiEncode('html',attributes.formName)#close').show();return false;"><i class="mi-plus-circle"></i> Add New Attribute</a></li>
<li><a href="javascript:;" class="btn" style="display:none;" id="#esapiEncode('html_attr',attributes.formName)#close" onclick="$('###esapiEncode('html',attributes.formName)#container').slideUp();this.style.display='none';$('###esapiEncode('html',attributes.formName)#open').show();return false;"><i class="mi-minus-circle"></i> Close</a></li>
<cfif isDefined('attributes.attributesArray') and ArrayLen(attributes.attributesArray)>
<li><a href="javascript:;" class="btn" style="display:none;" id="saveSort" onclick="extendManager.saveAttributeSort('attributesList');return false;"><i class="mi-check"></i> Save Order</a></li>
<li><a href="javascript:;" class="btn" id="showSort" onclick="extendManager.showSaveSort('attributesList');return false;"><i class="mi-arrows"></i> Reorder</a></li>
</cfif>
</cfif>
</ul>

<cfif attributes.action eq "add">
<div style="display:none;" id="#esapiEncode('html_attr',attributes.formName)#container" class="attr-add">
</cfif>
<form novalidate="novalidate" method="post" name="#esapiEncode('html_attr',attributes.formName)#" action="index.cfm" onsubmit="return validateForm(this);">
<cfif attributes.action neq "add">
<div class="mura-control-group">
	<label>Attribute ID: #attributes.attributeBean.getAttributeID()#</label>
</div>
</cfif>

<div class="mura-control-group">
	<label>Name (No spaces)</label>
		<input type="text" name="name" data-required="true" value="#esapiEncode('html_attr',attributes.attributeBean.getName())#" onchange="removePunctuation(this);" />
</div>
<div class="mura-control-group">
	<label>Label</label>
		<input type="text" name="label" value="#esapiEncode('html_attr',attributes.attributeBean.getLabel())#" />
</div>
<div class="mura-control-group">
	<label>Input Type</label>
		<select name="type">
		<cfloop list="#typelist#" index="t">
			<option value="#t#" <cfif attributes.attributeBean.getType() eq t>selected</cfif>>#t#</option>
		</cfloop>
		</select>
</div>

<div class="mura-control-group">
	<label>Default Value</label>
		<input type="text" name="defaultValue"  value="#esapiEncode('html_attr',attributes.attributeBean.getDefaultvalue())#"  maxlength="100" />
</div>
<div class="mura-control-group">
	<label>Tooltip</label>
		<input type="text" name="hint" value="#esapiEncode('html_attr',attributes.attributeBean.getHint())#" />
</div>
<div class="mura-control-group">
	<label>Required</label>
		<select name="required">
			<option value="false" <cfif attributes.attributeBean.getRequired() eq "false">selected</cfif>>False</option>
			<option value="true" <cfif attributes.attributeBean.getRequired() eq "true">selected</cfif>>True</option>
		</select>
</div>

<div class="mura-control-group">
	<label>Validate</label>
		<select name="validation">
			<option value="" <cfif attributes.attributeBean.getValidation() eq "">selected</cfif>>None</option>
			<option value="Date" <cfif attributes.attributeBean.getValidation() eq "Date">selected</cfif>>Date</option>
			<option value="DateTime" <cfif attributes.attributeBean.getValidation() eq "DateTime">selected</cfif>>DateTime</option>
			<option value="Numeric" <cfif attributes.attributeBean.getValidation() eq "Numeric">selected</cfif>>Numeric</option>
			<option value="Email" <cfif attributes.attributeBean.getValidation() eq "Email">selected</cfif>>Email</option>
			<option value="Regex" <cfif attributes.attributeBean.getValidation() eq "Regex">selected</cfif>>Regex</option>
			<option value="Color" <cfif attributes.attributeBean.getValidation() eq "Color">selected</cfif>>Color</option>
			<option value="URL" <cfif attributes.attributeBean.getValidation() eq "URL">selected</cfif>>URL</option>
		</select>
</div>

<div class="mura-control-group">
	<label>Regex</label>
		<input type="text" name="regex"  value="#esapiEncode('html_attr',attributes.attributeBean.getRegex())#" />
</div>

<div class="mura-control-group">
	<label>Validation Message</label>
		<input type="text" name="message"  value="#esapiEncode('html_attr',attributes.attributeBean.getMessage())#" />
</div>

<div class="mura-control-group">
	<label>Option List ("^" Delimiter)</label>
		<input type="text" name="optionList"  value="#esapiEncode('html_attr',attributes.attributeBean.getOptionList())#" />
</div>

<div class="mura-control-group">
	<label>Option Label List (Optional, "^" Delimiter)</label>
	<input type="text" name="optionLabelList"  value="#esapiEncode('html_attr',attributes.attributeBean.getOptionLabelList())#" />
</div>

<div class="mura-control-group">
	<label>For administrative Use Only?</label>
		<label class="radio inline"><input name="adminonly" type="radio" class="radio inline" value="1" <cfif attributes.attributeBean.getAdminOnly() eq 1 >Checked</cfif>>Yes</label>
		<label class="radio inline"><input name="adminonly" type="radio" class="radio inline" value="0" <cfif attributes.attributeBean.getAdminOnly() eq 0 >Checked</cfif>>No</label>
</div>

<div class="mura-actions">
	<div class="form-actions">
	<cfif attributes.action eq "add">
		<button class="btn mura-primary" type="button" onclick="submitForm(document.forms.#esapiEncode('html',attributes.formName)#,'add');"><i class="mi-check-circle"></i>Add</button>
		<button class="btn" type="button" onclick="$('###esapiEncode('html',attributes.formName)#container').slideUp();$('###esapiEncode('html',attributes.formName)#close').hide();$('###esapiEncode('html',attributes.formName)#open').show();"><i class="mi-times-circle"></i>Cancel</button>
	<cfelse>
		<button class="btn mura-primary" type="button" onclick="submitForm(document.forms.#esapiEncode('html',attributes.formName)#,'update');"><i class="mi-check-circle"></i>Update</button>
		<button class="btn" type="button" onclick="submitForm(document.forms.#esapiEncode('html',attributes.formName)#,'delete','Delete Attribute?');"><i class="mi-trash"></i>Delete</button>
		<button class="btn" type="button" onclick="$('###esapiEncode('html',attributes.formName)#container').slideUp();$('###esapiEncode('html',attributes.formName)#close').hide();$('###esapiEncode('html',attributes.formName)#open').show();$('li[attributeid=#attributes.attributeBean.getAttributeID()#]').removeClass('attr-edit');"><i class="mi-times-circle"></i>Cancel</button>
	</cfif>
	</div>
</div>

<input name="orderno" type="hidden" value="#attributes.attributeBean.getOrderno()#"/>
<input name="isActive" type="hidden" value="#attributes.attributeBean.getIsActive()#"/>
<input name="siteID" type="hidden" value="#attributes.attributeBean.getSiteID()#"/>
<input name="muraAction" type="hidden" value="cExtend.updateAttribute"/>
<input name="action" type="hidden" value="#esapiEncode('html_attr',attributes.action)#"/>
<input name="extendSetID" type="hidden" value="#esapiEncode('html_attr',attributes.attributeBean.getExtendSetID())#"/>
<input name="subTypeID" type="hidden" value="#esapiEncode('html_attr',attributes.subTypeID)#"/>
<input name="attributeID" type="hidden" value="#attributes.attributeBean.getAttributeID()#"/>
#attributes.muraScope.renderCSRFTokens(context=attributes.attributeBean.getAttributeID(),format="form")#
</form><cfif attributes.action eq "add"></div></cfif>
</cfoutput>
