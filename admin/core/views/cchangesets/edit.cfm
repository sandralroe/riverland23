<!--- license goes here --->
<cfset isEditor=listFindNoCase('editor,module',$.getBean('permUtility').getModulePermType('00000000000000000000000000000000014',rc.siteid))>
<cfoutput>
<div class="mura-header">
  <h1><cfif rc.changesetID neq ''>#application.rbFactory.getKeyValue(session.rb,'changesets.editchangeset')#<cfelse>#application.rbFactory.getKeyValue(session.rb,'changesets.addchangeset')#</cfif></h1>

  <cfset csrfTokens= #rc.$.renderCSRFTokens(context=rc.changeset.getchangesetID(),format="url")#>
  <cfinclude template="dsp_secondary_menu.cfm">

</div> <!-- /.mura-header -->

      <cfif not structIsEmpty(rc.changeset.getErrors())>
          <div class="alert alert-error"><span>#application.utility.displayErrors(rc.changeset.getErrors())#</span></div>
      </cfif>

      <cfif rc.changeset.getPublished()>
      <div class="alert alert-info"><span>#application.rbFactory.getKeyValue(session.rb,'changesets.publishednotice')#</span></div>
      <cfelse>
      <cfset hasPendingApprovals=rc.changeset.hasPendingApprovals()>
      <cfif hasPendingApprovals>
        <div class="alert alert-error"><span>#application.rbFactory.getKeyValue(session.rb,'changesets.haspendingapprovals')#</span></div>
      </cfif>
      <cfset hasAttachedExperience=rc.changeset.hasAttachedExperience()>
      <cfif hasAttachedExperience>
        <div class="alert alert-info"><span>#application.rbFactory.getKeyValue(session.rb,'changesets.hasAttachedExperience')#</span></div>
      </cfif>
      </cfif>

      <cfif len(trim(application.pluginManager.renderEvent("onChangesetEditMessageRender", request.event)))>
        <span id="msg">#application.pluginManager.renderEvent("onChangesetEditMessageRender", request.event)#</span>
      </cfif>
