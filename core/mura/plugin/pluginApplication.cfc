/* license goes here */
/**
 * This provides the ability to manage plugin specific application level variables
 */
component extends="mura.baseobject" output="false" hint="This provides the ability to manage plugin specific application level variables" {
	variables.properties=structNew();
	variables.wired=structNew();
	variables.pluginConfig="";

	public function init(any data="#structNew()#") output=false {
		variables.properties=arguments.data;
		variables.utility=getBean('utility');
		return this;
	}

	public function setPluginConfig(pluginConfig) output=false {
		variables.pluginConfig=arguments.pluginConfig;
	}

	public function setValue(required string property, required propertyValue="", required autowire="false") output=false {
		variables.properties[arguments.property]=arguments.propertyValue;
		structDelete(variables.wired,arguments.property);
		if ( arguments.autowire && isObject(arguments.propertyValue) ) {
			doAutowire(variables.properties[arguments.property]);
			variables.wired[arguments.property]=true;
		}
	}

	public function doAutowire(cfc) output=false {
		var i="";
		var property="";
		var setters="";
		if ( application.cfversion > 8 ) {
			setters=findImplicitAndExplicitSetters(arguments.cfc);
			for ( i in setters ) {
				wireProperty(arguments.cfc,i);
			}
		} else {
			for ( i in arguments.cfc ) {
				if ( len(i) > 3 && left(i,3) == "set" ) {
					property=right(i,len(i)-3);
					wireProperty(arguments.cfc,property);
				}
			}
		}
		return arguments.cfc;
	}

	private function wireProperty(object, property) output=false {
		var args=structNew();
		if ( arguments.property != "value" ) {
			if ( arguments.property == "pluginConfig" ) {
				args[arguments.property] = variables.pluginConfig;
				variables.utility.invokeMethod(component=arguments.object,methodName="set#arguments.property#",args=args);
			} else if ( structKeyExists(variables.properties,arguments.property) ) {
				args[arguments.property] = variables.properties[arguments.property];
				variables.utility.invokeMethod(component=arguments.object,methodName="set#arguments.property#",args=args);
			} else if ( getServiceFactory().containsBean(arguments.property) ) {
				args[arguments.property] = getBean(arguments.property);
				variables.utility.invokeMethod(component=arguments.object,methodName="set#arguments.property#",args=args);
			}
		}
	}
	//  Ported from FW1

	private function findImplicitAndExplicitSetters(cfc) output=false {

		//Moved all the varing to top of method for CF8 compilation.
		var baseMetadata = getMetadata( arguments.cfc );
		var setters = { };
		var md = "";
		var n = "";
		var property = "";
		var i = "";
		var implicitSetters = "";
		var member = "";
		var method = "";

		// is it already attached to the CFC metadata?
		if ( structKeyExists( baseMetadata, '__fw1_setters' ) )  {
			setters = baseMetadata.__fw1_setters;
		} else {
			md = { extends = baseMetadata };
			do {
				md = md.extends;
				implicitSetters = false;
				// we have implicit setters if: accessors="true" or persistent="true"
				if ( structKeyExists( md, 'persistent' ) and isBoolean( md.persistent ) ) {
					implicitSetters = md.persistent;
				}
				if ( structKeyExists( md, 'accessors' ) and isBoolean( md.accessors ) ) {
					implicitSetters = implicitSetters or md.accessors;
				}
				if ( structKeyExists( md, 'properties' ) ) {
					// due to a bug in ACF9.0.1, we cannot use var property in md.properties,
					// instead we must use an explicit loop index... ugh!
					n = arrayLen( md.properties );
					for ( i = 1; i lte n; i=i+1 ) {
						property = md.properties[ i ];
						if ( implicitSetters ||
								structKeyExists( property, 'setter' ) and isBoolean( property.setter ) and property.setter ) {
							setters[ property.name ] = 'implicit';
						}
					}
				}
			} while ( structKeyExists( md, 'extends' ) );
			// cache it in the metadata (note: in Railo 3.2 metadata cannot be modified
			// which is why we return the local setters structure - it has to be built
			// on every controller call; fixed in Railo 3.3)
			baseMetadata.__fw1_setters = setters;
		}
		// gather up explicit setters as well
		for ( member in arguments.cfc ) {
			method = arguments.cfc[ member ];
			n = len( member );
			if ( isCustomFunction( method ) and left( member, 3 ) eq 'set' and n gt 3 ) {
				 property = right( member, n - 3 );
				setters[ property ] = 'explicit';
			}
		}
		return setters;
	}

	public function getValue(required string property, required defaultValue="", required autowire="true") output=false {
		var returnValue="";
		if ( structKeyExists(variables.properties,arguments.property) ) {
			returnValue=variables.properties[arguments.property];
		} else {
			variables.properties[arguments.property]=arguments.defaultValue;
			returnValue=variables.properties[arguments.property];
		}
		if ( arguments.autowire && isObject(returnValue) && !structKeyExists(variables.wired,arguments.property) ) {
			doAutowire(returnValue);
			variables.wired[arguments.property]=true;
		}
		return returnValue;
	}

	public function getAllValues() output=false {
		return variables.properties;
	}

	public function valueExists(required string property) output=false {
		return structKeyExists(variables.properties,arguments.property);
	}

	public function removeValue(required string property) output=false {
		structDelete(variables.properties,arguments.property);
		structDelete(variables.wired,arguments.property);
	}

	/**
	 * This is for fw1 autowiring
	 */
	public function containsBean(required string property) output=false {
					return (structKeyExists(variables.properties,arguments.property) && isObject(variables.properties[arguments.property]))
	 				|| getServiceFactory().containsBean(arguments.property) || arguments.property == "pluginConfig";
	}

				/**
	 * This is for fw1 autowiring
	 */
	public function getBean(required string property) output=false {
			if ( arguments.property == "pluginConfig" ) {
				return variables.pluginConfig;
			} else if ( getServiceFactory().containsBean(arguments.property) ) {
				return getServiceFactory().getBean(arguments.property);
			} else {
				return getValue(arguments.property);
			}
		}

	}
