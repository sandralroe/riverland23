/* license goes here */
/**
 * This provides content iterating functionality
 */
component extends="mura.iterator.queryIterator" output="false" hint="This provides content iterating functionality" {
	variables.content="";
	variables.recordIDField="contenthistid";

	public function getEntityName() output=false {
		return "content";
	}

	public function init() output=false {
		super.init(argumentCollection=arguments);
		variables.content=getBean("contentNavBean");
		return this;
	}

	public function packageRecord() output=false {
		var item="";
		if ( isQuery(variables.records) ) {
			item=queryRowToStruct(variables.records,currentIndex());
		} else if ( isArray(variables.records) ) {
			item=variables.records[currentIndex()];
		} else {
			throw( message="The records have not been set." );
		}
		if(isObject(item)){
			variables.content=item;
		} else {
			variables.content=getBean("contentNavBean").set(item,this);
		}
		
		return variables.content;
	}

	public function getRecordIdField() output=false {
		if ( isArray(variables.records) ) {
			if ( arrayLen(variables.records) && structKeyExists(variables.records[1],'contenthistid') ) {
				return "contenthistid";
			} else {
				return "contentid";
			}
		} else {
			if ( isdefined("variables.records.contenthistid") ) {
				return "contenthistid";
			} else {
				return "contentid";
			}
		}
	}

	public function buildQueryFromList(idList, siteid, required idType="contentID") output=false {
		var i="";
		var idArray=listToArray(arguments.idList);
		variables.records=queryNew("#arguments.idType#,siteID","VARCHAR,VARCHAR");
		for ( i=1 ; i<=arrayLen(idArray) ; i++ ) {
			QueryAddRow(variables.records);
			QuerySetCell(variables.records, arguments.idType, idArray[i]);
			QuerySetCell(variables.records, 'siteID',arguments.siteid);
		}
		variables._recordcount=variables.records.recordcount;
		variables.maxRecordsPerPage=variables.records.recordcount;
		variables.recordIndex = 0;
		variables.pageIndex = 1;
		return this;
	}

}
