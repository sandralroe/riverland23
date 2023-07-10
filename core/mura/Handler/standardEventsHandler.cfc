//  license goes here 
/**
 * This provides default implementation for standard events that can be overridden through event system
 */
component extends="mura.baseobject" output="false" hint="This provides default implementation for standard events that can be overridden through event system" {
	// - HANDLERS 

	public function standardEnableLockdownHandler(required event,required $) output=false {
		if(request.returnFormat=='JSON'){
			request.muraJSONRedirectURL=arguments.$.siteConfig().getResourcePath(complete=true) & "/?lockdown=" & esapiEncode('url',$.siteConfig().getEnableLockdown());
		} else {
			if ( fileExists(expandPath('/muraWRM/config/lockdown.cfm')) ) {
				include "/muraWRM/config/lockdown.cfm";
			} else {
				include "/muraWRM/core/templates/lockdown.cfm";
			}
		}
	}

	public function standardWrongDomainHandler(required event,required $) output=false {
		if ( request.returnFormat == 'JSON' ) {
			request.muraJSONRedirectURL=arguments.$.getCurrentURL(complete=true,domain=arguments.$.siteConfig('domain'));
		} else {
			arguments.$.redirect(arguments.$.getCurrentURL(complete=true,domain=$.siteConfig('domain')));
		}
	}

	public function standardTranslationHandler(required $) output=false {

		param name="request.returnFormat" default="HTML";

		if(!listFindNoCase("HTML,JSON,AMP",request.returnFormat)){
			request.returnFormat="HTML";
		}
		
		arguments.$.event().getTranslator('standard#uCase(request.returnFormat)#').translate(arguments.$);
	}

	public function standardTrackSessionHandler(required event) output=false {
		application.sessionTrackingManager.trackRequest(arguments.event.getValue('siteID'),arguments.event.getValue('path'),arguments.event.getValue('keywords'),arguments.event.getValue('contentBean').getcontentID());
	}

	public function standardSetPreviewHandler(required event) output=false {
		arguments.event.setValue('track',0);
		arguments.event.setValue('nocache',1);
		arguments.event.setValue('contentBean',application.contentManager.getcontentVersion(arguments.event.getValue('previewID'),arguments.event.getValue('siteID'),true));
	}

	public function standardSetPermissionsHandler(required event) output=false {
		getBean("userUtility").returnLoginCheck(arguments.event.getValue("MuraScope"));
		if ( isArray(arguments.event.getValue('crumbdata')) && arrayLen(arguments.event.getValue('crumbdata')) ) {
			arguments.event.setValue('r',application.permUtility.setRestriction(arguments.event.getValue('crumbdata')));
			if ( arguments.event.getValue('r').restrict ) {
				arguments.event.setValue('nocache',1);
			}
		}
	}

	public function standardSetCommentPermissionsHandler(required event) output=false {
		arguments.event.setValue('muraAllowComments', 1);
	}

	public function standardSetCommenterHandler(required event) output=false {
		var remoteID = "";
		var commenter = event.getValue('commenterBean');
		var comment = event.getValue('commentBean');
		if ( !comment.getIsNew() ) {
			//  update existing commenter 
			commenter.loadBy(commenterID=comment.getUserID());
		} else {
			//  set up new commenter 
			if ( getCurrentUser().isLoggedIn() ) {
				remoteID = getCurrentUser().getUserID();
			} else if ( len(comment.getEmail()) > 0 ) {
				remoteID = comment.getEmail();
			}
			commenter.loadBy(remoteID=remoteID);
			commenter.setRemoteID(remoteID);
		}
		commenter.setName(comment.getName());
		commenter.setEmail(comment.getEmail());
		commenter.save();
		comment.setUserID(commenter.getCommenterID());
	}

	public function standardGetCommenterHandler(required event) output=false {
		var commenter = event.getValue('commenterBean');
		var comment = event.getValue('commentBean');
		commenter.loadBy(commenterID=comment.getUserID());
	}

	public function standardSetLocaleHandler(required event) output=false {
		var sessionData=getSession();
		cfparam( default="", name="sessionData.siteID" );
		setLocale(application.settingsManager.getSite(arguments.event.getValue('siteid')).getJavaLocale());
		if ( (not request.mura404 && arguments.event.getValue('contentBean').exists() && sessionData.siteid != arguments.event.getValue('siteid')) || !structKeyExists(sessionData,"locale") ) {
			// These are use for admin purposes
			sessionData.siteID=arguments.event.getValue('siteid');
			sessionData.userFilesPath = "#application.configBean.getAssetPath()#/#arguments.event.getValue('siteid')#/assets/";
			application.rbFactory.resetSessionLocale();
		}
	}

	public function standardSetIsOnDisplayHandler(required event) output=false {
		var crumbdata="";
		var previewData=getCurrentUser().getValue("ChangesetPreviewData");
		if ( isStruct(previewData) && listFind(previewData.contentIdList,"'#arguments.event.getValue("contentBean").getContentID()#'") ) {
			if ( arrayLen(arguments.event.getValue('crumbData')) > 1 ) {
				crumbdata=arguments.event.getValue('crumbdata');
				arguments.event.setValue('isOnDisplay',application.contentUtility.isOnDisplay(arguments.event.getValue('contentBean').getdisplay(),arguments.event.getValue('contentBean').getdisplaystart(),arguments.event.getValue('contentBean').getdisplaystop(),arguments.event.getValue('siteID'),arguments.event.getValue('contentBean').getparentid(),crumbdata[2].type));
			} else {
				arguments.event.setValue('isOnDisplay',application.contentUtility.isOnDisplay(arguments.event.getValue('contentBean').getdisplay(),arguments.event.getValue('contentBean').getdisplaystart(),arguments.event.getValue('contentBean').getdisplaystop(),arguments.event.getValue('siteID'),arguments.event.getValue('contentBean').getparentid(),"Page"));
			}
		} else if ( arguments.event.valueExists('previewID') ) {
			arguments.event.setValue('isOnDisplay',1);
		} else if ( arguments.event.getValue('contentBean').getapproved() == 0 ) {
			arguments.event.setValue('track',0);
			arguments.event.setValue('nocache',1);
			arguments.event.setValue('isOnDisplay',0);
		} else if ( arrayLen(arguments.event.getValue('crumbData')) > 1 ) {
			crumbdata=arguments.event.getValue('crumbdata');
			arguments.event.setValue('isOnDisplay',application.contentUtility.isOnDisplay(arguments.event.getValue('contentBean').getdisplay(),arguments.event.getValue('contentBean').getdisplaystart(),arguments.event.getValue('contentBean').getdisplaystop(),arguments.event.getValue('siteID'),arguments.event.getValue('contentBean').getparentid(),crumbdata[2].type));
		} else {
			arguments.event.setValue('isOnDisplay',1);
		}
	}

	public function standardSetContentRendererHandler(required event) output=false {
		arguments.event.getValue("muraScope").getContentRenderer();
	}

	public function standardSetContentHandler(required event) output=false {
		var renderer=arguments.event.getValue("contentRenderer");
		var themeRenderer=renderer;
		var contentArray="";
		if ( arguments.event.valueExists('previewID') ) {
			arguments.event.getHandler("standardSetPreview").handle(arguments.event);
			arguments.event.setValue('showMeta',1);
		} else {
			//arguments.event.getHandler("standardSetAdTracking").handle(arguments.event);
			if ( !arguments.event.valueExists('contentBean') ) {
				if ( len(arguments.event.getValue('linkServID')) ) {
					arguments.event.setValue('contentBean',application.contentManager.getActiveContent(listFirst(arguments.event.getValue('linkServID')),arguments.event.getValue('siteid'),true));
				} else if ( len(arguments.event.getValue('currentFilenameAdjusted')) &&  application.configBean.getLoadContentBy() == 'urltitle' ) {
					arguments.event.setValue('contentBean',application.contentManager.getActiveByURLTitle(listLast(arguments.event.getValue('currentFilenameAdjusted'),'/'),arguments.event.getValue('siteid'),true));
				} else {
					arguments.event.setValue('contentBean',application.contentManager.getActiveContentByFilename(arguments.event.getValue('currentFilenameAdjusted'),arguments.event.getValue('siteid'),true));
				}
			}
		}
		if ( isArray(arguments.event.getValue('contentBean')) ) {
			contentArray=arguments.event.getValue('contentBean');
			arguments.event.setValue('contentBean',contentArray[1]);
		}
		if ( arguments.event.getValue('contentBean').getType() != 'Variation' ) {
			arguments.event.getValidator("standardWrongFilename").validate(arguments.event);
			arguments.event.getValidator("standard404").validate(arguments.event);
			if ( application.settingsManager.getSite(arguments.event.getValue('siteid')).getUseSSL() ) {
				arguments.event.setValue('forcessl', true);
			} else if ( arguments.event.getValue('contentBean').getForceSSL() ) {
				arguments.event.setValue('forceSSL',arguments.event.getValue('contentBean').getForceSSL());
			}
		}
		if ( !isArray(arguments.event.getValue('crumbdata')) ) {
			arguments.event.setValue('crumbdata',arguments.event.getValue('contentBean').getCrumbArray(setInheritance=true));
		}
		renderer.injectMethod('crumbdata',arguments.event.getValue("crumbdata"));
		if ( isObject(themeRenderer) ) {
			themeRenderer.injectMethod('crumbdata',arguments.event.getValue("crumbdata"));
		}
	}

	public function standardSetAdTrackingHandler(required event) output=false {
		if ( arguments.event.getValue('trackSession') ) {
			arguments.event.setValue('track',1);
		} else {
			arguments.event.setValue('track',0);
		}
	}

	public function standardRequireLoginHandler(required event,required $) output=false {
		var loginURL = "";
		if ( arguments.event.getValue('isOnDisplay') && arguments.event.getValue('r').restrict 
			&& !arguments.event.getValue('r').loggedIn 
			&& !(
				listFindNoCase('login,editProfile,search',arguments.event.getValue('display'))
				 || listFindNoCase('login,create-profile',arguments.event.getValue('contentBean').get('urltitle'))
				) 
		) {
			loginURL = getBean('loginManager').getLoginURL(request.siteid);
			if ( find('?', loginURL) ) {
				loginURL &= "&returnURL=#URLEncodedFormat(arguments.event.getValue('contentRenderer').getCurrentURL())#";
			} else {
				loginURL &= "?returnURL=#URLEncodedFormat(arguments.event.getValue('contentRenderer').getCurrentURL())#";
			}

			getBean('utility').excludeFromClientCache();

			arguments.$.redirect(location=loginURL,statuscode=302);
			
		}
	}

	public function standardPostLogoutHandler(required event,required $) output=false {
		getBean('utility').excludeFromClientCache();
		arguments.$.redirect(location=arguments.$.getCurrentURL(),statuscode=302);
	}

	public function standardMobileHandler(required event) output=false {
		var renderer=arguments.event.getValue("contentRenderer");
		if ( fileExists(ExpandPath( "#arguments.event.getSite().getThemeIncludePath()#/templates/mobile.cfm")) ) {
			arguments.event.getValue("contentBean").setTemplate("mobile.cfm");
			renderer.showAdminToolbar=false;
			renderer.showMemberToolbar=false;
			renderer.showEditableObjects=false;
			renderer.contentListPropertyTagMap={containerEl="ul",itemEl="li",title="h3","default"="p"};
			arguments.event.setValue("muraMobileTemplate",true);
		}
	}

	public function standardWrongFilenameHandler(required event,required $) output=false {
		var currentFilename=arguments.event.getValue('currentFilename');
		var currentFilenameAdjusted=arguments.event.getValue('currentFilenameAdjusted');
		
		if ( !arguments.event.getValue('muraSiteIDRedirect') ) {
			if ( len(currentFilename) && currentFilename != currentFilenameAdjusted ) {
				arguments.event.setValue('currentFilename',arguments.event.getValue('contentBean').getFilename() & right(currentFilename,len(currentFilename)-len(currentFilenameAdjusted)));
			} else {
				arguments.event.setValue('currentFilename',arguments.event.getValue('contentBean').getFilename());
			}
		}
	
		arguments.$.redirect( arguments.$.getCurrentURL(complete=true) );

	}

	public function standardLinkTranslationHandler(required event) output=false {
		arguments.event.getTranslator('standardLink').translate(arguments.event);
	}

	public function standardForceSSLHandler(required $) output=false {
		if ( !application.utility.isHTTPS() ) {
			arguments.$.redirect( "https://#arguments.$.siteConfig('domain')##arguments.$.siteConfig('serverPort')##arguments.$.siteConfig('context')##arguments.$.getCurrentURL(complete=false,filterVars=false)#" );
		}
	}

	public function standardFileTranslationHandler(required event) output=false {
		arguments.event.getTranslator('standardFile').translate(arguments.event);
	}

	public function standardDoResponseHandler(required event) output=false {
		var showMeta=0;
		var renderer=arguments.event.getContentRenderer();
		var translator="";
		arguments.event.getValidator('standardForceSSL').validate(arguments.event);
		
		application.pluginManager.announceEvent(eventToAnnounce='onRenderStart', currentEventObject=arguments.event,objectid=arguments.event.getValue('contentBean').getContentID());

		switch ( arguments.event.getValue('contentBean').getType() ) {
			case  "Link":
			case  "File":
				if ( arguments.event.getValue('isOnDisplay') && ((not arguments.event.getValue('r').restrict) || (arguments.event.getValue('r').restrict && arguments.event.getValue('r').allow)) ) {
					if ( arguments.event.getValue('showMeta') != 1 && !arguments.event.getValue('contentBean').getKidsQuery(size=1).recordcount ) {
						switch ( arguments.event.getValue('contentBean').getType() ) {
							case  "Link":
								if ( !renderer.showItemMeta("Link") || arguments.event.getValue('showMeta') == 2 ) {
									translator=arguments.event.getHandler('standardLinkTranslation');
								} else {
									translator=arguments.event.getHandler('standardTranslation');
								}
								break;
							case  "File":
								if ( !(renderer.showItemMeta(arguments.event.getValue('contentBean').getFileExt()) || renderer.showItemMeta('File') ) || arguments.event.getValue('showMeta') == 2 || listFindNoCase('attachment,inline',arguments.event.getValue('method')) ) {
									
									translator=arguments.event.getHandler('standardFileTranslation');
							
								} else {
									translator=arguments.event.getHandler('standardTranslation');
								}
								break;
						}
					} else {
						
						translator=arguments.event.getHandler('standardTranslation');
					}
				} else {
					translator=arguments.event.getHandler('standardTranslation');
				}
				break;
			default:
				translator=arguments.event.getHandler('standardTranslation');
				break;
		}
		
		translator.handle(arguments.event);
		application.pluginManager.announceEvent(eventToAnnounce='onRenderEnd',currentEventObject=arguments.event,objectid=arguments.event.getValue('contentBean').getContentID());
	}

	public function standard404Handler(required event, required $) output=false {
		if ( arguments.event.getValue("contentBean").getIsNew() ) {
			getPluginManager().announceEvent(eventToAnnounce="onSite404",currentEventObject=arguments.event,objectid=arguments.event.getValue('contentBean').getContentID());
		}
		if ( arguments.event.getValue("contentBean").getIsNew() ) {
			request.mura404=true;
			var local.filename=arguments.event.getValue('currentFilenameAdjusted');
			while ( listLen(local.filename,'/') ) {
				var archived=getBean('contentFilenameArchive').loadBy(filename=local.filename,siteid=event.getValue('siteid'));
				if ( !archived.getIsNew() ) {
					var archiveBean=getBean('content').loadBy(contentid=archived.getContentID(),siteid=event.getValue('siteid'));
					if ( !archiveBean.getIsNew() ) {
						if ( local.filename == event.getValue('currentFilenameAdjusted') ) {
							arguments.$.redirect(archiveBean.getURL());
							return true;
						} else {
							archiveBean=getBean('content').loadBy(filename=replace(arguments.event.getValue('currentFilenameAdjusted'),local.filename,archiveBean.getFilename()),siteid=event.getValue('siteid'));
							if ( !archiveBean.getIsNew() ) {
								arguments.$.redirect(archiveBean.getURL());
								return true;
							}
						}
					} else {
						archived.delete();
					}
				}
				local.filename=listDeleteAt(local.filename,listLen(local.filename,'/'),'/');
			}
		}
		if ( !isdefined('request.muraJSONRedirectURL') && arguments.event.getValue("contentBean").getIsNew() ) {
			arguments.event.setValue('contentBean',application.contentManager.getActiveContentByFilename("404",arguments.event.getValue('siteid'),true));
			if ( len(arguments.event.getValue('previewID')) ) {
				arguments.event.getContentBean().setBody("The requested version of this content could not be found.");
			}
			if ( request.returnFormat != 'json' && request.muraFrontEndRequest && !arguments.$.siteConfig('isremote') ) {
				cfheader( statustext="Content Not Found", statuscode=404 );
			}
			var renderer=arguments.$.getContentRenderer();
			if ( isDefined('renderer.noIndex') ) {
				renderer.noIndex();
			}
		}
	}

	public function standardDoActionsHandler(required event, $) output=false {
		var a="";
		if ( arguments.event.getValue('doaction') != '' ) {
			for ( a in arguments.event.getValue('doaction') ) {
				doAction(a,arguments.event,arguments.$);
			}
		}
	}

	public function doAction(string theaction="", required event, $) output=false {
		switch ( arguments.theaction ) {
			case  "login":
				if ( fileExists(expandPath("/#application.configBean.getWebRootMap()#/#arguments.event.getValue('siteid')#/includes/loginHandler.cfc")) ) {
					new "#application.configBean.getWebRootMap()#.#arguments.event.getValue('siteid')#.includes.loginHandler"().handleLogin(arguments.event.getAllValues());
				} else {
					if ( !arguments.$.getContentRenderer().validateCSRFTokens || arguments.$.validateCSRFTokens(context='login') ) {
						var loginManager=arguments.$.getBean('loginManager');
						if ( isBoolean(arguments.$.event('attemptChallenge')) && arguments.$.event('attemptChallenge') ) {
							arguments.$.event('failedchallenge', !loginManager.handleChallengeAttempt(arguments.$));
							loginManager.completedChallenge(arguments.$);
						} else if ( isDefined('form.username') && isDefined('form.password') ) {
							loginManager.login(arguments.$.event().getAllValues(),'');
						}
					}
				}
				break;
			case  "return":
				application.emailManager.track(arguments.event.getValue('emailID'),arguments.event.getValue('email'),'returnClick');
				break;
			case  "logout":
				application.loginManager.logout();
				arguments.event.getHandler("standardPostLogout").handle(arguments.event);
				break;
			case  "updateprofile":
				var sessionData=getSession();
				if ( sessionData.mura.isLoggedIn ) {
					var eventStruct=arguments.event.getAllValues();
					structDelete(eventStruct,'isPublic');
					structDelete(eventStruct,'s2');
					structDelete(eventStruct,'type');
					structDelete(eventStruct,'groupID');
					eventStruct.userid=sessionData.mura.userID;
					arguments.event.setValue("userID",sessionData.mura.userID);
					if ( !arguments.$.getContentRenderer().validateCSRFTokens || arguments.$.validateCSRFTokens(context='editprofile') ) {
						arguments.event.setValue('passedProtect', arguments.$.getBean('utility').isHuman(arguments.event));
						if ( isDefined('request.addressAction') ) {
							if ( arguments.event.getValue('addressAction') == "create" ) {
								application.userManager.createAddress(eventStruct);
							} else if ( arguments.event.getValue('addressAction') == "update" ) {
								application.userManager.updateAddress(eventStruct);
							} else if ( arguments.event.getValue('addressAction') == "delete" ) {
								application.userManager.deleteAddress(arguments.event.getValue('addressID'));
							}
							//  reset the form 
							arguments.event.setValue('addressID','');
							arguments.event.setValue('addressAction','');
						} else {
							arguments.event.setValue('userBean',application.userManager.update( getBean("user").loadBy(userID=arguments.event.getValue("userID")).set(eventStruct).getAllValues() , iif(event.valueExists('groupID'),de('true'),de('false')),true,arguments.event.getValue('siteID')));
							if ( structIsEmpty(arguments.event.getValue('userBean').getErrors()) ) {
								application.loginManager.loginByUserID(eventStruct);
							}
						}
					} else {
						var userBean=arguments.$.getBean('userBean').loadBy(userid=sessionData.mura.userID).set(eventStruct);
						userBean.validate();
						userBean.getErrors().csfr='Your request contained invalid tokens';
						arguments.event.setValue('userBean',userBean);
					}
				}
				break;
			case  "createprofile":
				if ( application.settingsManager.getSite(arguments.event.getValue('siteid')).getextranetpublicreg() == 1 ) {
					var eventStruct=arguments.event.getAllValues();
					structDelete(eventStruct,'isPublic');
					structDelete(eventStruct,'s2');
					structDelete(eventStruct,'type');
					structDelete(eventStruct,'groupID');
					eventStruct.userid='';
					if ( !arguments.$.getContentRenderer().validateCSRFTokens || arguments.$.validateCSRFTokens(context='editprofile') ) {
						arguments.event.setValue('passedProtect', arguments.$.getBean('utility').isHuman(arguments.event));
						arguments.event.setValue('userBean',  getBean("user").loadBy(userID=arguments.event.getValue("userID")).set(eventStruct).save() );
						if ( structIsEmpty(arguments.event.getValue('userBean').getErrors()) && !arguments.event.valueExists('passwordNoCache') ) {
							application.userManager.sendLoginByUser(arguments.event.getValue('userBean'),arguments.event.getValue('siteid'),arguments.event.getValue('contentRenderer').getCurrentURL(),true);
						} else if ( structIsEmpty(arguments.event.getValue('userBean').getErrors()) && arguments.event.valueExists('passwordNoCache') && arguments.event.getValue('userBean').getInactive() == 0 ) {
							arguments.event.setValue('userID',arguments.event.getValue('userBean').getUserID());
							application.loginManager.loginByUserID(eventStruct);
						}
					} else {
						var userBean=arguments.$.getBean('userBean').set(eventStruct);
						userBean.validate();
						userBean.getErrors().csfr='Your request contained invalid tokens';
						arguments.event.setValue('userBean',userBean);
					}
				}
				break;
		
			case  "subscribe":
				arguments.event.setValue('passedProtect', arguments.$.getBean('utility').isHuman(arguments.event));
				if ( arguments.event.getValue("passedProtect") ) {
					application.mailinglistManager.createMember(arguments.event.getAllValues());
				}
				break;
			case  "unsubscribe":
				application.mailinglistManager.deleteMember(arguments.event.getAllValues());
				break;
			case  "masterSubscribe":
				arguments.event.setValue('passedProtect', arguments.$.getBean('utility').isHuman(arguments.event));
				if ( arguments.event.getValue("passedProtect") ) {
					application.mailinglistManager.masterSubscribe(arguments.event.getAllValues());
				}
				break;
			case  "setReminder":
				arguments.event.setValue('passedProtect', arguments.$.getBean('utility').isHuman(arguments.event));
				if ( arguments.event.getValue("passedProtect") ) {
					application.contentManager.setReminder(arguments.event.getValue('contentBean').getcontentid(),arguments.event.getValue('siteID'),arguments.event.getValue('email'),arguments.event.getValue('contentBean').getdisplaystart(),arguments.event.getValue('interval'));
				}
				break;
			case  "forwardEmail":
				arguments.event.setValue('passedProtect', arguments.$.getBean('utility').isHuman(arguments.event));
				if ( arguments.event.getValue("passedProtect") ) {
					arguments.event.setValue('to',arguments.event.getValue('to1'));
					arguments.event.setValue('to',listAppend(arguments.event.getValue('to'),arguments.event.getValue('to2')));
					arguments.event.setValue('to',listAppend(arguments.event.getValue('to'),arguments.event.getValue('to3')));
					arguments.event.setValue('to',listAppend(arguments.event.getValue('to'),arguments.event.getValue('to4')));
					arguments.event.setValue('to',listAppend(arguments.event.getValue('to'),arguments.event.getValue('to5')));
					application.emailManager.forward(arguments.event.getAllValues());
				}
				break;
		}
	}
	//  VALIDATORS 

	public function standardEnableLockdownValidator(required event,Mura) output=false {
		var valid = false;
		var renderer = Mura.siteConfig().getContentRenderer();
		var enableLockdown = Mura.siteConfig().getEnableLockdown();
		var isStaticRoute=request.muraAPIRequest && (
			Mura.siteConfig('isremote')
			&& (
				renderer.hasEditRoute() && isBoolean(Mura.event('isEditRoute')) && !Mura.event('isEditRoute')
				|| len(Mura.event('renderMode')) && Mura.event('renderMode') == 'static'
			) 
		); 
		
		if(listFindNoCase('development,archived',enableLockdown) && !getCurrentUser().isPassedLockdown()){
			var doLockdown=true;
		} else if(enableLockdown=='maintenance' && !(getCurrentUser().isLoggedIn()|| getCurrentUser().isPassedLockdown())){
			var doLockdown=true;
		} else {
			var doLockdown=false;
		}

		if(doLockdown){
			request.cacheItem=false;
			getBean('utility').excludeFromClientCache();
		}
		
		if (doLockdown && !isStaticRoute) {	
			if ( event.getValue('locks') == "true" ) {
				if ( enableLockdown == "development" || enableLockdown == 'archived' ) {
					//  all member types, set 'passedLockdown' cookie 
					valid = getBean('userUtility').login(event.getValue('locku'), event.getValue('lockp'), request.siteID, true, event.getValue('expires'));
				} else if ( enableLockdown == "maintenance" ) {
					//  only admin users, log user in 
					valid = getBean('userUtility').login(event.getValue('locku'), event.getValue('lockp'), '', false, '');
				}
			} 
			
			if ( !valid ) {
				arguments.event.getHandler("standardEnableLockdown").handle(arguments.event);
			}
		}
	}

	public function standardWrongDomainValidator(required event) output=false {
		var host=getBean('utility').getRequestHost();
		
		if ( request.returnFormat == 'HTML' && !len(arguments.event.getValue("previewID")) && (application.configBean.getMode() == 'production' && yesNoFormat(arguments.event.getValue("muraValidateDomain"))
		and !application.settingsManager.getSite(request.siteID).isValidDomain(domain:host, mode: "either",enforcePrimaryDomain=true))
			and !(host == 'LOCALHOST' && cgi.HTTP_USER_AGENT == 'vspider') ) {
			arguments.event.getHandler("standardWrongDomain").handle(arguments.event);
		}
	}

	public function standardTrackSessionValidator(required $) output=false {
		if ( arguments.event.getValue('trackSession')
			and len(arguments.$.content().getcontentID())
			and arguments.$.content().getIsNew() == 0
			and !arguments.$.event().valueExists('previewID')
			and arguments.$.siteConfig().getShowDashboard()
			and arguments.$.globalConfig().getSessionHistory() ) {
			arguments.$.event().getHandler("standardTrackSession").handle(arguments.event);
		}
	}

	public function standardRequireLoginValidator(required event) output=false {
		if (arguments.event.getValue('isOnDisplay') && arguments.event.getValue('r').restrict
			and !arguments.event.getValue('r').loggedIn
			and  !(
				listFindNoCase('login,editProfile,search',arguments.event.getValue('display'))
				 || listFindNoCase('login,create-profile',arguments.event.getValue('contentBean').get('urltitle'))
				) 
		) {
			arguments.event.getHandler("standardRequireLogin").handle(arguments.event);
		}
	}

	public function standardMobileValidator(required event) output=false {
		if ( !isBoolean(request.muraMobileRequest) ) {
			request.muraMobileRequest=false;
		}
		if ( request.muraMobileRequest && !len(arguments.event.getValue('altTheme')) ) {
			arguments.event.getHandler("standardMobile").handle(arguments.event);
		}
	}

	public function standardWrongFilenameValidator(required event) output=false {
		var requestedfilename=arguments.event.getValue('currentFilenameAdjusted');
		var contentFilename=arguments.event.getValue('contentBean').getFilename();
		var renderer=arguments.event.getContentRenderer();
	
		arguments.event.setValue(
		'muraSiteIDRedirect',
		(isBoolean(renderer.siteIDInURLS)
		and (
				renderer.siteIDInURLS && !request.muraSiteIDInURL
				or !renderer.siteIDInURLS && request.muraSiteIDInURL
			))
		);

		

		if ( (
			request.returnFormat != 'JSON'
				and  arguments.event.getValue('muraForceFilename')
				and contentFilename != '404'
				and len(requestedfilename)
				and requestedfilename != contentFilename

			) || arguments.event.getValue('muraSiteIDRedirect') ) {
			/*
				dump(requestedfilename);
				dump(contentFilename);
				dump(renderer.siteIDInURLS);
				dump(arguments.event.getValue('muraSiteIDRedirect'));
				abort;
			*/
			arguments.event.getHandler("standardWrongFilename").handle(arguments.event);
		}
		
	}

	public function standardForceSSLValidator(required event) output=false {
		var isHTTPS=application.utility.isHTTPS();
		if ( application.settingsManager.getSite(arguments.event.getValue('siteID')).getUseSSL()
		or (
			request.returnFormat == 'HTML'
			and !(len(arguments.event.getValue('previewID')) && isHTTPS)
			and (
				arguments.event.getValue("contentBean").getFilename() != "404"
				and
				(
					arguments.event.getValue('forceSSL') && !isHTTPS
				)
				or	(
					not (arguments.event.getValue('r').restrict || arguments.event.getValue('forceSSL')) && application.utility.isHTTPS()
				)
			)
		) ) {
			arguments.event.getHandler("standardForceSSL").handle(arguments.event);
		}
	}

	public function standard404Validator(required event) output=false {
		if ( arguments.event.getValue('contentBean').getIsNew() == 1 ) {
			arguments.event.getHandler("standard404").handle(arguments.event);
		}
	}
	//  TRANSLATORS 

	public function standardFileTranslator(required $) output=false {
		if ( request.returnFormat == 'JSON' ) {
			var apiUtility=$.siteConfig().getApi('json','v1');
				$.event('__MuraResponse__',
				apiUtility.getSerializer().serialize({
					'apiversion'=apiUtility.getApiVersion(),
					'method'='findOne',
					'params'=apiUtility.getParamsWithOutMethod(form),
					data={
						redirect=$.siteConfig().getResourcePath(complete=true) & '#application.configBean.getIndexPath()#/_api/render/file/?fileid=' & $.content('fileid'),
						statuscode=301
					}
				})
			);
		} else {
			$.getContentRenderer().renderFile($.content('fileid'),$.event('method'),$.event('size'));
		}
	}

	public function standardLinkTranslator(required $) output=false {
		param name="request.muraJSONRedirectURL" default="#$.getContentRenderer().setDynamicContent($.content('body'))#";
		param name="request.muraJSONRedirectStatusCode" default="301";
		
		var theLink=request.muraJSONRedirectURL;

		if ( left(theLink,1) == "?" ) {
			theLink="/" & theLink;
		}

		if ( request.returnFormat == 'JSON' ) {
			var apiUtility=$.siteConfig().getApi('json','v1');
			$.event('__MuraResponse__',
			apiUtility.getSerializer().serialize(
					{'apiversion'=apiUtility.getApiVersion(),
					'method'='findOne',
					'params'=apiUtility.getParamsWithOutMethod(form),
					data={
						redirect=theLink,
						statuscode=request.muraJSONRedirectStatusCode
					}
				})
			);
		} else {
			arguments.$.redirect(location=theLink,statusCode=request.muraJSONRedirectStatusCode);
		}
	}

	public function standardJSONTranslator($) output=false {
		
		try{

			if($.content('type')=='Variation'){
				if($.content('isnew')){
					$.content('notsaved',1);
				}
				$.content('isnew',0);
			}

			var apiUtility=$.siteConfig().getApi('json','v1');
			var result=structCopy($.content().getAllValues());
			var renderer=$.getContentRenderer();
			var editableAttributes=(isdefined('renderer.editableAttributesArray') && isArray(renderer.editableAttributesArray)) ? renderer.editableAttributesArray : [];

			request.cffpJS=true;

			result.template=renderer.getTemplate();
			result.conanicalURL=renderer.getConanicalURL();
			result.metadesc=renderer.getMetaDesc();
			result.isondisplay=$.event('isOnDisplay');

			for(var attr in editableAttributes){
				result['#attr.attribute#']=$.renderEditableAttribute(argumentCollection=attr);
			}

			$.event('response',result);

			result.displayRegions={};
			result.displayRegionNames=listToArray($.siteConfig('columnNames'),'^');
			param name="request.inheritedObjects" default="";
			result.inheritanceid=request.inheritedObjects;
			
			var inheritobjects = (isBoolean($.event('inheritobjects'))) ? $.event('inheritobjects') : true;

			var displayregions=$.event('displayregions');

			for(var r =1;r<=ListLen($.siteConfig('columnNames'),'^');r++){
				var regionName='#replace(listGetAt($.siteConfig('columnNames'),r,'^'),' ','','all')#';
				if(!len(displayregions) || listFindNoCase(displayregions,regionName)){
					result.displayRegions[regionName]=$.dspObjects(columnid=r,returnFormat='array',allowInheritance=inheritobjects);
				}
			}

			if(result.type != 'Variation' && $.globalConfig('htmlEditorType') != 'markdown'){
				result.body=apiUtility.applyRemoteFormat($.dspBody(body=$.content('body'),crumblist=false,renderKids=true,showMetaImage=false));
			}

			result.links=apiUtility.getLinks($.content());

			if(len($.event('expand'))){
				var p='';
				var expandParams={};
				var entity=$.content();
				var expand=$.event('expand');
				var expandAll=(expand=='all' || expand=='*');
				var expanded=1;
				var tracePoint=initTracePoint(detail="Expanding Content: #$.event('expand')#");

				if(arrayLen(entity.getHasManyPropArray())){
					for(p in entity.getHasManyPropArray()){
						if(expandAll || listFindNoCase(expand,p.name)){
							expandParams={maxitems=0,itemsperpage=0};
							expandParams['#entity.translatePropKey(p.loadkey)#']=entity.getValue(entity.translatePropKey(p.column));

							if(p.cfc=='content'){
								if(isDefined('url.showexcludesearch')){
									expandParams.showexcludesearch=url.showexcludesearch;
								}
								if(isDefined('url.includeHomePage')){
									expandParams.includeHomePage=url.includeHomePage;
								}
								if(isDefined('url.shownavonly')){
									expandParams.shownavonly=url.shownavonly;
								}

								expandParams.sortBy=entity.get('sortBy');
								expandParams.sortDirection=entity.get('sortDirection');
							}

							if(isDefined('url.maxitems')){
								expandParams.maxitems=url.maxitems;
							}
							if(isDefined('url.cachedWithin')){
								expandParams.cachedWithin=url.cachedWithin;
							}
							if(isDefined('url.itemsPerPage')){
								expandParams.itemsPerPage=url.itemsPerPage;
							}

							try{
								result[p.name]=apiUtility.findQuery(entityName=p.cfc,siteid=$.event('siteid'),params=expandParams,expand=expand,expanded=expanded,expandedProp=p.name);
							} catch(any e){/*WriteDump(p); abort;*/}
						}
					}
				}

				if(arrayLen(entity.getHasOnePropArray())){
					for(p in entity.getHasOnePropArray()){
						if(expandAll || listFindNoCase(expand,p.name)){
							try{
								if(p.name=='site'){
									result[p.name]=apiUtility.findOne(entityName='site',id=$.event('siteid'),siteid=$.event('siteid'),render=false,variation=false,expand=expand,expanded=expanded,expandedProp=p.name);
								} else {
									result[p.name]=apiUtility.findOne(entityName=p.cfc,id=entity.getValue(entity.translatePropKey(p.column)),siteid=$.event('siteid'),render=false,variation=false,expand=expand,expanded=expanded,expandedProp=p.name);
								}
							} catch(any e){/*WriteDump(p); abort;*/}
						}
					}
				}

				if(expandAll || listFindNoCase(expand,'crumbs')){
					result.crumbs=apiUtility.findCrumbArray(entityName='content',id=entity.getContentID(),siteid=$.event('siteid'),iterator=entity.getCrumbIterator(),expand='',expanded=1,expandedProp='crumbs');
				}

				if(expandAll || listFindNoCase(expand,'relatedcontent')){
					result.relatedcontent=apiUtility.findRelatedContent(entity=entity,siteid=$.event('siteid'),expand='',expanded=1,expandedProp='relatedcontent');
				}

				commitTracePoint(tracePoint);
			}

			var loginURL=$.siteConfig('loginURL');

			if(!len(trim(loginURL)) || findNoCase("display=login",loginURL)){
				loginURL=$.siteConfig().getAdminPath(complete=1) & "?muraAction=clogin.main";
			}

			result.config={
				loginurl=(result.type =='variation') ? $.siteConfig().getAdminPath(complete=1) & "/?muraAction=cLogin.main" : getBean('loginManager').getLoginURL(result.siteid),
				siteid=$.event('siteID'),
				contentid=$.content('contentid'),
				contenthistid=$.content('contenthistid'),
				changesetid=$.content('changesetid'),
				siteID=$.event('siteID'),
				context=$.siteConfig().getRootPath(complete=1),
				nocache=$.event('nocache'),
				assetpath=$.siteConfig().getAssetPath(complete=1),
				sitespath=$.siteConfig().getSitesPath(complete=1),
				corepath=$.siteConfig().getCorePath(complete=1),
				fileassetpath=$.siteConfig().getFileAssetPath(complete=1),
				adminpath=$.siteConfig().getAdminPath(complete=1),
				themepath=$.siteConfig().getThemeAssetPath(complete=1),
				pluginspath=$.siteConfig().getPluginsPath(complete=1),
				rootpath=$.siteConfig().getRootPath(complete=1),
				queueObjects=$.getContentRenderer().queueObjects,
				rb=$.getContentRenderer().getClientRenderVariables(),
				reCAPTCHALanguage=$.siteConfig('reCAPTCHALanguage'),
				preloaderMarkup=renderer.preloaderMarkup,
				mobileformat=$.event('muraMobileRequest'),
				adminpreview=lcase(structKeyExists(url,'muraadminpreview')),
				windowdocumentdomain=$.globalConfig('WindowDocumentDomain'),
				perm=$.event('r').perm,
				restricted=$.event('r').restrict,
				loginurl=loginURL
			};

			if(len($.globalConfig('apiEndpoint'))){
				result.config.apiEndpoint=apiUtility.getEndPoint();
			}

			result.HTMLHeadQueue=$.renderHTMLQueue('head');
			result.HTMLFootQueue=$.renderHTMLQueue('foot');
			result.HTMLBodyStartQueue=$.renderHTMLQueue('bodystart');

			result.id=result.contentid;
			result.links=apiUtility.getLinks($.content());
			result.images=apiUtility.setImageUrls($.content(),'fileid',$);

			var imageAttributes=(isdefined('renderer.imageAttributesArray') && isArray(renderer.imageAttributesArray)) ? renderer.imageAttributesArray : [];
			for(var img in imageAttributes){
				if(isValid('uuid',$.content(img))){
					result['#img#images']=apiUtility.setImageUrls($.content(),img,$);
				}
			}

			getpagecontext().getresponse().setcontenttype('application/json; charset=utf-8');

			$.announceEvent(eventName='onApiResponse',objectid=$.content('contentid'));
			$.announceEvent(eventName='on#result.type#apiresponse',objectid=$.content('contentid'));
			$.announceEvent(eventName='on#result.type##result.subtype#apiresponse',objectid=$.content('contentid'));

			structDelete(result,'addObjects');
			structDelete(result,'removeObjects');
			structDelete(result,'frommuracache');
			structDelete(result,'errors');
			structDelete(result,'instanceid');
			structDelete(result,'primaryKey');
			structDelete(result,'metakeywords');
			structDelete(result,'extenddatatable');
			structDelete(result,'extenddata');
			structDelete(result,'meta');
			structDelete(result,'extendAutoComplete');
			structDelete(result,'lastupdateby');
			structDelete(result,'lastupdatebyid');

			if($.content('type')=='Variation'){
				var variationTargeting=$.content().getVariationTargeting();
				result.initjs=variationTargeting.getInitJS();
				result.targetingjs=variationTargeting.getTargetingJS();
			}

			if(isDefined('request.muraJSONRedirectURL') && len(request.muraJSONRedirectURL)){
				param name="request.muraJSONRedirectStatusCode" default=301;
				result.redirect=request.muraJSONRedirectURL;
				result.statuscode=request.muraJSONRedirectStatusCode;
			}

			$.event('__MuraResponse__',apiUtility.serializeResponse(response={'apiversion'=apiUtility.getApiVersion(),'method'='findOne','params'={filename=result.filename,siteid=result.siteid,rendered=true},data=result},statuscode=200,fireEvents=false));

		} catch (any e){
			result.error = e;
			$.announceEvent(eventName='onapierror',objectid=$.content('contentid'));
			$.event('__MuraResponse__',apiUtility.serializeResponse(response={error=result.error.stacktrace},statuscode=500,fireEvents=false));
		}
		cfcontent( reset=true );
	}

	public function standardAMPTranslator($) output=false {

		$.event().getTranslator('standardHTML').translate(arguments.$);
	}

}