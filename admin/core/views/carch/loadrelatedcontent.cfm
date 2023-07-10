<!--- license goes here --->

<!---
	This file renders the search for and results
--->
<cfparam name="rc.isNew" default="1">
<cfparam name="rc.keywords" default="">
<cfparam name="rc.searchTypeSelector" default="">
<cfparam name="rc.relatedcontentsetid" default="">
<cfparam name="rc.rcStartDate" default="">
<cfparam name="rc.rcEndDate" default="">
<cfparam name="rc.rcCategoryID" default="">
<cfparam name="rc.external" default="true">
<cfparam name="rc.entitytype" default="content">
<cfset request.layout=false>
<cfset baseTypeList = "Page,Folder,Calendar,Gallery,File,Link"/>
<cfset rsSubTypes = application.classExtensionManager.getSubTypes(siteID=rc.siteID, activeOnly=true) />
<cfset contentPoolSiteIDs = $.getBean('settingsManager').getSite($.event('siteId')).getContentPoolID()>
<cfif listFind(contentPoolSiteIDs, $.event('siteid'))>
	<cfset contentPoolSiteIDs = listDeleteAt(contentPoolSiteIDs, listFind(contentPoolSiteIDs, $.event('siteid')))>
</cfif>
<cfset rc.contentBean=$.getBean('content').loadBy(contenthistid=rc.contenthistid,siteid=rc.siteid)>
<cfset subtype = application.classExtensionManager.getSubTypeByName(rc.contentBean.getType(), rc.contentBean.getSubType(), rc.siteid)>
<cfset relatedContentSets = subtype.getRelatedContentSets()>
<cfset hasNonstandardContent=false>
<cfloop from="1" to="#arrayLen(relatedContentSets)#" index="i">
	<cfif relatedContentSets[i].getRelatedContentSetId() neq "content">
		<cfset hasNonstandardContent=true>
		<cfbreak>
	</cfif>
