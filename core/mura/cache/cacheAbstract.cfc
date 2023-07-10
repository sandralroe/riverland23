//  license goes here 
/**
 * This provide basic factory methods for cache factories
 */
component output="false" extends="mura.baseobject" hint="This provide basic factory methods for cache factories" {
	variables.parent = "";
	variables.javaLoader = "";
	//  main collection 
	variables.collections = "";
	variables.collection = "";
	variables.map = "";
	variables.utility="";
	//  default variables 

	public function init() output=false {
		variables.collections = createObject( "java", "java.util.Collections" );
		variables.collection = "";
		variables.map = createObject( "java", "java.util.HashMap" ).init();
		variables.utility=application.utility;
		//  set the map into the collections 
		setCollection( variables.map );
		return this;
	}
	//  *************************
	//  GLOBAL 
	//  *************************

	public function getHashKey(required string key) output=false {
		return hash( arguments.key, "MD5" );
	}

	public function setParent(required parent) output=false {
		variables.parent = arguments.parent;
	}

	public function getParent() output=false {
		return variables.parent;
	}

	public boolean function hasParent() output=false {
		return isObject( variables.parent );
	}

	private function setCollection(required struct collection) output=false {
		variables.collection = arguments.collection;
	}
	//  *************************
	//  COMMON 
	//  *************************

	public function get(required string key) output=false {
		var hashedKey = getHashKey( arguments.key );
		var cacheData=structNew();
		//  check to see if the item is in the parent 
		//  only if a parent is present 
		if ( !has( arguments.key ) && hasParent() && getParent().has( arguments.key ) ) {
			return getParent().get( arguments.key );
		}
		//  check to make sure the key exists within the factory collection 
		if ( has( arguments.key ) ) {
			//  if it's a soft reference then do a get against the soft reference 
			cacheData=variables.collection.get( hashedKey );
			if ( isSoftReference( cacheData.object ) ) {
				//  is it still a soft reference 
				//  if so then return it 
				return cacheData.object.get();
			} else {
				//  return the object from the factory collection 
				return cacheData.object;
			}
		}
		throw( message="Key '#arguments.key#' was not found within the map collection" );
	}

	public function getAll() output=false {
		return variables.collection;
	}

	public function set(required string key, required any obj, boolean isSoft="false", timespan="") output=false {
		var softRef = "";
		var hashedKey = getHashKey( arguments.key );
		var cacheData=structNew();
		if ( arguments.timespan != '' ) {
			cacheData.expires=now() + arguments.timespan;
		} else {
			cacheData.expires=dateAdd("yyyy",1,now()) + 0;
		}
		//  check to see if this should be a soft reference 
		if ( arguments.isSoft ) {
			//  create the soft reference 
			cacheData.object = createObject( "java", "java.lang.ref.SoftReference" ).init( arguments.obj );
		} else {
			//  assign object to main collection 
			cacheData.object =arguments.obj;
		}
		//  assign object to main collection 
		variables.collection.put( hashedKey, cacheData );
	}

	public function size() output=false {
		return variables.map.size();
	}

	public boolean function keyExists(key) output=false {
		return isStruct( variables.collection ) && structKeyExists( variables.collection , arguments.key );
	}

	public boolean function has(required string key) output=false {
		var refLocal = structnew();
		var hashLocal=getHashKey( arguments.key );
		var cacheData="";
		refLocal.tmpObj=0;
		//  Check for Object in Cache. 

		if ( keyExists( hashLocal ) ) {
			cacheData=variables.collection.get( hashLocal );
			if ( isNumeric(cacheData.expires) && cacheData.expires > (now() + 0) ) {
				if ( isSoftReference( cacheData.object ) ) {
					refLocal.tmpObj =cacheData.object.get();
					return structKeyExists(refLocal, "tmpObj");
				}
				return true;
			} else {
				return false;
			}
		} else {
			return false;
		}
	}
	//  *************************
	//  PURGE 
	//  *************************

	public function purgeAll() output=false {
		variables.collections = createObject( "java", "java.util.Collections" );
		variables.collection = "";
		variables.map = createObject( "java", "java.util.HashMap" ).init();
		init();
	}

	public function purge(required string key) output=false {
		//  check to see if the id exists 
		if ( variables.map.containsKey( getHashKey( arguments.key ) ) ) {
			//  delete from map 
			variables.map.remove( getHashKey( arguments.key ) );
		}
	}
	//  *************************
	//  JAVALOADER 
	//  *************************

	public function setJavaLoader(required any javaLoader) output=false {
		variables.javaLoader = arguments.javaLoader;
	}

	public function getJavaLoader() output=false {
		return variables.javaLoader;
	}
	//  *************************
	//  SOFT REFERENCE 
	//  *************************

	private boolean function isSoftReference(required any obj) output=false {
		if ( isdefined("arguments.obj") && isObject( arguments.obj ) && variables.utility.checkForInstanceOf( arguments.obj, "java.lang.ref.SoftReference") ) {
			return true;
		}
		return false;
	}

	public function getCollection() output=false {
		return variables.collection;
	}

}
