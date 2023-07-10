<!--- license goes here --->
<cfsilent>
<cfset detailList = Left(rc.contentBean.getResponseDisplayFields(), 1) neq '~' ? ListFirst(rc.contentBean.getResponseDisplayFields(), '~') : ''>
<cfset summaryList = Right(rc.contentBean.getResponseDisplayFields(), 1) neq '~' ? ListLast(rc.contentBean.getResponseDisplayFields(), '~') : ''>
<cfhtmlhead text='<script src="assets/js/manageData.js?coreversion=#application.coreversion#" type="text/javascript"></script>'>
</cfsilent>
<script type="text/javascript">
function setFields(){
document.getElementById('responseDisplayFields').value=document.getElementById('summaryList2').value + '~' + document.getElementById('detailList2').value;
}
</script>

<cfoutput>
  <form novalidate="novalidate" name="frmDisplayFields" method="post" action="index.cfm">

<div class="mura-control-group">
<!---   <label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectfields')#</label> --->
  <div class="mura-control-group half">
  <label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.availablefields')#</label>
    <select name="availableFields" size="10" id="availableFields" class="multiSelect">
      <cfloop list="#rc.fieldnames#" index="f">
        <option value="#esapiEncode('html_attr',f)#">#esapiEncode('html',f)#</option>
      </cfloop>
    </select>
  </div>
  <div class="mura-control-group half">
    <table class="mura-control-table">
      <tr>
        <td class="nested"><input type="button" class="btn btn-sm" value=">>" onclick="dataManager.addObject('availableFields','summaryList','summaryList2');" class="objectNav btn">
          <br />
          <input type="button" class="btn btn-sm" value="<<" onclick="dataManager.deleteObject('summaryList','summaryList2');" class="objectNav btn">            </td>
        <td class="nested" style="width:76%;"> <label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.summarydisplayfields')#</label><br />
          <select name="summaryList" id="summaryList" size="4" style="width:100%;" class="multiSelect">
            <cfif summaryList neq "">
              <cfloop list="#summaryList#" delimiters="^" index="f">
                <option value="#esapiEncode('html_attr',f)#">#esapiEncode('html',f)#</option>
              </cfloop>
            </cfif>
          </select>
          <input type="hidden" name="summaryList2" id="summaryList2" value="#summaryList#" class="multiSelect"></td>
        <td  class="nested"><input type="button" class="btn btn-sm" value="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.up')#" onclick="dataManager.moveUp('summaryList','summaryList2');" class="objectNav btn">
          <br />
          <input type="button" class="btn btn-sm" value="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.down')#" onclick="dataManager.moveDown('summaryList','summaryList2');" class="objectNav btn"></td>
      </tr>
      <tr>
        <td class="nested"><input type="button" class="btn btn-sm" value=">>" onclick="dataManager.addObject('availableFields','detailList','detailList2');" class="objectNav btn">
          <br />
          <input type="button" class="btn btn-sm" value="<<" onclick="dataManager.deleteObject('detailList','detailList2');" class="objectNav btn"></td>
        <td class="nested"><label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.detaildisplayfields')#</label><br />
          <select name="detailList"  id="detailList" size="4" style="width:100%;">
            <cfif detailList neq "">
              <cfloop list="#detailList#" delimiters="^" index="f">
                <option value="#esapiEncode('html_attr',f)#">#esapiEncode('html',f)#</option>
              </cfloop>
            </cfif>
          </select>
          <input type="hidden" name="detailList2" id="detailList2" value="#detailList#"></td>
        <td  class="nested"><input type="button" class="btn btn-sm" value="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.up')#" onclick="dataManager.moveUp('detailList','detailList2');" class="objectNav btn">
          <br />
          <input type="button" class="btn btn-sm" value="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.down')#" onclick="dataManager.moveDown('detailList','detailList2');" class="objectNav btn"></td>
      </tr>
    </table>
  </div>
</div>

<div class="mura-control-group">
  <label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.recordsperpage')#
  </label>
  <select name="nextN" class="dropdown mura-constrain mura-numeric">
    <cfloop from="5" to="50" step="5" index="r">
      <option value="#r#" <cfif r eq rc.contentBean.getNextN()>selected</cfif>>#r#</option>
    </cfloop>
  </select>
</div>

<div class="mura-control-group">
  <label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.sortby')#</label>
  <select name="sortBy" class="dropdown mura-constrain">
    <cfloop list="#rc.fieldnames#" index="f">
      <option value="#esapiEncode('html_attr',f)#" <cfif f eq rc.contentBean.getSortBy()>selected</cfif>>#esapiEncode('html',f)#</option>
    </cfloop>
  </select>
  <select name="sortDirection" class="dropdown mura-constrain">
    <option value="asc" <cfif rc.contentBean.getSortDirection() eq 'asc'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.ascending')#</option>
    <option value="desc" <cfif rc.contentBean.getSortDirection() eq 'desc'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.descending')#</option>
  </select>
</div>

<div class="mura-actions">
  <div class="form-actions">
    <button class="btn mura-primary" onclick="submitForm(document.forms.frmDisplayFields,'setDisplay');"><i class="mi-check-circle"></i>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.update')#</button>
  </div>
</div>

<input type="hidden" value="setDisplay" name="action">
<input type="hidden" name="muraAction" value="cArch.datamanager" />
<input type="hidden" name="contentid" value="#esapiEncode('html_attr',rc.contentid)#" />
<input type="hidden" name="siteid" value="#esapiEncode('html_attr',session.siteid)#" />
<input type="hidden" name="moduleid" value="#esapiEncode('html_attr',rc.moduleid)#" />
</cfoutput>
</form>
