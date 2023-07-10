/* license goes here */
/**
 * This cache store items in java soft references
 */
component output="false" extends="mura.cache.cacheAbstract" hint="This cache store items in java soft references" {
	variables.isSoft=true;

	/**
	 * Constructor
	 */
	public function init(required boolean isSoft="true", required numeric freeMemoryThreshold="0") output=false {

		super.init( argumentCollection:arguments );
			variables.isSoft = arguments.isSoft;
			variables.freeMemoryThreshold=arguments.freeMemoryThreshold;
			return this;
	}

	public function set(required string key, any context, boolean isSoft="#variables.isSoft#", timespan="") output=false {
		super.set(arguments.key,arguments.context,arguments.isSoft,arguments.timespan);
	}

	public function get(required string key, any context, boolean isSoft="#variables.isSoft#", timespan="") output=false {
		var hashKey = getHashKey( arguments.key );
		//  if the key cannot be found and context is passed then push it in
		if ( !has( arguments.key ) && isDefined("arguments.context") ) {
			if ( hasFreeMemoryAvailable() ) {
				//  create object
				set( arguments.key, arguments.context, arguments.isSoft, arguments.timespan );
			} else {
				return arguments.context;
			}
		}

		//  if the key cannot be found then throw an error
		if ( !has( arguments.key )) {
			throw( message="Context not found for '#arguments.key#'" );
		}
		//  return cached context
		return super.get( arguments.key );
	}

	public boolean function hasFreeMemoryAvailable() output=false {
		if ( variables.freeMemoryThreshold ) {
			if ( getPercentFreeMemory() > variables.freeMemoryThreshold ) {
				return true;
			} else {
				return false;
			}
		} else {
			return true;
		}
	}

	public function getPercentFreeMemory() output=false {
		if ( !structKeyExists(request,"percentFreeMemory") ) {
			var runtime = getJavaRuntime();
			var usedMemory=runtime.totalMemory() - Runtime.freeMemory();
			request.percentFreeMemory=(Round((1-(usedMemory / runtime.maxMemory())) * 100));
		}
		return request.percentFreeMemory;
	}

	public function getJavaRuntime() output=false {
		if ( !structKeyExists(application,"javaRuntime") ) {
			application.javaRuntime=createObject("java","java.lang.Runtime").getRuntime();
		}
		return application.javaRuntime;
	}

}
