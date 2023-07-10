//   license goes here 
/**
 * This provides formBean functionality
 */
component displayname="formBean" output="false" extends="mura.baseobject" hint="This provides formBean functionality" {
	property name="FormID" type="uuid" default="" required="true" maxlength="35";
	property name="Name" type="string" default="" maxlength="150";
	property name="Package" type="string" default="" maxlength="50";
	property name="IsActive" type="boolean" default="0" required="true";
	property name="IsCurrent" type="boolean" default="0" required="true";
	property name="StatusCode" type="numeric" default="0" required="true";
	property name="Notes" type="string" default="";
	property name="SiteID" type="string" default="" required="true" maxlength="25";
	property name="RemoteID" type="string" default="" maxlength="35";
	property name="DateCreate" type="date" default="" required="true";
	property name="DateLastUpdate" type="date" default="" required="true";
	property name="Fields" type="Struct" default="" required="true";
	property name="FormAttributes" type="Struct" default="" required="true";
	property name="FieldOrder" type="Array" default="" required="true";
	property name="Pages" type="Array" default="" required="true";
	property name="DeletedFields" type="Struct" default="" required="false";
	property name="Config" type="Any" default="" required="true";
	variables.instance		= StructNew();
	variables.fieldsChecked	= false;
	//  INIT 

	public FormBean function init(string FormID="", string Name="", string Package="", boolean IsActive="0", boolean IsCurrent="0", numeric StatusCode="0", string Notes="", string SiteID="", string RemoteID="", string DateCreate="", string DateLastUpdate="", Struct FormAttributes="#StructNew()#", Struct Fields="#StructNew()#", Array FieldOrder="#ArrayNew(1)#", Array Pages="#ArrayNew(1)#", Struct DeletedFields="#StructNew()#", Any Config="#StructNew()#") output=false {
		super.init( argumentcollection=arguments );
		setFormID( arguments.FormID );
		setName( arguments.Name );
		setPackage( arguments.Package );
		setIsActive( arguments.IsActive );
		setIsCurrent( arguments.IsCurrent );
		setStatusCode( arguments.StatusCode );
		setNotes( arguments.Notes );
		setSiteID( arguments.SiteID );
		setRemoteID( arguments.RemoteID );
		setDateCreate( arguments.DateCreate );
		setDateLastUpdate( arguments.DateLastUpdate );
		setFormAttributes( arguments.FormAttributes );
		setFields( arguments.Fields );
		setFieldOrder( arguments.FieldOrder );
		setPages( arguments.Pages );
		setDeletedFields( arguments.DeletedFields );
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

	public function setFormID(required string FormID) output=false {
		variables.instance['formid'] = arguments.FormID;
	}

	public function getFormID() output=false {
		return variables.instance.FormID;
	}

	public function setName(required string Name) output=false {
		variables.instance['name'] = arguments.Name;
	}

	public function getName() output=false {
		return variables.instance.Name;
	}

	public function setPackage(required string Package) output=false {
		variables.instance['package'] = arguments.Package;
	}

	public function getPackage() output=false {
		return variables.instance.Package;
	}

	public function setIsActive(required boolean IsActive) output=false {
		variables.instance['isactive'] = arguments.IsActive;
	}

	public boolean function getIsActive() output=false {
		return variables.instance.IsActive;
	}

	public function setIsCurrent(required boolean IsCurrent) output=false {
		variables.instance['iscurrent'] = arguments.IsCurrent;
	}

	public boolean function getIsCurrent() output=false {
		return variables.instance.IsCurrent;
	}

	public function setStatusCode(required numeric StatusCode) output=false {
		variables.instance['statuscode'] = arguments.StatusCode;
	}

	public function getStatusCode() output=false {
		return variables.instance.StatusCode;
	}

	public function setNotes(required string Notes) output=false {
		variables.instance['notes'] = arguments.Notes;
	}

	public function getNotes() output=false {
		return variables.instance.Notes;
	}

	public function setSiteID(required string SiteID) output=false {
		variables.instance['siteid'] = arguments.SiteID;
	}

	public function getSiteID() output=false {
		return variables.instance.SiteID;
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
	//  Services 

	public function setFormAttributes(required struct FormAttributes) output=false {
		variables.instance['formattributes'] = arguments.FormAttributes;
	}

	public struct function getFormAttributes() output=false {
		if ( !variables.FormAttributesChecked && !structCount( variables.instance.FormAttributes ) ) {
			setFormAttributes( getFormService().getFormAttributeservice().getFormAttributes( formID = getFormID() ) );
			variables.FormAttributesChecked = true;
		}
		return variables.instance.FormAttributes;
	}

	public function setFields(required struct Fields) output=false {
		variables.instance['fields'] = arguments.Fields;
	}

	public struct function getFields() output=false {
		if ( !variables.fieldsChecked && !structCount( variables.instance.Fields ) ) {
			setFields( getFormService().getFieldService().getFields( formID = getFormID() ) );
			variables.fieldsChecked = true;
		}
		return variables.instance.Fields;
	}

	public function getField(required struct FieldID) output=false {
		if ( StructKeyExists( variables.instance.Fields,arguments.FieldID ) ) {
			return variables.instance.Fields[arguments.FieldID];
		}
		return false;
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

	public function setFieldOrder(required Array FieldOrder) output=false {
		variables.instance['fieldorder'] = arguments.FieldOrder;
	}

	public Array function getFieldOrder() output=false {
		return variables.instance.FieldOrder;
	}

	public function setPages(required Array Pages) output=false {
		variables.instance['pages'] = arguments.Pages;
	}

	public Array function getPages() output=false {
		return variables.instance.pages;
	}

	public function setDeletedFields(required struct DeletedFields) output=false {
		variables.instance['deletedfields'] = arguments.DeletedFields;
	}

	public struct function getDeletedFields() output=false {
		return variables.instance.DeletedFields;
	}

}
