//   license goes here 
/**
 * This provides fieldBean functionality
 */
component displayname="fieldBean" output="false" extends="mura.baseobject" hint="This provides fieldBean functionality" {
	property name="FieldID" type="uuid" default="" required="true" maxlength="35";
	property name="FormID" type="uuid" default="" required="true" maxlength="35";
	property name="FieldTypeID" type="uuid" default="" required="true" maxlength="35";
	property name="DatasetID" type="uuid" default="" maxlength="35";
	property name="Name" type="string" default="" maxlength="50";
	property name="Label" type="string" default="" maxlength="50";
	property name="displaylegend" type="numeric" default="1";
	property name="OrderNo" type="numeric" default="0" required="true";
	property name="IsActive" type="boolean" default="0" required="true";
	property name="IsDeleted" type="boolean" default="0" required="true";
	property name="IsRequired" type="boolean" default="0" required="true";
	property name="Type" type="string" default="COMMON" required="true" maxlength="20";
	property name="IsEntryType" type="string" default="SINGLE" required="true" maxlength="50";
	property name="Rblabel" type="string" default="" maxlength="100";
	property name="Cssstyle" type="string" default="" maxlength="50";
	property name="placeholder" type="string" default="" maxlength="255";
	property name="ToolTip" type="string" default="" maxlength="250";
	property name="ValidateType" type="string" default="" maxlength="35";
	property name="IsLocked" type="boolean" default="0" required="true";
	property name="ValidateRegex" type="string" default="" maxlength="100";
	property name="ValidateMessage" type="string" default="" maxlength="200";
	property name="SectionID" type="uuid" default="00000000-0000-0000-0000000000000000" required="true" maxlength="35";
	property name="RelatedID" type="uuid" default="" maxlength="35";
	property name="Params" type="string" default="";
	property name="RemoteID" type="string" default="" maxlength="35";
	property name="DateCreate" type="date" default="" required="true";
	property name="DateLastUpdate" type="date" default="" required="true";
	property name="FieldType" type="any" default="" required="true" maxlength="35";
	property name="Value" type="string" default="" required="false" maxlength="250";
	property name="Config" type="Any" default="" required="true";
	variables.instance = StructNew();
	//  INIT 

	public fieldBean function init(uuid FieldID="#CreateUUID()#", string FormID="", string FieldTypeID="", string DatasetID="", string Name="", string Label="", string Rblabel="", string Cssstyle="", string placeholder="", string ToolTip="", numeric OrderNo="0", boolean IsLocked="0", boolean IsActive="1", boolean IsDeleted="0", boolean IsRequired="0", string Type="COMMON", string IsEntryType="SINGLE", string ValidateType="", string ValidateRegex="", string ValidateMessage="", string SectionID="00000000-0000-0000-0000000000000000", string RelatedID="", string Params="", string RemoteID="", string DateCreate="", string DateLastUpdate="", boolean BeanExists="false", any FieldType="", string value="", Any Config="#StructNew()#") output=false {
		super.init( argumentcollection=arguments );
		setFieldID( arguments.FieldID );
		setFormID( arguments.FormID );
		setFieldTypeID( arguments.FieldTypeID );
		setDatasetID( arguments.DatasetID );
		setName( arguments.Name );
		setLabel( arguments.Label );
		setOrderNo( arguments.OrderNo );
		setIsActive( arguments.IsActive );
		setIsRequired( arguments.IsRequired );
		setType( arguments.Type );
		setIsEntryType( arguments.IsEntryType );
		setSectionID( arguments.SectionID );
		setRemoteID( arguments.RemoteID );
		setDateCreate( arguments.DateCreate );
		setDateLastUpdate( arguments.DateLastUpdate );
		setIsDeleted( arguments.IsDeleted );
		setRblabel( arguments.Rblabel );
		setCssstyle( arguments.Cssstyle );
		setPlaceHolder( arguments.placeholder );
		setToolTip( arguments.ToolTip );
		setIsLocked( arguments.IsLocked );
		setValidateType( arguments.ValidateType );
		setValidateMessage( arguments.ValidateMessage );
		setValidateRegex( arguments.ValidateRegex );
		setSectionID( arguments.SectionID );
		setRelatedID( arguments.RelatedID );
		setParams( arguments.Params );
		setFieldType( arguments.FieldType );
		setValue( arguments.Value );
		setConfig( arguments.Config );
		return this;
	}

	public FieldtypeBean function setAllValues(required struct values) output=false {
		variables.instance = arguments.values;
		return this;
	}

	public struct function getAllValues() output=false {
		return variables.instance;
	}

	public function setFieldID(required uuid FieldID) output=false {
		variables.instance['fieldid'] = arguments.FieldID;
	}

	public uuid function getFieldID() output=false {
		return variables.instance.FieldID;
	}

	public function setFormID(required string FormID) output=false {
		variables.instance['formid'] = arguments.FormID;
	}

	public function getFormID() output=false {
		return variables.instance.FormID;
	}

	public function setFieldTypeID(required string FieldTypeID) output=false {
		variables.instance['fieldtypeid'] = arguments.FieldTypeID;
	}

	public function getFieldTypeID() output=false {
		return variables.instance.FieldTypeID;
	}

	public function setDatasetID(required string DatasetID) output=false {
		variables.instance['datasetid'] = arguments.DatasetID;
	}

	public function getDatasetID() output=false {
		return variables.instance.DatasetID;
	}

	public function setName(required string Name) output=false {
		variables.instance['name'] = arguments.Name;
	}

	public function getName() output=false {
		return variables.instance.Name;
	}

	public function setLabel(required string Label) output=false {
		variables.instance['label'] = arguments.Label;
	}

	public function getLabel() output=false {
		return variables.instance.Label;
	}

	public function setRblabel(required string Rblabel) output=false {
		variables.instance['rblabel'] = arguments.Rblabel;
	}

	public function getRblabel() output=false {
		return variables.instance.Rblabel;
	}

	public function setCssstyle(required string Cssstyle) output=false {
		variables.instance['cssstyle'] = arguments.Cssstyle;
	}

	public function getCssstyle() output=false {
		return variables.instance.Cssstyle;
	}

	public function setPlaceHolder(required string placeholder) output=false {
		variables.instance['placeholder'] = arguments.placeholder;
	}

	public function getPlaceHolder() output=false {
		return variables.instance.placeholder;
	}

	public function setToolTip(required string ToolTip) output=false {
		variables.instance['tooltip'] = arguments.ToolTip;
	}

	public function getToolTip() output=false {
		return variables.instance.ToolTip;
	}

	public function setOrderNo(required numeric OrderNo) output=false {
		variables.instance['orderno'] = arguments.OrderNo;
	}

	public function getOrderNo() output=false {
		return variables.instance.OrderNo;
	}

	public function setIsLocked(required boolean IsLocked) output=false {
		variables.instance['islocked'] = arguments.IsLocked;
	}

	public boolean function getIsLocked() output=false {
		return variables.instance.IsLocked;
	}

	public function setIsActive(required boolean IsActive) output=false {
		variables.instance['isactive'] = arguments.IsActive;
	}

	public boolean function getIsActive() output=false {
		return variables.instance.IsActive;
	}

	public function setIsDeleted(required boolean IsDeleted) output=false {
		variables.instance['isdeleted'] = arguments.IsDeleted;
	}

	public boolean function getIsDeleted() output=false {
		return variables.instance.IsDeleted;
	}

	public function setIsRequired(required boolean IsRequired) output=false {
		variables.instance['isrequired'] = arguments.IsRequired;
	}

	public boolean function getIsRequired() output=false {
		return variables.instance.IsRequired;
	}

	public function setType(required string Type) output=false {
		variables.instance['type'] = arguments.Type;
	}

	public function getType() output=false {
		return variables.instance.Type;
	}

	public function setIsEntryType(required string IsEntryType) output=false {
		variables.instance['isentrytype'] = arguments.IsEntryType;
	}

	public function getIsEntryType() output=false {
		return variables.instance.IsEntryType;
	}

	public function setValidateType(required string ValidateType) output=false {
		variables.instance['validatetype'] = arguments.ValidateType;
	}

	public function getValidateType() output=false {
		return variables.instance.ValidateType;
	}

	public function setValidateMessage(required string ValidateMessage) output=false {
		variables.instance['validatemessage'] = arguments.ValidateMessage;
	}

	public function getValidateMessage() output=false {
		return variables.instance.ValidateMessage;
	}

	public function setValidateRegex(required string ValidateRegex) output=false {
		variables.instance['validateregex'] = arguments.ValidateRegex;
	}

	public function getValidateRegex() output=false {
		return variables.instance.ValidateRegex;
	}

	public function setSectionID(required string SectionID) output=false {
		variables.instance['sectionid'] = arguments.SectionID;
	}

	public function getSectionID() output=false {
		return variables.instance.SectionID;
	}

	public function setRelatedID(required string RelatedID) output=false {
		variables.instance['relatedid'] = arguments.RelatedID;
	}

	public function getRelatedID() output=false {
		return variables.instance.RelatedID;
	}

	public function setParams(required string Params) output=false {
		variables.instance['params'] = arguments.Params;
	}

	public function getParams() output=false {
		return variables.instance.Params;
	}

	public function setRemoteID(required string RemoteID) output=false {
		variables.instance['remoteid'] = arguments.RemoteID;
	}

	public function getRemoteID() output=false {
		return variables.instance.RemoteID;
	}

	public function setDateCreate(required string DateCreate) output=false {
		variables.instance['datecreate'] = arguments.DateCreate;
	}

	public function getDateCreate() output=false {
		return variables.instance.DateCreate;
	}

	public function setDateLastUpdate(required string DateLastUpdate) output=false {
		variables.instance['datelastupdate'] = arguments.DateLastUpdate;
	}

	public function getDateLastUpdate() output=false {
		return variables.instance.DateLastUpdate;
	}

	public struct function getParamsData() output=false {
		if ( !len( getParams() ) ) {
			return StructNew();
		} else {
			return deserializeJSON( getParams() );
		}
	}

	public function setParamsData(required struct ParamsData) output=false {
		if ( !structCount( arguments.ParamsData ) ) {
			setParams( "{}" );
		} else {
			setParams( serializeJSON( arguments.ParamsData ) );
		}
	}

	public struct function getConfig(string mode="json") output=false {
		if ( arguments.mode == "object" ) {
			return deserializeJSON( variables.instance.config );
		} else {
			return variables.instance.config;
		}
	}

	public function setConfig(required struct Config) output=false {
		if ( isJSON( arguments.Config ) ) {
			variables.instance['config'] = arguments.config;
		} else {
			variables.instance['config'] = serializeJSON( arguments.config );
		}
	}

	public function setFieldType(required any FieldType) output=false {
		variables.instance['fieldtype'] = arguments.FieldType;
	}

	public function getFieldType() output=false {
		if ( len( getFieldTypeID() ) == 35 && !isInstanceOf(variables.instance['fieldtype'],"FieldTypeBean") ) {
			setFieldType( getFieldService().getFieldTypeService().getBeanByAttributes( fieldTypeID = getFieldTypeID() ) );
		}
		return variables.instance.FieldType;
	}

	public function setValue(required any Value) output=false {
		variables.instance['value'] = arguments.Value;
	}

	public function getValue() output=false {
		return variables.instance.Value;
	}

}
