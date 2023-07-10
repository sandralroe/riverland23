/* license goes here */
/**
 * This provides user iterating functionality
 */
component extends="mura.iterator.queryIterator" output="false" hint="This provides user iterating functionality" {
	variables.userBean ="";
	variables.entityName ="user";
	variables.recordIDField="userID";

	public function getEntityName() output=false {
		return variables.entityName;
	}

	public function setEntityName(entityName) output=false {
		variables.entityName=arguments.entityName;
		return this;
	}

	public function packageRecord() output=false {
		if ( !isObject(variables.userBean) ) {
			variables.userBean=getBean("user");
			variables.userStructTemplate= structCopy(variables.userBean.getAllValues(autocomplete=false));
		} else {
			variables.userBean.setAllValues( structCopy(variables.userStructTemplate) );
		}
		variables.userBean.set(queryRowToStruct(variables.records,currentIndex())).setIsNew(0);
		getBean("userManager").setUserBeanMetaData(variables.userBean);
		variables.userBean.setValue('sourceIterator',this);
		return variables.userBean;
	}

	public function buildQueryFromList(idList, siteid) output=false {
		var i="";
		var idArray=listToArray(arguments.idList);
		variables.records=queryNew("userID,siteID","VARCHAR,VARCHAR");
		for ( i=1 ; i<=arrayLen(arguments.idArray) ; i++ ) {
			QueryAddRow(variables.records);
			QuerySetCell(variables.records,"userID", idArray[i]);
			QuerySetCell(variables.records, 'siteID',arguments.siteid);
		}
		variables._recordcount=variables.records.recordcount;
		variables.maxRecordsPerPage=variables.records.recordcount;
		variables.recordIndex = 0;
		variables.pageIndex = 1;
		return this;
	}

}
