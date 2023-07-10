/* license goes here */
component extends="mura.bean.bean" versioned=false hint="This provides dynamic CRUD functionality"{

	//property name="categoryAssignments" fieldtype="one-to-many" relatesto="entityCategoryAssign" displayName="Category Assignments" loadkey="entityid" cascade="delete";
	//property name="tagAssignments" fieldtype="one-to-many" relatesto="entityTagAssign" displayName="Tag Assignments" loadKey="entityid" cascade="delete";
	property name="saveErrors" type="boolean" persistent="false" comparable="false" default=false;

	function init(){
		super.init();
		variables.dbUtility="";
		variables.entityName="";
		variables.loadSQLHasWhereClause=false;

		var props=getProperties();

		for(var prop in props){
			if(!structKeyExists(variables.instance,prop)){
				prop=props[prop];

				if(structKeyExists(prop,"type") and listFindNoCase("struct,array",prop.type)){
					if(prop.type eq "struct"){
						variables.instance[prop.name]={};
					} else if(prop.type eq "array"){
						variables.instance[prop.name]=[];
					}
				} else if(prop.persistent){

					if(structKeyExists(prop,"fieldType") and prop.fieldType eq "id"){
						variables.instance[prop.column]=createUUID();
					} else if (listFindNoCase('created,lastupdate',prop.column) && (listFindNoCase('datetime,timestamp',prop.datatype) && !(structKeyExists(prop,"default") && prop.default != 'null') || structKeyExists(prop,"default") && (prop.default=='now()' || prop.default=='now')) ){
						variables.instance[prop.column]=now();
					} else if(!listFindNoCase('datetime,timestamp',prop.datatype) && structKeyExists(prop,"default")){
						if(prop.default neq 'null'){
							variables.instance[prop.column]=prop.default;
						} else {
							variables.instance[prop.column]='';
						}
					}

					if (prop.name eq 'lastupdateby'){
						if(isDefined("variables.sessionData.mura") and variables.sessionData.mura.isLoggedIn){
							variables.instance.LastUpdateBy = left(variables.sessionData.mura.fname & " " & variables.sessionData.mura.lname,50);
						} else {
							variables.instance.LastUpdateBy='';
						}
					} else if (prop.name eq 'lastupdatebyid'){
						if(isDefined("variables.sessionData.mura") and variables.sessionData.mura.isLoggedIn){
							variables.instance.LastUpdateById = variables.sessionData.mura.userID;
						} else {
							variables.instance.LastUpdateById='';
						}
					}

				}
				else {
					if(listFindNoCase('created,lastupdate',prop.column) && prop.datatype=='datetime' && !(structKeyExists(prop,"default") && prop.default != 'null')){
						variables.instance[prop.column]=now();
					} else if(structKeyExists(prop,"default")){
						if(prop.default neq 'null'){
							variables.instance[prop.column]=prop.default;
						} else {
							variables.instance[prop.column]='';
						}
					}
				}

				if(!isDefined('variables.instance.#prop.column#')){
					variables.instance[prop.column]='';
				}
			}
		}

		//writeDump(var=variables.properties,abort=true);

		return this;
	}
	
	function isORM(){
		return true;
	}

	private function setPropAsIDColumn(prop,isPrimaryKey=true){
		super.setPropAsIDColumn(argumentCollection=arguments);

		if(arguments.isPrimaryKey){
			arguments.prop.required=true;
			arguments.prop.nullable=false;
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

		preLoad();

		super.set(argumentCollection=arguments);

		if(len(getDiscriminatorColumn())){
			setValue(getDiscriminatorColumn(),getDiscriminatorValue());
		}

		postLoad();

		return this;
	}


	function getDbUtility(){
		if(not isObject(variables.dbUtility)){
			variables.dbUtility=getBean('dbUtility');
			variables.dbUtility.setTable(getTable());
			if(hasCustomDatasource() ){
				variables.dbUtility.setValue('customDatasource',getCustomDatasource());
				variables.dbUtility.setValue('DbUsername','');
				variables.dbUtility.setValue('DbPassword','');

				if(structKeyExists(application.objectMappings[variables.entityName],'dbtype') ){
					variables.dbUtility.setValue('dbType',application.objectMappings[variables.entityName].dbtype);
				}
			}
		}
		return variables.dbUtility;
	}

	function setSaveErrors(saveErrors){
		if(isBoolean(arguments.saveErrors)){
			variables.instance.saveErrors=arguments.saveErrors;
		}
		return this;
	}

	function getSaveErrors(){
		if(!isBoolean(variables.instance.saveErrors)){
			variables.instance.saveErrors=false;
		}
		return variables.instance.saveErrors;
	}

	function getDbType(){
		return getDbUtility().getDbType();
	}

	function setDbUtility(dbUtility){
		variables.dbUtility=arguments.dbUtility;
	}

	function getDiscriminatorColumn(){
		return application.objectMappings[variables.entityName].discriminatorColumn;
	}

	function getDiscriminatorValue(){
		return application.objectMappings[variables.entityName].discriminatorValue;
	}

	function getReadOnly(){
		return application.objectMappings[variables.entityName].readonly;
	}

	function getManageSchema(){
		return application.objectMappings[variables.entityName].manageschema;
	}

	function getPrimaryKey(){
		return application.objectMappings[variables.entityName].primaryKey;
	}

	function getUseTrash(){
		return application.objectMappings[variables.entityName].usetrash;
	}

	function getColumns(){
		if(hasTable()){
			if(!structKeyExists(application.objectMappings[variables.entityName],'columns')){
				/*
				if(!isdefined('url.applydbupdates')){
					var filepath=expandPath('/muraWRM/config/_mura');
					if(!directoryExists(filepath)){
						directoryCreate(filepath);
					}
					filepath=filePath=filePath & "/entities";
					if(!directoryExists(filepath)){
						directoryCreate(filepath);
					}
					filePath=filePath & "/" & getEntityName() & "_columns.json";
					if(fileExists(filePath)){
						try {
							application.objectMappings[variables.entityName].columns=deserializeJSON(fileRead(filePath));
						} catch(e){}
					}
				}
				if(!structKeyExists(application.objectMappings[variables.entityName],'columns')){
				*/
					if(!getDbUtility().tableExists()){
						checkSchema();
					}
					application.objectMappings[variables.entityName].columns=getDbUtility().columns();
					//fileWrite(filePath,serializeJSON(application.objectMappings[variables.entityName].columns));
				//}
			}

			return application.objectMappings[variables.entityName].columns;
		} else {
			return {};
		}
	}

	function getSite(){
		return getBean('settingsManager').getSite(getValue('siteID'));
	}

	function checkSchema(){
		var props=getProperties();
		getEntityName();

		if(!getManageSchema()){
			throw(type="MuraORMError",message="The Mura ORM entity '#getEntityName()#' is not allowed to manage schema.");
		}

		if(getBean('configBean').getValue(property="applyDbUpdates",defaultValue=true) && hasTable() && !structIsEmpty(props)){
			for(var prop in props){
				if(props[prop].persistent){
					getDbUtility().addColumn(argumentCollection=props[prop]);

					if(structKeyExists(props[prop],"fieldtype")){
						if(props[prop].fieldtype eq "id" && (!getIsHistorical() || props[prop].name=='histid')){
							getDbUtility().addPrimaryKey(argumentCollection=props[prop]);
						} else if ( listFindNoCase('one-to-one,one-to-many,many-to-one,index,id,unique-index',props[prop].fieldtype) ){
							getDbUtility().addIndex(argumentCollection=props[prop]);
						} else if ( 'unique-index'==props[prop].fieldtype ){
							getDbUtility().addUniqueIndex(argumentCollection=props[prop]);
						}
					}
				}
			}
		}

		param name="application.objectMappings.#variables.entityName#" default={};
		application.objectMappings[variables.entityName].columns=getColumns();
		
		//WriteDump(reg.getErrors());abort;

		return this;
	}

	function hasCustomDatasource(){
		return structKeyExists(application.objectMappings[variables.entityName],'datasource');
	}

	function getCustomDatasource(){
		return application.objectMappings[variables.entityName].datasource;
	}

	function getQueryAttrs(readOnly=getReadOnly()){
		return super.getQueryAttrs(argumentCollection=arguments);
	}

	function getQueryService(readOnly=getReadOnly()){
		return super.getQueryService(argumentCollection=arguments);
	}

	private function getQueryParamType(datatype){
		if(arguments.datatype=='int'){
			return "cf_sql_integer";
		} else if (arguments.datatype=='boolean'){
			return "cf_sql_bit";
		} else {
			return "cf_sql_" & arguments.datatype;
		}
	}

	private function addQueryParam(qs,prop,value){
		var paramArgs={};
		var columns=getColumns();

		if(arguments.prop.persistent){

			paramArgs={name=arguments.prop.column,cfsqltype=getQueryParamType(columns[arguments.prop.column].datatype)};

			if(structKeyExists(arguments,'value')){
				paramArgs.null=arguments.prop.nullable and (not len(arguments.value) or arguments.value eq "null");
			}	else {
				arguments.value='null';
				paramArgs.null=arguments.prop.nullable and (not len(variables.instance[arguments.prop.column]) or variables.instance[arguments.prop.column] eq "null");
			}

			if(arguments.prop.column == getDiscriminatorColumn()){
				paramArgs.value=getDiscriminatorValue();
			} else {
				paramArgs.value=arguments.value;
			}

			if(listFindNoCase('int,smalllint,tinyint',columns[arguments.prop.column].datatype) && isNumeric(paramArgs.value)){
				paramArgs.value=int(paramArgs.value);
			} else if(columns[arguments.prop.column].datatype eq 'datetime'){
				paramArgs.cfsqltype='cf_sql_timestamp';
				paramArgs.value=parseDateArg(paramArgs.value);
			} else if(listFindNoCase('text,longtext,json',columns[arguments.prop.column].datatype)){
				paramArgs.cfsqltype='cf_sql_longvarchar';
				if(columns[arguments.prop.column].datatype == 'json'){
					if(!isJSON(paramArgs.value)){
						paramArgs.value=serializeJSON(paramArgs.value);
					} else {
						paramArgs.value=serializeJSON(deserializeJSON(paramArgs.value));
					}
				}
			}

			if(len(variables.encryptionKey) && structKeyExists(arguments.prop,'encrypted')
				&& arguments.prop.encrypted) {
				if(len(variables.encryptionKey) && listFirst(paramArgs.value,":") != 'encrypted'){
					paramArgs.value="encrypted:#encrypt(paramArgs.value, variables.encryptionKey,"AES")#";
				}
			}

			arguments.qs.addParam(argumentCollection=paramArgs);

			return true;
		} else {
			return false;
		}

	}

	function validate(){
		super.validate();
		var props=getProperties();

		if(!len(getPrimaryKey()) || !props[getPrimaryKey()].persistent || !len(variables.instance[getPrimaryKey()]) || getPrimaryKey() == 'primarykey'){
			variables.instance.errors.primarykey="The primary key '#getPrimaryKey()#' is required.";
		}

		return this;
	}

	function save(){
		var pluginManager=getBean('pluginManager');
		var event=new mura.event({siteID=getValue('siteid'),bean=this});

		if(getIsHistorical()){
			set('histid',createUUID());
		}

		validate();

		if(getReadOnly()){
			throw(type="MuraORMError",message="The Mura ORM entity '#getEntityName()#' is read only.");
		}

		pluginManager.announceEvent(eventToAnnounce='onBefore#variables.entityName#Save',currentEventObject=event,objectid=get(get('primaryKey')));

		if(!hasErrors() || getSaveErrors()){
			var props=getProperties();
			var columns=getColumns();
			var prop={};
			var started=false;
			var sql='';
			var qs=getQueryService();

			// Set lastupdate columns if defined
			if (structkeyexists(props, "lastupdate") && listFindNoCase('datetime,timestamp',props.lastupdate.datatype)) {
				variables.instance.lastupdate = now();
			}
			if (structkeyexists(props, "lastupdateby")) {
				if(isDefined("variables.sessionData.mura") and variables.sessionData.mura.isLoggedIn){
					variables.instance.LastUpdateBy = left(variables.sessionData.mura.fname & " " & variables.sessionData.mura.lname,50);
				} else {
					variables.instance.LastUpdateBy='';
				}
			}
			if (structkeyexists(props, "lastupdatebyid")) {
				if(isDefined("variables.sessionData.mura") and variables.sessionData.mura.isLoggedIn){
					variables.instance.LastUpdateById = variables.sessionData.mura.userID;
				} else {
					variables.instance.LastUpdateById='';
				}
			}

			qs.addParam(name='primarykey',value=variables.instance[getPrimaryKey()],cfsqltype='cf_sql_varchar');

			if(!getIsHistorical() && qs.execute(sql='select #getPrimaryKey()# from #getTable()# where #getPrimaryKey()# = :primarykey').getResult().recordcount){

				pluginManager.announceEvent(eventToAnnounce='onBefore#variables.entityName#Update',currentEventObject=event,objectid=get(get('primaryKey')));
				preUpdate();

				for (prop in props){
					if(props[prop].persistent){
						addQueryParam(qs,props[prop],variables.instance[props[prop].column]);
					}
				}

				if(!hasErrors() || getSaveErrors()){

					savecontent variable="sql" {
						writeOutput('update #getTable()# set ');
						for(prop in props){
							if(props[prop].persistent && props[prop].column neq getPrimaryKey() && structKeyExists(columns, props[prop].column)){
								if(started){
									writeOutput(",");
								}
								writeOutput("#getDbUtility().getEscapedColumnName(props[prop].column)# = :#props[prop].column#");
								started=true;
							}
						}

						writeOutput(" where #getDbUtility().getEscapedColumnName(getPrimaryKey())# = :primarykey");

					}


					var obj='';

					if(arrayLen(variables.instance.removeObjects)){
						for(obj in variables.instance.removeObjects){
							obj.delete();
						}
					}

					if(arrayLen(variables.instance.addObjects)){
						for(obj in variables.instance.addObjects){
							obj.save();
						}
					}

					qs.execute(sql=sql);

					if(getUseCache()){
						purgeCache();
					}

					postUpdate();

					pluginManager.announceEvent(eventToAnnounce='onAfter#variables.entityName#Update',currentEventObject=event,objectid=get(get('primaryKey')));

					variables.instance.isnew=0;
					variables.instance.addObjects=[];
					variables.instance.removeObjects=[];
				}

			} else{

				//Historical saves always insert, if deleted then events are fired within delete method
				if(!(getIsHistorical() && get('deleted')==1)){
					if(exists()){
						preUpdate();
						pluginManager.announceEvent(eventToAnnounce='onBefore#variables.entityName#Update',currentEventObject=event,objectid=get(get('primaryKey')));
					} else {
						preCreate();
						preInsert();
						pluginManager.announceEvent(eventToAnnounce='onBefore#variables.entityName#Create',currentEventObject=event,objectid=get(get('primaryKey')));
					}
				}

				for (prop in props){
					if(props[prop].persistent){
						addQueryParam(qs,props[prop],variables.instance[props[prop].column]);
					}
				}

				if(!hasErrors() || getSaveErrors()){

					savecontent variable="sql" {
						writeOutput('insert into #getTable()# (');
						for(prop in props){
							if(props[prop].persistent && structKeyExists(columns, props[prop].column)){
								if(started){
									writeOutput(",");
								}
								
								writeOutput(getDbUtility().getEscapedColumnName(props[prop].column));
								started=true;
							}
						}

						writeOutput(") values (");

						started=false;
						for(prop in props){
							if(props[prop].persistent && structKeyExists(columns, props[prop].column)){
								if(started){
									writeOutput(",");
								}
								writeOutput(" :#props[prop].column#");
								started=true;
							}
						}

						writeOutput(")");

					}

					if(arrayLen(variables.instance.addObjects)){
						for(var obj in variables.instance.addObjects){
							obj.save();
						}
					}

					qs.execute(sql=sql);

					if(getUseCache()){
						purgeCache();
					}

					var doesExist=exists();

					variables.instance.isnew=0;
					variables.instance.addObjects=[];
					variables.instance.removeObjects=[];

					//Historical saves always insert, if deleted then events are fired within delete method
					if(!(getIsHistorical() && get('deleted')==1)){
						if(doesExist){
							postUpdate();
							pluginManager.announceEvent(eventToAnnounce='onAfter#variables.entityName#Update',currentEventObject=event,objectid=get(get('primaryKey')));
						} else{
							postCreate();
							postInsert();

							pluginManager.announceEvent(eventToAnnounce='onAfter#variables.entityName#Create',currentEventObject=event,objectid=get(get('primaryKey')));
						}
					}
				}
			}

			saveTagsAndCategories();

			//if historical and deleted then events are fired within delete method
			if(!(getIsHistorical() && get('deleted')==1)){
				pluginManager.announceEvent(eventToAnnounce='onAfter#variables.entityName#Save',currentEventObject=event,objectid=get(get('primaryKey')));
				pluginManager.announceEvent(eventToAnnounce='on#variables.entityName#Save',currentEventObject=event,objectid=get(get('primaryKey')));
			}

		/*
		} else {
			request.muratransaction=request.muratransaction-1;
		*/
		}

		if(getUseTrash()){
			getBean('trashManager').takeOut(this);
		}

		return this;
	}

	function saveTagsAndCategories(){

		if(getCategorizable() && (has('categoryid') || has('category'))){
			var saveCategories=false;
			var categoryArray=[];
			if(len(get('category'))){
				saveCategories=true;
				var checkArray=get('category');
				var categoryArray=[];

				if(!isArray(checkArray)){
					checkArray=listToArray(checkArray);
				}

				if(arrayLen(checkArray)){
					for(var i in checkArray){
						i=trim(i);
						if(len(i)){
							if(isValid(i,'uuid')){
								arrayAppend(categoryArray,i);
							} else {
								var category=$.getBean('category').loadBy(name=i);
								if(category.exists()){
									arrayAppend(categoryArray,i);
								}			
							} 
						}
					}
					
				}
			}

			if(len(get('categoryid'))){
				saveCategories=true;
				var categoryArray=get('categoryid');

				if(!isArray(categoryArray)){
					categoryArray=listToArray(categoryArray);
				}
			}

			if(saveCategories){
				queryExecute(
					"delete from tentitycategoryassign where entityid = :entityid",
					{
						entityid={
							value= get(get('primaryKey')),
							type= "varchar"
						}
					}
				);

				if(arrayLen(categoryArray)){
					for(var i in categoryArray){
						getBean('entityCategoryAssign')
							.set({
								entityid=get(get('primaryKey')),
								enititytype=getEntityName(),
								categoryid=i,
								siteid=get('siteid')
							})
							.save();
					}
				}
			}
		}

		if(getTaggable() && has('tags')){
			queryExecute(
				"delete from tentitytagassign where entityid = :entityid",
				{
					entityid={
						value= get(get('primaryKey')),
						type= "varchar"
					}
				}
			);

			for(var i in listToArray(get('tags'))){
				getBean('entityTagAssign')
					.set({
						entityid=get(get('primaryKey')),
						enititytype=getEntityName(),
						tag=i,
						taggroup='default',
						siteid=get('siteid')
					})
					.save();
			}
		}
	}
	
	function updateMappingsByIDLists(){
		var props=getProperties();
		var loadArgs={};
		var i=0;
		var subitem='';
		var subPrimaryKey='';
		var deleteID="";
		var saveID='';
		var subEntity='';
		var subItems='';
		var primaryLoadArgs={};
		var isMappingEntity=false;

		for(var prop in props){
			if(structKeyExists(props[prop],'cfc')
				&& props[prop].fieldtype eq 'one-to-many'
				&& structKeyExists(props[prop],'keycolumn') ){

				if( valueExist(props[prop].keycolumn) ){
					if(props[prop].fkcolumn eq 'primaryKey'){
						primaryLoadArgs={'#getPrimaryKey()#'=getValue(translatePropKey(props[prop].fkcolumn))};
					} else {
						primaryLoadArgs={'#props[prop].fkcolumn#'=getValue(translatePropKey(props[prop].fkcolumn))};
					}

					subItems=invoke(getBean(variables.entityName).loadBy(argumentCollection=primaryLoadArgs),'get#prop#Iterator');
					saveID=getValue(props[prop].keycolumn);
					deleteID="";

					while(subItems.hasNext()){
						subitem=subitems.next();
						if(not listFindNoCase(saveID,subItem.getValue(props[prop].keycolumn)) ){
		                    deleteID=listAppend(deleteID,subItem.getValue(props[prop].keycolumn));
		                }
					}

	            	if(len(deleteID)){
		                for(i=1; i lte listLen(deleteID); i=i+1){
		                	loadArgs=structAppend({'#props[prop].keycolumn#'=listGetAt(deleteID,i)},primaryLoadArgs);
		                	subItem=getBean(props[prop].cfc).loadBy(argumentCollection=loadArgs);

		                	if(!subItem.getIsNew()){
			                	if( props[prop].cascade eq 'delete'){
			                    	subItem.delete();
			                    } else {
			                    	if(props[prop].fkcolumn eq 'primaryKey'){
										 subItem.setValue(getPrimaryKey(),'');
									} else {
										 subItem.setValue(props[prop].fkcolumn,'');
									}
			                    }
		                	}
		                }
            		}

					for( i=1; i lte listLen(saveID); i=i+1){
							loadArgs=structAppend({'#props[prop].keycolumn#'=listGetAt(saveID,i)},primaryLoadArgs);

		               		getBean(props[prop].cfc)
		                    .loadBy(argumentCollection=loadArgs)
		                    .setOrderNo(i)
		                    .save();
	            	}
            	}
			}
		}
	}

	/*
	function save(){
		if(request.muraORMtransaction){
			_save();
		} else {
			request.muraORMtransaction=true;
			transaction {
				try{
					_save();
					if(request.muraORMtransaction){
						transactionCommit();
					} else {
						transactionRollback();
					}
				} catch(any err){
					transactionRollback();
				}
			}
			request.muraORMtransaction=false;
		}
	}

	function delete(){
		if(request.muraORMtransaction){
			_delete();
		} else {
			request.muraORMtransaction=true;
			transaction {
				try{
					_delete();
					if(request.muraORMtransaction){
						transactionCommit();
					} else {
						transactionRollback();
					}
				}
				catch(any err){
					transactionRollback();
				}
			}
			request.muraORMtransaction=false;
		}
	}*/

	function delete(){
		var props=getProperties();
		var pluginManager=getBean('pluginManager');
		var event=new mura.event({siteID=getValue('siteid'),bean=this});
		var subitem="";

		preDelete();
		pluginManager.announceEvent(eventToAnnounce='onBefore#variables.entityName#Delete',currentEventObject=event,objectid=get(get('primaryKey')));

		for(var prop in props){
			if(structKeyExists(props[prop],'cfc') and props[prop].fieldtype eq 'one-to-many' and  props[prop].cascade eq 'delete'){
				if(props[prop].fkcolumn eq 'primaryKey'){
					var loadArgs[getPrimaryKey()]=getValue(translatePropKey(props[prop].fkcolumn));
				} else {
					var loadArgs[props[prop].fkcolumn]=getValue(translatePropKey(props[prop].fkcolumn));
				}
				var subItems=invoke(getBean(variables.entityName).loadBy(argumentCollection=loadArgs),'get#prop#Iterator');
				while(subItems.hasNext()){
					subitem=subitems.next();
					if(!subitem.getIsNew()){
						subItem.setDeletedParentID(getValue(getPrimaryKey()));
						subitem.delete();
					}
				}
			}
		}

		if(getIsHistorical()){
			set('deleted',1);
			save(argumentCollection=arguments);
		} else {
			var qs=getQueryService();
			qs.addParam(name='primarykey',value=variables.instance[getPrimaryKey()],cfsqltype='cf_sql_varchar');
			qs.execute(sql='delete from #getTable()# where #getDbUtility().getEscapedColumnName(getPrimaryKey())# = :primarykey');
		}

		if(getUseCache()){
			purgeCache();
		}

		postDelete();

		if(getCategorizable()){
			queryExecute(
				"delete from tentitycategoryassign where entityid = :entityid",
				{
					entityid={
						value: get(get('primaryKey')),
						type: "varchar"
					}
				}
			);
		}

		if(getTaggable()){
			queryExecute(
				"delete from tentitytagassign where entityid = :entityid",
				{
					entityid={
						value: get(get('primaryKey')),
						type: "varchar"
					}
				}
			);
		}

		pluginManager.announceEvent(eventToAnnounce='onAfter#variables.entityName#Delete',currentEventObject=event,objectid=get(get('primaryKey')));
		pluginManager.announceEvent(eventToAnnounce='on#variables.entityName#Delete',currentEventObject=event,objectid=get(get('primaryKey')));

		if(getUseTrash()){
			getBean('trashManager').throwIn(this);
		}

		return this;
	}

	function loadBy(returnFormat="self",cachedWithin=createTimeSpan(0,0,0,0)){
		var qs=getQueryService(readOnly=true,cachedWithin=arguments.cachedWithin);
		var sql="";
		var props=getProperties();
		var prop="";
		var columns=getColumns();
		var started=variables.loadSQLHasWhereClause;
		var rs="";
		var hasArg=false;
		var hasdiscriminator=len(getDiscriminatorColumn());
		var discriminatorColumn=getDiscriminatorColumn();
		var foundDiscriminator=false;
		var primaryOnly=true;
		var primaryFound=false;
		var primarykeyargvalue='';
		var addVersionFilter=getIsVersioned() && !structKeyExists(arguments,'contenthistid');
		var tracePoint=initTracePoint(detail="Loading #getEntityName()#");

		if(!isDefined('arguments.siteid') && hasProperty('siteid') && len(getValue('siteID'))){
			arguments.siteid=getValue('siteID');
		}

		if(getIsHistorical()){
			if(isDate(request.muraPointInTime)){
				qs.addParam(name="pointInTime",cfsqltype="cf_sql_timestamp",value=request.muraPointInTime);
			} else {
				qs.addParam(name="pointInTime",cfsqltype="cf_sql_timestamp",value=now());
			}
		}

		savecontent variable="sql"{
			writeOutput(getLoadSQL() & " ");

			if(getIsHistorical()){
				writeOutput("
					inner join (
						select #getPrimaryKey()# pkey, max(lastupdate) lastupdatemax from #getTable()#
						where
						lastupdate <= :pointInTime
						group by #getPrimaryKey()#


					) activeTable
					 on (
						#getTable()#.#getPrimaryKey()#=activeTable.pkey
						and #getTable()#.lastupdate=activeTable.lastupdatemax
					 )"
				 );

			}

			if(addVersionFilter){
				writeOutput("
					inner join tcontent on (
						#getTable()#.contenthistid=tcontent.contenthistid
					)
				");
			}

			for(var arg in arguments){
				hasArg=false;
				prop=arg;

				if(structKeyExists(props,arg) or arg eq 'primarykey'){
					hasArg=true;
				} else if (structKeyExists(columns,arg)) {
					for(prop in props){
						if(props[prop].column eq arg){
							hasArg=true;
							break;
						}
					}
				}

				if(hasArg){
					if(arg eq 'primarykey'){
						arg=getPrimaryKey();
						prop=arg;
					}

					if(
						arg != getPrimaryKey()
						&& arg != 'siteid'
						&& !(hasDiscriminator && arg==discriminatorColumn)
					){
						primaryOnly=false;
					} else if(arg == getPrimaryKey() && len(arguments[arg])){
						primaryFound=true;
						primarykeyargvalue=arguments[arg];
					}

					if(hasdiscriminator && !foundDiscriminator && arg==discriminatorColumn){
						foundDiscriminator=true;
					}

					addQueryParam(qs,props[prop],arguments[arg]);

					if(not started){
						writeOutput("where ");
						started=true;
					} else {
						writeOutput("and ");
					}

					writeOutput(" #getTable()#.#arg#= :#arg# ");
				}

				if(hasDiscriminator && !foundDiscriminator){
					if(not started){
						writeOutput("where ");
						started=true;
					} else {
						writeOutput("and ");
					}

					writeOutput(" #getTable()#.#discriminatorColumn#= :#getDiscriminatorValue()# ");
				}

			}

			if(getIsHistorical()){
				if(not started){
					writeOutput("where ");
					started=true;
				} else {
					writeOutput("and ");
				}

				writeOutput(" #getTable()#.deleted= 0 ");
			}

			if(addVersionFilter){
				if(not started){
					writeOutput("where 1=1");
					started=true;
				}
				
				WriteOutput("#getBean('contentDAO').renderActiveClause("tcontent",arguments.siteID)#");
			}

			if(structKeyExists(arguments,'orderby') && len(arguments.orderby)){
				writeOutput("order by #arguments.orderby# ");
			} else if(len(getOrderBy())){
				writeOutput("order by #getOrderBy()# ");
			}
		}

		if(primaryFound && primaryOnly && getUseCache()){
			var cache=getCache();
			var cacheKey=getCacheKey(primarykeyargvalue);

			if(cache.has(cacheKey)){
				try{
					rs=cache.get(cacheKey);
					if(isDefined('rs')){
						setValue("frommuracache",true);
						commitTracePoint(initTracePoint(detail="DATA CACHE HIT: {class: #getEntityName()#, key: #cacheKey#}"));
					} else {
						rs=qs.execute(sql=sql).getResult();
						if(rs.recordcount){
							cache.get(cacheKey,rs);
						}
						commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: #getEntityName()#, key: #cacheKey#}"));
					}
				} catch(any e){
					rs=qs.execute(sql=sql).getResult();
					if(rs.recordcount){
						cache.get(cacheKey,rs);
					}
					commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: #getEntityName()#, key: #cacheKey#}"));
				}
			} else {
				rs=qs.execute(sql=sql).getResult();
				if(rs.recordcount){
					cache.get(cacheKey,rs);
				}
				commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: #getEntityName()#, key: #cacheKey#}"));
			}
		} else {
			rs=qs.execute(sql=sql).getResult();
		}

		if(rs.recordcount){
			set(rs);
		} else {
			set(arguments);
		}

		commitTracePoint(tracePoint);

		if(arguments.returnFormat eq 'query'){
			return rs;
		} else if( arguments.returnFormat eq 'iterator'){
			return getBean('beanIterator').setEntityName(variables.entityName).setQuery(rs);
		} else {
			return this;
		}
	}

	function getLoadSQL(){
		return "select #getLoadSQLColumnsAndTables()# ";
	}

	function getLoadSQLColumnsAndTables(){
		return "* from #getTable()# ";
	}

	function clone(){
		return getBean(variables.entityName).setAllValues(duplicate(getAllValues()));
	}

	function getFeed(){
		var feed=getBean('beanFeed').setEntityName(variables.entityName).setTable(getTable());

		if(hasProperty('siteid')){
			feed.setSiteID(getValue('siteID'));
		}

		if(len(getOrderBy())){
			feed.setOrderBy(getOrderBy());
		}

		return feed;
	}

	//BUNDLE METHODS

	function getIterator(){
		return getBean('beanIterator').setEntityName(variables.entityName);
	}

	function toBundle(bundle,siteid){
		var qs=getQueryService(readOnly=true);

		if(hasColumn('siteid') && structKeyExists(arguments,'siteid')){
			qs.setSQL("select * from #getTable()# where siteid = :siteid");
			qs.addParam(name="siteid",cfsqltype="cf_sql_varchar",value=arguments.siteid);
			arguments.bundle.setValue("rs" & getTable(),qs.execute().getResult());
		} else {
			arguments.bundle.setValue("rs" & getTable(),qs.execute(sql="select * from #getTable()#").getResult());
		}
		return this;
	}

	function fromBundle(bundle,keyFactory,siteid){
		var rs=arguments.bundle.getValue('rs' & getTable());
		var item='';
		var prop='';

		if(isQuery(rs) && rs.recordcount){
			var it=getIterator().setQuery(rs);

			while (it.hasNext()){
				item=it.next();

				if(structKeyExists(arguments, "siteid") && len(arguments.siteid) && item.hasProperty('siteid')){
					item.setValue('siteid',arguments.siteid);
				}

				for(prop in getProperties()){
					if(isSimpleValue(item.getValue(prop)) && isValid('uuid',item.getValue(prop)) ){
						item.setValue(prop,arguments.keyFactory.get(item.getValue(prop)));
					}

				}

				item.save();

			}


		}
	}

	//CACHING METHODS

	function getCacheName(){
		return application.objectMappings[variables.entityName].cachename;
	}

	function getCache(){
		return getBean('settingsManager').getSite(getCacheSiteID()).getCacheFactory(name=getCacheName());
	}

	function getUseCache(){
		return getBean('settingsManager').getSite(getCacheSiteID()).getCache();
	}

	function purgeCache(){
		var cacheKey=getCacheKey();
		getCache().purge(key=cacheKey);
		getBean('clusterManager').purgeCacheKey(cacheName=getCacheName(),cacheKey=cacheKey,siteid=getCacheSiteID());
	}

	function getCacheKey(primarykey){
		if(structKeyExists(arguments,'primarykey')){
			return getEntityName() & arguments.primarykey;
		} else {
			return getEntityName() & getValue(getPrimaryKey());
		}
	}

	function getCacheSiteID(){
		if(len(getValue('siteid'))){
			return getValue('siteid');
		} else {
			param name="variables.sessionData.siteid" default="default";
			return variables.sessionData.siteid;
		}
	}

	function hasColumn(column){
		getColumns();
		return isDefined("application.objectMappings.#getValue('entityName')#.columns.#arguments.column#");
	}

	function getPropertiesAsJSON(){
			var m=getBean('m').init('default');
			var props=m.siteConfig().getAPI().findProperties(getEntityName()).properties;
			var newline=chr(13)&chr(10);
			var tab=chr(9);
			var serialier=new mura.jsonSerializer();
			var result='{#newline##tab#"entityname"="#getEntityName()#",#newline##tab#displayname"="#getEntityDisplayName()#",#newline##tab#"table"="#getTable()#",#newline##tab#"historical"="#getIsHistorical()#",#newline##tab#"orderby"="#getOrderBy()#",#newline##tab#"bundleable"="#getBundleable()#",#newline##tab#"scaffold"="#getScaffold()#",#newline##tab#"public"="#getPublicAPI()#",#newline##tab#"properties"=[';

			for(var p in props){
				result = result & newline & tab & tab & "{";

				for(var k in p){
					result = result & newline & tab & tab & tab & '"#lcase(k)#"="#p[k]#",';
				}

				result = result & newline & tab & tab & "},";
			}

			result = result & newline & tab & "]";
			result = result & newline & "}";

			return result;
	 }

	//ORM EVENTHANDLING

	private function preLoad(){};
	private function postLoad(){};
	private function preUpdate(){};
	private function postUpdate(){};
	private function preCreate(){};
	private function preInsert(){};
	private function postCreate(){};
	private function postInsert(){};
	private function preDelete(){};
	private function postDelete(){};

}