<div class="block block-constrain">
      <cfset tablist="tabBasic">
      <cfset tablabellist=application.rbFactory.getKeyValue(session.rb,"sitemanager.content.tabs.basic")>
      <cfset hasCategories=application.categoryManager.getCategoryCount(rc.siteid)>
      <cfif hasCategories>
    <cfset tablist=listAppend(tablist,'tabCategorization')>
    <cfset tablabellist=listAppend(tabLabelList,application.rbFactory.getKeyValue(session.rb,"sitemanager.content.tabs.categorization"))>
      </cfif>
      <cfset tablist=listAppend(tablist,'tabTags')>
      <cfset tablabellist=listAppend(tablabellist,application.rbFactory.getKeyValue(session.rb,"sitemanager.content.tabs.tags"))>
      <ul class="mura-tabs nav-tabs" data-toggle="tabs">
        <cfloop from="1" to="#listlen(tabList)#" index="t">
             <li<cfif t eq 1> class="active"</cfif>><a href="###listGetAt(tabList,t)#" onclick="return false;"><span>#listGetAt(tabLabelList,t)#</span></a></li>
        </cfloop>
        </ul>

      <form novalidate="novalidate" action="./?muraAction=cChangesets.save&siteid=#esapiEncode('url',rc.siteid)#" method="post" name="form1" onsubmit="return validate(this);">

      <div class="block-content tab-content">
        <div id="tabBasic" class="tab-pane active">
          <div class="block block-bordered">
            <!-- block header -->
            <div class="block-header">
              <h3 class="block-title">Basic Settings</h3>
            </div> <!-- /.block header -->
            <div class="block-content">
            <div class="mura-control-group">
              <label>
            #application.rbFactory.getKeyValue(session.rb,'changesets.name')#
          </label>
              <input name="name" type="text" required="true" message="#application.rbFactory.getKeyValue(session.rb,'changesets.titlerequired')#" value="#esapiEncode('html_attr',rc.changeset.getName())#" maxlength="50">
          </div>

          <div class="mura-control-group">
            <label>
              #application.rbFactory.getKeyValue(session.rb,'changesets.description')#
            </label>
            <textarea name="description" rows="6">#esapiEncode('html',rc.changeset.getDescription())#</textarea>
          </div>
          <cfif rc.changeset.getPublished() or  (not rc.changeset.getPublished() and not hasAttachedExperience)>
            <div class="mura-control-group">
              <label>
                <span data-toggle="popover" title="" data-placement="right"
                  data-content="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"tooltip.changesetclosedate"))#"
                  data-original-title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"changesets.closedate"))#">#application.rbFactory.getKeyValue(session.rb,'changesets.closedate')# <i class="mi-question-circle"></i></span>
              </label>
              <cfif rc.changeset.getPublished()>
                <cfif lsIsDate(rc.changeset.getCloseDate())>
                  #LSDateFormat(rc.changeset.getCloseDate(),session.dateKeyFormat)# #LSTimeFormat(rc.changeset.getCloseDate(),"medium")#
                <cfelse>
                  #LSDateFormat(rc.changeset.getLastUpdate(),session.dateKeyFormat)# #LSTimeFormat(rc.changeset.getLastUpdate(),"medium")#
                </cfif>
              <cfelse>
                <cf_datetimeselector name="closeDate" datetime="#rc.changeset.getCloseDate()#" defaulthour="23" defaultminute="59">
              </cfif>
              </div>

              <div class="mura-control-group">
                <label>
                <span data-toggle="popover" title="" data-placement="right"
                  data-content="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"tooltip.changesetpublishdate"))#"
                  data-original-title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"changesets.publishdate"))#">
                  #application.rbFactory.getKeyValue(session.rb,'changesets.publishdate')# <i class="mi-question-circle"></i></span>
                </label>
                <cfif rc.changeset.getPublished()>
                  #LSDateFormat(rc.changeset.getLastUpdate(),session.dateKeyFormat)# #LSTimeFormat(rc.changeset.getLastUpdate(),"medium")#
                <cfelse>
                  <cf_datetimeselector name="publishDate" datetime="#rc.changeset.getpublishdate()#">
                </cfif>
              </div>
           </cfif>
        </div>

      </div>
      </div> <!--- /.tab-pane --->
      <cfif hasCategories>
        <div id="tabCategorization" class="tab-pane">

          <div class="block block-bordered">
            <!-- block header -->
            <div class="block-header">
			       <h3 class="block-title">Categories</h3>
            </div> <!-- /.block header -->
            <div class="block-content">

              <div class="mura-control-group">
              <!--- Category Filters --->
              <label>#application.rbFactory.getKeyValue(session.rb,'changesets.categoryassignments')#</label>
                <div id="mura-list-tree" class="mura-control justify">
                <cf_dsp_categories_nest siteID="#rc.siteID#" parentID="" nestLevel="0" categoryid="#rc.changeset.getCategoryID()#">
            </div>
          </div>
        </div>
      </div>

        </div> <!--- /.tab-pane --->
    </cfif>

      <div id="tabTags" class="tab-pane">

        <div class="block block-bordered">
          <!-- block header -->
          <div class="block-header">
			       <h3 class="block-title">Tags</h3>
          </div> <!-- /.block header -->
          <div class="block-content">

        <div class="mura-control-group">
          <label>
          #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.tags')#
          </label>
          <div id="tags" class="mura-control justify tagSelector">
            <input type="text" name="tags">
            <cfif len(rc.changeset.getTags())>
              <cfloop list="#rc.changeset.getTags()#" index="i">
                <span class="tag">
                  #esapiEncode('html',i)# <a><i class="mi-times-circle"></i></a>
                  <input name="tags" type="hidden" value="#esapiEncode('html_attr',i)#">
                </span>
              </cfloop>
            </cfif>
          </div>

          <script>
          	$(document).ready(function(){
						$.ajax({
							url: '?muraAction=cchangesets.loadtagarray&siteid=' + siteid,
							dataType: 'text',
							success:function(data){
                var tagArray=[];
                if(data){
							       tagArray=eval('(' + data + ')');
		            }
								$('##tags').tagSelector(tagArray, 'tags');
							}
						});
					});
        </script>
      </div>
    </div>
  </div>
    </div> <!--- /.tab-pane --->

  </div> <!--- /.tab-content --->
  <cfif isEditor>
  <div class="mura-actions">
      <div class="form-actions">
        <cfif rc.changesetID eq ''>
          <button type="button" class="btn mura-primary" onclick="submitForm(document.forms.form1,'add');"><i class="mi-check-circle"></i>#application.rbFactory.getKeyValue(session.rb,'changesets.add')#</button>
          <input type=hidden name="changesetID" value="#rc.changeset.getchangesetID()#">
        <cfelse>
          <cfif rc.changeset.getPublished() or (not rc.changeset.getPublished() and not hasAttachedExperience)>
          <button class="btn" type="button" onclick="confirmDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'changesets.deleteconfirm'))#','./?muraAction=cChangesets.delete&changesetID=#rc.changeset.getchangesetID()#&siteid=#esapiEncode('url',rc.changeset.getSiteID())##csrfTokens#')"><i class="mi-trash"></i> #application.rbFactory.getKeyValue(session.rb,'changesets.delete')#</button>
          </cfif>
          <button class="btn" type="button" onclick="submitForm(document.forms.form1,'update');"><i class="mi-check-circle"></i>#application.rbFactory.getKeyValue(session.rb,'changesets.update')#</button>
          <cfif not rc.changeset.getPublished() and not (hasPendingApprovals or hasAttachedExperience)>
            <button class="btn mura-primary" type="button" onclick="confirmDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'changesets.publishnowconfirm'))#','./?muraAction=cChangesets.publish&changesetID=#rc.changeset.getchangesetID()#&siteid=#esapiEncode('url',rc.changeset.getSiteID())##csrfTokens#')"><i class="mi-check-circle"></i> #application.rbFactory.getKeyValue(session.rb,'changesets.publishnow')#</button>
          </cfif>
          <cfif rc.changeset.getPublished()>
            <button class="btn" type="button" onclick="confirmDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'changesets.rollbackconfirm'))#','./?muraAction=cChangesets.rollback&changesetID=#rc.changeset.getchangesetID()#&siteid=#esapiEncode('url',rc.changeset.getSiteID())##csrfTokens#')"><i class="mi-history"></i> #application.rbFactory.getKeyValue(session.rb,'changesets.rollback')#</button>
          </cfif>
           <input type=hidden name="changesetID" value="#rc.changeset.getchangesetID()#">
        </cfif>
        <input type="hidden" name="action" value="">
        #rc.$.renderCSRFTokens(context=rc.changeset.getchangesetID(),format="form")#
      </div>
    </div>
  </cfif>
  </form>

</div> <!-- /.block-constrain -->
</cfoutput>
