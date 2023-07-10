/* license goes here */
/**
 * This provides a utility to access all Mura functionality
 */
component extends="mura.baseobject" output="false" hint="This provides a utility to access all Mura functionality" {
	variables.instance.event="";
	
	this.homeid='00000000000000000000000000000000001';

	public function init(data) output=false {
		var initArgs=structNew();
		if ( structKeyExists(arguments,"data") && !(isSimpleValue(arguments.data) && !len(arguments.data)) ) {
			if ( isObject(arguments.data) ) {
				setEvent(arguments.data);
			} else {
				if ( isStruct(arguments.data) ) {
					initArgs=arguments.data;
				} else {
					initArgs.siteID=arguments.data;
				}
				initArgs.muraScope=this;
				setEvent(new mura.event(initArgs).setValue('MuraScope',this));
			}
		}
		structAppend(this,request.customMuraScopeKeys,false);
		return this;
	}

	/**
	 * Handles missing method exceptions.
	 */
	public function OnMissingMethod(required string MissingMethodName, required struct MissingMethodArguments) output=false {
		var local=structNew();
		var object="";
		var prefix="";
		if ( len(arguments.MissingMethodName) ) {
			if ( isObject(getEvent()) && structKeyExists(variables.instance.event,arguments.MissingMethodName) ) {
				object=variables.instance.event;
			} else if ( isObject(getContentRenderer()) && structKeyExists(getContentRenderer(),arguments.MissingMethodName) ) {
				object=getContentRenderer();
			} else if ( structKeyExists(request.customMuraScopeKeys,arguments.MissingMethodName) ) {
				return request.customMuraScopeKeys[arguments.MissingMethodName];
			} else if ( isObject(getContentBean()) ) {
				if ( structKeyExists(getContentBean(),arguments.MissingMethodName) ) {
					object=getContentBean();
				} else {
					prefix=left(arguments.MissingMethodName,3);
					if ( listFindNoCase("set,get",prefix) && len(arguments.MissingMethodName) > 3 ) {
						if ( getContentBean().valueExists(right(arguments.MissingMethodName,len(arguments.MissingMethodName)-3)) ) {
							object=getContentBean();
						} else {
							throw( message="The method '#arguments.MissingMethodName#' is not defined" );
						}
					} else {
						throw( message="The method '#arguments.MissingMethodName#' is not defined" );
					}
				}
			} else {
				throw( message="The method '#arguments.MissingMethodName#' is not defined" );
			}
			savecontent variable="local.thevalue2" {
					if ( !structIsEmpty(arguments.MissingMethodArguments) ) {
						local.theValue1=object.invokeMethod( methodArguments=arguments.MissingMethodArguments, methodName=arguments.MissingMethodName);
					} else {
						local.theValue1=object.invokeMethod(methodName=arguments.MissingMethodName);
					}
			}

			if ( isDefined("local.theValue1") ) {
				return local.theValue1;
			} else if ( isDefined("local.theValue2") ) {
				return local.theValue2;
			} else {
				return "";
			}
		} else {
			return "";
		}
	}

	function getContentRenderer(force="false") output=false {
		if ( arguments.force || !isObject(event("contentRenderer")) ) {
			if ( len(event('siteid')) ) {
				if ( !arguments.force && structKeyExists(request,"contentRenderer") && request.contentRenderer.getValue('siteid') == event('siteid') ) {
					event("contentRenderer",request.contentRenderer);
				} else {
					//  temp fix, may become permanent
					if ( globalConfig().getValue(property='alwaysUseLocalRenderer',defaultValue=false) ) {
						if ( fileExists(application.configBean.getSiteDir() & "/#siteConfig('siteid')#/contentRenderer.cfc") ) {
							event("contentRenderer",new "#globalConfig('sitemap')#.#siteConfig('siteid')#.contentRenderer"(preInit=true) );
						} else {
							event("contentRenderer",new "#globalConfig('sitemap')#.#siteConfig('siteid')#.includes.contentRenderer"(preInit=true) );
						}
					} else {
						if ( fileExists(expandPath("#siteConfig().getIncludePath()#/contentRenderer.cfc")) ) {
							event("contentRenderer",new "#siteConfig().getAssetMap()#.contentRenderer"(preInit=true) );
						} else {
							event("contentRenderer",new "#siteConfig().getAssetMap()#.includes.contentRenderer"(preInit=true) );
						}
					}
					//  end temp fix
					event("contentRenderer").init(event=event(),$=event("muraScope"),mura=event("muraScope") );
					if ( fileExists(expandPath(siteConfig().getThemeIncludePath()) & "/contentRenderer.cfc" ) ) {
						var themeRenderer=new "#siteConfig().getThemeAssetMap()#.contentRenderer"();
						themeRenderer.injectMethod('$',event("muraScope")).injectMethod('mura',event("muraScope")).injectMethod('event',event());
						themeRenderer.init(event=event(),$=event("muraScope"),mura=event("muraScope") );
						var siteRenderer=event("contentRenderer");
						var key='';
						for ( key in themeRenderer ) {
							siteRenderer.injectMethod('#key#',themeRenderer[key]);
						}
					}
					event("contentRenderer").setValue('siteid',event('siteid'));
				}
				event("contentRenderer").postMergeInit();
			} else if ( structKeyExists(application,"contentRenderer") ) {
				event("contentRenderer",getBean('contentRenderer'));
			}
		}
		return event("contentRenderer");
	}

	/**
* deprecated: use getContentRenderer()
*/
function getSiteRenderer() output=false {
		return getContentRenderer();
	}

	/**
* deprecated: use getContentRenderer()
*/
function getThemeRenderer() output=false {
		return getContentRenderer();
	}

	function getContentBean() output=false {
		return event("contentBean");
	}

	function setContentBean(contentBean) output=false {
		if ( isObject(arguments.contentBean) ) {
			return event("contentBean",arguments.contentBean);
		}
		return this;
	}

	function getEvent() output=false {
		if ( !isObject(variables.instance.event) ) {
			if ( structKeyExists(request,"servletEvent") ) {
				variables.instance.event=request.servletEvent;
			} else if ( structKeyExists(request,"event") ) {
				variables.instance.event=request.event;
			} else {
				variables.instance.event=new mura.event($=this);
			}
		}
		return variables.instance.event;
	}

	function getGlobalEvent() output=false {
		var temp="";
		if ( structKeyExists(request,"servletEvent") ) {
			return request.servletEvent;
		} else if ( structKeyExists(request,"event") ) {
			return request.event;
		} else {
			temp=structNew();
			var sessionData=getSession();
			if ( isdefined("sessionData.siteid") ) {
				temp.siteID=sessionData.siteID;
			}
			request.muraGlobalEvent=new mura.event(temp);
			return request.muraGlobalEvent;
		}
	}

	function setEvent(event) output=false {
		if ( isObject(arguments.event) ) {
			variables.instance.event=arguments.event;
		}
		return this;
	}

	function event(property, propertyValue) output=false {
		if ( structKeyExists(arguments,"property") ) {
			if ( isObject(getEvent()) ) {
				if ( structKeyExists(arguments,"propertyValue") ) {
					getEvent().setValue(arguments.property,arguments.propertyValue);
					return this;
				} else {
					return getEvent().getValue(arguments.property);
				}
			} else {
				throw( message="The event is not set in the Mura Scope." );
			}
		} else {
			return getEvent();
		}
	}

	function content(property, propertyValue) output=false {
		if ( structKeyExists(arguments,"property") ) {
			if ( isObject(getContentBean()) ) {
				if ( structKeyExists(arguments,"propertyValue") ) {
					getContentBean().setValue(arguments.property,arguments.propertyValue);
					return this;
				} else {
					return getContentBean().getValue(arguments.property);
				}
			} else {
				throw( message="The content is not set in the Mura Scope." );
			}
		} else {
			return getContentBean();
		}
	}

	function currentUser(property, propertyValue) output=false {
		if ( structKeyExists(arguments,"property") ) {
			if ( structKeyExists(arguments,"propertyValue") ) {
				getCurrentUser().setValue(arguments.property,arguments.propertyValue);
				return this;
			} else {
				return getCurrentUser().getValue(arguments.property);
			}
		} else {
			return getCurrentUser();
		}
	}

	function siteConfig(property, propertyValue) output=false {
		var site="";
		var theValue="";
		var sessionData=getSession();
		var siteID = Len(event('siteid')) ? event('siteid') : IsDefined('sessionData') && StructKeyExists(sessionData, 'siteid')? sessionData.siteid: '';
		if ( len(siteid) ) {
			site=getBean('settingsManager').getSite(siteid);
			if ( structKeyExists(arguments,"property") ) {
				if ( structKeyExists(arguments,"propertyValue") ) {
					site.setValue(arguments.property,arguments.propertyValue);
					return this;
				} else {
					return (IsSimpleValue(site.getValue(arguments.property)) && Len(site.getValue(arguments.property))) || !IsSimpleValue(site.getValue(arguments.property))
			? site.getValue(arguments.property)
			: globalConfig(arguments.property);
				}
			} else {
				return site;
			}
		} else {
			throw( message="The SiteID is not set in the current Mura Scope event." );
		}
	}

	function globalConfig(property, propertyValue) output=false {
		var theValue="";
		if ( structKeyExists(arguments,"property") ) {
			if ( structKeyExists(arguments,"propertyValue") ) {
				var args={'#arguments.property#'=arguments.propertyValue };
				application.configBean.invokeMethod(methodName="set#arguments.property#", methodArguments=args);
				return this;
			} else {
				return application.configBean.invokeMethod(methodName="get#arguments.property#");
			}
		} else {
			return application.configBean;
		}
	}

	function component(property, propertyValue) output=false {
		var componentBean="";
		var component=event('component');
		if ( structKeyExists(arguments,"property") && isStruct(component) ) {
			if ( structKeyExists(arguments,"property") && structKeyExists(component,arguments.property) ) {
				if ( structKeyExists(arguments,"propertyValue") ) {
					component[arguments.property]=arguments.propertyValue;
					return this;
				} else {
					return component[arguments.property];
				}
			} else {
				return "";
			}
		} else if ( isStruct(component) ) {
			componentBean=getBean("content");
			componentBean.setAllValues(component);
			return componentBean;
		} else {
			throw( message="No component has been set in the Mura Scope." );
		}
	}

	function currentURL() output=false {
		return getContentRenderer().getCurrentURL();
	}

	function getParent() output=false {
		var parent="";
		if ( structKeyExists(request,"crumbdata") && arrayLen(request.crumbdata) > 1 ) {
			return getBean("contentNavBean").set(request.crumbdata[2],"active");
		} else if ( isObject(getContentBean()) ) {
			return getContentBean().getParent();
		} else {
			throw( message="No primary content has been set." );
		}
	}

	function hasParent() output=false {
		return structKeyExists(request,"crumbdata") && arrayLen(request.crumbdata) > 1;
	}

	function getBean(beanName, siteID="") output=false {
		if ( len(arguments.siteID) ) {
			return super.getBean(arguments.beanName,arguments.siteID);
		} else {
			return super.getBean(arguments.beanName,event('siteid'));
		}
	}

	function announceEvent(eventName,objectid="",index="0") output=false {
		if(!len(arguments.objectid) && isObject(event('contentBean'))){
			arguments.objectid=event().getValue('contentBean').getContentID();
		}
		getEventManager().announceEvent(eventToAnnounce=arguments.eventName,currentEventObject=this,index=arguments.index,objectid=arguments.objectid);
		return this;
	}

	function renderEvent(eventName,objectid="",index="0") output=false {
		if(!len(arguments.objectid) && isObject(event('contentBean'))){
			arguments.objectid=event().getValue('contentBean').getContentID();
		}
		return getEventManager().renderEvent(eventToRender=arguments.eventName,currentEventObject=this,index=arguments.index,objectid=arguments.objectid);
	}

	function createHREF(required type="Page", required filename="", required siteid="#event('siteid')#", required contentid="", required target="", required targetParams="", required querystring="", required string context="#application.configBean.getContext()#", required string stub="#application.configBean.getStub()#", required string indexFile="", required boolean complete="false", required string showMeta="0") output=false {
		return getContentRenderer().createHref(argumentCollection=arguments);
	}

	function rbKey(key, string locale="") output=false {
		if(!isDefined('request.muraUseSiteBundles')){
			request.muraUseSiteBundles=(isDefined('url.muraAction') && url.muraAction=='cArch.loadclassconfigurator') || !(isDefined('request.muraAdminRequest') && request.muraAdminRequest);
		}
		if ( !request.muraUseSiteBundles ) {
			if ( len(arguments.locale) ) {
				return application.rbFactory.getKeyValue(arguments.locale,arguments.key);
			} else {
				var sessionData=getSession();
				return application.rbFactory.getKeyValue(sessionData.rb,arguments.key);
			}
		} else {
			if ( len(arguments.locale) ) {
				return siteConfig("RBFactory").getKeyValue(arguments.locale,arguments.key);
			} else {
				return siteConfig("RBFactory").getKey(arguments.key);
			}
		}
	}

	function setCustomMuraScopeKey(name, value) output=false {
		this['#arguments.name#']=arguments.value;
		request.customMuraScopeKeys['#arguments.name#']=arguments.value;
	}

	function static(staticDirectory="", staticUrl="", outputDirectory="compiled", minifyMode="package", checkForUpdates="true", addCacheBusters="true", forceCompilation="false", javaLoaderScope="#application.configBean.getValue('cfStaticJavaLoaderScope')#") output=false {
		var hashKey="";
		if ( !len(arguments.staticDirectory) && len(event("siteid")) ) {
			arguments.staticDirectory=ExpandPath(siteConfig("themeIncludePath"));
		}
		hashKey=hash(arguments.staticDirectory);
		if ( !structKeyExists(application.cfstatic,hashKey) ) {
			if ( !len(arguments.staticUrl) ) {
				arguments.staticUrl=replace(globalConfig("context") & right(arguments.staticDirectory,len(arguments.staticDirectory)-len(expandPath("/muraWRM"))), "\","/","all");
			}
			if ( !directoryExists(arguments.staticDirectory & "/compiled") ) {
				getBean("fileWriter").createDir(arguments.staticDirectory & "/compiled");
			}
			application.cfstatic[hashKey]=new org.cfstatic.CfStatic(argumentCollection=arguments);
		}
		return application.cfstatic[hashKey];
	}

	function each(collection, action, $="#this#", delimiters=",") {
		var i="";
		var queryIterator="";
		var test=false;
		var item="";
		if ( structKeyExists(arguments,"mura") ) {
			arguments.$=arguments.mura;
		}
		if ( isObject(arguments.collection) && structKeyExists(arguments.collection,"hasNext") ) {
			arguments.$.event("each:count",arguments.collection.getRecordCount());
			while ( arguments.collection.hasNext() ) {
				item=arguments.collection.next();
				arguments.$.event("each:index",arguments.collection.getRecordIndex());
				test=arguments.action(item=item, $=arguments.$, mura=arguments.$);
				if ( isDefined("test") && isBoolean(test) && !test ) {
					break;
				}
			}
		} else if ( isArray(arguments.collection) && arrayLen(arguments.collection) ) {
			arguments.$.event("each:count",arrayLen(arguments.collection));
			for ( i=1 ; i<=arrayLen(arguments.collection) ; i++ ) {
				arguments.$.event("each:index",i);
				test=arguments.action(item=arguments.collection[i], $=arguments.$, mura=arguments.$);
				if ( isDefined("test") && isBoolean(test) && !test ) {
					break;
				}
			}
		} else if ( isStruct(arguments.collection) ) {
			arguments.$.event("each:count",structCount(arguments.collection));
			arguments.$.event("each:index",0);
			for ( i in arguments.collection ) {
				arguments.$.event("each:index",arguments.$.event("each:index")+1);
				test=arguments.action(item=arguments.collection[i], $=arguments.$, mura=arguments.$);
				if ( isDefined("test") && isBoolean(test) && !test ) {
					break;
				}
			}
		} else if ( isQuery(arguments.collection) ) {
			queryIterator=new mura.iterator.queryIterator();
			queryIterator.setQuery(arguments.collection).init();
			arguments.$.event("each:count",queryIterator.getRecordCount());
			while ( queryIterator.hasNext() ) {
				item=queryIterator.next();
				arguments.$.event("each:index",queryIterator.getRecordIndex());
				test=arguments.action(item=item, $=arguments.$);
				if ( isDefined("test") && isBoolean(test) && !test ) {
					break;
				}
			}
		} else if ( isSimpleValue(arguments.collection) && len(arguments.collection) ) {
			arguments.collection=listToArray(arguments.collection,arguments.delimiters);
			arguments.$.event("each:count",arrayLen(arguments.collection));
			for ( i=1 ; i<=arrayLen(arguments.collection) ; i++ ) {
				arguments.$.event("each:index",i);
				test=arguments.action(item=arguments.collection[i], $=arguments.$, mura=arguments.$);
				if ( isDefined("test") && isBoolean(test) && !test ) {
					break;
				}
			}
		}
	}

	function isHandledEvent(eventName) output=false {
		return structKeyExists(request.muraHandledEvents,arguments.eventName);
	}

	function getCrumbPropertyArray(property, direction="desc") output=false {
		var it=content().getCrumbIterator();
		var propertyArray=[];
		var item="";
		if ( arguments.direction == "desc" ) {
			it.end();
			while ( it.hasPrevious() ) {
				item=it.previous();
				arrayAppend(propertyArray,item.getValue(arguments.property));
			}
		} else {
			while ( it.hasNext() ) {
				item=it.next();
				arrayAppend(propertyArray,item.getValue(arguments.property));
			}
		}
		return propertyArray;
	}

	function validateCSRFTokens() output=false {
		arguments.$=this;
		return currentUser().validateCSRFTokens(argumentCollection=arguments);
	}

	function renderCSRFTokens() output=false {
		return currentUser().renderCSRFTokens(argumentCollection=arguments);
	}

	function generateCSRFTokens() output=false {
		return currentUser().generateCSRFTokens(argumentCollection=arguments);
	}

	function setAdminAlert(key, text, type="") output=false {
		if ( len(event('siteid')) ) {
			if ( len(arguments.type) && !ListFindNoCase('error,warning,success,info', arguments.type) ) {
				arguments.type='';
			}
			var sessionData=getSession();
			param name="sessionData.mura.alerts" default=structNew();
			if ( structKeyExists(sessionData.mura.alerts,'#event('siteid')#') ) {
				sessionData.mura.alerts['#event('siteid')#']={};
			}
			sessionData.mura.alerts['#event('siteid')#']['#arguments.key#']={text=arguments.text,type=arguments.type};
		}
	}

	function removeAdminAlert(key, text) output=false {
		if ( len(event('siteid')) ) {
			var sessionData=getSession();
			param name="sessionData.mura.alerts" default=structNew();
			if ( structKeyExists(sessionData.mura.alerts,'#event('siteid')#') ) {
				sessionData.mura.alerts['#event('siteid')#']={};
			}
			structDelete(sessionData.mura.alerts['#event('siteid')#'],'#arguments.key#');
		}
	}

	function getFeed(entityName) output=false {
		return getBean(arguments.entityName).getFeed();
	}
}
