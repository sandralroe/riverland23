/* license goes here */
/**
 * This provides base iterating functionality to all entities
 */
component extends="mura.iterator.queryIterator" output="false" hint="This provides base iterating functionality to all entities" {
	variables.entityName="bean";

	public function init() output=false {
		super.init();
		return this;
	}

	public function setEntityName(entityName) output=false {
		if ( len(arguments.entityName) ) {
			variables.entityName=arguments.entityName;
		}
		return this;
	}

	public function getEntityName() output=false {
		return variables.entityName;
	}

	public function packageRecord(recordIndex="#currentIndex()#") output=false {
		var bean="";
		if ( isQuery(variables.records) ) {
			return getBean(variables.entityName).set(queryRowToStruct(variables.records,arguments.recordIndex)).setIsNew(0);
		} else if ( isArray(variables.records) ) {
			bean=variables.records[arguments.recordIndex];
			if ( isObject(bean) ) {
				return bean;
			} else {
				return getBean(variables.entityName).set(bean);
			}
		} else {
			throw( message="The records have not been set." );
		}
	}

	public function getBeanArray() output=false {
		var array=arrayNew(1);
		var record = "";
		if ( isArray(variables.records) ) {
			for ( record in variables.records ) {
				arrayAppend(array,packageRecord(record));
			}
			return array;
		} else if ( isQuery(variables.records) ) {

			if(variables.records.recordcount){
				for(var i=1;i<=variables.records.recordcount;i++){
					arrayAppend(array,packageRecord(i));
				}
			}

			return array;
		} else {
			throw( message="The records have not been set." );
		}
	}

}