</cfloop>
<cfset request.layout=false>
<cfoutput>
	<script>
		function toggleRelatedType(clicked){
			$('##mura-rc-quickedit').hide();

			if($(clicked).val()=='internal'){
				$(".mura-related-internal").show();
				$(".mura-related-external").hide();
			} else {
				$(".mura-related-internal").hide();
				$(".mura-related-external").show();
			}
		}

		function createExternalLink(){

			if($('##mura-related-title').val()=='' || $('##mura-related-url').val()==''){

				alertDialog("#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.newcontentvalidation'))#");

				return false;
			}

			var newcontentid=Math.random();

			$(".draggableContainmentExternal .list-table-items").append(
			 	$('<li/>').attr('data-contentid',newcontentid)
			 	.attr('data-url',$('##mura-related-url').val())
			 	.attr('data-title',$('##mura-related-title').val())
			 	.attr('data-content-type','Link/Default')
			 	.attr('class','item')
			 	.append(
			 		$('<button class="btn mura-rc-quickoption" type="button" value="'+ newcontentid +'"><i class="mi-plus-circle"></i></button><ul class="navZoom"><li class="mi-link "> ' + $('##mura-related-title').val() + '</li></ul>')
			 	)
			 );

			if(!$(".draggableContainmentExternal").is(":visible")){
				$(".draggableContainmentExternal").fadeIn();
			}

			$(".draggableContainmentExternal .rcDraggable li.item").draggable({
				connectToSortable: '.rcSortable',
				helper: 'clone',
				revert: 'invalid',
				appendTo: 'body',
				start: function(event, ui) {
					// bind mouse events to clone
					$('##mura-rc-quickedit').hide();
					siteManager.bindMouse();
				},
				zIndex: 100
			}).disableSelection();

			siteManager.setupRCQuikEdit();

			siteManager.bindMouse();

		}

		Mura(function(){

			function getEntityType(){
				var entitytype=Mura('input[name="entitytype"]:checked');
				if(!entitytype.length){
					entitytype=Mura('input[name="entitytype"]');
				}
				return entitytype.val();
			}

			function handleEntityTypeChange(){
				var entitytype=getEntityType()
				Mura('.mura-related-ui').hide();
				Mura('.mura-related-ui__' + entitytype).show();
				if(entitytype=='content' && Mura('##contentlocation2').is(':checked')){
					Mura('.mura-related-internal').hide();
				}
			}

			Mura('input[name="entitytype"]').click(handleEntityTypeChange);

			handleEntityTypeChange();

			var relatedcontentsetid='#esapiEncode("javascript",rc.relatedcontentsetid)#';

			Mura('.mura-related-ui_search').click(function(e){
					e.preventDefault();
					var entitytype=getEntityType()
					var valueSelector = '.mura-related-ui-input__'+ entitytype;
					Mura('##mura-rc-quickedit').hide();
					siteManager.loadRelatedContent(contentid,siteid, 0, $(valueSelector).serialize(), false,true,relatedcontentsetid);
			})

		});
	</script>

	<cfif hasNonstandardContent and arrayLen(relatedContentSets) gt 1>
		<div class="mura-control-group">
			<label>Which type of content do you want related?</label>
			<label class="radio inline"><input type="radio" name="entitytype" value="content"<cfif rc.entitytype eq 'content'> checked="true"</cfif>/>Site Content</label>
			<cfset foundTypes={}>
			<cfloop from="1" to="#arrayLen(relatedContentSets)#" index="i">
				<cfif relatedContentSets[i].getEntityType() neq 'content' and not structKeyExists(foundTypes,'#relatedContentSets[i].getEntityType()#')>
				<cfset foundTypes['#relatedContentSets[i].getEntityType()#']=true>
				<label class="radio inline"><input type="radio" name="entitytype" value="#esapiEncode('html_attr',relatedContentSets[i].getEntityType())#"<cfif rc.entitytype eq relatedContentSets[i].getEntityType()> checked="true"</cfif>/>#esapiEncode('html',relatedContentSets[i].getDisplayName())#</label>
				</cfif>
			</cfloop>
		</div>
	<cfelse>
		<input type="hidden" name="entitytype" value="#esapiEncode('html_attr',relatedContentSets[i].getEntityType())#"/>
	</cfif>

	<cfset foundTypes={}>
	<cfloop from="1" to="#arrayLen(relatedContentSets)#" index="i">
		<cfif relatedContentSets[i].getEntityType() neq 'content' and not structKeyExists(foundTypes,'#relatedContentSets[i].getEntityType()#')>
			<cfset foundTypes['#relatedContentSets[i].getEntityType()#']=true>
			<div class="mura-control-group mura-related-ui mura-related-ui__#esapiEncode('html_attr',relatedContentSets[i].getEntityType())#" style="display:none;"">
				<label>Keyword Search</label>
				<div  class="mura-control justify">
						<div class="mura-input-set pull-left">
						<input type="text" class="mura-related-ui-input__#esapiEncode('html_attr',relatedContentSets[i].getEntityType())#" name="keywords" value="#esapiEncode('html_attr',rc.keywords)#" placeholder="Keywords"/>
						<button type="button" class="mura-related-ui_search" name="btnSearch" class="btn"><i class="mi-search"></i></button>
					</div>
				</div>
			</div>
		</cfif>
	</cfloop>


	<div class="mura-related-ui mura-related-ui__content" style="display:none;">
		<cfif rc.external>
			<div class="mura-control-group" >
				<label>
					<span data-toggle="popover" title="" data-placement="right"
	  			data-content="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'tooltip.addrelatedcontent'))#"
	  			data-original-title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.whereistherelatedcontent'))#">
			  	#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.whereistherelatedcontent')# <i class="mi-question-circle"></i></span>
				</label>
					<label class="radio inline"><input type="radio" onclick="toggleRelatedType(this)" id="contentlocation1" name="contentlocation" value="internal" checked="true"/>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.inthissite')#</label>
					<label class="radio inline"><input type="radio" onclick="toggleRelatedType(this)" id="contentlocation2" name="contentlocation" value="external"/>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.onanothersite')#</label>
			</div>
			</cfif>

			<div class="mura-control-group mura-related-internal">
				<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.inthissite')#</label>
				<div id="internalContent" class="mura-control justify">
						<div class="mura-input-set pull-left">
						<input type="text" name="keywords" value="#esapiEncode('html_attr',rc.keywords)#" id="rcSearch" placeholder="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.searchforcontent')#"/>
						<button type="button" name="btnSearch" id="rcBtnSearch" class="btn"><i class="mi-search"></i></button>
					</div>
					<a href="##" class="btn pull-left" id="aAdvancedSearch" data-toggle="button">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.advancedsearch')#</a>
				</div>
			</div>

			<div class="mura-related-internal">
				<div id="rcAdvancedSearch" style="display:none;">
					<div class="mura-control-group">
						<cfif rc.relatedcontentsetid neq 'calendar'>

							<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.contenttype')#</label>
							<select name="searchTypeSelector" id="searchTypeSelector">
								<option value="">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.all')#</option>
								<cfloop list="#baseTypeList#" index="t">
									<cfsilent>
										<cfquery name="rsst" dbtype="query">select * from rsSubTypes where type = <cfqueryparam cfsqltype="cf_sql_varchar"  value="#t#"> and subtype not in ('Default','default') and adminonly!=1</cfquery>
									</cfsilent>
									<option value="#t#^Default"<cfif rc.searchTypeSelector eq "#t#^Default"> selected="selected"</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.type.#lcase(t)#")#</option>
									<cfif rsst.recordcount>
										<cfloop query="rsst">
											<option value="#t#^#rsst.subtype#"<cfif rc.searchTypeSelector eq "#t#^#rsst.subtype#"> selected="selected"</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.type.#lcase(t)#")#  / #rsst.subtype#</option>
										</cfloop>
									</cfif>
								</cfloop>
							</select>

						</cfif>
					</div>
				<div class="mura-control-group">
					<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.releasedaterange')#</label>
					<div class="mura-control-inline">
						<label>#application.rbFactory.getKeyValue(session.rb,"params.from")#</label>
						<input type="text" name="rcStartDate" id="rcStartDate" class="datepicker mura-relatedContent-datepicker" placeholder="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.startdate'))#" value="#rc.rcStartDate#" />
						<label>#application.rbFactory.getKeyValue(session.rb,"params.to")#</label>
						 <input type="text" name="rcEndDate" id="rcEndDate" class="datepicker mura-relatedContent-datepicker" placeholder="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.enddate')#" value="#rc.rcEndDate#" />
					</div>
				</div>
				<div class="mura-control-group">
					<div class="mura-control justify">
						<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.availablecategories')#</label>
						<div id="mura-list-tree">
							<cf_dsp_categories_nest siteID="#rc.siteID#" parentID="" categoryID="#rc.rcCategoryID#" nestLevel="0" useID="0" elementName="rcCategoryID">
						</div>
					</div>
				</div>
			</div>
		</div>
		<div class="mura-control-inline mura-related-external" style="display:none;">
				<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.title')#</label>
				<input type="text" id="mura-related-title" value="">
				<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.url')#</label>
				<input type="text" id="mura-related-url" value="" placeholder="http://www.example.com">
				<button type="button" name="btnCreateLink" id="rcBtnCreateLink" class="btn" onclick="createExternalLink();"><i class="mi-plus-circle"></i></button>
		</div>

		<div class="mura-related-external" style="display:none;">
			<div class="draggableContainmentExternal mura-control-group" style="display:none;">
				<div class="list-table search-results">
					<div class="list-table-content-set">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.availableurls')#</label></div>
					<ul class="rcDraggable list-table-items"></ul>
				</div>
			</div>
		</div>
	</div>
