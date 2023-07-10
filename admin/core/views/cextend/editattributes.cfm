<!--- license goes here --->
<cfinclude template="js.cfm">

<cfset subType=application.classExtensionManager.getSubTypeByID(rc.subTypeID) />
<cfset extendSet=subType.loadSet(rc.extendSetID)/>
<cfset attributesArray=extendSet.getAttributes() />

<cfoutput>
<div class="mura-header">
  <h1>Manage Extended Attribute Set</h1>
    <div class="nav-module-specific btn-group">
     <div class="btn-group">
    <a class="btn dropdown-toggle" data-toggle="dropdown" href="##">
             <i class="mi-arrow-circle-left"></i> Back <span class="caret"></span>
     </a>
     <ul class="dropdown-menu">
        <li><a href="./?muraAction=cExtend.listSubTypes&siteid=#esapiEncode('url',rc.siteid)#">Back to Class Extensions</a></li>
        <li><a href="./?muraAction=cExtend.listSets&subTypeID=#esapiEncode('url',rc.subTypeID)#&siteid=#esapiEncode('url',rc.siteid)#">Back to Class Extension Overview</a></li>
     </ul>
     </div>
     <div class="btn-group">
     <a class="btn dropdown-toggle" data-toggle="dropdown" href="##">
             <i class="mi-pencil"></i> Edit <span class="caret"></span>
     </a>
     <ul class="dropdown-menu">
        <li><a href="./?muraAction=cExtend.editSubType&subTypeID=#esapiEncode('url',rc.subTypeID)#&siteid=#esapiEncode('url',rc.siteid)#">Class Extension</a></li>
        <li><a href="./?muraAction=cExtend.editSet&subTypeID=#esapiEncode('url',rc.subTypeID)#&extendSetID=#esapiEncode('url',rc.extendSetID)#&siteid=#esapiEncode('url',rc.siteid)#">Attribute Set</a></li>
     </ul>
     </div>
    </div>

</div> <!-- /.mura-header -->

<div class="block block-constrain">
    <div class="block block-bordered">
      <div class="block-content">      
      <h2><i class="#subtype.getIconClass(includeDefault=true)#"></i> #application.classExtensionManager.getTypeAsString(subType.getType())# / #subType.getSubType()#</h2>

      <h3><strong>Attributes Set:</strong> #extendSet.getName()#</h3>

      <cfset newAttribute=extendSet.getAttributeBean() />
      <cfset newAttribute.setSiteID(rc.siteID) />
      <cfset newAttribute.setOrderno(arrayLen(attributesArray)+1) />
      <cf_dsp_attribute_form attributesArray="#attributesArray#" attributeBean="#newAttribute#" action="add" subTypeID="#rc.subTypeID#" formName="newFrm" muraScope="#rc.$#">

      <cfif arrayLen(attributesArray)>
      <ul id="attributesList" class="attr-list">
      <cfloop from="1" to="#arrayLen(attributesArray)#" index="a">	
      <cfset attributeBean=attributesArray[a]/>
      <cfoutput>
	<li test attributeID="#attributeBean.getAttributeID()#">
      		<span id="handle#a#" class="handle" style="display:none;"><i class="mi-arrows"></i></span>
		<p>#attributeBean.getName()#</p>
		<div class="btns">
      		<a title="Edit" href="javascript:;" id="editFrm#a#open" onclick="jQuery('##editFrm#a#container').slideDown();this.style.display='none';jQuery('##editFrm#a#close').show();;$('li[attributeID=#attributeBean.getAttributeID()#]').addClass('attr-edit');return false;"><i class="mi-pencil"></i></a>
      		<a title="Edit" href="javascript:;" style="display:none;" id="editFrm#a#close" onclick="jQuery('##editFrm#a#container').slideUp();this.style.display='none';jQuery('##editFrm#a#open').show();$('li[attributeID=#attributeBean.getAttributeID()#]').removeClass('attr-edit');return false;"><i class="mi-check"></i></a>
      		<a title="Delete" href="./?muraAction=cExtend.updateAttribute&action=delete&subTypeID=#esapiEncode('url',rc.subTypeID)#&extendSetID=#attributeBean.getExtendSetID()#&siteid=#esapiEncode('url',rc.siteid)#&attributeID=#attributeBean.getAttributeID()##rc.$.renderCSRFTokens(context=attributeBean.getAttributeID(),format='url')#" onClick="return confirmDialog('Delete the attribute #esapiEncode("javascript","'#attributeBean.getname()#'")#?',this.href)"><i class="mi-trash"></i></a>
		</div>
	<div style="display:none;" id="editFrm#a#container">
		<cf_dsp_attribute_form attributeBean="#attributeBean#" action="edit" subTypeID="#rc.subTypeID#" formName="editFrm#a#" muraScope="#rc.$#">
	</div>
	</li>
      </cfoutput>
      </cfloop>
      </ul>

      <cfelse>
      <div class="help-block-empty">This set has no attributes.</div>
      </cfif>
      </div> <!-- /.block-content -->
    </div> <!-- /.block-bordered -->
  </div> <!-- /.block-constrain -->
</cfoutput>