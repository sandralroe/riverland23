<cfif this.SSR>
<cfscript>

	function filterResourceHubListArgs(list){
        var candidates=listToArray(list);
        var graduates=[];
        for(var candidate in candidates){
            if(!listFindNoCase('all,*,undefined,[]',candidate)){
                arrayAppend(graduates,candidate);
            }
        }

        return arrayToList(graduates);
    }

	param name="objectParams.sourcetype" default="";
	param name="objectParams.source" default="";
	param name="objectParams.personaids" default="";
	param name="objectParams.categoryids" default="";
	param name="objectParams.subtypes" default="";
	param name="objectParams.source" default="";
	param name="objectParams.layout" default="default";
	param name="this.defaultCollectionDisplayList" default="Image,Date,Title,Summary,Credits,Tags";
	param name="objectParams.displayList" default="#this.defaultCollectionDisplayList#";
	param name="objectParams.items" default="";
	param name="objectParams.maxitems" default="200";
	param name="objectParams.nextN" default="20";
	param name="objectParams.sortBy" default="";
	param name="objectParams.nextnid" default="#createUUID()#";
	param name="objectParams.viewalllink" default="";
	param name="objectParams.viewalllabel" default="";
	param name="objectParams.modalimages" default="false";
	param name="objectParams.scrollpages" default="false";
	param name="objectParams.sortBy" default="releaseDate";
	param name="objectParams.sortDirection" default="desc";


	if(not len(objectparams.layout)){
		objectParams.layout='default';
	}

	objectParams.layout=listLast(replace(objectParams.layout, "\", "/", "ALL"),"/");

	hasMXP=Mura.getServiceFactory().containsBean('marketingManager');

	if (not isDefined('session.mura.mxp')){
		if(hasMXP){
			session.mura.mxp=getBean('marketingManager').getDefaults();
		} else {
			session.mura.mxp={};
		}
	}

	param name="session.mura.mxp.trackingProperties.personaid" default='';
	param name="session.mura.mxp.trackingProperties.stageid" default='';
	param name="session.resourceFilter" default={};
	param name="session.resourceFilter.personaid" default=session.mura.mxp.trackingProperties.personaid;
	param name="session.resourceFilter.lastpersonaid" default='';
	param name="session.resourceFilter.categoryid" default='';
	param name="session.resourceFilter.lastcategoryid" default='';
	param name="session.resourceFilter.subtype" default='';
	param name="session.resourceFilter.lastsubtype" default='';
	param name="session.resourceFilter.hasFilter" default=false;
	param name="form.personaid" default='';
	param name="form.categoryid" default='';
	param name="form.subtype" default='';

	form.personaid=filterResourceHubListArgs(form.personaid);

	if(isdefined("form.newfilter") || len(form.personaid)){
		session.resourceFilter.personaid=form.personaid;
		session.resourceFilter.hasFilter=true;
	}

	form.categoryid=filterResourceHubListArgs(form.categoryid);

	if(isdefined("form.newfilter") || len(form.categoryid)){
		session.resourceFilter.categoryid=form.categoryid;
		session.resourceFilter.hasFilter=true;
	}

	form.subtype=filterResourceHubListArgs(form.subtype);

	if(isdefined("form.newfilter") || len(form.subtype)){
		session.resourceFilter.subtype=form.subtype;
		session.resourceFilter.hasFilter=true;
	}

	showFilter=session.resourceFilter.hasFilter;

	personas=[];

	if(len(objectparams.personaids) && Mura.getServiceFactory().containsBean('persona')){
		personaIterator=Mura.getFeed('persona')
			.where()
			.prop('personaid').isIn(objectparams.personaids)
			.getIterator();

		if(personaIterator.hasNext()){
			personaOptions=listToArray(objectparams.personaids);
			for(pid in personaOptions){
				personaIterator.reset();
				while(personaIterator.hasNext()){
					persona=personaIterator.next();
					if(persona.get('personaid') == pid){
						arrayAppend(personas,persona);
						break;
					}
				}
			}
		}
	}

	categoryIterator=Mura.getFeed('category')
		.where()
		.prop('categoryid').isIn(objectparams.categoryids)
		.getIterator();

	categories=[];

	if(categoryIterator.hasNext()){
		categoryOptions=listToArray(objectparams.categoryids);
		for(cid in categoryOptions){
			categoryIterator.reset();
			while(categoryIterator.hasNext()){
				category=categoryIterator.next();
				if(category.get('categoryid') == cid){
					arrayAppend(categories,category);
					break;
				}
			}
		}
	}

	if(!isNumeric(Mura.event('startrow'))){
		Mura.event('startrow',1);
	}

	excludeIDList=Mura.content('contentid');

	feed=Mura.getFeed('content')
		.where().prop('type').isIn('Page,Link,File')
		.setMaxItems(objectParams.maxitems);

	if(len(objectparams.subtypes)){
		feed.andProp('subtype').isIn(objectparams.subtypes);
	}

	if(len(excludeIDList)){
		feed.andProp('contentid').isNotIn(excludeIDList)
	}
	
	if(len(session.resourceFilter.subtype) && listFindNoCase(objectparams.subtypes,session.resourceFilter.subtype)){
		feed.andProp('subtype').isEQ(session.resourceFilter.subtype);
	}

	// if(hasMXP && len(session.resourceFilter.personaid)){
	// 	feed.sort('mxpRelevance');
	// }

	if(listLen(session.resourceFilter.categoryid) && session.resourceFilter.categoryid neq "all"){
		feed.andProp('categoryid').isIn(session.resourceFilter.categoryid);
		feed.setUseCategoryIntersect(true);
	}

	// if(hasMXP && len(session.resourceFilter.personaid) && listFindNoCase(objectparams.personaids,session.resourceFilter.personaid)){
	// 	form.personaid=session.resourceFilter.personaid;
	// 	feed.setSortBy('mxpRelevance');
	// } else {
	// 	feed.setSortBy('releaseDate');
	// 	feed.setSortDirection('desc');
	// }
	feed.setSortBy(objectParams.sortBy);
	feed.setSortDirection(objectParams.sortDirection);

	feed.andProp('path').containsValue(Mura.content('contentid'));

	iterator=feed.getIterator(cachedWithin=createTimeSpan(0, 0, 0, 5));

	iterator.setNextN(objectParams.nextn);
	
	if(isBoolean(objectParams.scrollpages) and objectParams.scrollpages or variables.$.event('nextnid') eq objectParams.nextnid){
		if(isNumeric(variables.$.event('pageNum')) and variables.$.event('pageNum') gt 1 and ceiling(iterator.getRecordCount() / objectParams.nextN) >= variables.$.event('pageNum')){
			iterator.setPage(variables.$.event('pageNum'));
		} else if( isNumeric(variables.$.event('startrow')) and variables.$.event('startrow') gt 1){
			iterator.setStartRow(variables.$.event('startrow'));
		} else {
			iterator.setPage(1);
		}
	}


	if (session.resourceFilter.hasFilter){
		if (session.resourceFilter.personaid != session.resourceFilter.lastpersonaid){
			//reset to page 1
			variables.$.event('pageNum',1);
			variables.$.event('startrow',1);
			iterator.setStartRow(1);
		}

		if (session.resourceFilter.categoryid != session.resourceFilter.lastcategoryid){
			//reset to page 1
			variables.$.event('pageNum',1);
			variables.$.event('startrow',1);
			iterator.setStartRow(1);
		}

		if (session.resourceFilter.subtype != session.resourceFilter.lastsubtype){
			//reset to page 1
			variables.$.event('pageNum',1);
			variables.$.event('startrow',1);
			iterator.setStartRow(1);
		}

		session.resourceFilter.lastpersonaid = session.resourceFilter.personaid;
		session.resourceFilter.lastcategoryid = session.resourceFilter.categoryid;
		session.resourceFilter.lastsubtype = session.resourceFilter.subtype;
	}
	
</cfscript>
<script>
	Mura(function(){
		Mura('#resource-filter-form select').on('change',function(){
			Mura('#resource-filter-form').submit();
		});
	});
</script>
<cfoutput>

<form id="resource-filter-form">
	<input type="hidden" name="newfilter" value="true">
	<div class="resources__container__filter">
		<div class="filter<cfif showFilter> filter-reveal</cfif>">
			<div class="filter__constrain">
				<!---<div class="filter__constrain__heading">
					<p>View Resources For:</p>
				</div>--->
				<cfif arrayLen(personas)>
				<div class="topic">
					<p>Audience</p>
					<select name="personaid" class="#this.formSelectClass#">
						<option value="">All</option>
						<cfloop array="#personas#" index="persona">
							<option value="#persona.getPersonaID()#"<cfif persona.getPersonaID() eq session.resourceFilter.personaid>selected</cfif>>#esapiEncode('html',persona.getName())#</option>
						</cfloop>
					</select>
				</div>
				</cfif>
				<cfif arrayLen(categories)>
				<cfloop array="#categories#" index="category">
					<cfset subCategeries=Mura.getFeed('category').where().prop('parentid').isEQ(category.getCategoryID()).getIterator()>
					<div class="topic">
						<p>#esapiEncode('html',category.getName())#</p>
						<select name="categoryid" class="#this.formSelectClass#">
							<option value="all">All</option>
							<cfloop condition="subCategeries.hasNext()">
								<cfset subcategory=subCategeries.next()>
								<option value="#subcategory.getCategoryID()#"<cfif listFindNoCase(session.resourceFilter.categoryid,subcategory.getCategoryID())>selected</cfif>>#esapiEncode('html',subcategory.getName())#</option>
							</cfloop>
						</select>
					</div>
				</cfloop>
				</cfif>
				<cfif listLen(objectparams.subtypes) gt 1>
					<div class="type">
						<p>Content Type</p>
						<select name="subtype" class="#this.formSelectClass#">
							<option value="">All</option>
							<cfloop array="#listToArray(objectparams.subtypes)#" index="type">
								<option value="#esapiEncode('html_attr',type)#" <cfif type eq session.resourceFilter.subtype>selected</cfif>>#esapiEncode('html',type)#</option>
							</cfloop>
						</select>
					</div>
				</cfif>
			</div>
		</div>
	</div>
</form>

<cfif iterator.getRecordCount()>
	#variables.$.dspObject_include(
			theFile='collection/layouts/#objectParams.layout#/index.cfm',
			propertyMap=this.contentGridPropertyMap,
			iterator=iterator,
			objectParams=objectParams
		)#
<cfelse>
	<cfoutput>#variables.dspObject_include(thefile='collection/includes/dsp_empty.cfm',objectid=objectParams.source,objectParams=objectParams)#</cfoutput>
</cfif>
</cfoutput>
<cfscript>
	//delete params that we don't want to persist
	structDelete(objectParams,'categoryid');
	structDelete(objectParams,'type');
	structDelete(objectParams,'today');
	structDelete(objectParams,'tag');
	structDelete(objectParams,'startrow');
</cfscript>

<cfelse>
	<cfset objectParams.render="client">
	<cfset objectParams.async=false>
</cfif>