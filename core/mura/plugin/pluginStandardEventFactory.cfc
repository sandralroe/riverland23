/* license goes here */
/**
 * This provides event handler mapping/caching functionality
 */
component extends="mura.cache.cacheAbstract" output="false" hint="This provides event handler mapping/caching functionality" {

	public function init(siteid, standardEventsHandler, pluginManager) output=false {
		variables.siteid=arguments.siteid;
		variables.standardEventsHandler=arguments.standardEventsHandler;
		variables.pluginManager=arguments.pluginManager;
		super.init();
		return this;
	}

	public function get(required string key, required localHandler="") output=false {
		var hashKey = getHashKey( arguments.key );
		var checkKey= "__check__" & arguments.key;
		var localKey=arguments.key;
		var hashCheckKey = getHashKey( checkKey );
		var rs="";
		var event="";
		var classInstance="";
		var wrappedClassInstance="";
		// If the local handler has a locally defined method then use it instead
		// if (NOT arguments.persist or NOT has( localKey )){
		if ( !has( localKey ) ) {
			if ( isObject(arguments.localHandler) && structKeyExists(arguments.localHandler, localKey) ) {
				classInstance=localHandler;
				wrappedClassInstance=wrapHandler(classInstance, localKey);
				// if (arguments.persist){
				super.set( localKey, wrappedClassInstance );
				// }
				return wrappedClassInstance;
			}
			// If there is a non plugin listener then use it instead
			classInstance=variables.pluginManager.getSiteListener(variables.siteID, localKey);
			if ( isObject(classInstance) ) {
				wrappedClassInstance=wrapHandler(classInstance, localKey);
				// if (arguments.persist){
				super.set( localKey, wrappedClassInstance );
				// }
				return wrappedClassInstance;
			}

			classInstance=variables.pluginManager.getGlobalListener(localKey);
			if ( isObject(classInstance) ) {
				wrappedClassInstance=wrapHandler(classInstance, localKey);
				// if (arguments.persist){
				super.set( localKey, wrappedClassInstance );
				// }
				return wrappedClassInstance;
			}
		}
		//  Check if the prelook for plugins has been made
		// if( NOT arguments.persist or NOT has( checkKey )){
		if ( !has( checkKey ) ) {
			rs=variables.pluginManager.getScripts(localKey, variables.siteid);
			//  If it has not then get it
			// if (arguments.persist){
			super.set( checkKey, rs.recordcount );
			// }
			if ( rs.recordcount ) {
				classInstance=variables.pluginManager.getComponent("plugins.#rs.directory#.#rs.scriptfile#", rs.pluginID, variables.siteID, rs.docache);
				wrappedClassInstance=wrapHandler(classInstance, localKey);
				// if (arguments.persist){
				super.set( localKey, wrappedClassInstance );
				// }
				return wrappedClassInstance;
			}
		}
		if ( has( localKey ) ) {
			//  It's already in cache
			return variables.collection.get( getHashKey(localKey) ).object;
		} else {
			//  return cached context
			if ( structKeyExists(variables.standardEventsHandler,localKey) ) {
				wrappedClassInstance=wrapHandler(variables.standardEventsHandler,localKey);
				super.set( localKey, wrappedClassInstance );
			} else {
				wrappedClassInstance=wrapHandler(new "mura.Translator.#localKey#"(),localKey);
			}
			/* if (arguments.persist){
				super.set( localKey, wrappedClassInstance );
			}
			*/
			return wrappedClassInstance;
		}
	}

	public function wrapHandler(handler, eventName) output=false {
		return new mura.plugin.pluginStandardEventWrapper(arguments.handler,arguments.eventName);
	}

	public boolean function has(required string key) output=false {
		return structKeyExists( variables.collection , getHashKey( arguments.key ) );
	}

}
