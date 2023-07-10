/* license goes here */
/**
 * This provides a proxy to larger content data
 */
component extends="mura.baseobject" output="false" hint="This provides a proxy to larger content data" {
	variables.instance=structNew();
	variables.instance.content="";
	variables.instance.struct=structNew();
	variables.iterator="";

	public function setContentManager(contentManager) {
		variables.contentManager=arguments.contentManager;
		return this;
	}

	public function setSettingsManager(settingsManager) {
		variables.settingsManager=arguments.settingsManager;
		return this;
	}

	function getPrimaryKey(){
		return 'contentid';
	}

	function getEntityName(){
		return 'content';
	}

	function getIsNew(){
		return 0;
	}

	public function translatePropKey(property){
		if(arguments.property eq 'primaryKey'){
			return getPrimaryKey();
		}
		return arguments.property;
	}

	/**
	 * Handles missing method exceptions.
	 */
	public function OnMissingMethod(required string MissingMethodName, required struct MissingMethodArguments) output=false {
		var prop="";
		var prefix=left(arguments.MissingMethodName,3);
		var theValue="";
		var bean="";
		if ( len(arguments.MissingMethodName) ) {
			//  forward normal getters to the default getValue method
			if ( listFindNoCase("set,get",prefix) && len(arguments.MissingMethodName) > 3 ) {
				prop=right(arguments.MissingMethodName,len(arguments.MissingMethodName)-3);
				if ( prefix == "get" ) {
					return getValue(prop);
				} else if ( prefix == "set" && !structIsEmpty(MissingMethodArguments) ) {
					setValue(prop,MissingMethodArguments[1]);
					return this;
				}
			}
			//  otherwise get the bean and if the method exsists forward request
			bean=getContentBean();
			if ( !structIsEmpty(MissingMethodArguments) ) {
					theValue=bean.invokeMethod( methodArguments=MissingMethodArguments,  methodName=MissingMethodName );
			} else {
					theValue=bean.invokeMethod( methodName=MissingMethodName );
			}
			if ( isDefined("theValue") ) {
				return theValue;
			} else {
				return "";
			}
		} else {
			return "";
		}
	}
	
	public function set(contentStruct, sourceIterator) output=true {
		if(isStruct(arguments.contentStruct)){
			//Original
			variables.instance.struct=arguments.contentStruct;
			variables.sourceiterator=arguments.sourceIterator;
			if ( isObject(variables.instance.content) ) {
				variables.instance.content.setIsNew(1);
			}
			//End Original
		} else if( isSimpleValue(arguments.contentStruct)) {
			setValue(arguments.contentStruct,arguments.sourceIterator);
		}

		return this;
	}
	
	public function get(property) output=false {
		return getValue(arguments.property);
	}

	public function getValue(property) output=false {
		if ( len(arguments.property) ) {
			if ( isDefined("this.get#arguments.property#") ) {
				var tempFunc=this["get#arguments.property#"];
				return tempFunc();
			} else if ( structKeyExists(variables.instance.struct,"#arguments.property#") ) {
				return variables.instance.struct["#arguments.property#"];
			} else if ( isValid('variableName', arguments.property) ) {
				//throw(message=arguments.property);
				//dump(arguments.property);abort;
				return invoke(getContentBean(),'get#arguments.property#');
			} else {
				return getContentBean().getValue(arguments.property);
			}
		} else {
			return "";
		}
	}

	public function setValue(property, propertyValue) output=false {
		if ( isDefined("this.set#arguments.property#") ) {
			var tempFunc=this["set#arguments.property#"];
			tempFunc(arguments.propertyValue);
		} else {
			variables.instance.struct[arguments.property]=arguments.propertyValue;
			getContentBean().setValue(arguments.property, arguments.propertyValue);
		}
		return this;
	}

	function getHasManyPropArray(){
		param name='application.objectMappings.content.hasMany' default=[];
		return application.objectMappings.content.hasMany;
	}

	function getHasOnePropArray(){
		param name='application.objectMappings.content.hasOne' default=[];
		return application.objectMappings.content.hasOne;
	}

	public function getContent(){
		return getContentBean();
	}

	public function hasContentBean(){
		return isObject(variables.instance.content);
	}

	public function hasContent(){
		return hasContentBean();
	}

	public function getDynamic(){
		return false;
	}

	public function getScaffold(){
		return false;
	}

	public function getOrderBy(){
		return "lastupdate desc";
	}

	public function getContentBean() output=false {
		//throw(message="test");
		if ( !isObject(variables.instance.content) ) {
			variables.instance.content=getBean("content");
			variables.instance.content.setIsNew(1);
			variables.instance.contentStructTemplate=structCopy(variables.instance.content.getAllValues(autocomplete=false));
		}
		if ( !variables.instance.content.getIsNew() ) {
			return variables.instance.content;
		} else {
			variables.instance.content.setAllValues( structCopy(variables.instance.contentStructTemplate) );
			if ( structKeyExists(variables.instance.struct,"contentHistID") ) {
				variables.instance.content=variables.contentManager.getContentVersion(contentHistID=variables.instance.struct.contentHistID, siteID=variables.instance.struct.siteID, contentBean=variables.instance.content, sourceIterator=variables.sourceIterator);
			} else if ( structKeyExists(variables.instance.struct,"contentID") ) {
				variables.instance.content=variables.contentManager.getActiveContent(contentID=variables.instance.struct.contentID,siteID=variables.instance.struct.siteID, contentBean=variables.instance.content, sourceIterator=variables.sourceIterator);
			} else {
				throw( message="The query you are iterating over does not contain either contentID or contentHistID" );
			}
			variables.instance.content.setValue('sourceIterator',variables.sourceiterator);
			return variables.instance.content;
		}
	}

	public function getAllValues(expand="true") output=false {
		if ( arguments.expand ) {
			return getContentBean().getAllValues(argumentCollection=arguments);
		} else {
			return variables.instance.struct;
		}
	}

	public function getParent() output=false {
		var i="";
		var cl=0;
		if ( structKeyExists(request,"crumbdata") ) {
			cl=arrayLen(request.crumbdata)-1;
			if ( cl ) {
				for ( i=1 ; i<=cl ; i++ ) {
					if ( request.crumbdata[i].contentID == getValue("contentID") ) {
						return getBean("contentNavBean").set(request.crumbData[i+1],"active");
					}
				}
			}
		}
		return getContentBean().getParent();
	}

	public function getCrumbArray(required sort="asc", required boolean setInheritance="false") output=false {
		return variables.contentManager.getCrumbList(contentID=getValue("contentID"), siteID=getValue("siteID"), setInheritance=arguments.setInheritance, path=getValue("path"), sort=arguments.sort);
	}

	public function getCrumbIterator(required sort="asc", required boolean setInheritance="false") output=false {
		var a=getCrumbArray(setInheritance=arguments.setInheritance,sort=arguments.sort);
		var it=getBean("contentIterator");
		it.setArray(a);
		return it;
	}

	public function getURL(required querystring="", required boolean complete="false", required string showMeta="0", secure="false",useEditRoute=false) output=false {
		return variables.contentManager.getURL(this, arguments.queryString, arguments.complete, arguments.showMeta, arguments.secure,arguments.useEditRoute);
	}

	public function getAssocURL() output=false {
		if ( getValue('type') == 'Link' ) {
			return getValue('body');
		} else {
			return variables.contentManager.getURL(this,'',true);
		}
	}

	public function getImageURL(required size="undefined", direct="true", complete="false", height="", width="", defaultURL="", secure="false", useProtocol="true") output=false {
		arguments.bean=this;
		if(isDefined('arguments.default')){
			arguments.defaultURL=arguments.default;
		}
		return variables.contentManager.getImageURL(argumentCollection=arguments);
	}

	public function getFileMetaData(property="fileid") output=false {
		return getBean('fileMetaData').loadBy(contentid=getValue('contentid'),contentHistID=getValue('contentHistID'),siteID=getValue('siteid'),fileid=getValue(arguments.property));
	}

	public function getRelatedContentQuery(required boolean liveOnly="false", required date today="#now()#", string sortBy="orderno", string sortDirection="asc", string relatedContentSetID="", string name="", boolean reverse="false") output=false {
		return variables.contentManager.getRelatedContent(getValue('siteID'), getValue('contentHistID'), arguments.liveOnly, arguments.today, arguments.sortBy, arguments.sortDirection, arguments.relatedContentSetID, arguments.name, arguments.reverse, getValue('contentID'));
	}

	public function getRelatedContentIterator(required boolean liveOnly="false", required date today="#now()#", string sortBy="orderno", string sortDirection="asc", string relatedContentSetID="", string name="", boolean reverse="false") output=false {
		var q=getRelatedContentQuery(argumentCollection=arguments);
		var it=getBean("contentIterator");
		it.setQuery(q);
		return it;
	}

	//This is duplicated in the contentBean
	public function getEditUrl(required boolean compactDisplay="false", tab, required complete="false", required hash="false", required instanceid='') output=false {
		var returnStr="";
		var topID="00000000000000000000000000000000001";
		if ( listFindNoCase("Form,Component", getValue('type')) ) {
			topID=getValue('moduleid');
		}
		if ( arguments.compactDisplay ) {
			arguments.compactDisplay='true';
		}

		if(len(arguments.instanceid)){
			returnStr= "#getBean('configBean').getAdminPath(complete=arguments.complete)#/?muraAction=cArch.editLive&contentId=#esapiEncode('url',getValue('contentid'))#&type=#esapiEncode('url',getValue('type'))#&siteId=#esapiEncode('url',getValue('siteid'))#&instanceid=#esapiEncode('url',arguments.instanceid)#&compactDisplay=#esapiEncode('url',arguments.compactdisplay)#";
		} else {
			returnStr= "#getBean('configBean').getAdminPath(complete=arguments.complete)#/?muraAction=cArch.edit&contenthistid=#esapiEncode('url',getValue('contenthistid'))#&contentid=#esapiEncode('url',getValue('contentid'))#&type=#esapiEncode('url',getValue('type'))#&siteid=#esapiEncode('url',getValue('siteid'))#&topid=#esapiEncode('url',topID)#&parentid=#esapiEncode('url',getValue('parentid'))#&moduleid=#esapiEncode('url',getValue('moduleid'))#&compactdisplay=#esapiEncode('url',arguments.compactdisplay)#";
		}

		if ( structKeyExists(arguments,"tab") ) {
			returnStr=returnStr & "##" & arguments.tab;
		}
		if ( arguments.hash ) {
			var redirectid=getBean('utility').createRedirectId(returnStr);
			returnStr=getBean('settingsManager').getSite(getValue('siteid')).getContentRenderer().createHREF(complete=arguments.complete,filename=redirectid);
		}
		return returnStr;
	}

	public function hasImage(usePlaceholder="true") {
		return variables.contentManager.hasImage(bean=this,usePlaceholder=arguments.usePlaceholder);
	}

	public struct function getExtendedAttributes(name="") output=false {
		return getContentBean().getExtendedAttributes(name=arguments.name);
	}

	public function getExtendedAttributesList(name="") output=false {
		return StructKeyList(getExtendedAttributes(name=arguments.name));
	}

	public function getExtendedAttributesQuery(name="") output=false {
		return getContentBean().getExtendedAttributesQuery(name=arguments.name);
	}

	public function setDisplayInterval(displayInterval) output=false {
		if ( !isSimpleValue(arguments.displayInterval) ) {
			if ( isValid('component',arguments.displayInterval) ) {
				arguments.displayInterval=arguments.displayInterval.getAllValues();
			}
			if ( isDefined('arguments.displayInterval.end') ) {
				if ( arguments.displayInterval.end == 'on'
	and isDefined('arguments.displayInterval.endon')
	and isDate(arguments.displayInterval.endon) ) {
					setValue('displayStop',arguments.displayInterval.end);
				} else if ( arguments.displayInterval.end == 'after'
		and isDefined('arguments.displayInterval.endafter')
		and isNumeric(arguments.displayInterval.endafter)
		or arguments.displayInterval.end == 'never' ) {
					if ( isDate(getValue('displayStop')) ) {
						setValue('displayStop',dateAdd('yyyy',100,getValue('displayStop')));
					} else {
						setValue('displayStop',dateAdd('yyyy',100,getValue('displayStart')));
					}
				}
			}
			arguments.displayInterval=serializeJSON(arguments.displayInterval);
		}
		variables.instance.struct.displayInterval=arguments.displayInterval;
		getContentBean().setValue("displayInterval", arguments.displayInterval);
		return this;
	}

	public function getDisplayIntervalDesc() output=false {
		return getBean('settingsManager').getSite(getValue('siteid')).getContentRenderer().renderIntervalDesc(this);
	}

	public function getDisplayInterval(serialize="false") output=false {
		if ( structKeyExists(variables.instance.struct,"displayInterval") ) {
			var result=variables.instance.struct["displayInterval"];
		} else {
			var result=getContentBean().getValue("displayInterval");
		}
		if ( !arguments.serialize ) {
			return getBean('contentDisplayInterval').set(getBean('contentIntervalManager').deserializeInterval(
				interval=result,
				displayStart=getValue('displayStart'),
				displayStop=getValue('displayStop')
			)).setContent(this);
		} else {
			return result;
		}
	}

	public function getKidsQuery(required aggregation="false", required applyPermFilter="false", required size="0", required sortBy="#getValue('sortBy')#", required sortDirection="#getValue('sortDirection')#", required nextN="#getValue('nextN')#", today=now(), categoryid='', useCategoryIntersect=false ) output=false {
		arguments.parentid=getValue('contentid');
		arguments.siteid=getValue('siteid');
		return variables.contentManager.getKidsQuery(argumentCollection=arguments);
	}

	public function getKidsIterator(required liveOnly="true", required aggregation="false", required applyPermFilter="false", required size="0", required sortBy="#getValue('sortBy')#", required sortDirection="#getValue('sortDirection')#", required nextN="#getValue('nextN')#", today=now(), categoryid='', useCategoryIntersect=false)output=false {
		var q="";
		var it=getBean("contentIterator");
		if ( arguments.liveOnly ) {
			q=getKidsQuery(argumentCollection=arguments);
		} else {
			arguments.parentid=getValue('contentid');
			arguments.siteid=getValue('siteid');
			q=variables.contentManager.getNest(argumentCollection=arguments);
		}
		it.setQuery(q,arguments.nextn);
		return it;
	}

	function getPermissions(){
		var isSuperUser=getCurrentUser().isSuperUser();
		var permissions={
			read=isSuperUser,
			delete=isSuperUser,
			save=isSuperUser,
			role=(isSuperUser)?'editor':'none'
		};

		if(!isSuperUser && get('siteid') != ''){
			var r=getBean('permUtility').setRestriction(this.getCrumbArray());

			switch(r.perm){
				case "editor":
					permissions.delete=true;
				case 'author':
					permissions.save=true;
					permissions.role=r.perm
				case 'read':
					permissions.read=true;
			}		
		}
		return permissions;
	}

}