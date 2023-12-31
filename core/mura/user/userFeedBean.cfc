/* license goes here */
/**
 * This provides user feed functionality
 */
component extends="mura.bean.beanFeed" entityName="user" output="false" hint="This provides user feed functionality" {
	property name="inActive" type="numeric" default="0" required="true";
	property name="isPublic" type="numeric" default="1" required="true";
	property name="groupID" type="string" default="" required="true";
	property name="type" type="numeric" default="2" required="true";
	property name="categoryID" type="string" default="" required="true";
	property name="siteID" type="string" default="" required="true";
	property name="sortBy" type="string" default="lname" required="true";
	property name="sortDirection" type="string" default="asc" required="true";
	property name="bean" type="string" default="user" required="true";
	variables.entityName="user";

	public function init() output=false {
		super.init(argumentCollection=arguments);
		variables.instance.inactive="";
		variables.instance.isPublic=1;
		variables.instance.groupID="";
		variables.instance.type=2;
		variables.instance.categoryID="";
		variables.instance.siteID="";
		variables.instance.sortBy="lname";
		variables.instance.sortDirection="asc";
		variables.instance.table="tusers";
		variables.instance.entityName="user";
		variables.instance.fieldAliases={'tag'={field='tuserstags.tag',datatype='varchar'}};
		variables.instance.cachedWithin=createTimeSpan(0,0,0,0);
		variables.instance.params=queryNew("param,relationship,field,condition,criteria,dataType","integer,varchar,varchar,varchar,varchar,varchar" );
		return this;
	}

	public function setParams(required any params) output=false {
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
						listLast(arguments.params['paramField#i#'],'^')
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
			if ( structKeyExists(arguments.params,"inactive") ) {
				setInActive(arguments.params.inactive);
			}
			if ( structKeyExists(arguments.params,"ispublic") ) {
				setIsPublic(arguments.params.ispublic);
			}
			if ( structKeyExists(arguments.params,"type") ) {
				setType(arguments.params.type);
			}
			if ( structKeyExists(arguments.params,"siteid") ) {
				setValue('siteid',arguments.params.siteid);
			}
			if ( structKeyExists(arguments.params,"categoryID") ) {
				setCategoryID(arguments.params.categoryID);
			}
			if ( structKeyExists(arguments.params,"groupID") ) {
				setGroupID(arguments.params.groupID);
			}
		}
		return this;
	}

	public function getQuery(required cachedWithin="#variables.instance.cachedWithin#") output=false {
		variables.instance.cachedWithin=arguments.cachedWithin;
		if ( !len(variables.instance.siteID) ) {
			throw( message="The 'SITEID' value must be set in order to search users." );
		}
		return getBean('userManager').getAdvancedSearchQuery(userFeedBean=this);
	}

	public function getIterator(required cachedWithin="#variables.instance.cachedWithin#") output=false {
		var rs=getQuery(argumentCollection=arguments);
		//When selecting distinct generic iterators and beans are used
		if(!getDistinct() && !isAggregateQuery()){
			it=getBean("userIterator");
		} else {
			it=getBean("beanIterator");
		}

		if(variables.instance.type==1){
			it.setEntityName('group');
		}

		it.setQuery(rs,variables.instance.nextN);
		return it;
	}

	public function setInActive(inactive) output=false {
		if ( isNumeric(arguments.inactive) ) {
			variables.instance.inactive=arguments.inactive;
		}
		return this;
	}

	public function setIsPublic(isPublic) output=false {
		variables.instance.isPublic=arguments.isPublic;
		return this;
	}

	public function setType(type) output=false {
		if ( isNumeric(arguments.type) ) {
			variables.instance.type=arguments.type;
		} else if ( arguments.type == 'user' ) {
			variables.instance.type=2;
		} else if ( arguments.type == 'group' ) {
			variables.instance.type=1;
		}
		return this;
	}

	public function setGroupID(String groupID, required boolean append="false") output=false {
		var i="";
		if ( !arguments.append ) {
			variables.instance.groupID = trim(arguments.groupID);
		} else {

			for(i in listToArray(arguments.groupID)){
				if (not listFindNoCase(variables.instance.groupID,trim(i))){
			    	variables.instance.groupID = listAppend(variables.instance.groupID,trim(i));
			  }
			}

		}
		return this;
	}

	public function setCategoryID(String categoryID, required boolean append="false") output=false {
		var i="";
		if ( !arguments.append ) {
			variables.instance.categoryID = trim(arguments.categoryID);
		} else {

			for(i in listToArray(arguments.categoryID)){
				if (not listFindNoCase(variables.instance.categoryID,trim(i))){
			    	variables.instance.categoryID = listAppend(variables.instance.categoryID,trim(i));
			  }
			}

		}
		return this;
	}

	public function getAvailableCount() output=false {
		return getQuery(countOnly=true).count;
	}

	public function clone() output=false {
		return getBean("userFeed").setAllValues(structCopy(getAllValues()));
	}

}
