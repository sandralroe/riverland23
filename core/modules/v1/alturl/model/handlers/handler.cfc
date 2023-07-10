<cfcomponent output="false" extends="mura.baseobject">
	<!--- This is set to allow the tab in the admin to read the correct name --->
	<cfset this.pluginName = "Alternate URLs">

	<cfscript>
		public any function onRenderStart(Mura) {
			// no Mura Content
			if (Mura.content().exists() && Mura.content().getIsOnDisplay()) {
				if(Mura.siteConfig('cache')){
					var cache=Mura.siteConfig().getCacheFactory(name="data");
					var cacheKey=Mura.content('siteid') & Mura.content('contentid') & 'renderstartredirects';
					var redirectCount=cache.get(cacheKey,'');
					
					if(!isdefined('redirectcount')){
 					   redirectcount='';
					}

					if(isNumeric(redirectCount)){
						commitTracePoint(initTracePoint(detail="DATA CACHE HIT: {class: onRenderStart redirects, key: #cacheKey#}"));
					} else {
						commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: onRenderStart redirects, key: #cacheKey#}"));
					}
				} else {
					var redirectCount=1;
				}

				if(!isNumeric(redirectCount) || redirectCount){
					var tracePoint=initTracePoint(detail="onRenderStart redirects");

					var altURLit = Mura.getFeed('alturl')
						.where()
						.prop('contenthistid').isEQ(Mura.content('contenthistid'))
						.andProp('ismuracontent').isEQ(1)
						.getIterator();

					if(Mura.siteConfig('cache')){
						cache.set(cacheKey,altURLit.getRecordCount());
					}
					// have Mura content with redirect -- temporary "link"
					if (isStruct(altURLit) && altURLit.hasNext()) {
						item = altURLit.next();
						var content = Mura.getBean('content').loadBy(filename=item.get('alturl'));
						if(content.exists() && content.getFilename() != Mura.content('filename')){	
							if(len(item.get('statuscode')) && listFind('301,302',item.get('statuscode'))) {
								if(content.get('type') == 'Link'){
									var linkurl=content.get('body');
									var curqs=Mura.getCurrentQueryString();
									if(len(curqs) > 1 && find('?',linkurl)){
										linkurl=linkurl & '&' & right(curqs,len(curqs)-1);
									} else {
										linkurl=linkurl & curqs;
									}
									Mura.redirect(location=linkurl,addToken=false,statusCode=item.getstatuscode());
								} else {
									Mura.redirect(location=content.getURL(complete=true,queryString=Mura.getCurrentQueryString()),addToken=false,statusCode=item.getstatuscode());
								}
							} else {
								content.set('canonicalURL',content.getURL(complete=true));
								Mura.event('muraForceFilename',false);
								Mura.event('content',content);
							}
						} else if (!content.exists() && item.get('alturl') != Mura.content('filename')){
							Mura.redirect(location=Mura.createHREF(filename=item.get('alturl'),queryString=Mura.getCurrentQueryString(),complete=true),addToken=false,statusCode=item.getstatuscode());
						}
					}

					commitTracePoint(tracePoint);
				}
			}
		}

		public any function onSiteRequestStart(Mura){

			if(len(request.currentfilename) && getServiceFactory().containsBean(listFirst(request.currentfilename,'.'))){
				return;
			}

			if(Mura.siteConfig('cache')){
				var cache=Mura.siteConfig().getCacheFactory(name="data");
				var cacheKey=Mura.event('siteid') & request.currentfilename & 'requeststartredirects';
				var redirectCount=cache.get(cacheKey,'');

				if(!isdefined('redirectcount')){
						redirectcount='';
				}

				if(isNumeric(redirectCount)){
					commitTracePoint(initTracePoint(detail="DATA CACHE HIT: {class: onSiteRequestStart redirects, key: #cacheKey#}"));
				} else {
					commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: onSiteRequestStart redirects, key: #cacheKey#}"));
				}
			} else {
				var redirectCount=1;
			}


			if(!isNumeric(redirectCount) || redirectCount){
				var changesetIDList='';
				var previewData=getCurrentUser().getValue("ChangesetPreviewData");
				var tracePoint=initTracePoint(detail="onSiteRequestStart redirects");
				var filename=request.currentfilename;
				
				if(!len(filename)){
					filename="null";
				}

				if(isDefined('previewData.changesetIDList')){
					changesetIDList=previewData.changesetIDList;
				}

				// (from URL to Mura Bean)
				var altURLit = Mura.getFeed('alturl')
					.where()
					.prop('alturl').isEQ(filename)
					.andProp('ismuracontent').isEQ(0)
					.getIterator();
				
				if(Mura.siteConfig('cache')){
					cache.set(cacheKey,altURLit.getRecordCount());
				}
			
				if (altURLit.hasNext()) {
					var altURL=altURLit.next();
					var content=Mura.getBean('content').loadBy(contenthistid=altURL.get('contenthistid'));
				
					if(content.exists() 
						&& (content.getActive() 
							|| (len(changesetIDList)
								&& len(content.getChangesetid())
								&& listFindNoCase(changesetIDList,content.getChangesetid())
							)
						)
						&& content.getIsOnDisplay()){
						if(len(altURL.get('statuscode')) && listFind('301,302',altURL.get('statuscode'))) {
							Mura.redirect(location=content.getURL(complete=true,queryString=Mura.getCurrentQueryString()),addToken=false,statusCode=altURL.getstatuscode());
						} else {
							content.set('canonicalURL',content.getURL(complete=true));
							Mura.event('muraForceFilename',false);
							Mura.event('contentBean',content);
						}
					}
				}
				commitTracePoint(tracePoint);
			}
		}

	</cfscript>

	<cffunction name="onBeforeContentSave" >
		<cfargument name="Mura">

		<cfset var content = Mura.event('newBean') />

		<cfif StructKeyExists(form, "fieldnames") 
			and len(arguments.Mura.event('alturluiid'))
			and arguments.Mura.event('alturluiid') eq content.getContentID()>
			
			<cfset var redirectErrors = content.getErrors() />
			<cfset var redirectcount=0>
			<!--- get a list of the field names --->
			<cfset var sortedFormFields = ListSort(form.fieldnames, "Text")>
				<!--- loope that list field names --->
				<cfloop index="thefield" list="#sortedFormFields#">
					<!--- filter by the "alturl_" for each redirect added--->
					<cfif FindNoCase("alturl_", thefield)>
						<cfscript>

							// if we find a match above, and it has a value
							// set it to the redirect bean
							if(len(Mura.event('#thefield#'))){
								// load the bean by the redirect id portion of the input name
								var alturlid=listLast(#thefield#,'_');
								var theAltURL = Mura.getBean('alturl');
								// set the form value as a var for replacing logic below
								var	altURLFormValue = trim(form['#thefield#']);

								var altstatuscode='';

								if(structKeyExists(form,'altstatuscode_#alturlid#')){
									altstatuscode=form['altstatuscode_#alturlid#'];
								}
								// If the user added a trailing slash remove it
								if (right(altURLFormValue,1) == '/') {
									altURLFormValue = left(altURLFormValue,len(altURLFormValue)-1);
								}

								// If the user added a preceeding slash remove it
								if (left(altURLFormValue,1) == '/') {
									altURLFormValue = right(altURLFormValue,len(altURLFormValue)-1);
								}
								//replace any html and replace spaces with hyphens
								altURLFormValue = Mura.stripHTML(altURLFormValue);
								altURLFormValue = replaceNoCase(altURLFormValue,' ', '-','ALL');

								theAltURL.set({
										alturlid=alturlid,
										alturl=altURLFormValue,
										ismuracontent=Mura.event('ismuracontent'),
										statuscode=altstatuscode,
										datecreated=createODBCDateTime(now()),
										lastUpdateById=Mura.currentUser('userid')
									});

								content.addObject(theAltURL);

								if(content.get('isMuraContent')==0){
									theAltURL.validate();

									if(theAltURL.hasErrors()){
										structAppend(content.getErrors(),theAltURL.getErrors());
									}
								}

								redirectcount=redirectcount+1;

								if(content.get('isMuraContent')==1 && redirectcount > 1){
									content.getErrors().redirectcount="When redirect from a content node you can only have one";
								}
							}
						</cfscript>
					</cfif>
				</cfloop>
				<cfscript>
					var cache=Mura.siteConfig().getCacheFactory(name="data");
					cache.purge(content.get('siteid') & content.get('contentid') & 'renderstartredirects');
					cache.purge(content.get('siteid') & content.get('filename') & 'requeststartredirects');
				</cfscript>
			</cfif>
	</cffunction>

</cfcomponent>