</cfoutput>


<cfif not rc.isNew>
	<cfscript>
		$=application.serviceFactory.getBean("MuraScope");

		if(rc.entitytype == 'content'){
			function getRelatedFeed($,siteid){
				feed=$.getBean("feed");
				feed.setMaxItems(100);
				feed.setNextN(100);
				feed.setLiveOnly(0);
				feed.setShowNavOnly(0);
				feed.setShowExcludeSearch(1);
				feed.setSortBy("lastupdate");
				feed.setSortDirection("desc");
				feed.setContentPoolID($.siteConfig('contentpoolid'));

				feed.addParam(field="active", criteria=1, condition="eq");
				feed.addParam(field="contentid", criteria=$.event('contentid'), condition="neq");

				if(isDefined('rc.relatedcontentsetid') && rc.relatedcontentsetid=='calendar'){
					feed.addParam(field="tcontent.type",criteria='Calendar',condition="eq");
				} else {
					if (len($.event("searchTypeSelector"))) {
						feed.addParam(field="tcontent.type",criteria=listFirst($.event("searchTypeSelector"), "^"),condition="eq");
						feed.addParam(field="tcontent.subtype",criteria=listLast($.event("searchTypeSelector"), "^"),condition="eq");
					}
				}

				if(len($.event("rcStartDate")) or len($.event("rcEndDate"))){
					feed.addParam(relationship="and (");

					started=false;

					feed.addParam(relationship="(");

					if (len($.event("rcStartDate"))) {
						feed.addParam(field="tcontent.releaseDate",datatype="date",condition="gte",criteria=$.event("rcStartDate"));
					}

					if (len($.event("rcEndDate"))) {
						feed.addParam(field="tcontent.releaseDate",datatype="date",condition="lt",criteria=dateAdd('d',1,$.parseDateArg($.event("rcEndDate"))));
					}

					feed.addParam(relationship=")");

					feed.addParam(relationship="or (");

					if (len($.event("rcStartDate"))) {
						feed.addParam(field="tcontent.displayStart",datatype="date",condition="gte",criteria=$.event("rcStartDate"));
					}

					if (len($.event("rcEndDate"))) {
						feed.addParam(field="tcontent.displayStart",datatype="date",condition="lt",criteria=dateAdd('d',1,$.event("rcEndDate")));
					}

					feed.addParam(relationship=")");

					feed.addParam(relationship="or (");

					if (len($.event("rcStartDate"))) {
						feed.addParam(field="tcontent.featureStart",datatype="date",condition="gte",criteria=$.event("rcStartDate"));
					}

					if (len($.event("rcEndDate"))) {
						feed.addParam(field="tcontent.featureStart",datatype="date",condition="lt",criteria=dateAdd('d',1,$.parseDateArg($.event("rcEndDate"))));
					}

					feed.addParam(relationship=")");



					feed.addParam(relationship=")");
				}

				if (len($.event("rcCategoryID"))) {
					feed.setCategoryID($.event("rcCategoryID"));
				}

				if (len($.event("keywords"))) {
					subList=$.getBean("contentManager").getPrivateSearch(arguments.siteid,$.event("keywords"));
					feed.addParam(field="tcontent.contentID",datatype="varchar",condition="in",criteria=valuelist(subList.contentID));
				}
				return feed;
			}

			rc.rslist=getRelatedFeed($,$.event('siteid')).getQuery();
		} else {

		}
	</cfscript>

	<cfif rc.entitytype eq 'content'>
		<div class="mura-control-group mura-related-internal mura-related-ui mura-related-ui__content">
			<cfset started=false>
				<div class="draggableContainmentInternal list-table search-results">
					<div class="list-table-content-set">
						<cfoutput><cfif len( contentPoolSiteIDs )>#$.getBean('settingsManager').getSite($.event('siteId')).getSite()#:</cfif>
							#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.searchresults')# <cfif rc.rslist.recordcount>(1-#min(rc.rslist.recordcount,100)# of #rc.rslist.recordcount#)</cfif></cfoutput>
					</div>
					<ul class="rcDraggable list-table-items">
						<cfoutput query="rc.rslist" startrow="1" maxrows="100">
							<cfsilent>
								<cfset crumbdata=application.contentManager.getCrumbList(rc.rslist.contentid, rc.rslist.siteid)/>
								<cfset verdict=application.permUtility.getnodePerm(crumbdata)/>
								<cfif verdict neq 'none'>
									<cfset started=true>
								</cfif>
							</cfsilent>
							<cfif verdict neq 'none'>
							<!---<cfif arrayLen(crumbdata) and structKeyExists(crumbdata[1],"parentArray") and not listFind(arraytolist(crumbdata[1].parentArray),rc.contentid)>--->
								<li class="item" data-content-type="#esapiEncode('html_attr','#rc.rslist.type#/#rc.rslist.subtype#')#" data-contentid="#rc.rslist.contentID#">
									<button class="btn mura-rc-quickoption" type="button" value="#rc.rslist.contentID#"><i class="mi-plus"></i></button>  #$.dspZoomNoLinks(crumbdata=crumbdata, charLimit=90, minLevels=2)#
								</li>
							</cfif>
						</cfoutput>
						<cfif not started>
							<cfoutput>
								<li class="item">#application.rbFactory.getKeyValue(session.rb,'sitemanager.noresults')#</li>
							</cfoutput>
						</cfif>
					</ul>
			</div>

			<!--- Cross-Site Related Search --->
			<cfloop list="#contentPoolSiteIDs#" index="siteId">
				<cfset started=false>
				<cfif siteId neq $.event('siteid') and len($.event("keywords"))>
					<cfset rc.rslist=getRelatedFeed($,siteId).getQuery()>
					<cfset started=false>

					<div class="draggableContainmentInternal list-table search-results">
						<div class="list-table-content-set">
							<cfoutput>#$.getBean('settingsManager').getSite(siteId).getSite()#:
							#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.searchresults')# <cfif rc.rslist.recordcount>(1-#min(rc.rslist.recordcount,100)# of #rc.rslist.recordcount#)</cfif></cfoutput>
						</div>
						<ul class="rcDraggable list-table-items">
							<cfoutput query="rc.rslist" startrow="1" maxrows="100">
								<cfsilent>
									<cfset crumbdata=application.contentManager.getCrumbList(rc.rslist.contentid, rc.rslist.siteid)/>
									<cfset verdict=application.permUtility.getnodePerm(crumbdata)/>
									<cfif verdict neq 'none'>
										<cfset started=true>
									</cfif>
								</cfsilent>
								<cfif verdict neq 'none'>
								<!---<cfif arrayLen(crumbdata) and structKeyExists(crumbdata[1],"parentArray") and not listFind(arraytolist(crumbdata[1].parentArray),rc.contentid)>--->
									<li class="item" data-content-type="#esapiEncode('html_attr','#rc.rslist.type#/#rc.rslist.subtype#')#" data-contentid="#rc.rslist.contentID#">
										<button class="btn mura-rc-quickoption" type="button" value="#rc.rslist.contentID#"><i class="mi-plus"></i></button>  #$.dspZoomNoLinks(crumbdata=crumbdata, charLimit=90, minLevels=2)#
									</li>
								</cfif>
							</cfoutput>
							<cfif not started>
								<cfoutput>
									<li class="item">#application.rbFactory.getKeyValue(session.rb,'sitemanager.noresults')#</li>
								</cfoutput>
							</cfif>
						</ul>
					</div>
				</cfif>
			</cfloop>
		</div>
	<cfelse>
		<cfscript>
			sample=$.getBean(rc.entitytype);
			feed=sample.getFeed().maxItems(100);
			searchableProps=sample.getSearchableProps();
			if(arrayLen(searchableProps) && len(rc.keywords)){
				feed.where();
				feed.openGrouping();
				for(p in searchableProps){
					feed.orProp(p).containsValue(rc.keywords);
				}
				feed.closeGrouping();
			}

			results=feed.getIterator();

		</cfscript>
		<cfoutput>

		<div class="mura-control-group mura-related-ui mura-related-ui__#esapiEncode('html_attr',rc.entitytype)#">
			<cfset started=false>
				<div class="draggableContainmentInternal list-table search-results">
					<div class="list-table-content-set">
							#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.relatedcontent.searchresults')# <cfif results.getRecordcount()>(1-#min(results.getRecordcount(),100)# of #results.getRecordcount()#)</cfif>
					</div>
					<ul class="rcDraggable list-table-items">
						<cfif results.hasNext()>
							<cfloop condition="results.hasNext()">
								<cfset item=results.next()>
								<cfset started=false>
								<li class="item" data-content-type="custom/#esapiEncode('html_attr','#rc.entitytype#')#" data-contentid="#item.get(item.getPrimaryKey())#">
									<button class="btn mura-rc-quickoption" type="button" value="#item.get(item.getPrimaryKey())#"><i class="mi-plus"></i></button>
									<i class="mi-cube"></i> <cfloop array="#sample.getListViewProps()#" index="p"><cfif started>, </cfif>#esapiEncode('html',item.get(p))#<cfset started=true></cfloop>
								</li>
							</cfloop>
						<cfelse>
								<li class="item">#application.rbFactory.getKeyValue(session.rb,'sitemanager.noresults')#</li>
						</cfif>
					</ul>
			</div>
			</cfoutput>

	</cfif>

	<!--- end not isnew --->
</cfif>
