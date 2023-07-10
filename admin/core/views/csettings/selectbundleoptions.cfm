 <!--- license goes here --->
 <cfoutput>
  <script>
function submitBundle(){
	if(jQuery("##saveFileDir").val() != ''){
		var message="Create and Save Bundle to Server?";
	} else {
		var message="Create and Download Bundle File?";
	}
	jQuery("##alertDialogMessage").html(message);
	jQuery("##alertDialog").dialog({
			resizable: false,
			modal: true,
			buttons: {
				'No': function() {
					jQuery(this).dialog('close');
				},
        Yes:
          {click: function() {
            jQuery(this).dialog('close');
            //jQuery(".form-actions").hide();
            //jQuery("##actionIndicator").show();
            document.pluginSelectFrm.submit();
            }
          , text: 'Yes'
          , class: 'mura-primary'
        } // /Yes
			}
		});

	return false;
}

checked=false;
function checkAll (form) {

    if (checked == false) {
        checked = true
    }
    else {
        checked = false
    }

    jQuery('input[name="moduleID"]').attr("checked",checked);

}
</script>

<div class="mura-header">
  <h1>Create Site Bundle</h1>
  <div class="nav-module-specific btn-group">
      <a class="btn" href="./?muraAction=cSettings.editSite&siteID=#esapiEncode('url',rc.siteID)#"><i class="mi-arrow-circle-left"></i> Back to Site Settings</a>
  </div>
</div> <!--- /.mura-header --->

<div class="block block-constrain">


  <form id="pluginSelectFrm" name="pluginSelectFrm" action="./index.cfm">


    <div class="block block-bordered">
    <div class="block-content">


    <div class="mura-control-group">
      <label>Include in Site Bundle:</label>

  <div class="help-block">A Bundle includes a Site's architecture &amp; content, all rendering files (display objects, themes, javascript, etc.) and any of the items you select below. </div>

      <label class="checkbox"><input type="checkbox" checked name="includeStructuredAssets" value="true">Files Associated with Content</label>
      
      <label class="checkbox"><input type="checkbox" name="includeTrash" value="true">Items in Trash Bin</label>

      <label class="checkbox"><input type="checkbox" name="includeVersionHistory" value="true">Content Version Histories</label>

      <label class="checkbox"><input type="checkbox" name="includeMetaData" value="true">Content Comments and Ratings</label>

      <cfif application.settingsManager.getSite(session.siteid).getemailbroadcaster()>
        <label class="checkbox"><input type="checkbox" name="includeMailingListMembers" value="true">Mailing List Members</label>
      </cfif>

      <label class="checkbox"><input type="checkbox" name="includeFormData" value="true">Form Response Data</label>
      <cfset siteBean=application.settingsManager.getSite(session.siteID)>
      <cfif siteBean.getPublicUserPoolID() eq siteBean.getSiteID() and siteBean.getPrivateUserPoolID() eq siteBean.getSiteID()>
        <label class="checkbox"><input type="checkbox" name="includeUsers" value="true">
          Site Members &amp; Administrative Users</label>
      </cfif>
  </div>

    <div class="mura-control-group">
      <label>Also include selected Plugins:</label>
      <div class="mura-control justify">
      <cfif rc.rsplugins.recordcount gt 1>
          <a class="btn" href="##" onclick="checkAll('pluginSelectFrm'); return false;"><i class="mi-check"></i> Select All</a>
      </cfif>
        <cfif rc.rsplugins.recordcount>
          <cfloop query="rc.rsplugins">
              <label class="checkbox">
                <input type="checkbox" name="moduleID" value="#rc.rsplugins.moduleID#">
                #esapiEncode('html',rc.rsplugins.name)#</label>
          </cfloop>
          <cfelse>
              <div class="help-block-empty">This site currently has no plugins assigned to it.</p>
        </cfif>
        </div>
    </div>

    <div class="mura-control-group">
      <label>
        Server Directory <span>(Optional)</span></label>
      <div class="mura-control justify">
        <p class="help-block">
          Set the complete server path to the directory where the bundle .zip file is created.
          <br>If left blank, the bundle file will immediately download in the browser after creation.
        <br><br>
        Current Working Directory: #replace(application.configBean.getWebRoot(),"\","/","all")##application.configBean.getAdminDir()#/temp</p>
      </div>
      <div class="mura-control justify">
        <div class="mura-input-set">
          <input type="button" class="btn" onclick="jQuery('##saveFileDir').val('#esapiEncode('javascript','#replace(application.configBean.getWebRoot(),"\","/","all")##application.configBean.getAdminDir()#/temp')#');" value="Select Working Directory">
          <input class="text" type="text" name="saveFileDir" id="saveFileDir">
        </div>
      </div>
    </div>

        </div> <!--- /.block-content --->

      <div class="mura-actions">
        <div class="clearfix form-actions">
        <button class="btn mura-primary" onClick="return submitBundle();"><i class="mi-check-circle"></i>Create Bundle</button>
        <input type="hidden" name="muraAction" value="cSettings.createBundle">
        <input type="hidden" name="siteID" value="#esapiEncode('html_attr',rc.siteID)#">
        </div>
      </div>

      </div> <!--- /.block.block-bordered --->

  </form>

</div>

</cfoutput>