/* license goes here */
/**
 * This provides functionality for beans that are extended via the class extension manager
 */
component extends="mura.bean.bean" output="false" hint="This provides functionality for beans that are extended via the class extension manager" {
	property name="extendData" type="any" default="" comparable="false" persistent="false";
	property name="extendSetID" type="string" default="" comparable="false" persistent="false";
	property name="extendDataTable" type="string" default="tclassextenddata" required="true" comparable="false" persistent="false";
	property name="type" type="string" default="Custom";
	property name="subType" type="string" default="Default";
	property name="siteID" type="string" default="" required="true";
	property name="extendAutoComplete" type="boolean" default="true" required="true" comparable="false" persistent="false";

	public function init() output=false {
		super.init(argumentCollection=arguments);
		variables.instance.extendData="";
		variables.instance.extendSetID="";
		variables.instance.extendDataTable="tclassextenddata";
		variables.instance.extendAutoComplete = true;
		variables.instance.frommuracache = false;
		variables.instance.type = "Custom";
		variables.instance.subType = "Default";
		variables.instance.siteiD = "";
		variables.instance.sourceIterator = "";
		variables.missingDefaultAppended=false;
		return this;
	}

	public function setConfigBean(configBean) output=false {
		variables.configBean=arguments.configBean;
		return this;
	}
	//  This needs to be overriden

	public function getExtendBaseID() output=false {
		return "";
	}

	public function setType(required string Type) output=false {
		arguments.Type=trim(arguments.Type);
		if ( len(arguments.Type) && variables.instance.Type != arguments.Type ) {
			variables.instance.Type = arguments.Type;
			purgeExtendedData();
		}
		return this;
	}

	public function setSubType(required string SubType) output=false {
		arguments.subType=trim(arguments.subType);
		if ( len(arguments.subType) && variables.instance.SubType != arguments.SubType ) {
			variables.instance.SubType = arguments.SubType;
			purgeExtendedData();
		}
		return this;
	}

	public function setSiteID(required string SiteID) output=false {
		if ( len(arguments.siteID) && trim(arguments.siteID) != variables.instance.siteID ) {
			variables.instance.SiteID = trim(arguments.SiteID);
			purgeExtendedData();
		}
		return this;
	}

	public function getExtendedData() output=false {
		if ( !isObject(variables.instance.extendData) ) {
			variables.instance.extendData=variables.configBean.getClassExtensionManager().getExtendedData(
				baseID=getExtendBaseID()
				, type=variables.instance.type
				, subType=variables.instance.subtype
				, siteID=variables.instance.siteID
				, dataTable=variables.instance.extendDataTable
				, sourceIterator=variables.instance.sourceIterator
			);
		}
		return variables.instance.extendData;
	}

	public function purgeExtendedData() output=false {
		variables.instance.extendData="";
		variables.instance.extendAutoComplete = true;
		variables.instance.sourceIterator = "";
		return this;
	}

	public function getExtendedAttribute(required string key, required boolean useMuraDefault="false") output=false {
		return getExtendedData().getAttribute(arguments.key,arguments.useMuraDefault);
	}

	public function appendMissingAttributes() output=false {
		if ( !variables.missingDefaultAppended ) {
			getBean('configBean')
			.getClassExtensionManager()
			.appendMissingAttributes(variables.instance);
			variables.missingDefaultAppended=true;
		}
	}

	public struct function getExtendedAttributes(name="") output=false {
		var extendSetData = getExtendedData().getAllExtendSetData();
		extendSetData=StructKeyExists(extendSetData, 'data') ? extendSetData.data : {};
		var i = "";
		if ( Len(arguments.name) ) {
			var rsAttributes = getExtendedAttributesQuery(name=arguments.name);
			if ( rsAttributes.recordcount ) {
				extendSetData = {};

				for(i=1;i <= rsAttributes.recordcount;i++){
					extendSetData['#rsAttributes.name[currentrow]#'] = rsAttributes.attributeValue[currentrow];
				}

			}
		}
		if ( !structIsEmpty(extendSetData) ) {
			for ( i in extendSetData ) {
				if ( valueExists(i) ) {
					extendSetData[i]=getValue(i);
				}
			}
		}
		return extendSetData;
	}

	public function getExtendedAttributesList(name="") output=false {
		return StructKeyList(getExtendedAttributes(name=arguments.name));
	}

	public function getExtendedAttributesQuery(name="") output=false {

		var structData = getExtendedData().getAllValues();
		var rsData = StructKeyExists(structData, 'data') ? structData.data : QueryNew('');
		var rsDefinitions = StructKeyExists(structData, 'definitions') ? structData.definitions : QueryNew('');
		var rsExtendSet = queryNew('');
		var qs='';
		var rsAttributes = rsData;
		if ( Len(arguments.name) ) {
			if ( rsDefinitions.recordcount ) {

				qs=getQueryService();
				qs.setDbType('query');
				qs.setAttributes(rsDefinitions=rsDefinitions);
				qs.addParam( name="name", cfsqltype="cf_sql_varchar", value=arguments.name );

				rsExtendSet=qs.execute(sql="SELECT DISTINCT extendsetid FROM rsDefinitions WHERE extendsetname = :name").getResult();

			}

			if ( rsExtendSet.recordcount ) {

				qs=getQueryService();
				qs.setDbType('query');
				qs.setAttributes(rsData=rsData);
				qs.addParam( name="id", cfsqltype="cf_sql_varchar", value=rsExtendSet.extendsetid );

				rsAttributes=qs.execute(sql="SELECT * FROM rsData WHERE extendsetid = :id").getResult();

			}
		}
		return rsAttributes;
	}

	public function setValue(required string property, propertyValue="") output=false {
		var extData =structNew();
		var i = "";
		if ( isSimpleValue(arguments.propertyValue) ) {
			arguments.propertyValue=trim(arguments.propertyValue);
		}
		if ( arguments.property != 'value' && isValid('variableName',arguments.property) && isDefined("this.set#arguments.property#") ) {
			var tempFunc=this["set#arguments.property#"];
			tempFunc(arguments.propertyValue);
		} else {
			variables.instance["#arguments.property#"]=arguments.propertyValue;
		}
		return this;
	}

	public function getValue(required string property, defaultValue) output=false {
		var tempValue="";
		if ( isValid('variableName',arguments.property) && isDefined("this.get#arguments.property#") && arguments.property != 'bean') {
			var tempFunc=this["get#arguments.property#"];
			return tempFunc();
		} else if ( structKeyExists(variables.instance,"#arguments.property#") ) {
			return variables.instance["#arguments.property#"];
		} else if ( !variables.instance.frommuracache ) {
			if ( structKeyExists(arguments,"defaultValue") ) {
				tempValue=getExtendedAttribute(arguments.property,true);
				if ( tempValue != "useMuraDefault" ) {
					variables.instance["#arguments.property#"]=tempValue;
					return tempValue;
				} else {
					variables.instance["#arguments.property#"]=arguments.defaultValue;
					return arguments.defaultValue;
				}
			} else {
				return getExtendedAttribute(arguments.property);
			}
		} else if ( structKeyExists(arguments,"defaultValue") ) {
			variables.instance["#arguments.property#"]=arguments.defaultValue;
			return arguments.defaultValue;
		} else {
			appendMissingAttributes();
			if ( structKeyExists(variables.instance,"#arguments.property#") ) {
				return variables.instance["#arguments.property#"];
			} else {
				return '';
			}
		}
	}

	public struct function getAllValues(required autocomplete="#variables.instance.extendAutoComplete#") output=false {
		var i="";
		var extData="";
		if ( arguments.autocomplete ) {
			extData=getExtendedData().getAllExtendSetData();
			if ( !structIsEmpty(extData) ) {
				structAppend(variables.instance,extData.data,false);

				for(i in ListToArray(extData.extendSetID)){
					if(!listFind(variables.instance.extendSetID,i)){
						variables.instance.extendSetID=listAppend(variables.instance.extendSetID,i);
					}
				}

			}
		}
		purgeExtendedData();
		return variables.instance;
	}

}
