/* license goes here */
component extends="mura.bean.beanORM" versioned=true bundleable=true hint="This provides the ability to have entities that are versioned in sync with a tree level content node"{
	property name="activeContent" fieldtype="many-to-one" cfc="content" fkcolumn="contentid";
	property name="content" fieldtype="many-to-one" cfc="content" fkcolumn="contenthistid" comparable=false;
	property name="site" fieldtype="one-to-one" cfc="site" fkcolumn="siteID";

	private function addObject(obj){
		var args={
			'#getPrimaryKey()#'=getValue("#getPrimaryKey()#")
		};
		invoke(arguments.obj,'set#getPrimaryKey()#',args);
		arguments.obj.setValue('contenthistid',getValue('contenthistid'));
		arguments.obj.setValue('contentid',getValue('contentid'));
		arguments.obj.setValue('siteid',getValue('siteid'));

		arrayAppend(variables.instance.addObjects,arguments.obj);
		return this;
	}

	function persistToVersion(previousBean,newBean,$){
		return true;
	}

	function toBundle(bundle,siteid,includeVersionHistory=false,contenthistid){
		var qs=getQueryService();

		if(isDefined("arguments.contenthistid")){
			qs.setSQL("select * from #getTable()# where contenthistid in ( :contenthistid ) ");

			qs.addParam(name="contenthistid",list=true,cfsqltype="cf_sql_varchar",value=arguments.contenthistid);

		} else {
			if(arguments.includeVersionHistory){
				qs.setSQL("select * from #getTable()# where siteid = :siteid");
			} else {
				qs.setSQL("select * from #getTable()# where siteid = :siteid and contenthistid in (select contenthistid from tcontent where active=1 and siteid = :siteid) ");
			}
		}

		qs.addParam(name="siteid",cfsqltype="cf_sql_varchar",value=arguments.siteid);

		arguments.bundle.setValue("rs" & getTable(),qs.execute().getResult());

		return this;
	}


}
