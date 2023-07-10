<!--- license goes here --->
<cfcomponent extends="mura.bean.bean" output="false" hint="This is provides base feed functionality for all entities">

	<cfproperty name="entityName" type="string" default="">
	<cfproperty name="table" type="string" default="">
	<cfproperty name="keyField" type="string" default="">
	<cfproperty name="nextN" type="numeric" default="0" required="true">
	<cfproperty name="maxItems" type="numeric" default="1000" required="true">
	<cfproperty name="siteID" type="string" default="">
	<cfproperty name="contentpoolid" type="string" default="">
	<cfproperty name="sortBy" type="string" default="">
	<cfproperty name="sortDirection" type="string" default="asc" required="true">
	<cfproperty name="orderby" type="string" default="">
	<cfproperty name="additionalColumns" type="string" default="">
	<cfproperty name="sortTable" type="string" default="">
	<cfproperty name="pageIndex" type="numeric" default="1">

	<cfscript>
	function init() output=false {
		variables.instance={};
		variables.instance.isNew=1;
		variables.instance.errors={};
		variables.customSort=false;
		variables.instance.fromMuraCache = false;
		if ( !structKeyExists(variables.instance,"instanceID") ) {
			variables.instance.instanceID=createUUID();
		}
		variables.instance.addObjects=[];
		variables.instance.removeObjects=[];
		variables.instance.siteID="";
		variables.instance.contentPoolID="";
		variables.instance.entityName="";
		variables.instance.fields="";
		variables.instance.distinct=false;
		variables.instance.table="";
		variables.instance.keyField="";
		variables.instance.sortBy="";
		variables.instance.sortDirection="asc";
		variables.instance.orderby="";
		variables.instance.tableFieldLookUp=structNew();
		variables.instance.tableFieldlist="";
		variables.instance.nextN=1000;
		variables.instance.maxItems=0;
		variables.instance.pageIndex=1;
		variables.instance.additionalColumns="";
		variables.instance.sortTable="";
		variables.instance.fieldAliases={};
		variables.instance.cachedWithin=createTimeSpan(0,0,0,0);
		variables.instance.params=queryNew("param,relationship,field,condition,criteria,dataType","integer,varchar,varchar,varchar,varchar,varchar" );
		variables.instance.joins=arrayNew(1);
		variables.instance.pendingParam={};
		variables.instance.sumValArray=[];
		variables.instance.countValArray=[];
		variables.instance.avgValArray=[];
		variables.instance.minValArray=[];
		variables.instance.maxValArray=[];
		variables.instance.groupByArray=[];

		return this;
	}

	function getEntityName() output=false {
		return variables.instance.entityName;
	}

	function setEntityName(entityName) output=false {
		variables.instance.entityName=arguments.entityName;
		return this;
	}

	function getOrderBy() output=false {
		return variables.instance.orderby;
	}

	function setOrderBy(orderby) output=false {
		variables.instance.orderby=arguments.orderby;
		return this;
	}

	function getContentPoolID() output=false {
		if ( !len(variables.instance.contentpoolid) ) {
			variables.instance.contentpoolid=variables.instance.siteid;
		} else if ( variables.instance.contentpoolid == '*' ) {
			variables.instance.contentpoolid=getBean('settingsManager').getSite(variables.instance.siteid).getContentPoolID();
		}
		return variables.instance.contentpoolid;
	}

	function getSort() output=false {
		return variables.instance.orderby;
	}

	function setSort(sort) output=false {
		setOrderBy(orderby=arguments.sort);
		return this;
	}

	function setSortDirection(any sortDirection) output=false {
		if ( listFindNoCase('desc,asc',arguments.sortDirection) ) {
			variables.instance.sortDirection = arguments.sortDirection;
		}
		return this;
	}

	function setItemsPerPage(itemsPerPage) output=false {
		setNextN(nextN=arguments.itemsPerPage);
		return this;
	}

	function getItemsPerPage() output=false {
		return variables.instance.NextN;
	}

	function setNextN(any NextN) output=false {
		if ( isNumeric(arguments.nextN) ) {
			variables.instance.NextN = arguments.NextN;
		}
		return this;
	}

	function setMaxItems(any maxItems) output=false {
		if ( isNumeric(arguments.maxItems) ) {
			variables.instance.maxItems = arguments.maxItems;
		}
		return this;
	}

	function setFields(fields) output=false {
		loadTableMetaData();
		var tempArray=[];
		if(len(arguments.fields)){
			for(var p in listToArray(arguments.fields)){
				var c=listFirst(trim(p),'.');
				if(structKeyExists(application.objectMappings[getEntityName()].columns,c)){
					arrayAppend(tempArray,transformFieldName(p));
				}
			}
		}
		variables.instance.fields=arrayToList(tempArray);
		return this;
	}

	function setDistinct(distinct=true) output=false {
		variables.instance.distinct=arguments.distinct;
		return this;
	}

	function getFields() output=false {
		return variables.instance.fields;
	}

	function getDistinct() output=false {
		return variables.instance.distinct;
	}

	function loadTableMetaData() output=false {
		var rs="";
		var temp="";
		var i="";
		if ( !structKeyExists(application.objectMappings, variables.instance.entityName) ) {
			application.objectMappings[variables.instance.entityName] = structNew();
		}
		if ( !structKeyExists(application.objectMappings[variables.instance.entityName], "columns") ) {
			var entity=getEntity();
			var dbUtility=entity.getDbUtility();
			if(entity.hasTable() && !dbUtility.tableExists() && structKeyExists(entity,"checkSchema")){
				entity.checkSchema();	
			}
			application.objectMappings[variables.instance.entityName].columns = dbUtility.columns(table=variables.instance.table);
		}
		if ( !structKeyExists(application.objectMappings[variables.instance.entityName], "columnlist") ) {
			application.objectMappings[variables.instance.entityName].columnlist = structKeyList(application.objectMappings[variables.instance.entityName].columns);
		}
	}

	function getTableFieldList() output=false {
		loadTableMetaData();
		return application.objectMappings[variables.instance.entityName].columnlist;
	}

	function formatField(field) output=false {
		loadTableMetaData();
		//list first on field value in case json field
		if ( structKeyExists(application.objectMappings[variables.instance.entityName].columns,listFirst(arguments.field,'.')) ) {
			arguments.field="#variables.instance.table#.#arguments.field#";
		}
		return arguments.field;
	}

	function setConfigBean(configBean) output=false {
		variables.configBean=arguments.configBean;
		return this;
	}

	function setAdvancedParams(required any params) output=false {
		return setParams(argumentCollection=arguments);
	}

	function setParams(required any params) output=false {
		var rows=0;
		var I = 0;
		if ( isquery(arguments.params) ) {
			variables.instance.params=arguments.params;
		} else if ( isdefined('arguments.params.param') ) {
			clearparams();
			for ( i=1 ; i<=listLen(arguments.params.param) ; i++ ) {
				addParam(
							listFirst(arguments.params['paramField#i#'],'^'),
							arguments.params['paramRelationship#i#'],
							arguments.params['paramCriteria#i#'],
							arguments.params['paramCondition#i#'],
							listLast(arguments.params['params.paramField#i#'],'^')
							);
			}
		} else if ( isdefined('arguments.params.paramarray') && isArray(arguments.params.paramarray) ) {
			clearparams();
			for ( i=1 ; i<=arrayLen(arguments.params.paramarray) ; i++ ) {
				addParam(
							listFirst(arguments.params.paramarray[i].field,'^'),
							arguments.params.paramarray[i].relationship,
							arguments.params.paramarray[i].criteria,
							arguments.params.paramarray[i].condition,
							listLast(arguments.params.paramarray[i].field,'^')
							);
			}
		}
		if ( isStruct(arguments.params) ) {
			if ( structKeyExists(arguments.params,"siteid") ) {
				setSiteID(arguments.params.siteid);
			}
		}
		return this;
	}

	function addParam(required string field="", required string relationship="and", required string criteria="", required string condition="EQUALS", required string datatype="") output=false {
		var rows=1;

		if ( structKeyExists(arguments,'column') ) {
			arguments.field=arguments.column;
		}
		if ( structKeyExists(arguments,'name') ) {
			arguments.field=arguments.name;
		}
		if ( structKeyExists(arguments,'value') ) {
			arguments.criteria=arguments.value;
		}

		if(isValid('variablename',arguments.field) && isdefined('set#arguments.field#')){
				setValue(arguments.field,arguments.criteria);
				return this;
		}

		if ( structKeyExists(variables.instance.fieldAliases,arguments.field) ) {
			arguments.datatype=variables.instance.fieldAliases[arguments.field].datatype;
			arguments.field=variables.instance.fieldAliases[arguments.field].field;
		}
		if ( !len(arguments.dataType) ) {
			loadTableMetaData();
			
			if ( !structKeyExists(variables, "dbUtility") ) {
				variables.dbUtility = getEntity().getDbUtility();
			}
			
			var transformField=listToArray(arguments.field,'.');
			
			if(arrayLen(transformField) >= 2 and transformField[2] != '$'){
				var tempEntity=transformField[1];
				var originalTempEntity=tempEntity;

				var tempField=listRest(arrayToList(transformField,'.'));
				var entity=getEntity();

				if(entity.hasTable() && entity.getTable()==tempEntity){
					var tempField=tempField;
					var tempEntity=variables.instance.entityName;
				} else {
					if(entity.hasSynthedFn('get#tempEntity#')){
						tempEntity=entity.getSynthedFn('get#tempEntity#').args.cfc;
					}
					if(getServiceFactory().containsBean(tempEntity)){
						local.related=getServiceFactory().getBean(tempEntity);
						if(isDefined('local.related.getFeed')){
							local.related.getFeed().loadTableMetaData();
							innerJoin(originalTempEntity);
						}
					}
				}
			} else {
				var tempField=listFirst(arguments.field,'.');
				var tempEntity=variables.instance.entityName;
			}
			
			if ( structKeyExists(application.objectMappings,tempEntity) 
				&& structKeyExists(application.objectMappings[tempEntity],'columns')
				&& structKeyExists(application.objectMappings[tempEntity].columns,tempField) ) {
				arguments.dataType=variables.dbUtility.transformParamType(application.objectMappings[tempEntity].columns[tempField].dataType);
			} else {
				arguments.dataType="varchar";
			}
		}
		queryAddRow(variables.instance.params,1);
		rows = variables.instance.params.recordcount;
		querysetcell(variables.instance.params,"param",rows,rows);
		querysetcell(variables.instance.params,"field",formatField(arguments.field),rows);
		querysetcell(variables.instance.params,"relationship",arguments.relationship,rows);
		querysetcell(variables.instance.params,"criteria",arguments.criteria,rows);
		querysetcell(variables.instance.params,"condition",arguments.condition,rows);
		querysetcell(variables.instance.params,"dataType",arguments.datatype,rows);
		return this;
	}

	function addAdvancedParam(required string field="", required string relationship="and", required string criteria="", required string condition="EQUALS", required string datatype="") output=false {
		return addParam(argumentCollection=arguments);
	}

	function getAdvancedParams() {
		return getParams();
	}

	function getParams() {
		return variables.instance.params;
	}

	function clearAdvancedParams() {
		variables.instance.params=queryNew("param,relationship,field,condition,criteria,dataType","integer,varchar,varchar,varchar,varchar,varchar" );
		return this;
	}

	function clearParams() {
		return clearAdvancedParams();
	}

	function addJoin(required string joinType="inner", required string table="", required string clause="",required string loadkey="",tableAlias="") output=false {
		if ( !hasJoin(arguments.table,arguments.tableAlias) ) {
			arrayAppend(variables.instance.joins, arguments);
		}
		return this;
	}

	function getJoins() {
		return variables.instance.joins;
	}

	function clearJoins() {
		variables.instance.joins=arrayNew(1);
		return this;
	}

	//This needs to eventually support table alias
	function hasJoin(table,tableAlias='') {

		if(listLen(arguments.table,' ') gt 1){
			arguments.tableAlias=listLast(arguments.table,' ');
			arguments.table=listFirst(arguments.table,' ');
		}

		var join = "";
		for ( join in getJoins() ) {
			if ( arguments.table == join.table && arguments.tableAlias == join.tableAlias ) {
				return true;
			}
		}
		return false;
	}

	function getDbType() output=false {
		if ( structKeyExists(application.objectMappings,variables.instance.entityName) && structKeyExists(application.objectMappings[variables.instance.entityName],'dbtype') ) {
			return application.objectMappings[variables.instance.entityName].dbtype;
		} else {
			return variables.configBean.getDbType();
		}
	}

	function hasColumn(column) output=false {
		return isDefined("application.objectMappings.#getValue('entityName')#.columns.#arguments.column#");
	}

	function hasDiscriminatorColumn() output=false {
		return isDefined("application.objectMappings.#getValue('entityName')#.discriminatorColumn") && len(application.objectMappings[getValue('entityName')].discriminatorColumn);
	}

	function getIsHistorical() output=false {
		return isDefined("application.objectMappings.#getValue('entityName')#.historical") && IsBoolean(application.objectMappings[getValue('entityName')].historical) && application.objectMappings[getValue('entityName')].historical;
	}

	function getIsVersioned() output=false {
		return isDefined("application.objectMappings.#getValue('entityName')#.versioned") && IsBoolean(application.objectMappings[getValue('entityName')].versioned) && application.objectMappings[getValue('entityName')].versioned;
	}

	function getDiscriminatorColumn() output=false {
		return application.objectMappings[getValue('entityName')].discriminatorColumn;
	}

	function getDiscriminatorValue() output=false {
		return application.objectMappings[getValue('entityName')].discriminatorValue;
	}

	function hasCustomDatasource() output=false {
		return structKeyExists(application.objectMappings,variables.instance.entityName) && structKeyExists(application.objectMappings[variables.instance.entityName],'datasource');
	}

	function getCustomDatasource() output=false {
		return application.objectMappings[variables.instance.entityName].datasource;
	}

	function getQueryAttrs(cachedWithin="#variables.instance.cachedWithin#") output=false {
		arguments.readOnly=true;
		return super.getQueryAttrs(argumentCollection=arguments);
	}

	function getQueryService(cachedWithin="#variables.instance.cachedWithin#") output=false {
		arguments.readOnly=true;
		return super.getQueryService(argumentCollection=arguments);
	}

	function getIterator(cachedWithin="#variables.instance.cachedWithin#",query) output=false {
		if(isDefined('arguments.query')){
			var rs=arguments.query;
		} else {
			var rs=getQuery(argumentCollection=arguments);
		}
		
		var it='';

		//When selecting distinct generic iterators and beans are used
		if(!getDistinct() && !isAggregateQuery()){
			if ( getServiceFactory().containsBean("#variables.instance.entityName#Iterator") ) {
				it=getBean("#variables.instance.entityName#Iterator");
			} else {
				it=getBean("beanIterator");
			}
			it.setEntityName(getValue('entityName'));
		} else {
			it=getBean("beanIterator");
		}

		it.setQuery(rs);
		it.setFeed('feed',this);
		it.setPageIndex(getValue('pageIndex'));
		it.setItemsPerPage(getItemsPerPage());
		return it;
	}

	function getAvailableCount() output=false {
		return getQuery(countOnly=true).count;
	}

	function clone() output=false {
		return getBean("beanFeed").setAllValues(structCopy(getAllValues()));
	}

	function where(property) output=false {
		if ( isDefined('arguments.property') ) {
			andProp(argumentCollection=arguments);
		}
		return this;
	}

	function prop(property) output=false {
		andProp(argumentCollection=arguments);
		return this;
	}

	function andProp(property) output=false {
		variables.instance.pendingParam.relationship='and';
		variables.instance.pendingParam.column=transformFieldName(arguments.property);
		transformDataType(arguments.property);
		return this;
	}

	function orProp(property) output=false {
		variables.instance.pendingParam.relationship='or';
		variables.instance.pendingParam.column=transformFieldName(arguments.property);
		transformDataType(arguments.property);
		return this;
	}

	function isEQ(criteria) output=false {
		variables.instance.pendingParam.condition='eq';
		variables.instance.pendingParam.criteria=arguments.criteria;
		addParam(argumentCollection=variables.instance.pendingParam);
		variables.instance.pendingParam={};
		return this;
	}

	function isNEQ(criteria) output=false {
		variables.instance.pendingParam.condition='neq';
		variables.instance.pendingParam.criteria=arguments.criteria;
		addParam(argumentCollection=variables.instance.pendingParam);
		variables.instance.pendingParam={};
		return this;
	}

	function isGT(criteria) output=false {
		variables.instance.pendingParam.condition='gt';
		variables.instance.pendingParam.criteria=arguments.criteria;
		addParam(argumentCollection=variables.instance.pendingParam);
		variables.instance.pendingParam={};
		return this;
	}

	function isGTE(criteria) output=false {
		variables.instance.pendingParam.condition='gte';
		variables.instance.pendingParam.criteria=arguments.criteria;
		addParam(argumentCollection=variables.instance.pendingParam);
		variables.instance.pendingParam={};
		return this;
	}

	function isLT(criteria) output=false {
		variables.instance.pendingParam.condition='lt';
		variables.instance.pendingParam.criteria=arguments.criteria;
		addParam(argumentCollection=variables.instance.pendingParam);
		variables.instance.pendingParam={};
		return this;
	}

	function isLTE(criteria) output=false {
		variables.instance.pendingParam.condition='lte';
		variables.instance.pendingParam.criteria=arguments.criteria;
		addParam(argumentCollection=variables.instance.pendingParam);
		variables.instance.pendingParam={};
		return this;
	}

	function isIn(criteria) output=false {
		variables.instance.pendingParam.condition='in';
		variables.instance.pendingParam.criteria=arguments.criteria;
		addParam(argumentCollection=variables.instance.pendingParam);
		variables.instance.pendingParam={};
		return this;
	}

	function isNotIn(criteria) output=false {
		variables.instance.pendingParam.condition='notin';
		variables.instance.pendingParam.criteria=arguments.criteria;
		addParam(argumentCollection=variables.instance.pendingParam);
		variables.instance.pendingParam={};
		return this;
	}

	function containsValue(criteria) output=false {
		variables.instance.pendingParam.condition='contains';
		variables.instance.pendingParam.criteria=arguments.criteria;
		addParam(argumentCollection=variables.instance.pendingParam);
		variables.instance.pendingParam={};
		return this;
	}

	function beginsWith(criteria) output=false {
		variables.instance.pendingParam.condition='begins';
		variables.instance.pendingParam.criteria=arguments.criteria;
		addParam(argumentCollection=variables.instance.pendingParam);
		variables.instance.pendingParam={};
		return this;
	}

	function endsWith(criteria) output=false {
		variables.instance.pendingParam.condition='ends';
		variables.instance.pendingParam.criteria=arguments.criteria;
		addParam(argumentCollection=variables.instance.pendingParam);
		variables.instance.pendingParam={};
		return this;
	}

	function null() output=false {
		variables.instance.pendingParam.condition='=';
		variables.instance.pendingParam.criteria='null';
		addParam(argumentCollection=variables.instance.pendingParam);
		variables.instance.pendingParam={};
		return this;
	}

	function openGrouping() output=false {
		addParam(relationship='andOpenGrouping');
		variables.instance.pendingParam={};
		return this;
	}

	function andOpenGrouping() output=false {
		return openGrouping();
	}

	function orOpenGrouping() output=false {
		addParam(relationship='orOpenGrouping');
		variables.instance.pendingParam={};
		return this;
	}

	function closeGrouping() output=false {
		addParam(relationship='closeGrouping');
		variables.instance.pendingParam={};
		return this;
	}

	function sort(property, direction) output=false {
		//  default sort direction ASC for everything *except* mxpRelevance, which should be DESC so the highest point values are first.
	
		if ( !StructKeyExists( arguments, "direction" ) ) {
			if ( arguments.property == "mxpRelevance" ) {
				arguments.direction = "desc";
			} else {
				arguments.direction = "asc";
			}
		}
	
		if(!variables.customSort){
			variables.instance.orderby='';
		}
		
		variables.instance.orderby=listAppend(variables.instance.orderby, transformFieldName(arguments.property) & ' ' & arguments.direction);
		
		variables.customSort=true;
		return this;
	}

	function itemsPerPage(itemsPerPage) output=false {
		setNextN(arguments.itemsPerPage);
		return this;
	}

	function maxItems(maxItems) output=false {
		setMaxItems(arguments.maxItems);
		return this;
	}

	function fields(fields) output=false {
		return setFields(arguments.fields);
	}

	function distinct(distinct=true) output=false {
		return setDistinct(arguments.distinct);
	}

	function getEntity() output=false {
		if ( !isdefined('variables.sampleEntity') ) {
			variables.sampleEntity=getBean(getEntityName());
		}
		return variables.sampleEntity;
	}

	function innerJoin(relatedEntity) output=false {
		var entity=getEntity();
		
		if(entity.hasSynthedFn('get#relatedEntity#')){
			var synthedProps=entity.getSynthedFn('get#relatedEntity#');

			if(!structKeyExists(application.objectMappings[synthedProps.args.cfc],'table')){
				getBean(synthedProps.args.cfc);
			}
			if(synthedProps.args.inverse){
				entity=getBean(synthedProps.args.cfc);
				if(synthedProps.args.loadkey eq 'primaryKey'){
					var translatedLoadKey=entity.getPrimaryKey();
				} else {
					var translatedLoadKey=entity.translatePropKey(synthedProps.args.loadkey);
				}
				var tableAlias=(arguments.relatedEntity==entity.getTable()) ? '' : arguments.relatedEntity;
				addJoin('inner',application.objectMappings[synthedProps.args.cfc].table,'#entity.getTable()#.#translatedLoadKey#=#arguments.relatedEntity#.#entity.translatePropKey(synthedProps.args.fkcolumn)#',translatedLoadKey,tableAlias);
			} else {
				if(synthedProps.args.loadkey eq 'primaryKey'){
					var translatedLoadKey=entity.getPrimaryKey();
				} else {
					var translatedLoadKey=entity.translatePropKey(synthedProps.args.loadkey);
				}
				var tableAlias=(arguments.relatedEntity==entity.getTable()) ? '' : arguments.relatedEntity;
				addJoin('inner',application.objectMappings[synthedProps.args.cfc].table,'#entity.getTable()#.#entity.translatePropKey(synthedProps.args.fkcolumn)#=#arguments.relatedEntity#.#translatedLoadKey#',translatedLoadKey,tableAlias);
			}
		} else {
			var p="";
			for ( p in entity.getHasManyPropArray() ) {
				if ( p.cfc == arguments.relatedEntity || p.name == arguments.relatedEntity ) {
					var translatedLoadKey=entity.translatePropKey(p.loadkey);
					if(!structKeyExists(application.objectMappings[p.cfc],'table')){
						getBean(p.cfc);
					}
					addJoin('inner',application.objectMappings[p.cfc].table,'#entity.getTable()#.#entity.translatePropKey(p.column)#=#application.objectMappings[p.cfc].table#.#translatedLoadKey#',translatedLoadKey,arguments.relatedEntity);
					return this;
				}
			}
			for ( p in entity.getHasOnePropArray() ) {
				if ( p.cfc == arguments.relatedEntity || p.name == arguments.relatedEntity ) {
					var translatedLoadKey=entity.translatePropKey(p.loadkey);
					if(!structKeyExists(application.objectMappings[p.cfc],'table')){
						getBean(p.cfc);
					}
					addJoin('inner',application.objectMappings[p.cfc].table,'#entity.getTable()#.#entity.translatePropKey(p.column)#=#application.objectMappings[p.cfc].table#.#translatedLoadKey#',translatedLoadKey,arguments.relatedEntity);
					return this;
				}
			}
		}
		return this;
	}

	function leftJoin(entityName) output=false {
		var entity=getEntity();
		if(entity.hasSynthedFn('get#relatedEntity#')){
			var synthedProps=entity.getSynthedFn('get#relatedEntity#');
			if(!structKeyExists(application.objectMappings[synthedProps.args.cfc],'table')){
				getBean(synthedProps.args.cfc);
			}
			if(synthedProps.args.inverse){
				entity=getBean(synthedProps.args.cfc);
				if(synthedProps.args.loadkey eq 'primaryKey'){
					var translatedLoadKey=entity.getPrimaryKey();
				} else {
					var translatedLoadKey=entity.translatePropKey(synthedProps.args.loadkey);
				}
				var tableAlias=(arguments.relatedEntity==entity.getTable()) ? '' : arguments.relatedEntity;
				addJoin('left',application.objectMappings[synthedProps.args.cfc].table,'#entity.getTable()#.#translatedLoadKey#=#arguments.relatedEntity#.#entity.translatePropKey(synthedProps.args.fkcolumn)#',translatedLoadKey,tableAlias);
			} else {
				if(synthedProps.args.loadkey eq 'primaryKey'){
					var translatedLoadKey=entity.getPrimaryKey();
				} else {
					var translatedLoadKey=entity.translatePropKey(synthedProps.args.loadkey);
				}
				var tableAlias=(arguments.relatedEntity==entity.getTable()) ? '' : arguments.relatedEntity;
				addJoin('left',application.objectMappings[synthedProps.args.cfc].table,'#entity.getTable()#.#entity.translatePropKey(synthedProps.args.fkcolumn)#=#arguments.relatedEntity#.#translatedLoadKey#',translatedLoadKey,tableAlias);
			}
		} else {
			var p="";
			for ( p in entity.getHasManyPropArray() ) {
				if ( p.cfc == arguments.relatedEntity || p.name == arguments.relatedEntity ) {
					var translatedLoadKey=entity.translatePropKey(p.loadkey);
					if(!structKeyExists(application.objectMappings[p.cfc],'table')){
						getBean(p.cfc);
					}
					addJoin('left',application.objectMappings[p.cfc].table,'#entity.getTable()#.#entity.getValue(entity.translatePropKey(p.column))#=#arguments.relatedEntity#.#translatedLoadKey#',translatedLoadKey,arguments.relatedEntity);
					return this;
				}
			}
			for ( p in entity.getHasOnePropArray() ) {
				if ( p.cfc == arguments.relatedEntity || p.name == arguments.relatedEntity ) {
					var translatedLoadKey=entity.translatePropKey(p.loadkey);
					if(!structKeyExists(application.objectMappings[p.cfc],'table')){
						getBean(p.cfc);
					}
					addJoin('left',application.objectMappings[p.cfc].table,'#entity.getTable()#.#entity.getValue(entity.translatePropKey(p.column))#=#arguments.relatedEntity#.#translatedLoadKey#',translatedLoadKey,arguments.relatedEntity);
					return this;
				}
			}
		}
		return this;
	}
 
	function groupBy(property) output=false {
		if(len(trim(arguments.property))){
			for(var p in listToArray(arguments.property)){
				arrayAppend(variables.instance.groupByArray,transformFieldName(p));
			}
		}
		return this;
	}

	function aggregate(type,property) output=false {
		if(len(trim(arguments.property))){
			switch(arguments.type){
				case 'sum':
				for(var p in listToArray(arguments.property)){
					arrayAppend(variables.instance.sumValArray,transformFieldName(p));
				}
				break;
				case 'count':
				for(var p in listToArray(arguments.property)){
					arrayAppend(variables.instance.countValArray,transformFieldName(p));
				}
				break;
				case 'avg':
				for(var p in listToArray(arguments.property)){
					arrayAppend(variables.instance.avgValArray,transformFieldName(p));
				}
				break;
				case 'min':
				for(var p in listToArray(arguments.property)){
					arrayAppend(variables.instance.minValArray,transformFieldName(p));
				}
				break;
				case 'max':
				for(var p in listToArray(arguments.property)){
					arrayAppend(variables.instance.maxValArray,transformFieldName(p));
				}
				break;
				case 'groupby':
				for(var p in listToArray(arguments.property)){
					arrayAppend(variables.instance.groupByArray,transformFieldName(p));
				}
				break;
			}
		}
		return this;
	}

	function transformFields(fields){
		return fields;
	}

	function transformDataType(property){
		var transformField=listToArray(arguments.property);
		if(arrayLen(transformField) >= 2 && transformField[2] != '$'){
			var field=transformField[2];
			var entityName=transformField[1];
			if(getServiceFactory().containsBean(entityName)){
				local.related=getBean(entityName);
				if(isDefined('local.related.getFeed')){
					local.related.getFeed().loadTableMetaData();
					if ( structKeyExists(application.objectMappings,entityName) 
						&& structKeyExists(application.objectMappings[entityName],'columns')
						&& structKeyExists(application.objectMappings[entityName].columns,field) ) {
						if ( !structKeyExists(variables, "dbUtility") ) {
							variables.dbUtility = getEntity().getDbUtility();
						}
						variables.instance.pendingParam.dataType=variables.dbUtility.transformParamType(application.objectMappings[entityName].columns[field].dataType);
					}
				}				
			}
		}
	}

	function transformFieldName(fieldname){
		arguments.fieldname=trim(arguments.fieldname);
		
		if(arguments.fieldname==application.objectMappings[getEntityName()].table & ".*"){
			return arguments.fieldname;
		}

		var transformField=listToArray(arguments.fieldname,'.');

		if ( arrayLen(transformField) >= 2 && transformField[2] != "$") {
			if(structKeyExists(application.objectMappings,transformField[1])){
				if(!structKeyExists(application.objectMappings[transformField[1]],'table')){
					getBean(transformField[1]);
				}
				arguments.fieldname=application.objectMappings[transformField[1]].table & '.' & transformField[2];
			}

		//List first in case it has $ json operator
		} else if(structKeyExists(application.objectMappings[getEntityName()],transformField[1])){
			if(!structKeyExists(application.objectMappings[getEntityName()],'table')){
				getBean(getEntityName());
			}
			arguments.fieldname=application.objectMappings[getEntityName()].table & '.' & transformField[1]
		}
		
		if(find('$',arguments.fieldname)){
			var column=listFirst(arguments.fieldname,'$');
			column=left(column,len(column)-1);
			switch (application.configBean.getDbType()){
				case "mssql":
				case "oracle":
					return "json_value(#column#,'$#listRest(arguments.fieldname,"$")#') as #replace(column,".","_")#";
				case "mysql":
					return "json_unquote(json_extract(#column#,'$#listRest(arguments.fieldname,"$")#')) as #replace(column,".","_")#";
				case "postgresql":
					return "#column#::json->>'#listRest(arguments.fieldname,"$")#' as #replace(column,".","_")#"
			}
		}

		return arguments.fieldname;

	}


	function isAggregateQuery(){
		if(isDefined('url.fields') && len(url.fields)){
			return false;
		}
		for(var i in ['minValArray','maxValArray','avgValArray','sumValArray','countValArray','groupByArray']){
			if(arrayLen(variables.instance[i])){
				return true;
			}
		}

		return false;
	}

	private function caseInsensitiveOrderBy(required orderBy) output=false {
		var orderByList = "";
		var orderByValue = "";
		var table = "";
		var column = "";
		var sortcolumn = "";
		var refcolumn = "";

		for(orderByValue in listToArray(arguments.orderby)){
			table = getEntity().getTable();
			column = listfirst(orderByValue, " ");
			
			var columnArray=listToArray(column,'.');
			
			if ( arrayLen(columnArray) >= 2 && columnArray[2] != "$" ) {
				table = listfirst(column, ".");
				sortcolumn = listrest(column, ".");
				refcolumn=listFirst(sortcolumn, ".");
			} else {
				sortcolumn = column;
				refcolumn = listFirst(column,'.');
			}
			
			if ( len(refcolumn) && find('$',sortcolumn)) {
				var dbtype=getDbType();
				if(dbtype=='mysql'){
					//Not using  ->> for mariadb support
					orderByList = listappend(orderByList, "json_unquote(json_extract(#table#.#replace(sortcolumn,".$",",'$")#')) " & listrest(orderByValue, " "));
				} else if(listFindNoCase('oracle,mssql',dbtype)){
					orderByList = listappend(orderByList, "json_value(#table#.#replace(sortcolumn,".$",",'$")#') " & listrest(orderByValue, " "));
				} else if (dbtype=='postgresql'){
					orderByList = listappend(orderByList, "#table#.#replace(sortcolumn,".$",",'::json->>'")#' " & listrest(orderByValue, " "));
				}
				
			} else if ( len(refcolumn) && structkeyexists(application.objectMappings, table) && structkeyexists(application.objectMappings[table]["columns"], refcolumn) && listfindnocase("char,varchar", application.objectMappings[table]["columns"][refcolumn]["dataType"]) ) {
				orderByList = listappend(orderByList, "lower(" & column & ") " & listrest(orderByValue, " "));
			} else {
				orderByList = listappend(orderByList, orderByValue);
			}
		}
	
		return orderByList;
	}

	function sanitizedValue(value) output=false {
		return REReplace(value,"[^0-9A-Za-z\._,\- ]\*","","all");
	}

	function getOffset() output=false {
		return (getValue('pageIndex')-1) * getValue('nextN');
	}

	function getFetch() output=false {
		return getValue('nextN');
	}

	function getStartRow() output=false {
		return getOffset() +1;
	}

	function getEndRow() output=false {
		var endrow=getOffset()+getValue('nextN');
		if ( endrow > getValue('maxItems') ) {
			endrow=getValue('maxItems');
		}
		return endrow;
	}
	</cfscript>

	<cffunction name="getQuery" output="false">
		<cfargument name="countOnly" default="false">
		<cfargument name="cachedWithin" default="#variables.instance.cachedWithin#">

		<cfset var rs="">
		<cfset var isListParam=false>
		<cfset var param="">
		<cfset var started=false>
		<cfset var openGrouping=false>
		<cfset var jointable="">
		<cfset var jointables="">
		<cfset var dbType=getDbType()>
		<cfset var tableModifier="">
		<cfset var transformCriteria="">
		<cfset var tracePoint=initTracePoint(detail="Loading #getEntityName()# query")>

		<cfif getIsVersioned()>
			<cfset var hasContenthistidAsParam=false>
		</cfif>

		<cfif getDbType() eq "MSSQL">
			<cfset tableModifier="with (nolock)">
		</cfif>

		<cfif hasDiscriminatorColumn()>
			<cfset addParam(column=hasDiscriminatorColumn(),criteria=hasDiscriminatorValue())>
		</cfif>

		<cfloop query="variables.instance.params">
			<cfif listLen(variables.instance.params.field,".") eq 2 and not find('$',variables.instance.params.field)>
				<cfset jointable=REReplace(listFirst(variables.instance.params.field,"."),"[^0-9A-Za-z\._,\- ]","","all") >
				<cfset var originalJoinTable=jointable>
				<cfif getServiceFactory().containsBean(jointable)>
					<cfset jointable=originalJoinTable & ' ' & getBean(jointable).getTable()>
				</cfif>
				<cfif len(originalJoinTable) and originalJoinTable neq variables.instance.table and not listFind(jointables,jointable)>
					<cfset jointables=listAppend(jointables,jointable)>
				</cfif>
			</cfif>
		</cfloop>

		<cfquery attributeCollection="#getQueryAttrs(name='rs',cachedWithin=arguments.cachedWithin)#">
			<cfif not arguments.countOnly and dbType eq "oracle" and variables.instance.maxItems>select * from (</cfif>
			select
			<cfif getDistinct()>distinct</cfif>
			<cfif not arguments.countOnly and dbtype eq "mssql" and variables.instance.maxItems>top #val(variables.instance.maxItems)#</cfif>

			<cfif not arguments.countOnly>
				<cfif len(getFields())>
					#sanitizedValue(transformFields(getFields()),"[^0-9A-Za-z$\(\)>'\._,\- ]","","all")#
					from #variables.instance.table# #tableModifier#
				<cfelseif isAggregateQuery()>
					<cfset started=false>
					<cfif arrayLen(variables.instance.groupByArray)>
						<cfloop array="#variables.instance.groupByArray#" index="local.i">
							<cfif started>, <cfelse><cfset started=true></cfif>
							#sanitizedValue(local.i)#
						</cfloop>
					</cfif>
					<cfif arrayLen(variables.instance.sumValArray)>
						<cfloop array="#variables.instance.sumValArray#" index="local.i">
							<cfif started>, <cfelse><cfset started=true></cfif>
							sum(#sanitizedValue(local.i)#) as sum_#sanitizedValue(listLast(local.i,'.'))#
						</cfloop>
					</cfif>
					<cfif arrayLen(variables.instance.countValArray)>
						<cfloop array="#variables.instance.countValArray#" index="local.i">
							<cfif started>, <cfelse><cfset started=true></cfif>
							<cfif listLast(local.i,'.') eq '*'>count(*) as count<cfelse>count(#sanitizedValue(local.i)#) as count_#sanitizedValue(listLast(local.i,'.'))#</cfif>
						</cfloop>
					</cfif>
					<cfif arrayLen(variables.instance.avgValArray)>
						<cfloop array="#variables.instance.avgValArray#" index="local.i">
							<cfif started>, <cfelse><cfset started=true></cfif>
							avg(#sanitizedValue(local.i)#) as avg_#sanitizedValue(listLast(local.i,'.'))#
						</cfloop>
					</cfif>
					<cfif arrayLen(variables.instance.minValArray)>
						<cfloop array="#variables.instance.minValArray#" index="local.i">
							<cfif started>, <cfelse><cfset started=true></cfif>
							min(#sanitizedValue(local.i)#) as min_#sanitizedValue(listLast(local.i,'.'))#
						</cfloop>
					</cfif>
					<cfif arrayLen(variables.instance.maxValArray)>
						<cfloop array="#variables.instance.maxValArray#" index="local.i">
							<cfif started>, <cfelse><cfset started=true></cfif>
							max(#sanitizedValue(local.i)#) as max_#sanitizedValue(listLast(local.i,'.'))#
						</cfloop>
					</cfif>
					<cfset started=false>
					from #variables.instance.table# #tableModifier#
				<cfelseif len(getEntity().getLoadSQLColumnsAndTables())>
					<cfset loadTableMetaData()>
					#getEntity().getLoadSQLColumnsAndTables()#
				<cfelse>
					#getTableFieldList()#
					from #variables.instance.table# #tableModifier#
				</cfif>

			<cfelse>
				count(*) as count from #variables.instance.table# #tableModifier#
			</cfif>

			<cfif getIsHistorical()>
				<cfset var primaryKey=getEntity().getPrimaryKey()>

				inner join (
					select #primaryKey# primarykey, max(lastupdate) lastupdatemax from #variables.instance.table# #tableModifier#
					where
					lastupdate <= <cfif isDate(request.muraPointInTime)>
									<cfqueryparam cfsqltype="cf_sql_timestamp" value="#request.muraPointInTime#">
								<cfelse>
									<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
								</cfif>
					group by #primaryKey#

				) activeTable
				on (
					#variables.instance.table#.#primaryKey#=activeTable.primarykey
					and #variables.instance.table#.lastupdate=activeTable.lastupdatemax
				)
			</cfif>

			<cfif getIsVersioned()>
				left join tcontent #tableModifier# on (
					#variables.instance.table#.contenthistid=tcontent.contenthistid
				)
			</cfif>

			<!--- Join to implied tables based on field prefix --->

			<cfloop list="#jointables#" index="jointable">
				<cfif not hasJoin(jointable) and len(variables.instance.keyField)>
					inner join #jointable# #tableModifier# on (#variables.instance.table#.#variables.instance.keyField#=#jointable#.#variables.instance.keyField#)
				</cfif>
			</cfloop>

			<!--- Join to explicit tables based on join clauses --->
			<cfloop from="1" to="#arrayLen(variables.instance.joins)#" index="local.i">
				<cfif len(variables.instance.joins[local.i].clause) and not (listFindNoCase(jointables,variables.instance.joins[local.i].table) and len(variables.instance.keyField))>
					#variables.instance.joins[local.i].jointype# 
						join #variables.instance.joins[local.i].table# <cfif len(variables.instance.joins[local.i].tableAlias)>#variables.instance.joins[local.i].tableAlias#</cfif> #tableModifier# on (
						#variables.instance.joins[local.i].clause#
						<cfif variables.instance.joins[local.i].table eq 'tcontent' and variables.instance.joins[local.i].loadkey neq 'contenthistid'>
							and <cfif len(variables.instance.joins[local.i].tableAlias)>#variables.instance.joins[local.i].tableAlias#.active=1<cfelse>tcontent.active=1</cfif>
						</cfif>
					)
				</cfif>
			</cfloop>

			where

			<cfif
				(not isDefined('application.objectMappings.#getValue('entityName')#.columns') and len(variables.instance.siteID))
				or
				(hasColumn('siteid') and len(variables.instance.siteID))>
				#variables.instance.table#.siteID in (<cfqueryparam cfsqltype="cf_sql_varchar" list=true value="#getContentPoolID()#"/>)
			<cfelse>
				1=1
			</cfif>

			<cfif variables.instance.params.recordcount>
			<cfset started = false>
			<cfloop query="variables.instance.params">
				<cfset param=new mura.queryParam(variables.instance.params.relationship,
						variables.instance.params.field,
						variables.instance.params.dataType,
						variables.instance.params.condition,
						variables.instance.params.criteria
					) />

				<cfif param.getIsValid()>
					<cfset transformCriteria=listToArray(param.getCriteria(),'.')>
					
					<cfif not started >
						<cfset openGrouping=true />
						and (
					</cfif>
					<cfif listFindNoCase("openGrouping,(",param.getRelationship())>
						<cfif not openGrouping>and</cfif> (
						<cfset openGrouping=true />
					<cfelseif listFindNoCase("orOpenGrouping,or (",param.getRelationship())>
						<cfif not openGrouping>or</cfif> (
						<cfset openGrouping=true />
					<cfelseif listFindNoCase("andOpenGrouping,and (",param.getRelationship())>
						<cfif not openGrouping>and</cfif> (
						<cfset openGrouping=true />
					<cfelseif listFindNoCase("and not (",param.getRelationship())>
						<cfif not openGrouping>and</cfif> not (
						<cfset openGrouping=true />
					<cfelseif listFindNoCase("or not (",param.getRelationship())>
						<cfif not openGrouping>or</cfif> not (
						<cfset openGrouping=true />
					<cfelseif listFindNoCase("closeGrouping,)",param.getRelationship())>
						)
						<cfset openGrouping=false>
					<cfelseif not openGrouping>
						#param.getRelationship()#
					</cfif>

					<cfset started = true />
					<cfset isListParam=listFindNoCase("IN,NOT IN,NOTIN",param.getCondition())>
				
					<cfif len(param.getField())>
						<cfif getEntity().getCategorizable() && param.getField() eq 'categoryid' and not getEntity().hasProperty('categoryid')>
							#getEntity().get('primaryKey')# in (
								select entityid from tentitycategoryassign #tableModifier#
								where categoryid #param.getCondition()#
								<cfif isListParam>(</cfif><cfqueryparam cfsqltype="cf_sql_#param.getDataType()#" value="#param.getCriteria()#" list="#iif(isListParam,de('true'),de('false'))#" null="#iif(param.getCriteria() eq 'null',de('true'),de('false'))#"><cfif isListParam>)</cfif>
								and entitytype=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getEntity().getEntityName()#">
							)
						<cfelseif getEntity().getCategorizable() && param.getField() eq 'category' and not getEntity().hasProperty('category')>
								#getEntity().get('primaryKey')# in (
								select entityid from tentitycategoryassign #tableModifier#
								inner join tcontentcategories on (tentitycategoryassign.categoryid = tcontentcategories.categoryid)
								where tcontentcategories.name #param.getCondition()#
								<cfif isListParam>(</cfif><cfqueryparam cfsqltype="cf_sql_#param.getDataType()#" value="#param.getCriteria()#" list="#iif(isListParam,de('true'),de('false'))#" null="#iif(param.getCriteria() eq 'null',de('true'),de('false'))#"><cfif isListParam>)</cfif>
								and entitytype=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getEntity().getEntityName()#">
							)
						<cfelseif getEntity().getTaggable() && param.getField() eq 'tag' and not getEntity().hasProperty('tags')>
							#getEntity().get('primaryKey')# in (
								select entityid from tentitytagassign #tableModifier#
								tag #param.getCondition()#
								<cfif isListParam>(</cfif><cfqueryparam cfsqltype="cf_sql_#param.getDataType()#" value="#param.getCriteria()#" list="#iif(isListParam,de('true'),de('false'))#" null="#iif(param.getCriteria() eq 'null',de('true'),de('false'))#"><cfif isListParam>)</cfif>
								and entitytype=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getEntity().getEntityName()#">
						<cfelseif getEntity().getTaggable() && param.getField() eq 'taggroup' and not getEntity().hasProperty('taggroup')>
							<!--- Do Nothing --->
						<cfelse>
							<cfif getIsVersioned() and transformCriteria[arrayLen(transformCriteria)] eq 'contenthistid'>
								<cfset hasContenthistidAsParam=true>
							</cfif>
							#param.getFieldStatement()#
							<!---TO DO: Make conditional subquery for params prefixed entities that have a table not in a join.--->
							<cfif param.getCriteria() eq 'null'>
								#param.getCondition()# NULL
							<cfelse>
								#param.getCondition()#

								<!---
									Support to recognize if the param criteria is prefix with a table or entityname
									Vague CF10 support
								--->
								
								<cfif arrayLen(transformCriteria) gte 2 and transformCriteria[2] neq '$'>
									<!--- Check if it's an entity make sure schema data is loaded --->
								
									<cfif getServiceFactory().containsBean('#transformCriteria[1]#')>
										<cfset local.related=getBean('#transformCriteria[1]#')>
										<cfif isDefined('local.related.getFeed')>
											<cfset local.related.getFeed().loadTableMetaData()>
										</cfif>
									</cfif>
									<!--- Is it the name of an entity --->
									<cfif structKeyExists(application.objectMappings,'#transformCriteria[1]#') and structKeyExists(application.objectMappings['#transformCriteria[1]#'].columns,'#transformCriteria[2]#')>
										#application.objectMappings['#transformCriteria[1]#'].table#.#sanitizedValue(transformCriteria[2])#
									<cfelse>
										<!--- Is it the name of table that has been joined --->
										<cfif application.objectMappings[ getEntityName()].table eq transformCriteria[1] or hasJoin(transformCriteria[1])>
											#transformCriteria[1]#.#sanitizedValue(transformCriteria[2])#
										<cfelse>
											<cfif isListParam>(</cfif><cfqueryparam cfsqltype="cf_sql_#param.getDataType()#" value="#param.getCriteria()#" list="#iif(isListParam,de('true'),de('false'))#" null="#iif(param.getCriteria() eq 'null',de('true'),de('false'))#"><cfif isListParam>)</cfif>
										</cfif>
									</cfif>
								<cfelse>
									<cfif isListParam>(</cfif><cfqueryparam cfsqltype="cf_sql_#param.getDataType()#" value="#param.getCriteria()#" list="#iif(isListParam,de('true'),de('false'))#" null="#iif(param.getCriteria() eq 'null',de('true'),de('false'))#"><cfif isListParam>)</cfif>
								</cfif>
							</cfif>
							<cfset openGrouping=false>
						</cfif>
					</cfif>
				</cfif>
			</cfloop>
			<cfif started>)</cfif>
		</cfif>

		<cfif getIsHistorical()>
			and #variables.instance.table#.deleted=0
		</cfif>

		<cfif getIsVersioned() and not hasContenthistidAsParam>
			#getBean('contentGateway').renderActiveClause('tcontent',get('siteid'))#
		</cfif>

		<cfset started=false>
		<cfif arrayLen(variables.instance.groupByArray)>
			group by
			<cfloop array="#variables.instance.groupByArray#" index="local.i">
				<cfif started>, <cfelse><cfset started=true></cfif>
				#sanitizedValue(local.i)#
			</cfloop>
		</cfif>
		<cfset started=false>

		<cfif not arguments.countOnly>
			<cfif len(variables.instance.orderby)>
				order by #caseInsensitiveOrderBy(REReplace(variables.instance.orderby,"[^0-9A-Za-z\(\)$\._,\-%//""'' ]","","all"))#
				<cfif listFindNoCase("oracle,postgresql", dbType)>
					<cfif lcase(listLast(variables.instance.orderby, " ")) eq "asc">
						NULLS FIRST
					<cfelse>
						NULLS LAST
					</cfif>
				</cfif>
			<cfelseif len(variables.instance.sortBy)>
				order by #caseInsensitiveOrderBy(REReplace("#variables.instance.table#.#variables.instance.sortby# #variables.instance.sortDirection#","[^0-9A-Za-z$\(\)\._,\- ]","","all"))#
				<cfif listFindNoCase("oracle,postgresql", dbType)>
					<cfif variables.instance.sortDirection eq "asc">
						NULLS FIRST
					<cfelse>
						NULLS LAST
					</cfif>
				</cfif>
			</cfif>

			<cfif listFindNoCase("mysql,postgresql", dbType) and variables.instance.maxItems>limit <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.instance.maxItems#" /> </cfif>
			<cfif dbType eq "nuodb" and variables.instance.maxItems>fetch <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.instance.maxItems#" /></cfif>
			<cfif dbType eq "oracle" and variables.instance.maxItems>) where ROWNUM <= <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.instance.maxItems#" /> </cfif>
		</cfif>

		</cfquery>
		<cfset commitTracePoint(tracePoint)>
		<cfreturn rs>
	</cffunction>

</cfcomponent>
