<cfparam name="objectparams.formid" default="#m.siteConfig('gatedFormID')#">
<cfparam name="objectparams.selector" default='a[href*="/gated/"]'>
<cfparam name="objectparams.assetlabel" default=''>
<cfparam name="objectparams.hideengaged" default="0">
<cfparam name="objectparams.instanceclass" default="">

<cfif isValid("uuid",objectparams.objectid)>
  <cfset objectparams.formid=objectparams.objectid>
</cfif>
<cfset hasModulePerm=rc.configuratormode neq 'backend' and rc.$.getBean('permUtility').getModulePerm('00000000000000000000000000000000004',rc.siteid)>

<cfoutput>
  <div class="mura-control-group">
    <label>CSS Selector (Optional)</label>
    <input type="text" name="selector" class="objectParam" value="#esapiEncode('html_attr',objectParams.selector)#"/>
  </div>
  <div class="mura-control-group">
    <label>Label (Optional)</label>
    <input type="text" name="assetlabel" class="objectParam" value="#esapiEncode('html_attr',objectParams.assetlabel)#"/>
  </div>
  <div class="mura-control-group">
  <cfset forms=m.getFeed('content').setSiteid(session.siteid).setType('Form').getIterator()>
    <label>
       Form Presented to User
    </label>
    <select name="formid" id="formid" class="objectParam" >
      <option value='unconfigured'>Select Form</option>
      <cfloop condition="forms.hasNext()">
       <cfset f=forms.next()>
       <option value="#f.getContentID()#"<cfif objectparams.formid eq f.getContentID()> selected</cfif>>#esapiEncode('html',f.getTitle())#</option>
       </cfloop>
     </select>
     <cfif hasModulePerm>
 			<button class="btn" id="editBtn">#application.rbFactory.getKeyValue(session.rb,'sitemanager.edit')#</button>
 		</cfif>
  </div>
  <div class="mura-control-group">
    <label>
        #application.rbFactory.getKeyValue(session.rb,'collections.cssclass')#
    </label>
    <input name="instanceclass" class="objectParam" type="text" value="#esapiEncode('html_attr',objectparams.instanceclass)#" maxlength="255">
    </div>
  </div>
  <!---
  <div class="mura-control-group">
    <label class="mura-control-label">#application.rbFactory.getKeyValue(session.rb,'cta.hideengaged')#</label>
    <select name="hideengaged" class="objectParam">
        <option value="0" <cfif not objectparams.hideengaged> selected</cfif>>False</option>
        <option value="1" <cfif objectparams.hideengaged> selected</cfif>>True</option>
    </select> 
  </div>
  --->
  <input type="hidden" class="objectParam" name="trimparams" value="true"/>
  <input type="hidden" class="objectParam" name="objectid" value=""/>

  <cfif hasModulePerm>
  <script>
  	$(function(){
  		function setEditOption(){
  			var selector=$('##formid');
  			var val=selector.val();
  			if(val && val !='unconfigured'){
  		 		$('##editBtn').html('<i class="mi-pencil"></i>Edit');
  		 	} else {
  		 		$('##editBtn').html('<i class="mi-plus-circle"></i> Create New');
  		 	}
  		}

  		$('##formid').change(setEditOption);
  		setEditOption();

  		$('##editBtn').click(function(){
  				frontEndProxy.post({
  					cmd:'openModal',
  					src:'?muraAction=cArch.editLive&contentId=' + $('##formid').val()  + '&type=Form&siteId=#esapiEncode("javascript",rc.siteid)#&instanceid=#esapiEncode("javascript",rc.instanceid)#&compactDisplay=true'
  					}
  				);
  		})

  	});
  </script>
  </cfif>
</cfoutput>
