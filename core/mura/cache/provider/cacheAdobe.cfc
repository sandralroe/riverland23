/* License goes here */
component extends="mura.baseobject" output="false" hint="This is used by advanced caching to interact with CFML service"{
	property name="cacheName"
		type="string"
		getter="true"
		setter="true"
		default="data"
		hint="The name of the cache.";

	public any function init(){
		if(listFindNoCase('data,output', arguments.name)){
			var cachePrefix=getBean('configBean').get('AdvancedCachePrefix');

			variables.cacheName=arguments.siteID & "-" &arguments.name;
			
			if(len(cachePrefix)){
				variables.cacheName=cachePrefix & "-" & variables.cacheName;
			}
		} else {
			variables.cacheName=arguments.name;
		}

		if(!cacheRegionExists(variables.cacheName) ) {
			cacheRegionNew(variables.cacheName);
		}

		return this;
	}

	public any function get(key){
		return cacheGet(arguments.key,variables.cacheName);
	}

	public any function getAll(){
		return CacheGetAllIds(variables.cacheName);
	}

	public any function put(key,value,timespan=1,idleTime=1){

		if(arguments.timespan eq ""){
			arguments.timespan=1;
		}

		if(arguments.idleTime eq ""){
			arguments.idleTime=1;
		}

		cachePut(arguments.key,
			arguments.value,
			arguments.timespan,
			arguments.idleTime,
			variables.cacheName);
	}

	public any function has(key){
		return !isNull(cacheGet(key,variables.cacheName));
	}

	public any function purge(key){
		cacheRemove(arguments.key,false,variables.cacheName);
	}

	public any function purgeAll(){
		var cache=cacheGetSession(variables.cacheName, true);

		if(!isNull(cache)){
			cache.removeAll();
		}

	}

	public any function size(){
		return arrayLen(CacheGetAllIds(variables.cacheName));
	}
}
