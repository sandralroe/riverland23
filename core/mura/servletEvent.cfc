/* license goes here */
/**
 * This provides specialized methods to the primary front end request event object
 */
component output="false" extends="mura.baseobject" hint="This provides specialized methods to the primary front end request event object" {

	public function init() output=false {

		if (NOT IsDefined("request"))
	    request=structNew();
		StructAppend(request, url, "no");
		StructAppend(request, form, "no");

		if (IsDefined("request.muraGlobalEvent")){
			StructAppend(request, request.muraGlobalEvent.getAllValues(), "no");
			StructDelete(request,"muraGlobalEvent");
		}
		param name="request.doaction" default="";
		param name="request.month" default=month(now());
		param name="request.year" default=year(now());
		param name="request.display" default="";
		param name="request.startrow" default=1;
		param name="request.pageNum" default=1;
		param name="request.keywords" default="";
		param name="request.tag" default="";
		param name="request.mlid" default="";
		param name="request.noCache" default=0;
		param name="request.categoryID" default="";
		param name="request.relatedID" default="";
		param name="request.linkServID" default="";
		param name="request.track" default=1;
		param name="request.exportHTMLSite" default=0;
		param name="request.returnURL" default="";
		param name="request.showMeta" default=0;
		param name="request.forceSSL" default=0;
		param name="request.muraForceFilename" default=true;
		param name="request.muraSiteIDInURL" default=false;

		setValue('HandlerFactory',application.pluginManager.getStandardEventFactory(getValue('siteid')));
		setValue("MuraScope",new mura.MuraScope());
		getValue('MuraScope').setEvent(this);
		return this;
	}

	public function setValue(required string property, propertyValue="", required scope="request") output=false {
		var theScope=getScope(arguments.scope);
		theScope["#arguments.property#"]=arguments.propertyValue;
		return this;
	}

	public function set(required string property, defaultValue, required scope="request") output=false {
		return setValue(argumentCollection=arguments);
	}

	public function getValue(required string property, defaultValue, required scope="request") output=false {
		var theScope=getScope(arguments.scope);
		if ( structKeyExists(theScope,"#arguments.property#") ) {
			return theScope["#arguments.property#"];
		} else if ( structKeyExists(arguments,"defaultValue") ) {
			theScope["#arguments.property#"]=arguments.defaultValue;
			return theScope["#arguments.property#"];
		} else {
			return "";
		}
	}

	public function get(required string property, defaultValue, required scope="request") output=false {
		return getValue(argumentCollection=arguments);
	}

	public function getAllValues(required scope="request") output=false {
		return getScope(arguments.scope);
	}

	public struct function getScope(required scope="request") output=false {
		switch ( arguments.scope ) {
			case  "request":
				return request;
				break;
			case  "form":
				return form;
				break;
			case  "url":
				return url;
				break;
			case  "session":
				return session;
				break;
			case  "server":
				return server;
				break;
			case  "application":
				return application;
				break;
			case  "attributes":
				return attributes;
				break;
			case  "cluster":
				return cluster;
				break;
		}
	}

	public function valueExists(required string property, required scope="request") output=false {
		var theScope=getScope(arguments.scope);
		return structKeyExists(theScope,arguments.property);
	}

	public function removeValue(required string property, required scope="request") output=false {
		var theScope=getScope(arguments.scope);
		structDelete(theScope,arguments.property);
	}

	public function getHandler(handler) output=false {
		return getValue('HandlerFactory').get(arguments.handler & "Handler",getValue("localHandler"));
	}

	public function getValidator(validation) output=false {
		return getValue('HandlerFactory').get(arguments.validation & "Validator",getValue("localHandler"));
	}

	public function getTranslator(translator) output=false {
		return getValue('HandlerFactory').get(arguments.translator & "Translator",getValue("localHandler"));
	}

	public function getContentRenderer() output=false {
		return getValue('contentRenderer');
	}

	/**
	 * deprecated: use getContentRenderer()
	 */
	public function getThemeRenderer() output=false {
		return getContentRenderer();
	}

	public function getContentBean() output=false {
		return getValue('contentBean');
	}

	public function getCrumbData() output=false {
		return getValue('crumbdata');
	}

	public function getSite() output=false {
		return application.settingsManager.getSite(getValue('siteid'));
	}

	public function getMuraScope() output=false {
		return getValue("MuraScope");
	}

	public function getBean(beanName, siteID) output=false {
		if ( structKeyExists(arguments,"siteid") ) {
			return super.getBean(arguments.beanName,arguments.siteID);
		} else {
			return super.getBean(arguments.beanName,getValue('siteid'));
		}
	}

}
