/* license goes here */
component extends="mura.cache.cacheAbstract" hint="This allows Mura to use core CFML caching" output="false" {

	public any function init(name,siteid) {
		lock name="creatingCache#arguments.name##arguments.siteid#" type="exclusive" timeout=90{
			if ( ListFindNoCase('Railo,Lucee',  server.coldfusion.productname) ) {
				variables.collection=new provider.cacheLucee(argumentCollection=arguments);
			} else {
				variables.collection=new provider.cacheAdobe(argumentCollection=arguments);
			}
			variables.map=variables.collection;
		}
		return this;
	}

	public any function set(key,context,timespan=1,idleTime=1) {
		try	{
			variables.collection.put( getHashKey( arguments.key ), arguments.context, arguments.timespan, arguments.idleTime );
		} catch(Any e){
			logError(e);
			return arguments.context;
		}
	}

	public any function get(key, context, timespan=createTimeSpan(1,0,0,0), idleTime=createTimeSpan(1,0,0,0)) {
		var local.exists = has( arguments.key );

		try	{
			if ( local.exists ) {
				return variables.collection.get(getHashKey( arguments.key ));
			} else {
				if ( isDefined("arguments.context") ) {
						set( arguments.key, arguments.context,arguments.timespan,arguments.idleTime );
						return arguments.context;
				} else  if ( hasParent() && getParent().has( arguments.key ) ) {
					return getParent().get( arguments.key );
				} else {
					if ( isDefined("arguments.context") ) {
							return arguments.context;
					} else {
						throw(message="Context not found for '#arguments.key#'");
					}
				}
			}
		} catch(Any e){
			logError(e);
			if ( isDefined("arguments.context") ) {
				set( arguments.key, arguments.context,arguments.timespan,arguments.idleTime );
				return arguments.context;
			} else  if ( hasParent() && getParent().has( arguments.key ) ) {
				return getParent().get( arguments.key );
			} else {
				if ( isDefined("arguments.context") ) {
						return arguments.context;
				} else {
					throw(message="Context not found for '#arguments.key#'");
				}
			}
		}		
	}

	public any function purge(key) {
		try	{
			variables.collection.purge(getHashKey( arguments.key ));
		} catch(Any e){
			logError(e);
		}
	}

	public any function purgeAll() {
		try	{
			variables.collection.purgeAll();
		} catch(Any e){
			logError(e);
		}	
	}

	public any function getAll() {
		try	{
			return variables.collection.getAll();
		} catch(Any e){
			logError(e);
			return [];
		}	
	}

	public any function has(key) {
		try	{
			if ( isDefined('request.purgeCache') && isBoolean(request.purgeCache) && request.purgeCache) {
				return false;
			}
			return variables.collection.has(getHashKey( arguments.key ) );
		} catch(Any e){
			logError(e);
			return false;
		}	
		
	}

	public any function getCollection() {
		return variables.collection;
	}

}
