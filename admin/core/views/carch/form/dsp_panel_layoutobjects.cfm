<!--- license goes here --->
<cfsilent>
  <cfset tabList=listAppend(tabList,"tabLayoutObjects")>
  <cfif isArray($.getContentRenderer().defaultInheritedRegions)>
    <cfset $.getContentRenderer().defaultInheritedRegions=arrayToList($.getContentRenderer().defaultInheritedRegions)>
  </cfif>
  <cfloop from="1" to="#application.settingsManager.getSite($.event('siteID')).getColumnCount()#" index="i">
    <cfparam name="request.rsContentObjects#i#.recordcount" default=0>
  </cfloop>
</cfsilent>
<cfoutput>
  <div class="mura-panel" id="tabLayoutObjects">
    <div class="mura-panel-heading" role="tab" id="heading-layout">
      <h4 class="mura-panel-title">
        <a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##content-panels" href="##panel-layout" aria-expanded="false" aria-controls="panel-layout">#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.tabs.layoutobjects")#</a>
      </h4>
    </div>
      <div id="panel-layout" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading-layout" aria-expanded="false" style="height: 0px;">
        <div class="mura-panel-body">

      			<span id="extendset-container-tablayoutobjectstop" class="extendset-container"></span>
            <div class="mura-control-group">

                    <div class="mura-control-group">
                      <label>
                          <span data-toggle="popover" title="" data-placement="right"
                          data-content="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"tooltip.layoutTemplate"))#"
                          data-original-title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.fields.layouttemplate"))#">
                            #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.layouttemplate')#
                           <i class="mi-question-circle"></i></span>
                			</label>
    		              <select name="template" class="dropdown">
    			            <cfif rc.contentid neq '00000000000000000000000000000000001'>
	                          <cfset templateName = application.contentManager.getTemplateFromParent(rc.parentID, rc.siteid)>
	                          <cfif templateName eq "">
	                          	<cfset templateName = application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.none')>
	                          </cfif>
    			              <option value="">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.inherit')# (#templateName#)</option>
    			            </cfif>
    									<cfset renderer=rc.$.getContentRenderer()>
    									<cfif isDefined('renderer.templateArray') and isArray(renderer.templateArray)>
    										<cfset templateArray=renderer.templateArray>
    									<cfelse>
    										<cfset templateArray=listToArray(rc.$.siteConfig('templateList'),'^')>
    									</cfif>
    									<cfif rc.moduleID eq  '00000000000000000000000000000000000' and arrayLen(templateArray)>
    										<cfloop from="1" to="#arrayLen(renderer.templateArray)#" index="t">
    			                <cfoutput>
    			                  <option value="#templateArray[t]#" <cfif rc.contentBean.gettemplate() eq templateArray[t]>selected</cfif>>#templateArray[t]#</option>
    			                </cfoutput>
    				            </cfloop>
    									<cfelse>
    				            <cfloop query="rc.rsTemplates">
    				              <cfif listFindNocase('cfm,html,htm,hbs',listLast(rc.rsTemplates.name,'.'))>
    				                <option value="#rc.rsTemplates.name#" <cfif rc.contentBean.gettemplate() eq rc.rsTemplates.name>selected</cfif>>#rc.rsTemplates.name#</option>
    				              </cfif>
    				            </cfloop>
    									</cfif>
    		          		</select>
            			</div>

                  <div class="mura-control-group">
                  <label>
                    <span data-toggle="popover" title="" data-placement="right"
                    data-content="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"tooltip.childTemplate"))#"
                    data-original-title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.fields.childtemplate"))#">
                      #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.childtemplate')#
                     <i class="mi-question-circle"></i></span>
                  </label>
                  <select name="childTemplate" class="dropdown">
    	            <option value="">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.none')#</option>
    							<cfset templateArray=listToArray(rc.$.siteConfig('templateList'),'^')>
    							<cfif rc.moduleID eq  '00000000000000000000000000000000000' and arrayLen(templateArray)>
    								<cfloop from="1" to="#arrayLen(templateArray)#" index="t">
    	                <cfoutput>
    	                  <option value="#templateArray[t]#" <cfif rc.contentBean.getchildTemplate() eq templateArray[t]>selected</cfif>>#templateArray[t]#</option>
    	                </cfoutput>
    		            </cfloop>
    							<cfelse>
    								<cfloop query="rc.rsTemplates">
    		              <cfif listFindNocase('cfm,html,htm,hbs',listLast(rc.rsTemplates.name,'.'))>
    		                <cfoutput>
    		                  <option value="#rc.rsTemplates.name#" <cfif rc.contentBean.getchildTemplate() eq rc.rsTemplates.name>selected</cfif>>#rc.rsTemplates.name#</option>
    		                </cfoutput>
    		              </cfif>
    		            </cfloop>
    							</cfif>
    	          </select>
            </div>
          </div>

          <div class="mura-control-group">
            <label>
              <span data-toggle="popover" title="" data-placement="right"
              data-content="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"tooltip.inheritancerules"))#"
              data-original-title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.fields.inheritancerules"))#">
                #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.inheritancerules')#
               <i class="mi-question-circle"></i></span>
            </label>
             <cfif structKeyExists(request, "inheritedObjects") and len(request.inheritedObjects)>
                <cfset inheritBean=$.getBean('content').loadBy(contenthistid=request.inheritedObjects)>
                <cfset querystring=(inheritBean.getActive()) ? "editlayout=true" : "previewid=#inheritBean.getContentHistID()#&editlayout=true">
                <cfif inheritBean.getContentID() neq rc.contentBean.getContentID()>
                <div class="help-block">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.currentinheritance')#:
                <cfif listFindNoCase("author,editor",application.permUtility.getnodePerm(inheritBean.getCrumbArray()))>
                  <a href='#inheritBean.getURL(secure=rc.$.getBean('utility').isHTTPs(),queryString=querystring,complete=1,useEditRoute=true)#'>#esapiEncode('html',inheritBean.getMenuTitle())#</a>
                <cfelse>
                   #esapiEncode('html',inheritBean.getMenuTitle())#
                </cfif>
                </div>
                </cfif>
            </cfif>
            <label for="ior" class="radio inline">
            <input type="radio" name="inheritObjects" id="ior" value="Reject" <cfif listFindNoCase(rc.contentBean.getinheritObjects(),'reject')>checked</cfif>>
            #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.donotinheritcascade')#
            </label>
            <label for="ioc" class="radio inline">
            <input type="radio" name="inheritObjects" id="ioc" value="Cascade" <cfif listFindNoCase(rc.contentBean.getinheritObjects(),'cascade')>checked</cfif>>
            #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.startnewcascade')#
            </label>
            <label for="ioi" class="radio inline">
            <input type="radio" name="inheritObjects" id="ioi" value="Inherit" <cfif listFindNoCase(rc.contentBean.getinheritObjects(),'inherit') or rc.contentBean.getinheritObjects() eq ''>checked</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.inheritcascade')#
            </label>
          </div>
					<div id="inheritanceRegionOptin" class="mura-control-group" style="display:none">
						<label>
						<span data-toggle="popover" title="" data-placement="right"
						data-content="Hold shift to select muiltiple options"
						data-original-title="Region Selector">
						Select regions to inherit?
						<i class="mi-question-circle"></i></label>
						<select multiple="multiple" class="multiSelect"  name="inheritObjects" size="5" style="display:block">
							<option value=""<cfif !rc.contentBean.getIsNew() && listFindNoCase('inherit,cascade,reject',rc.contentBean.getinheritObjects())> selected</cfif>>All</option>
							<cfloop from="1" to="#application.settingsManager.getSite(rc.siteid).getcolumnCount()#" index="r">
                <cfif listlen(application.settingsManager.getSite(rc.siteid).getcolumnNames(),"^") gte r>
                  <cfset regionName=listgetat(application.settingsManager.getSite(rc.siteid).getcolumnNames(),r,"^")>
                <cfelse>
                  <cfset regionName="Region #r#">
                </cfif>
                <option value="#r#"<cfif listfind(rc.contentBean.getinheritObjects(),r) or (rc.contentBean.getIsNew() and (listFindNoCase($.getContentRenderer().defaultInheritedRegions,r) or listFindNoCase($.getContentRenderer().defaultInheritedRegions,regionName)))> selected</cfif>>#regionName#</option>
							</cfloop>
						</select>
					</div>
					<script>
						jQuery(function($){
							function handleClick(){
								if($('input[name="inheritObjects"][value="Inherit"]').is(":checked")){
									$('##inheritanceRegionOptin').show();
								} else {
									$('##inheritanceRegionOptin').hide();
								}
							}

							$('input[name="inheritObjects"]').on(
								'click',
								handleClick
							);

							handleClick();
						});
					</script>

            <cfif rc.$.getContentRenderer().useLayoutManager()>
              <div class="mura-control-group">
                <label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.contentobjects')#</label>
                <div class="help-block">
                  <cfset querystring=(rc.contentBean.getActive()) ? "editlayout=true" : "previewid=#rc.contentBean.getContentHistID()#&editlayout=true">
                  <p>To manage content objects <a href="#rc.contentBean.getURL(secure=rc.$.getBean('utility').isHTTPs(),queryString=queryString,complete=1,useEditRoute=true)#">click here</a>.</p>
                </div>
              </div>

            <cfelse>
              <div class="mura-control-group">
                <label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.contentobjects')#</label>
                <!--- 'big ui' flyout panel --->
                <div class="bigui" id="bigui__layoutobjects" data-label="#esapiEncode('html_attr', application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.manageobjects'))#">
                  <div class="bigui__title">#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.contentobjects'))#</div>

                  <div class="bigui__controls">

                        <div id="editObjects">
                        <script>
                         var availableObjectSuffix='';
                        </script>
                        <div id="availableObjectsContainer">
                        <dl>
                          <dt>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.availablecontentobjects')#</dt>
                          <dd>
                            <select name="classSelector" onchange="siteManager.loadObjectClass('#esapiEncode("Javascript",rc.siteid)#',this.value,'','#rc.contentBean.getContentID()#','#esapiEncode("Javascript",rc.parentID)#','#rc.contentBean.getContentHistID()#',0);"  id="dragme">
                              <option value="">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectobjecttype')#</option>
                              <option value="system">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.system')#</option>
                              <option value="navigation">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.navigation')#</option>
                              <cfif application.settingsManager.getSite(rc.siteid).getemailbroadcaster()>
                              <option value="mailingList">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.mailinglists')#</option>
                              </cfif>
                              <cfif application.settingsManager.getSite(rc.siteid).getAdManager()>
                              <option value="adzone">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.adregions')#</option>
                              </cfif>
                                <!--- <option value="category">Categories</option> --->
                              <option value="folder">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.folders')#</option>
                              <option value="calendar">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.calendars')#</option>
                              <option value="gallery">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.galleries')#</option>
                              <option value="component">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.components')#</option>
                              <cfif application.settingsManager.getSite(rc.siteid).getDataCollection()>
                                <option value="form">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.forms')#</option>
                              </cfif>
                              <cfif application.settingsManager.getSite(rc.siteid).getHasfeedManager()>
                              <option value="localFeed">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.localindexes')#</option>
                              <option value="slideshow">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.localindexslideshows')#</option>
                              <option value="remoteFeed">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.remotefeeds')#</option>
                              </cfif>
                              <cfif fileExists("#application.configBean.getWebRoot()#/#rc.siteid#/includes/display_objects/custom/admin/dsp_objectClassLabel.cfm")>
                              <cfinclude template="/#application.configBean.getWebRootMap()#/#rc.siteID#/includes/display_objects/custom/admin/dsp_objectClassLabel.cfm" >
                              </cfif>
                              <option value="plugins">#application.rbFactory.getKeyValue(session.rb,'layout.plugins')#</option>
                            </select>
                          </dd>
                        </dl>
                        <div id="classList"></div>
                    </div><!--- /#availableObjects --->
                    <div id="availableRegions">
                      <cfloop from="1" to="#application.settingsManager.getSite(rc.siteid).getcolumnCount()#" index="r">
                        <div class="region">
                                <div class="btn-group btn-group-vertical"> <a class="objectNav btn" onclick="siteManager.addDisplayObject('availableObjects' + availableObjectSuffix,#r#,true);"> <i class="mi-caret-right"></i></a> <a class="objectNav btn" onclick="siteManager.deleteDisplayObject(#r#);"> <i class="mi-caret-left"></i></a> </div>
                          <cfif listlen(application.settingsManager.getSite(rc.siteid).getcolumnNames(),"^") gte r>
                            <dl>
                            <dt>#listgetat(application.settingsManager.getSite(rc.siteid).getcolumnNames(),r,"^")#
                              <cfelse>
                            <dt>
                            Region #r#
                          </cfif>
                  #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.contentobjects')#
                          </dt>
                          <cfset variables["objectlist#r#"]="">
                          <dd>
                            <select name="selectedObjects#r#" id="selectedObjects#r#" class="multiSelect displayRegions" multiple="multiple" size="4" data-regionid="#r#">
                              <cfloop query="request.rsContentObjects#r#">
                                <option  value="#request["rsContentObjects#r#"].object#~#esapiEncode('html',request["rsContentObjects#r#"].name)#~#request["rsContentObjects#r#"].objectid#~#esapiEncode('html',request["rsContentObjects#r#"].params)#">
                                #request["rsContentObjects#r#"].name#

                                </option>
                                <cfset variables["objectlist#r#"]=listappend(variables["objectlist#r#"],"#request["rsContentObjects#r#"].object#~#esapiEncode('html',request["rsContentObjects#r#"].name)#~#request["rsContentObjects#r#"].objectid#~#esapiEncode('html',request["rsContentObjects#r#"].params)#","^")>
                              </cfloop>
                            </select>
                            <input type="hidden" name="objectList#r#" id="objectList#r#" value="#variables["objectlist#r#"]#">
                          </dd>
                          </dl>
                                <div class="btn-group btn-group-vertical"> <a class="objectNav btn" value="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.up')#" onclick="siteManager.moveDisplayObjectUp(#r#);"> <i class="mi-caret-up"></i></a> <a class="objectNav btn" value="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.down')#" onclick="siteManager.moveDisplayObjectDown(#r#);"> <i class="mi-caret-down"></i></a> </div>
                        </div> <!--- /.region --->
                      </cfloop>
                    </div> <!--- /#availableRegions --->
                  </div> <!--- /#editObjects--->

                  </div>
                </div> <!--- /.bigui --->

              </div> <!--- /.mura-control-group --->
        </cfif>

        <!--- list display options --->
        <cfif rc.moduleid eq '00000000000000000000000000000000000' and (not rc.$.getContentRenderer().useLayoutManager() and listFindNoCase('Page,Folder,Gallery,Calender',rc.type))>

          <cfset displayList=rc.contentBean.getDisplayList()>
          <cfset availableList=rc.contentBean.getAvailableDisplayList()>
          <cfset imageSizes=application.settingsManager.getSite(rc.siteid).getCustomImageSizeIterator()>

          <div class="mura-control-group">
              <label>#application.rbFactory.getKeyValue(session.rb,'collections.imagesize')#</label>
            <select name="imageSize" data-displayobjectparam="imageSize" onchange="if(this.value=='custom'){jQuery('##feedCustomImageOptions').fadeIn('fast')}else{jQuery('##feedCustomImageOptions').hide();jQuery('##feedCustomImageOptions').find(':input').val('AUTO');}">
              <cfloop list="Small,Medium,Large" index="i">
                <option value="#lcase(i)#"<cfif i eq rc.contentBean.getImageSize()> selected</cfif>>#I#</option>
              </cfloop>
              <cfloop condition="imageSizes.hasNext()">
                <cfset image=imageSizes.next()>
                <option value="#lcase(image.getName())#"<cfif image.getName() eq rc.contentBean.getImageSize()> selected</cfif>>#esapiEncode('html',image.getName())#</option>
              </cfloop>
              <option value="custom"<cfif "custom" eq rc.contentBean.getImageSize()> selected</cfif>>Custom</option>
            </select>
          </div>

          <div id="feedCustomImageOptions" class="mura-control-group"<cfif rc.contentBean.getImageSize() neq "custom"> style="display:none"</cfif>>
            <span class="half">
              <label>#application.rbFactory.getKeyValue(session.rb,'collections.imagewidth')#</label>
              <input name="imageWidth" data-displayobjectparam="imageWidth" type="text" value="#rc.contentBean.getImageWidth()#" />
            </span>
            <span class="half">
              <label>#application.rbFactory.getKeyValue(session.rb,'collections.imageheight')#</label>
              <input name="imageHeight" data-displayobjectparam="imageHeight" type="text" value="#rc.contentBean.getImageHeight()#" />
            </span>
          </div>

          <div class="mura-control-group" id="availableFields">
            <label>
              <span class="half">Available Fields</span> <span class="half">Selected Fields</span>
            </label>

            <div id="sortableFields">
              <p class="dragMsg">
                <span class="dragFrom half">Drag Fields from Here&hellip;</span><span class="half">&hellip;and Drop Them Here.</span>
              </p>

              <ul id="contentAvailableListSort" class="contentDisplayListSortOptions">
                <cfloop list="#availableList#" index="i">
                  <li class="ui-state-default">#trim(i)#</li>
                </cfloop>
              </ul>
              <ul id="contentDisplayListSort" class="contentDisplayListSortOptions">
                <cfloop list="#displayList#" index="i">
                  <li class="ui-state-highlight">#trim(i)#</li>
                </cfloop>
              </ul>
              <input type="hidden" id="contentDisplayList" value="#displayList#" name="displayList"/>
              <script>
                //Removed from jQuery(document).ready() because it would not fire in ie7 frontend editing.
                siteManager.setContentDisplayListSort();
              </script>
            </div>
            </div>

          <div class="mura-control-group">
            <label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.recordsperpage')#</label>
            <select name="nextN" class="dropdown">
              <cfloop list="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,50,100" index="r">
                <option value="#r#" <cfif r eq rc.contentBean.getNextN()>selected</cfif>>#r#</option>
              </cfloop>
            </select>
          </div>

        </cfif>
        <!--- /list display options --->

      <span id="extendset-container-layout" class="extendset-container"></span>
      <span id="extendset-container-tablayoutobjectsbottom" class="extendset-container"></span>

    </div>
  </div>
</div>
  <cfinclude template="../dsp_configuratorJS.cfm">
</cfoutput>
