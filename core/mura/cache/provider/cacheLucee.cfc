/* License goes here */
component extends="mura.baseobject" output="false" hint="This is used by advanced caching to interact with CFML service" {
	property name="cacheName"
		type="string"
		getter="true"
		setter="true"
		default="data"
		hint="The name of the cache.";

	public any function init(name,siteid){
		
		if(listFindNoCase('data,output', arguments.name)){
			var cachePrefix=getBean('configBean').get('AdvancedCachePrefix');

			variables.cacheName=arguments.siteID & "-" &arguments.name;
			
			if(len(cachePrefix)){
				variables.cacheName=cachePrefix & "-" & variables.cacheName;
			}
		} else {
			variables.cacheName=arguments.name;
		}

		/*
    	if(!cacheRegionExists(variables.cacheName) ) {
			cacheRegionNew(variables.cacheName);
		}
		*/

		return this;
	}

	public any function get(key){
		return cacheGet(id=arguments.key,throwWhenNotExist=true,cacheName=variables.cacheName);
	}

	public any function getAll(){
		return cacheGetAll(filter="", cacheName=variables.cacheName);
	}

	public any function put(key,value,timespan=1,idleTime=1){

		if(arguments.timespan eq ""){
			arguments.timespan=CreateTimeSpan(1,0,0,0);
		} else if (arguments.timespan < 1000 AND !isDate(arguments.timespan)){
			arguments.timespan=CreateTimeSpan(arguments.timespan,0,0,0);
		}

		if(arguments.idleTime eq ""){
			arguments.idleTime=CreateTimeSpan(1,0,0,0);
		} else if (arguments.idleTime < 1000 AND !isDate(arguments.idleTime)){
			arguments.idleTime=CreateTimeSpan(arguments.idleTime,0,0,0);
		}

		cachePut(id=arguments.key,
			value=arguments.value,
			timespan=arguments.timespan,
			idleTime=arguments.idleTime,
			cacheName=variables.cacheName
		);
	}

	public any function has(key){
		return cacheKeyExists(key,variables.cacheName);
	}

	public any function purge(key){
		cacheRemove(ids=arguments.key,cacheName=variables.cacheName);
	}

	public any function purgeAll(){
		cacheClear("",variables.cacheName);
	}

	public any function size(){
		return cacheCount(variables.cacheName);
	}

}
