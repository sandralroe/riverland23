/* license goes here */
component extends="mura.bean.beanORM" historical=true bundleable=true hint="This provide a historical record of an entities versions"{
	property name="histid" fieldtype="id" historical=true;
	property name="created" fieldtype="index" datatype="datetime";
	property name="lastupdate" fieldtype="index" datatype="datetime";
	property name="deleted" fieldtype="index" datatype="tinyint" default=0;

	function getVersionHistoryQuery(){
		var qs=getQueryService();
		qs.addParam(name="primarykey",cfsqltype='cf_sql_varchar',value=get(get('primaryKey')));
		return qs.execute(sql='select * from #getTable()# where #get('primaryKey')# = :primarykey order by lastupdate desc').getResult();
	}

	function getVersionHistoryIterator(){
		return getIterator().setQuery(getVersionHistoryQuery());
	}
}
