/* license goes here */
/**
 * This provides a utility to hold the contextual information related to code execution
 */
component output="false" extends="mura.baseobject" hint="This provides a utility to hold the contextual information related to code execution" {
	variables.event=structNew();

	public function init(any data="#structNew()#", $) output=false {
		if ( isStruct(arguments.data) ) {
			variables.event=arguments.data;
		}
		if ( isdefined("form") ) {
			structAppend(variables.event,form,false);
		}
		structAppend(variables.event,url,false);
		if ( structKeyExists(arguments,"$") ) {
			setValue("MuraScope",arguments.$);
		} else {
			setValue("MuraScope",new mura.MuraScope());
		}
		getValue('MuraScope').setEvent(this);
		if ( len(getValue('siteid')) && getBean('settingsManager').siteExists(getValue('siteid')) ) {
			loadSiteRelatedObjects();
		} else {
			setValue("contentRenderer",getBean('contentRenderer'));
		}
		return this;
	}

	public function setValue(required string property, propertyValue="") output=false {
		variables.event["#arguments.property#"]=arguments.propertyValue;
		return this;
	}

	public function set(required string property, defaultValue) output=false {
		return setValue(argumentCollection=arguments);
	}

	public function getValue(required string property, defaultValue) output=false {
		if ( structKeyExists(variables.event,"#arguments.property#") ) {
			return variables.event["#arguments.property#"];
		} else if ( structKeyExists(arguments,"defaultValue") ) {
			variables.event["#arguments.property#"]=arguments.defaultValue;
			return variables.event["#arguments.property#"];
		} else {
			return "";
		}
	}

	public function get(required string property, defaultValue) output=false {
		return getValue(argumentCollection=arguments);
	}

	public function valueExists(required string property) output=false {
		return structKeyExists(variables.event,arguments.property);
	}

	public function removeValue(required string property) output=false {
		structDelete(variables.event,arguments.property);
		return this;
	}

	public function getValues() output=false {
		return variables.event;
	}

	public function getAllValues() output=false {
		return variables.event;
	}

	public function getHandler(handler) output=false {
		if ( isObject(getValue('HandlerFactory')) ) {
			return getValue('HandlerFactory').get(arguments.handler & "Handler",getValue("localHandler"));
		} else {
			throwSiteIDError();
		}
	}

	public function getValidator(validation) output=false {
		if ( isObject(getValue('ValidatorFactory')) ) {
			return getValue('ValidatorFactory').get(arguments.validation & "Validator",getValue("localHandler"));
		} else {
			throwSiteIDError();
		}
	}

	public function getTranslator(translator) output=false {
		if ( isObject(getValue('TranslatorFactory')) ) {
			return getValue('TranslatorFactory').get(arguments.translator & "Translator",getValue("localHandler"));
		} else {
			throwSiteIDError();
		}
	}

	public function getContentRenderer() output=false {
		var renderer=getValue('contentRenderer');
		return getValue('contentRenderer');
		return renderer;
	}

	/**
	 * deprecated: use getContentRenderer()
	 */
	public function getThemeRenderer() output=false {
		return getContentRenderer();
	}

	public function getSite() output=false {
		if ( len(getValue('siteid')) ) {
			return getBean('settingsManager').getSite(getValue('siteid'));
		} else {
			throwSiteIDError();
		}
	}

	public function getServiceFactory() output=false {
		if ( isDefined('application') && structKeyExists(application,'serviceFactory') ) {
			return application.serviceFactory;
		} else if ( structKeyExists(variables,'applicationScope') ) {
			//  in case this is called in the onRequestEnd()
			return variables.applicationScope;
		}
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

	public function throwSiteIDError() output=false {
		throw( message="The 'SITEID' was not defined for this event", type="custom" );
	}

	public function loadSiteRelatedObjects() output=false {
		if ( !isObject(getValue("HandlerFactory")) ) {
			setValue('HandlerFactory',getBean('pluginManager').getStandardEventFactory(getValue('siteid')));
		}
		if ( !valueExists("contentRenderer") ) {
			setValue('contentRenderer',getValue('MuraScope').getContentRenderer());
		}
		setValue('localHandler',getBean('settingsManager').getSite(getValue('siteID')).getLocalHandler());
		return this;
	}

}
