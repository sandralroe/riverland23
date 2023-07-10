/* license goes here */
component extends="mura.baseobject" output="false" hint="This provides core bean functionality"{

	property name="errors" type="struct" persistent="false" comparable="false";
	property name="isNew" type="numeric" persistent="false" default="1";
	property name="fromMuraCache" type="boolean" default="false" persistent="false" comparable="false";
	property name="instanceID" type="string" persistent="false" comparable="false";

	variables.properties={};
	variables.validations={};
	variables.entityName="";
	variables.primaryKey="";
	variables.encryptionKey="";
	
	function init(){
		super.init(argumentCollection=arguments);

		variables.encryptionKey=getBean('configBean').getValue('encryptionKey');
		variables.sessionData=getSession();
		variables.instance=structNew();
		variables.instance.isNew=1;
		variables.instance.errors=structNew();
		variables.instance.fromMuraCache = false ;
		if(not structKeyExists(variables.instance,"instanceID")){
			variables.instance.instanceID=createUUID();
		}
		variables.instance.addObjects=[];
		variables.instance.removeObjects=[];

		getProperties();

		return this;
	}

	function getIsProxiedEntity(){
        return false;
    }

	function getDbUtility(){
		return getBean('dbUtility');
	}

	function OnMissingMethod(string MissingMethodName,Struct MissingMethodArguments){
		var prefix=left(arguments.MissingMethodName,3);
		var synthedFunctions = getSynthedFunctions();

		if(len(arguments.MissingMethodName)){

			if(variables.entityName != '' && structKeyExists(synthedFunctions, arguments.MissingMethodName)){
				try{

					if(not structKeyExists(arguments,'MissingMethodArguments')){
						arguments.MissingMethodArguments={};
					}

					var synthedFunction=synthedFunctions[arguments.MissingMethodName];

					if(structKeyExists(synthedFunction,'args')){

						if(structKeyExists(synthedFunction.args,'cfc')){
							var bean=getBean(synthedFunction.args.cfc);
							//writeDump(var=bean.getProperties());

							if(!structKeyExists(synthedFunction.args,'loadKey')
								|| !(structKeyExists(bean,'has') && bean.has(synthedFunction.args.loadkey))
							){
								if(synthedFunction.args.functionType eq 'getEntity'){
									if(structKeyExists(synthedFunction.args, "inverse")){
										synthedFunction.args.loadKey=getPrimaryKey();
									} else {
										synthedFunction.args.loadKey=bean.getPrimaryKey();
									}
								} else{
									synthedFunction.args.loadkey=application.objectMappings[variables.entityName].synthedFunctions[arguments.MissingMethodName].args.fkcolumn;
								}
							}
						
							var synthedArgs=synthArgs(synthedFunction.args);

							for(var arg in synthedArgs) {
								if(!structKeyExists(arguments.MissingMethodArguments,arg)){
									arguments.MissingMethodArguments[arg]=synthedArgs[arg];
								}
							}
						}
					}

					//writeDump(var=arguments.MissingMethodArguments);
					//writeDump(var=synthedFunction.exp,abort=true);
					return evaluate(synthedFunction.exp);

				} catch(any err){
					if(request.muratransaction){
						transactionRollback();
					}
					writeDump(var=synthedFunction);
					writeDump(var=err,abort=true);
				}
			}

			if(listFindNoCase("set,get",prefix) and len(arguments.MissingMethodName) gt 3){
				var prop=right(arguments.MissingMethodName,len(arguments.MissingMethodName)-3);

				if(prefix eq "get"){
					return getValue(prop);
				}

				if(not structIsEmpty(arguments.MissingMethodArguments)){
					return setValue(prop,arguments.MissingMethodArguments[1]);
				} else {
					throw(message="The method '#arguments.MissingMethodName#' requires a property value");
				}

			} else {
				throw(message="The method '#arguments.MissingMethodName#' is not defined");
			}
		} else {
			return "";
		}

	}

	function getInstanceName(){
		if(structKeyExists(variables,'instanceName')){
			return getValue(variables.instanceName);
		} else if(valueExists('name')){
			return getValue('name');
		} else {
			return getValue(getPrimaryKey());
		}
	}

	function setAddedObjectValues(properties){
		set(arguments.properties);
		for(var obj in variables.instance.addObjects){
			obj.set(arguments.properties);
			obj.setAddedObjectValues(arguments.properties);
		}
		return this;
	}

	private function addObject(obj){
		var p='';
		var many=getHasManyPropArray();
		var one=getHasOnePropArray();

		for(var p in many){
			if(p.cfc == obj.getEntityName()){
				var setkey=translatePropKey(p.loadkey);
				var args={
					'#setkey#'=getValue(translatePropKey(p.fkcolumn))
				};
				invoke(arguments.obj,'set#setkey#',args);
				arrayAppend(variables.instance.addObjects,arguments.obj);
				return this;
			}
		}

		for(var p in one){
			if(p.cfc == obj.getEntityName()){
				var setkey=translatePropKey(p.loadkey);
				var args={
					'#setkey#'=getValue(translatePropKey(p.fkcolumn))
				};
				invoke(arguments.obj,'set#setkey#',args);
				arrayAppend(variables.instance.addObjects,arguments.obj);
				return this;
			}
		}

		var setkey=getPrimaryKey();
		var args={
			'#setkey#'=getValue(getPrimaryKey())
		};
		invoke(arguments.obj,'set#setkey#',args);
		arrayAppend(variables.instance.addObjects,arguments.obj);
		return this;
	}

	private function removeObject(obj){
		if(getValue(getPrimaryKey()) == obj.getValue(getPrimaryKey())){
			arrayAppend(variables.instance.removeObjects,arguments.obj);
		}
		return this;
	}

	private function synthArgs(args){
		param name="args.inverse" default=false;
		if(args.inverse){
			var translatedLoadKey=translatePropKey(arguments.args.fkcolumn);
			var translatedFKColumn=translatePropKey(args.loadkey);
		} else {
			var translatedLoadKey=translatePropKey(args.loadkey);
			var translatedFKColumn=translatePropKey(arguments.args.fkcolumn);
		}
	
		var returnArgs={
				"#translatedLoadKey#"=getValue(translatedFKColumn),
				returnFormat=arguments.args.returnFormat,
				inverse=args.inverse
			};

		/*
		This should only happen with loading many-to-one relationships when local
		fkcolumn (many) value is empty.
		*/
		if(!len(returnArgs[translatedLoadKey])){
			setValue(translatedFKColumn,createUUID());
			returnArgs[translatedLoadKey]=getValue(translatedFKColumn);
		}

		if(structKeyExists(arguments.args,'siteid')){
			returnArgs.siteid=getValue('siteid');
		}
		if(isDefined('application.objectMappings.#getEntityName()#.properties.#arguments.args.prop#.orderby')){
			returnArgs.orderby=application.objectMappings[getEntityName()].properties[arguments.args.prop].orderby;
		} else if(isDefined('application.objectMappings.#arguments.args.cfc#.orderby')){
			returnArgs.orderby=application.objectMappings[arguments.args.cfc].orderby;
		}

		return returnArgs;
	}

	function translatePropKey(property){
		if(arguments.property eq 'primaryKey'){
			return getPrimaryKey();
		}
		return arguments.property;
	}

 	function parseDateArg(String arg){

 		//fix so that date's like 2015-06-23T14:22:35 can be parsed
 		if(refind('(\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d)',arguments.arg)){
 			arguments.arg=replace(arguments.arg,'T',' ');
 		}

		if(!refind('(\d\d\d\d-\d\d-\d\d\s\d\d:\d\d:\d\d)',arguments.arg) && lsisDate(arguments.arg)){
			try{
				return lsparseDateTime(arguments.arg);
			} catch(any e){
				return arguments.arg;
			}

		} else if(isDate(arguments.arg)){
			try{
				return parseDateTime(arguments.arg);
			} catch(any e){
				return arguments.arg;
			}
		} else {
			return "";
		}
	}

	function set(property,propertyValue){

		if(!isDefined('arguments.data') ){
			if(isSimpleValue(arguments.property)){
				return setValue(argumentCollection=arguments);
			}

			//process complex object
			arguments.data=property;
		}

		var prop='';
		var properties=getProperties();
		var collection='';
		var item='';
		var propStruct={};
		var loadArgs={};
		var obj='';
		var idList='';
		var hasMany='';

		if(isQuery(arguments.data) and arguments.data.recordcount){
			for(var i=1;i<=listLen(arguments.data.columnlist);i++){
				prop=listgetAt(arguments.data.columnlist,i);
				setValue(prop,arguments.data[prop][1]);
			}
			variables.instance.isNew=0;
		} else if(isStruct(arguments.data)){
			//set basic values
			for(prop in arguments.data){
				if (isValid('variableName',prop) && IsSimpleValue(prop) && !isNull(arguments.data['#prop#']) && Len(prop) && !(prop==getPrimaryKey() && !len(arguments.data['#prop#'])) ) {
					setValue(prop,arguments.data['#prop#']);
				}
			}

			//look for relationships
			for(prop in arguments.data){

				if(isValid('variableName',prop)
					&& isdefined('properties.#prop#.fieldtype')
					&& listFindNoCase('one-to-many,many-to-many,one-to-one',properties[prop].fieldtype)
				){

					propStruct=properties[prop];

					if(listFindNoCase('one-to-many,many-to-many',properties[prop].fieldtype)) {
						collection=arguments.data['#prop#'];

						if(isJSON(collection)){
							collection=deserializeJSON(collection);
						}

						if(isdefined('collection.items')
							&& isArray(collection.items)
							&& isdefined('collection.cascade')
							&& listFindNoCase('replace,merge',collection.cascade)){

							idlist='';

							for(item in collection.items){
								obj=getBean(propStruct.cfc);
								obj.setSiteID(getValue('siteid'));

								if(isDefined('item.id')){
									loadArgs={'#obj.getPrimaryKey()#'=item.id};
								} else {
									loadArgs={'#obj.getPrimaryKey()#'=item[obj.getPrimaryKey()]};
								}

								obj.loadBy(argumentCollection=loadArgs).set(item);
								addObject(obj);
								idlist=listAppend(idlist,obj.get(obj.getPrimaryKey()));

							}

							if(collection.cascade=='replace'){
								hasMany=invoke(this,'get#prop#Iterator');

								while(hasMany.hasNext()){
									obj=hasMany.next();
									if(!listFindNoCase(idlist,obj.get(obj.getPrimaryKey()))){
										removeObject(obj);
									}
								}
							}
						}

					} else {
						item=arguments.data['#prop#'];

						if(isDefined('item.casade') && listFindNoCase('merge,replace,true',item.casade)){
							obj=getBean(propStruct.cfc);
							obj.setSiteID(getValue('siteid'));

							if(isDefined('item.id')){
								loadArgs={'#obj.getPrimaryKey()#'=item.id};
							} else {
								loadArgs={'#obj.getPrimaryKey()#'=item[obj.getPrimaryKey()]};
							}

							obj.loadBy(argumentCollection=loadArgs).set(item);
							addObject(item);

						}
					}

				}
			}
		}

		return this;
	}

	function parseEncrypted(value){
		if(len(variables.encryptionKey) && isSimpleValue(arguments.value) && len(arguments.value) > 10 && left(arguments.value,10) == "encrypted:"){
			try {
				return decrypt(listRest(arguments.value,":"), variables.encryptionKey,'AES');
			} catch(any e){
				logError(e);
				return arguments.value;
			}
		} else {
			return arguments.value;
		}
	}

	function setValue(property,propertyValue=''){

		arguments.propertyValue=parseEncrypted(arguments.propertyValue);

		if(arguments.property != 'value' && isValid('variableName',replace(arguments.property,'.','-')) && isDefined("this.set#arguments.property#")){
			var tempFunc=this["set#arguments.property#"];
			tempFunc(arguments.propertyValue);
		} else if (len(variables.entityName)) {
			var props=getProperties();
			if(structKeyExists(props,'#arguments.property#') && props['#arguments.property#'].datatype=='datetime'){
				variables.instance["#arguments.property#"]=parseDateArg(arguments.propertyValue);
			} else {
				if(isSimpleValue(arguments.propertyValue)){
					arguments.propertyValue=trim(arguments.propertyValue);
				}
				variables.instance["#arguments.property#"]=arguments.propertyValue;
			}
		} else {
			if(isSimpleValue(arguments.propertyValue)){
				arguments.propertyValue=trim(arguments.propertyValue);
			}
			variables.instance["#arguments.property#"]=arguments.propertyValue;
		}

		return this;
	}

	function get(String property='',defaultValue){
		if(arguments.property==''){
			return getAllValues(argumentCollection=arguments);
		}
		return getValue(argumentCollection=arguments);
	}

	function getValue(String property,defaultValue){

		if(isValid('variableName',arguments.property) && isDefined("this.get#arguments.property#") && arguments.property != 'bean'){
			var tempFunc=this["get#arguments.property#"];
			return tempFunc();
		} else if(structKeyExists(variables.instance,"#arguments.property#")){
			return variables.instance["#arguments.property#"];
		} else if(structKeyExists(arguments,"defaultValue")){
			variables.instance["#arguments.property#"]=arguments.defaultValue;
			return variables.instance["#arguments.property#"];
		} else{
			return "" ;
		}

	}

	function setAllValues(instance){
		init();
		structAppend(variables.instance,arguments.instance,true);
		return this;
	}

	function getAllValues(){
		return variables.instance;
	}

	function getAll(){
		return getAllValues(argumentCollection=arguments);
	}

	function stripSystemKeys(data){
		var response=duplicate(arguments.data);
		structDelete(response,'saveErrors');
		structDelete(response,'removeObjects');
		structDelete(response,'addObjects');
		structDelete(response,'primaryKey');
		structDelete(response,'errors');
		return response;
	}

	function valueExists(valueKey){
		return structKeyExists(variables.instance,arguments.valueKey);
	}

	function has(valueKey){
		return valueExists(argumentCollection=arguments);
	}

	function validate(fields=''){
		var errorCheck={};
		var checknum=1;
		var checkfound=false;
		var p='';
		var prop={};
		var properties=getProperties();
		var propVal='';

		var errors=getBean('beanValidator').validate(this);
		
		if(len(arguments.fields)){
			variables.instance.errors={};
			for(var e in ListToArray(arguments.fields)){
				if(structkeyExists(errors,e)){
					variables.instance.errors[e]=errors[e];
				}
			}
		} else {
			variables.instance.errors=errors;
		}

		//writeDump(var=properties,abort=true);

		if(getBean('configBean').getValue(property='stricthtml',defaultValue=false)){
			var stricthtmlexclude=getBean('configBean').getValue(property='stricthtmlexclude',defaultValue='');
			for(p in properties){
				if(!len(arguments.fields) || listFindNoCase(arguments.fields,p)){
					prop=properties[p];
					param name="prop.html" default=false;
					if(!prop.html){
						propVal=getValue(prop.column);
						if(isSimpleValue(propVal) && !(len(stricthtmlexclude) && listFind(stricthtmlexclude,prop.column)) && reFindNoCase("<[\/]?[^>]*>",propVal)){
							variables.instance.errors['#prop.name#encoding']="The field '#prop.name#' contains invalid characters.";
						}
					}
				}
			}
		}

		if(!len(arguments.fields)){
			if(arrayLen(variables.instance.addObjects)){
				for(var obj in variables.instance.addObjects){
					errorCheck=obj.validate().getErrors();
					if(!structIsEmpty(errorCheck)){
						do{
							if( !structKeyExists(variables.instance.errors,obj.getEntityName() & checknum) ){
								variables.instance.errors[obj.getEntityName()  & checknum ]=errorCheck;
								checkfound=true;
							}
						} while (!checkfound);
					}
					checknum = checknum + 1;
				}
			}
		}

		return this;
	}

	function setErrors(errors){
		if(isStruct(arguments.errors)){
			 variables.instance.errors = arguments.errors ;
		}
		return this;
	}

	function getErrors(){
		return variables.instance.errors;
	}

	function hasErrors(){
		return not structIsEmpty(variables.instance.errors);
	}

	function setlastUpdateBy(lastUpdateBy){
		variables.instance.lastUpdateBy = left(trim(arguments.lastUpdateBy),50) ;
		return this;
	}

	function getIsHistorical(){
		param name="application.objectMappings.#variables.entityName#.historical" default=false;
		return application.objectMappings[variables.entityName].historical;
	}

	function getScaffold(){
		param name="application.objectMappings.#variables.entityName#.scaffold" default=false;
		return application.objectMappings[variables.entityName].scaffold;
	}

	function getBundleable(){
		param name="application.objectMappings.#variables.entityName#.bundleable" default=false;
		return application.objectMappings[variables.entityName].bundleable;
	}

	function getDynamic(){
		param name="application.objectMappings.#variables.entityName#.dynamic" default=false;
		return application.objectMappings[variables.entityName].dynamic;
	}

	function getTaggable(){
		return hasProperty('tagassignments');
	}

	function getCategorizable(){
		return hasProperty('categoryassignments');
	}

	function getPrimaryKey(){
		return variables.primarykey;
	}

	function getTable(){
		param name="application.objectMappings.#variables.entityName#.table" default="";
		return application.objectMappings[variables.entityName].table;
	}

	function getIsVersioned(){
		param name="application.objectMappings.#variables.entityName#.versioned" default="false";
		return application.objectMappings[variables.entityName].versioned;
	}

	function getOrderBy(){
		param name="application.objectMappings.#variables.entityName#.orderby" default="";
		return application.objectMappings[variables.entityName].orderby;
	}

	function getPublicAPI(){
		param name="application.objectMappings.#variables.entityName#.public" default="false";
		return application.objectMappings[variables.entityName].public;
	}

	function hasTable(){
		return structKeyExists(application.objectMappings[variables.entityName],'table') && len(application.objectMappings[variables.entityName].table);
	}

	function hasSynthedFn(fnName){
		param name='application.objectMappings.#variables.entityName#.synthedFunctions' default={};
		return structKeyExists(application.objectMappings['#variables.entityName#'].synthedFunctions,arguments.fnName);
	}
	
	function getSynthedFn(fnName){
		var data=application.objectMappings['#variables.entityName#'].synthedFunctions[arguments.fnName];
		param name="data.args.inverse" default=false;
		return data;
	}

	function getHasManyPropArray(){
		param name='application.objectMappings.#variables.entityName#.hasMany' default=[];
		return application.objectMappings[variables.entityName].hasMany;
	}

	function getHasOnePropArray(){
		param name='application.objectMappings.#variables.entityName#.hasOne' default=[];
		return application.objectMappings[variables.entityName].hasOne;
	}

	function getProperties(rebuild=false){

		getEntityName();

		if(arguments.rebuild || !isdefined('application.objectMappings.#variables.entityName#.properties')){
			lock type="exclusive" name="muraORMProps#variables.entityName##application.instanceID#" timeout="5" {
				if(arguments.rebuild || !isdefined('application.objectMappings.#variables.entityName#.properties')){
					var pname='';
					var i='';
					var prop={};
					var omd=duplicate(getMetaData(this));
					var md=omd;
					var loadKey="";
					var dottedPath=md.fullname;
					var synthArgs={};
					var defaultMetaData={column="",table="",datatype="varchar","default"="null",nullable=true};

					param name="application.objectMappings.#variables.entityName#" default={};
					param name="application.objectMappings.#variables.entityName#.synthedFunctions" default={};
					param name="application.objectMappings.#variables.entityName#.remoteFunctions" default={};
					param name="application.objectMappings.#variables.entityName#.hasMany" default=[];
					param name="application.objectMappings.#variables.entityName#.hasOne" default=[];
					param name="application.objectMappings.#variables.entityName#.displayname" default=getEntityName();

					application.objectMappings[variables.entityName].properties={};
					application.objectMappings[variables.entityName].primarykey="";

					if(structKeyExists(md,'versioned') && md.versioned){
						application.objectMappings[variables.entityName].versioned=true;

						if(not listFindNoCase(application.objectMappings.versionedBeans, variables.entityName)){
							application.objectMappings.versionedBeans=listAppend(application.objectMappings.versionedBeans, variables.entityName);
						}
					} else {
						application.objectMappings[variables.entityName].versioned=false;
					}

					if(structKeyExists(md,'bundleable') && md.bundleable){
						application.objectMappings[variables.entityName].bundleable=md.bundleable;

						if(not listFindNoCase(application.objectMappings.bundleableBeans, variables.entityName)){
							application.objectMappings.bundleableBeans=listAppend(application.objectMappings.bundleableBeans, variables.entityName);
						}
					} else {
						application.objectMappings[variables.entityName].bundleable=false;
					}

					if(structKeyExists(md,'orderby')){
						application.objectMappings[variables.entityName].orderby=md.orderby;
					} else{
						application.objectMappings[variables.entityName].orderby='';
					}

					if(structKeyExists(md,'displayname')){
						application.objectMappings[variables.entityName].displayname=md.displayname;
					}

					if(structKeyExists(md,'datasource') && md.datasource != application.configBean.getDatasource()){
						application.objectMappings[variables.entityName].datasource=md.datasource;

						if(structKeyExists(md,'dbtype')){
							application.objectMappings[variables.entityName].dbtype=md.dbtype;
						}
					}

					if(structKeyExists(md,'table')){
						application.objectMappings[variables.entityName].table=md.table;
					} else {
						application.objectMappings[variables.entityName].table='';
					}

					if(structKeyExists(md,'public')){
						application.objectMappings[variables.entityName].public=md.public;
					} else {
						application.objectMappings[variables.entityName].public=false;
					}

					if(structKeyExists(md,'proxyid')){
						application.objectMappings[variables.entityName].proxyid=md.proxyid;
					} else {
						application.objectMappings[variables.entityName].proxyid="";
					}

					if(structKeyExists(md,'discriminatorColumn')){
						application.objectMappings[variables.entityName].discriminatorColumn=md.discriminatorColumn;
					} else {
						application.objectMappings[variables.entityName].discriminatorColumn='';
					}

					if(structKeyExists(md,'discriminatorValue')){
						application.objectMappings[variables.entityName].discriminatorValue=md.discriminatorValue;
					} else {
						application.objectMappings[variables.entityName].discriminatorValue='';
					}

					if(structKeyExists(md,'cachename')){
						application.objectMappings[variables.entityName].cachename=md.cachename;
					} else {
						application.objectMappings[variables.entityName].cachename='data';
					}

					if(structKeyExists(md,'readonly')){
						application.objectMappings[variables.entityName].readonly=md.readonly;
					} else {
						application.objectMappings[variables.entityName].readonly=false;
					}

					if(structKeyExists(md,'historical')){
						application.objectMappings[variables.entityName].historical=md.historical;
					} else {
						application.objectMappings[variables.entityName].historical=false;
					}

					if(structKeyExists(md,'manageschema')){
						application.objectMappings[variables.entityName].manageschema=md.manageschema;
					} else {
						application.objectMappings[variables.entityName].manageschema=true;
					}

					if(structKeyExists(md,'dynamic')){
						application.objectMappings[variables.entityName].dynamic=md.dynamic;
					} else {
						application.objectMappings[variables.entityName].dynamic=false;
					}

					if(structKeyExists(md,'scaffold')){
						application.objectMappings[variables.entityName].scaffold=md.scaffold;
					} else {
						application.objectMappings[variables.entityName].scaffold=false;
					}

					if(structKeyExists(md,'usetrash')){
						application.objectMappings[variables.entityName].usetrash=md.usetrash;
					} else {
						application.objectMappings[variables.entityName].usetrash=false;
					}

					//Need to set top level historcal entity level property based on property check before fully parsing properties

					for (md;
					    structKeyExists(md, "extends");
					    md = md.extends)
					  {

					    if (structKeyExists(md, "properties"))
						    {
						      for (i = 1;
						           i <= arrayLen(md.properties);
						           i++)
						      {

								  if(structKeyExists(md.properties[i],'historical') && isBoolean(md.properties[i].historical) && md.properties[i].historical){
									  application.objectMappings[variables.entityName].historical=true;
									  break;
								  }

							  }
						  }
				    }

					//reset to original component metadata
					md=omd;

					//Look for remote functions
					for (md;
					    structKeyExists(md, "extends");
					    md = md.extends)
					  {

					    if (structKeyExists(md, "functions"))
						    {
						      for (i = 1;
						           i <= arrayLen(md.functions);
						           i++)
						      {

								  if(structKeyExists(md.functions[i],'access') && md.functions[i].access=='remote'){
									  application.objectMappings[variables.entityName].remoteFunctions[md.functions[i].name]=md.functions[i].parameters;
								  }

							  }
						  }
				    }

					//reset to original component metadata
					md=omd;

					for (md;
					    structKeyExists(md, "extends");
					    md = md.extends)
					  {
					    if (structKeyExists(md, "properties"))
					    {
					      for (i = 1;
					           i <= arrayLen(md.properties);
					           i++)
					      {
					        pName = md.properties[i].name;

					        //writeDump(var=pname,abort=true);

					        if(!structkeyExists(application.objectMappings[variables.entityName].properties,pName)){
					       	 	application.objectMappings[variables.entityName].properties[pName]=md.properties[i];
					       	 	prop=application.objectMappings[variables.entityName].properties[pName];
					       	 	prop.table=application.objectMappings[variables.entityName].table;

					       	 	param name="prop.comparable" default=true;
								param name="prop.required" default=false;
					       	 	param name="prop.nullable" default=true;
					       	 	param name="prop.fieldtype" default="";
					       	 	param name="prop.nested" default="false";
								param name="prop.html" default="false";
								param name="prop.encrypted" default="false";

					       	 	if(prop.required){
					       	 		prop.nullable=false;
					       	 	}

					       	 	if(prop.nullable){
					       	 		prop.required=false;
					       	 	}

						       	if(prop.fieldtype eq 'id'){
									setPropAsIDColumn(prop);
									if(!getIsHistorical() || prop.name !='histid'){
										application.objectMappings[variables.entityName].primaryKey=prop.name;
									}
							      }

			       	 	if(!structKeyExists(prop,"dataType")){
			       	 		if(structKeyExists(prop,"ormtype")){
			       	 			prop.dataType=prop.ormtype;
			       	 		} else if(structKeyExists(prop,"type")){
			       	 			prop.dataType=prop.type;
			       	 		} else {
			       	 			prop.type="string";
			       	 			prop.dataType="varchar";
			       	 		}
			       	 	}

			       	 	if(listFindNoCase('date,timetamp',prop.dataType)){
			       	 		prop.dataType='datetime';
						}
							
						if(structKeyExists(prop,'encrypted')){
							prop.encrypted=prop.encrypted;
						}

						if(structKeyExists(prop,'relatesto')){
							prop.cfc=prop.relatesto;
						}

						if(structKeyExists(prop,'optionlist') && len(prop.optionlist)){
							if(!structKeyExists(prop,'optionvaluelist') || !len(prop.optionvaluelist)){
								prop.optionvaluelist=prop.optionlist;
							}
						}

			       	 	if(structKeyExists(prop,'cfc')){

			       	 		param name="prop.fkcolumn" default="primaryKey";
							param name="prop.callbackname" default=variables.entityName;
			       	 		prop.column=prop.fkcolumn;

			       	 		param name="prop.loadkey" default=prop.fkcolumn;

			       	 		if(prop.nested){
			       	 			prop.loadkey='parentid';
			       	 		}

							param name="application.objectMappings.#prop.cfc#" default={};
							param name="application.objectMappings.#prop.cfc#.synthedFunctions" default={};

			       	 		if(prop.fieldtype eq 'one-to-many' or prop.fieldtype eq 'many-to-many'){

								appendHasRef(variables.entityName,'hasMany',prop,false);
								//arrayAppend(application.objectMappings[variables.entityName].hasMany, prop);

								//Add has many methods to entity
								application.objectMappings[variables.entityName].synthedFunctions['get#prop.name#Iterator']={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments)',args={prop=prop.name,fkcolumn=prop.fkcolumn,loadkey=prop.loadkey,cfc=prop.cfc,returnFormat="iterator",functionType='getEntityIterator'}};
								application.objectMappings[variables.entityName].synthedFunctions['get#prop.name#']=application.objectMappings[variables.entityName].synthedFunctions['get#prop.name#Iterator'];
								application.objectMappings[variables.entityName].synthedFunctions['get#prop.name#Query']={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments)',args={prop=prop.name,fkcolumn=prop.fkcolumn,loadkey=prop.loadkey,cfc=prop.cfc,returnFormat="query",functionType='getEntityQuery'}};
								application.objectMappings[variables.entityName].synthedFunctions['has#prop.name#']={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments).recordcount',args={prop=prop.name,fkcolumn=prop.fkcolumn,loadkey=prop.loadkey,cfc=prop.cfc,returnFormat="query",functionType='hasEntity'}};
								application.objectMappings[variables.entityName].synthedFunctions['add#prop.name#']={exp='addObject(arguments.MissingMethodArguments[1])',args={prop=prop.name,functionType='addEntity'}};
								application.objectMappings[variables.entityName].synthedFunctions['remove#prop.name#']={exp='removeObject(arguments.MissingMethodArguments[1])',args={prop=prop.name,functionType='removeEntity'}};

								//If there's a defined singular name then add has many methods under that name as well to entity
								if(structKeyExists(prop,"singularname")){
									application.objectMappings[variables.entityName].synthedFunctions['get#prop.singularname#Iterator']=application.objectMappings[variables.entityName].synthedFunctions['get#prop.name#Iterator'];
									//application.objectMappings[variables.entityName].synthedFunctions['get#prop.singularname#']=application.objectMappings[variables.entityName].synthedFunctions['get#prop.singularname#Iterator'];
									application.objectMappings[variables.entityName].synthedFunctions['get#prop.singularname#Query']=application.objectMappings[variables.entityName].synthedFunctions['get#prop.name#Query'];
									application.objectMappings[variables.entityName].synthedFunctions['add#prop.singularname#']=application.objectMappings[variables.entityName].synthedFunctions['add#prop.name#'];
									application.objectMappings[variables.entityName].synthedFunctions['has#prop.singularname#']=application.objectMappings[variables.entityName].synthedFunctions['has#prop.name#'];
									application.objectMappings[variables.entityName].synthedFunctions['remove#prop.singularname#']=application.objectMappings[variables.entityName].synthedFunctions['remove#prop.name#'];
								}

										//If it's a relationship to a core entity then add the synthesized method to the core entity's mappings
				       	 		if(listFindNoCase('content,user,feed,category,address,site,comment',prop.cfc)){

									param name="application.objectMappings.#prop.cfc#.hasMany" default=[];
									param name="application.objectMappings.#prop.cfc#.hasOne" default=[];

				       	 			if(prop.fieldtype eq 'many-to-many'){
										//Add has many methods to the core entity
										if(prop.fkcolumn!='primarykey'){
											appendHasRef(prop.cfc,'hasMany', {name=pluralizeHasRefName(variables.entityName),cfc=variables.entityName,loadkey=prop.fkcolumn,column=prop.loadkey});
										}
										application.objectMappings[prop.cfc].synthedFunctions['get#prop.callbackname#Iterator']={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments)',args={prop=variables.entityName,fkcolumn=prop.fkcolumn,loadkey=prop.loadkey,inverse=true,siteid=true,cfc="#variables.entityName#",returnFormat="iterator",functionType='getEntityIterator'}};
										application.objectMappings[prop.cfc].synthedFunctions['get#prop.callbackname#']=application.objectMappings[prop.cfc].synthedFunctions['get#prop.callbackname#Iterator'];
										application.objectMappings[prop.cfc].synthedFunctions['get#prop.callbackname#Query']={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments)',args={prop=variables.entityName,fkcolumn=prop.fkcolumn,loadkey=prop.loadkey,inverse=true,siteid=true,cfc="#variables.entityName#",returnFormat="query",functionType='getEntityQuery'}};
					       	 			//application.objectMappings[prop.cfc].synthedFunctions['has#variables.entityName#']={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments).recordcount',args={prop=variables.entityName,fkcolumn=prop.fkcolumn,cfc="#variables.entityName#",returnFormat="query",functionType='hasEntity'}};
					       	 			application.objectMappings[prop.cfc].synthedFunctions['add#prop.callbackname#']={exp='addObject(arguments.MissingMethodArguments[1])',args={prop=variables.entityName,functionType='addEntity'}};
					       	 			application.objectMappings[prop.cfc].synthedFunctions['remove#prop.callbackname#']={exp='removeObject(arguments.MissingMethodArguments[1])',args={prop=variables.entityName,functionType='removeEntity'}};

				       	 			} else {
										//Add has one methods to the core entity
										if(prop.fkcolumn!='primarykey'){
											appendHasRef(prop.cfc,'hasOne',{name=variables.entityName,cfc=variables.entityName,loadkey=prop.fkcolumn,column=prop.loadkey});
										}
										application.objectMappings[prop.cfc].synthedFunctions['get#prop.callbackname#']={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments)',args={prop=variables.entityName,fkcolumn="#prop.fkcolumn#",loadkey=prop.loadkey,inverse=true,siteid=true,cfc="#variables.entityName#",returnFormat="this",functionType='getEntity'}};
				       	 				//application.objectMappings[prop.cfc].synthedFunctions['set#prop.callbackname#']={exp='setValue("#prop.fkcolumn#",arguments.MissingMethodArguments[1].getValue(arguments.MissingMethodArguments[1].getValue("#prop.fkcolumn#"))',args={prop=variables.entityName,functionType='setEntity'}};
				       	 			}

				       	 		} else {

									param name="application.objectMappings.#prop.cfc#.hasMany" default=[];
									param name="application.objectMappings.#prop.cfc#.hasOne" default=[];

									if(prop.fieldtype eq 'many-to-many'){
										//Only add method to other entity if is is not already defined
										//Add has many methods to the core entity
										if(prop.fkcolumn!='primarykey'){
											appendHasRef(prop.cfc,'hasMany', {name=variables.entityName,cfc=variables.entityName,loadkey=prop.fkcolumn,column=prop.loadkey});
										}
										param name="application.objectMappings.#prop.cfc#.synthedFunctions.get#prop.callbackname#Iterator" default={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments)',args={prop=variables.entityName,fkcolumn=prop.fkcolumn,loadkey=prop.loadkey,inverse=true,siteid=true,cfc="#variables.entityName#",returnFormat="iterator",functionType='getEntityIterator'}};
										param name="application.objectMappings.#prop.cfc#.synthedFunctions.get#prop.callbackname#" default=application.objectMappings[prop.cfc].synthedFunctions['get#prop.callbackname#Iterator'];
										param name="application.objectMappings.#prop.cfc#.synthedFunctions.get#prop.callbackname#Query" default={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments)',args={prop=variables.entityName,fkcolumn=prop.fkcolumn,loadkey=prop.loadkey,inverse=true,siteid=true,cfc="#variables.entityName#",returnFormat="query",functionType='getEntityQuery'}};
					       	 			//application.objectMappings[prop.cfc].synthedFunctions['has#prop.callbackname#']={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments).recordcount',args={prop=variables.entityName,fkcolumn=prop.fkcolumn,cfc="#variables.entityName#",returnFormat="query",functionType='hasEntity'}};
					       	 			param name="application.objectMappings.#prop.cfc#.synthedFunctions.add#prop.callbackname#" default={exp='addObject(arguments.MissingMethodArguments[1])',args={prop=variables.entityName,functionType='addEntity'}};
					       	 			param name="application.objectMappings.#prop.cfc#.synthedFunctions.remove#prop.callbackname#" default={exp='removeObject(arguments.MissingMethodArguments[1])',args={prop=variables.entityName,functionType='removeEntity'}};

				       	 			} else {
										//Only add method to other entity if is is not already defined
										//Add has one methods to the core entity
										if(prop.fkcolumn!='primarykey'){
											appendHasRef(prop.cfc,'hasOne', {name=variables.entityName,cfc=variables.entityName,loadkey=prop.fkcolumn,column=prop.loadkey});
										}
										param name="application.objectMappings.#prop.cfc#.synthedFunctions.get#prop.callbackname#" default={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments)',args={prop=variables.entityName,fkcolumn="#prop.fkcolumn#",loadkey=prop.loadkey,inverse=true,siteid=true,cfc="#variables.entityName#",returnFormat="this",functionType='getEntity'}};
				       	 				//application.objectMappings[prop.cfc].synthedFunctions['set#variables.entityName#']={exp='setValue("#prop.fkcolumn#",arguments.MissingMethodArguments[1].getValue(arguments.MissingMethodArguments[1].getValue("#prop.fkcolumn#"))',args={prop=variables.entityName,functionType='setEntity'}};
				       	 			}
								}

			       	 		} else if (prop.fieldtype eq 'many-to-one' or prop.fieldtype eq 'one-to-one'){
								
								appendHasRef(variables.entityName,'hasOne',prop,false);
								//arrayAppend(application.objectMappings[variables.entityName].hasOne, prop);
								//Add has one methods to entity
		       	 				if(prop.fkcolumn eq 'siteid'){
			       	 				application.objectMappings[variables.entityName].synthedFunctions['get#prop.name#']={exp='getBean("settingsManager").getSite(getValue("siteID"))',args={prop=prop.name,functionType='getEntity'}};
			       	 				application.objectMappings[variables.entityName].synthedFunctions['set#prop.name#']={exp='setValue("siteID",arguments.MissingMethodArguments[1].getSiteID()))',args={prop=prop.name,functionType='setEntity'}};
			       	 			} else {
			       	 				application.objectMappings[variables.entityName].synthedFunctions['get#prop.name#']={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments)',args={prop=prop.name,fkcolumn=prop.fkcolumn,loadkey=prop.loadkey,cfc=prop.cfc,returnFormat="this",functionType='getEntity'}};
			       	 				application.objectMappings[variables.entityName].synthedFunctions['set#prop.name#']={exp='setValue("#prop.fkcolumn#",arguments.MissingMethodArguments[1].getValue(arguments.MissingMethodArguments[1].getPrimaryKey()))',args={prop=prop.name,functionType='setEntity'}};
			       	 			}

								param name="application.objectMappings.#prop.cfc#" default={};
								param name="application.objectMappings.#prop.cfc#.synthedFunctions" default={};

								//If it's a relationship to a core entity then add the synthesized method to the core entity's mappings
			       	 			if(listFindNoCase('content,user,feed,category,address,site,comment',prop.cfc)){

									param name="application.objectMappings.#prop.cfc#.hasMany" default=[];
									param name="application.objectMappings.#prop.cfc#.hasOne" default=[];

			       	 				if(prop.fieldtype eq 'many-to-one'){
										appendHasRef(prop.cfc,'hasMany', {name=prop.callbackname,cfc=variables.entityName,loadkey=prop.fkcolumn,column=prop.loadkey});
										//Add has many methods to the core entity
			       	 					application.objectMappings[prop.cfc].synthedFunctions['get#prop.callbackname#Iterator']={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments)',args={prop=variables.entityName,fkcolumn=prop.fkcolumn,loadkey=prop.loadkey,inverse=true,siteid=true,cfc=variables.entityName,returnFormat="iterator",functionType='getEntityIterator'}};
										application.objectMappings[prop.cfc].synthedFunctions['get#prop.callbackname#']=application.objectMappings[prop.cfc].synthedFunctions['get#prop.callbackname#Iterator'];
				       	 				application.objectMappings[prop.cfc].synthedFunctions['get#prop.callbackname#Query']={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments)',args={prop=variables.entityName,fkcolumn=prop.fkcolumn,loadkey=prop.loadkey,inverse=true,siteid=true,cfc=variables.entityName,returnFormat="query",functionType='getEntityQuery'}};
				       	 				//application.objectMappings[prop.cfc].synthedFunctions['has#variables.entityName#']={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments).recordcount',args={prop=variables.entityName,fkcolumn=prop.fkcolumn,cfc="#variables.entityName#",returnFormat="query",functionType='hasEntity'}};
				       	 				application.objectMappings[prop.cfc].synthedFunctions['add#prop.callbackname#']={exp='addObject(arguments.MissingMethodArguments[1])',args={prop=variables.entityName,functionType='addEntity'}};
				       	 				application.objectMappings[prop.cfc].synthedFunctions['remove#prop.callbackname#']={exp='removeObject(arguments.MissingMethodArguments[1])',args={prop=variables.entityName,functionType='removeEntity'}};

			       	 				} else {
										//Add has one methods to the core entity
										if(prop.fkcolumn!='primarykey'){
											appendHasRef(prop.cfc,'hasOne', {name=variables.entityName,cfc=variables.entityName,loadkey=prop.fkcolumn,column=prop.loadkey});
										}
										application.objectMappings[prop.cfc].synthedFunctions['get#prop.callbackname#']={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments)',args={prop=variables.entityName,fkcolumn=prop.fkcolumn,loadkey=prop.loadkey,inverse=true,siteid=true,cfc=variables.entityName,returnFormat="this",functionType='getEntity'}};
					       	 			//application.objectMappings[prop.cfc].synthedFunctions['set#variables.entityName#']={exp='setValue("#prop.fkcolumn#",arguments.MissingMethodArguments[1].getValue(arguments.MissingMethodArguments[1].getValue("#prop.fkcolumn#"))',args={prop=variables.entityName,functionType='setEntity'}};
				       	 			}
			       	 			} else {
									if(prop.fieldtype eq 'many-to-one'){
										//Only add method to other entity if is is not already defined
										//Add has many methods to the core entity
										appendHasRef(prop.cfc, 'hasMany',{name=prop.callbackname,cfc=variables.entityName,loadkey=prop.fkcolumn,column=prop.loadkey});
			       	 					param name="application.objectMappings.#prop.cfc#.synthedFunctions.get#prop.callbackname#Iterator" default={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments)',args={prop=variables.entityName,fkcolumn=prop.fkcolumn,loadkey=prop.loadkey,inverse=true,siteid=true,cfc=variables.entityName,returnFormat="iterator",functionType='getEntityIterator'}};
										param name="application.objectMappings.#prop.cfc#.synthedFunctions.get#prop.callbackname#" default=application.objectMappings[prop.cfc].synthedFunctions['get#variables.entityName#Iterator'];
				       	 				param name="application.objectMappings.#prop.cfc#.synthedFunctions.get#prop.callbackname#Query" default={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments)',args={prop=variables.entityName,fkcolumn=prop.fkcolumn,loadkey=prop.loadkey,inverse=true,siteid=true,cfc=variables.entityName,returnFormat="query",functionType='getEntityQuery'}};
				       	 				//application.objectMappings[prop.cfc].synthedFunctions['has#prop.callbackname#']={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments).recordcount',args={prop=variables.entityName,fkcolumn=prop.fkcolumn,cfc="#variables.entityName#",returnFormat="query",functionType='hasEntity'}};
				       	 				param name="application.objectMappings.#prop.cfc#.synthedFunctions.add#prop.callbackname#" default={exp='addObject(arguments.MissingMethodArguments[1])',args={prop=variables.entityName,functionType='addEntity'}};
				       	 				param name="application.objectMappings.#prop.cfc#.synthedFunctions.remove#prop.callbackname#" default={exp='removeObject(arguments.MissingMethodArguments[1])',args={prop=variables.entityName,functionType='removeEntity'}};

			       	 				} else {
										//Only add method to other entity if is is not already defined
										//Add has one methods to the core entity
										if(prop.fkcolumn!='primarykey'){
											appendHasRef(prop.cfc,'hasOne', {name=variables.entityName,cfc=variables.entityName,loadkey=prop.fkcolumn,column=prop.loadkey});
										}
										param name="application.objectMappings.#prop.cfc#.synthedFunctions.get#prop.callbackname#" default={exp='bean.loadBy(argumentCollection=arguments.MissingMethodArguments)',args={prop=variables.entityName,fkcolumn=prop.fkcolumn,loadkey=prop.loadkey,inverse=true,siteid=true,cfc=variables.entityName,returnFormat="this",functionType='getEntity'}};
					       	 			//application.objectMappings[prop.cfc].synthedFunctions['set#variables.entityName#']={exp='setValue("#prop.fkcolumn#",arguments.MissingMethodArguments[1].getValue(arguments.MissingMethodArguments[1].getValue("#prop.fkcolumn#"))',args={prop=variables.entityName,functionType='setEntity'}};
				       	 			}
										}

			       	 		}

			       	 		param name="prop.cascade" default="none";
							param name="prop.persistent" default=true;

			       	 		if(prop.column=='primarykey'){
			       	 			prop.persistent=false;
			       	 		} else if(prop.persistent){
			       	 			setPropAsIDColumn(prop,false);
			       	 		}


			       	 	} else if(!structKeyExists(prop,"persistent") ){
			       	 		prop.persistent=true;
			       	 	}

			       	 	param name="prop.column" default=prop.name;

			       	 	structAppend(prop,
			       	 		defaultMetaData,
									false
								);

								/*
								if(prop.dataType=='string'){
									prop.dataType='varchar';
								}

								if(prop.dataType=='varchar' && !structKeyExists(prop,'length')){
									prop.length=50;
								}
								*/

					      	}
					      }
					    }
				    }
				}
			}


			getValidations();

			//getServiceFactory().declareBean(beanName=variables.entityName,dottedPath=dottedPath,isSingleton=false);
		}

		//abort;

		//writeDump(var=application.objectMappings[variables.entityName].properties,abort=true);

		return application.objectMappings[variables.entityName].properties;
	}

	function appendHasRef(cfc,type,ref,candidate=true){

		if(arguments.candidate){
			if((!(getScaffold() || getDynamic()) && listFindNoCase('content,user,group,address,comment,category,changeset',arguments.cfc)) || !(structKeyExists(arguments.ref,'name') && len(arguments.ref.name ))){
				return;
			}
		}

		arguments.ref.scaffold=(getScaffold() || getDynamic());

		param name="application.objectMappings.#arguments.cfc#" default={};
		param name="application.objectMappings.#arguments.cfc#.#arguments.type#" default=[];

		var hasArray=application.objectMappings['#arguments.cfc#']['#arguments.type#'];

		for(var i in hasArray){
			if(structKeyExists(i,'name') && i.name == arguments.ref.name
			|| (arguments.candidate && structKeyExists(i,'cfc') && i.cfc == arguments.ref.cfc)){
				return;
			}
		}

		arrayAppend(hasArray,arguments.ref);
	}

	function pluralizeHasRefName(name){
		if(right(arguments.name,1) != 's'){
			return arguments.name & 's';
		} else {
			return arguments.name;
		}
	}

	private function setPropAsIDColumn(prop,isPrimaryKey=true){
		arguments.prop.type="string";
		arguments.prop.default="";

		/*
		if(arguments.isPrimaryKey){
			arguments.prop.required=true;
			arguments.prop.nullable=false;
		}
		*/
		if(!getIsProxiedEntity()){
			if(arguments.prop.name eq 'site'){
				arguments.prop.ormtype="varchar";
				arguments.prop.datatype="varchar";
				arguments.prop.length=25;
			} else {
				arguments.prop.ormtype="char";
				arguments.prop.datatype="char";
				arguments.prop.length=35;
			}
		}
	}

	function getEntityName(){

		if(!len(variables.entityName)){
			var md=getMetaData(this);

			if(structKeyExists(md,'entityName')){
				variables.entityName=listLast(md.entityName,".");
			} else {
				variables.entityName=listLast(md.name,".");

				if(variables.entityName != 'bean' && right(variables.entityName,4) eq "bean"){
					variables.entityName=left(variables.entityName,len(variables.entityName)-4);
				}
			}
		}

		return variables.entityName;

	}

	function getEntityDisplayName(){
		getEntityName();
		param name="application.objectMappings.#variables.entityName#.displayname" default=getEntityName();
		return application.objectMappings[variables.entityName].displayname;
	}

	function hasProperty(property){
		var props=getProperties();

		for(var prop in props){
			if(prop eq arguments.property or structKeyExists(props[prop],'column') and  props[prop].column eq arguments.property){
				return true;
			}
		}

		return false;
	}

	function isComparable(property){
		var props=getProperties();

		if(structKeyExists(props, property) && structKeyExists(props[property],'comparable')){
			return props[property].comparable;
		} else {
			return true;
		}
	}

	function getValidations(){
		getEntityName();

		if(structIsEmpty(variables.validations)){

			if(!isDefined('application.objectMappings.#variables.entityName#.validations')){
				lock type="exclusive" name="muraORMValidations#variables.entityName##application.instanceID#" timeout="5" {
					if(!isDefined('application.objectMappings.#variables.entityName#.validations')){
						param name="application.objectMappings" default={};
						param name="application.objectMappings.#variables.entityName#" default={};

						application.objectMappings[variables.entityName].validations={};
						application.objectMappings[variables.entityName].validations.properties={};

						var props=getProperties();
						var rules=[];
						var rule={};
						var ruleKey='';
						var tempRule='';
						var basicRules = ['regex','minValue','maxValue','minLength','maxLength','minCollection','maxCollection','minList','maxList','inlist','method','lte','lt','gte','gt','eq','neq'];


						for(var prop in props){

							if(props[prop].persistent){
								rules=[];

								if(structKeyExists(props[prop], "fkcolumn")){
									ruleKey=props[prop].fkcolumn;
								} else {
									ruleKey=prop;
								}

								if(structKeyExists(props[prop], "datatype") && props[prop].datatype != 'any'){
									if(structKeyExists(props[prop], "message")){
										rule={message=props[prop].message};
									} else {
										rule={};
									}
									structAppend(rule,{datatype=props[prop].datatype});
									arrayAppend(rules, rule);
								}

								if(structKeyExists(props[prop], "required") && props[prop].required){
									if(structKeyExists(props[prop], "message")){
										rule={message=props[prop].message};
									} else {
										rule={};
									}
									structAppend(rule,{required=props[prop].required});
									arrayAppend(rules,rule);
								}

								if(structKeyExists(props[prop], "format")){
									if(structKeyExists(props[prop], "message")){
										rule={message=props[prop].message};
									} else {
										rule={};
									}
									structAppend(rule,{format=props[prop].format});
									arrayAppend(rules,rule);
								}

								if(structKeyExists(props[prop], "length") && isNumeric(props[prop].length)){
									if(structKeyExists(props[prop], "message")){
										rule={message=props[prop].message};
									} else {
										rule={};
									}
									structAppend(rule,{maxLength=props[prop].length});
									arrayAppend(rules,rule);
								}

								for(var r=1;r <= arrayLen(basicRules);r++){
									if(structKeyExists(props[prop], basicRules[r])){
										if(structKeyExists(props[prop], "message")){
											rule={message=props[prop].message};
										} else {
											rule={};
										}
										tempRule=props[prop];
										structAppend(rule, {'#basicRules[r]#'=tempRule[basicRules[r]]});
										arrayAppend(rules, rule);
									}

								}

								if(arrayLen(rules)){
									application.objectMappings[variables.entityName].validations.properties[ruleKey]=rules;
								}
							}
						}
					}
				}
			}

			return application.objectMappings[variables.entityName].validations;
		}

		return variables.validations;
	}

	function setValidations(validations){
		variables.validations=arguments.validations;
		return this;
	}

	function getSynthedFunctions(){
		getEntityName();

		if(len(variables.entityName)){
			param name="application.objectMappings.#variables.entityName#" default={};
			param name="application.objectMappings.#variables.entityName#.synthedFunctions" default={};

			return application.objectMappings[variables.entityName].synthedFunctions;
		} else {
			return {};
		}
	}

	function compare(bean, propertyList=''){

		var returnStruct={};
		var diffMatchPatch=getBean('diffMatchPatch');
		var diffObj={};
		var i='';
		var propertyArray=listToArray(arguments.propertyList);
		var property='';

		if(!arrayLen(propertyArray)){
			propertyArray=StructKeyArray(getAllValues());
		}

		if(!isObject(arguments.bean) && isStruct(arguments.bean)){
			arguments.bean=new mura.bean.bean().set(arguments.bean);
		}

		for(i=1; i lte arrayLen(propertyArray); i++){
			property=propertyArray[i];
			if(isComparable(property)
				&& isSimpleValue(getValue(property))
				&& isSimpleValue(arguments.bean.getValue(property))
				&& getValue(property) != arguments.bean.getValue(property)
			){

				diffObj=diffMatchPatch.compute(javaCast('string',getValue(property)),javaCast('string',arguments.bean.getValue(property)));
				returnStruct[property]=diffObj;
			}
		}

		return returnStruct;
	}

	function getFeed(beanName=''){
		if(len(arguments.beanName) && arguments.beanName != getEntityName()){
			return getBean(arguments.beanName).getFeed();
		}

		if(getServiceFactory().containsBean(variables.entityName & 'Feed')){
			var feed=getBean(variables.entityName & 'Feed');
		} else {
			var feed=getBean('beanFeed');
		}

		feed.setEntityName(variables.entityName).setTable(getTable());

		if(hasProperty('siteid')){
			feed.setSiteID(getValue('siteID'));
		}

		if(len(getOrderBy())){
			feed.setOrderBy(getOrderBy());
		}

		return feed;
	}

	function exists() {
		param name="variables.instance.isNew" default=1;
		return !variables.instance.isNew;
	}

	function clone(){
		getBean("content").setAllValues(structCopy(getAllValues()));
	}

	//used in json api for entity specific permission checking
	function allowAccess($,m,mura){
		return false;
	}

	function allowSave(){
		return false;
	}

	function allowDelete(){
		return false;
	}

	function allowRead(){
		return true;
	}

	function allowQueryParams(params,$,m,mura){
		return true;
	}

	function applyGatewaySecurity(feed){
		return arguments.feed;
	}

	function transformEventName(eventName){
		var entityName=getEntityName();
		var beginningTrimmed=false;

		if(entityName=='contentnav'){
			entityName='content';
		}

		if(len(arguments.eventName) > 2 && left(arguments.eventName,2)=='on'){
			arguments.eventName=right(arguments.eventName,len(arguments.eventName)-2);
		}

		var eventNameMap={
			'beforesave'='before#entityName#save',
			'beforeUpdate'='before#entityName#Update',
			'beforeCreate'='before#entityName#Create',
			'aftersave'='after#entityName#save',
			'save'='after#entityName#save',
			'afterUpdate'='after#entityName#Update',
			'afterCreate'='after#entityName#Create',
			'beforeDelete'='before#entityName#Delete',
			'afterDelete'='after#entityName#Delete',
			'delete'='after#entityName#Delete'
		};

		if(structKeyExists(eventNameMap,arguments.eventName)){
			arguments.eventName=eventNameMap[arguments.eventName];
		}

		if(!(left(arguments.eventName,2) == 'on' || left(arguments.eventName,8) == 'standard')){
			arguments.eventName='on' & arguments.eventName;
		}

		return arguments.eventName;
	}

	function on(eventName,fn){
		var handler=new mura.baseobject();
		if(listFindNoCase('content,contentnav',getEntityName())){
			var pk='contentid';
		} else {
			var pk=get('primaryKey');
		}
		handler.injectMethod(transformEventName(arguments.eventName),arguments.fn);

		getBean('pluginManager').addEventHandler(component=handler,siteid=get('siteid'),objectid=get(pk));
		return this;
	}

	function trigger(eventName){
		if(listFindNoCase('content,contentnav',getEntityName())){
			var pk='contentid';
		} else {
			var pk=get('primaryKey');
		}
		getBean('pluginManager').announceEvent(
			eventToAnnounce=transformEventName(arguments.eventName),
			currentEventObject=new mura.event({
					siteid=get('siteid'),
					bean=this
				}),
			objectid=get(pk)
			);

		return this;
	}

	function addEventHandler(component){
		if(!isObject(arguments.component) && isStruct(arguments.component)){
			for(var e in arguments.component){
				on(e,component[e]);
			}
		} else {
			if(listFindNoCase('content,contentnav',getEntityName())){
				var pk='contentid';
			} else {
				var pk=get('primaryKey');
			}
			getBean('pluginManager').addEventHandler(component=arguments.component,siteid=get('siteid'),objectid=get(pk));
		}
		return this;
	}

	function registerAsEntity(){
		param name="request.muraRegisteredEntity" default={};

		if(!structKeyExists(request.muraRegisteredEntity,'#getEntityName()#')){
			getProperties();

			var tracePoint=initTracepoint("Registering Entity: #getEntityName()#");
			var reg=getRegisteredEntity();
			var dynamic=reg.getScaffold();

			if(reg.getIsNew() || reg.getDynamic()){

				if(reg.getIsNew()){
					reg
					.set('scaffold',getScaffold())
					.set('dynamic',getDynamic())
					.set('name',getEntityName())
					.set('displayName',getEntityDisplayName())
					.set('ishistorical',getIsHistorical());
				}

				var doSave=reg.getIsNew();

				var md=GetMetaData(this);

				if(structKeyExists(md,'path')){
					try{
						if(reg.getDynamic()){
							var code=fileRead(expandpath(md.path));
							if(len(code) && code != reg.get('code')){
								reg.set('code', code);
								doSave=true;
							}
						}
					} catch(any e){}

					if(md.path != reg.get('path')){
						reg.set('path',md.path);
						doSave=true;
					}
				}

				if(doSave){
					try{
						reg.save();
					} catch (any e){
						writeLog(type="Error", log="exception", text="Error registering #md.path#");
					}
				}
			}

			request.muraRegisteredEntity['#getEntityName()#']=true;
			commitTracePoint(tracePoint);
		}
	}

	function getRegisteredEntity(){
		return getBean('entity').loadBy(name=getEntityName());
	}

	function getPermissions(){
		var isSuperUser=getCurrentUser().isSuperUser();
		var permissions={
			read=isSuperUser,
			delete=isSuperUser,
			save=isSuperUser
		};

		if(!isSuperUser && get('siteid') != ''){
			var m=getBean('m').init(get('siteid'));
			var api=m.siteConfig().getApi(type="json", version="v1");
			var permUtility=getBean('permUtility');
			if(!getPublicAPI() && !(allowRead(m) || api.allowAccess(this,m))){
				return permissions;
			} else {
				permissions.save=(allowSave(m) || api.allowAction(this,m));
				permissions.delete=(allowDelete(m) || api.allowAction(this,m));
				permissions.read= getPublicAPI() || (api.allowAccess(this,m) && allowRead(m));
				return permissions;
			}
		} else {
			return permissions;
		}
	}

	function getListViewProps(){
		var props=getProperties();
		var result=[];
		for(p in props){
			if(structKeyExists(props[p],'listview') && props[p].listview){
				ArrayAppend(result,p);
			}
		}
		return result;
	}

	function getSearchableProps(){
		var props=getProperties();
		var result=[];
		for(p in props){
			if(structKeyExists(props[p],'datatype') && listFindNoCase('longtext,text,varchar',props[p].datatype)){
				ArrayAppend(result,p);
			}
		}
		return result;
	}

	function toBundle(){
		return this;
	}

}
