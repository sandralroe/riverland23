//   license goes here 
/**
 * This provides fieldtypeBean functionality
 */
component displayname="fieldtypeBean" output="false"  extends="mura.baseobject" hint="This provides fieldtypeBean functionality" {
	property name="FieldTypeID" type="uuid" default="" required="true" maxlength="35";
	property name="Label" type="string" default="" required="true" maxlength="45";
	property name="RbLabel" type="string" default="" maxlength="35";
	property name="Fieldtype" type="string" default="" required="true" maxlength="25";
	property name="Bean" type="string" default="" required="true" maxlength="50";
	property name="IsData" type="boolean" default="0" required="true";
	property name="IsLong" type="boolean" default="0" required="true";
	property name="IsMultiselect" type="boolean" default="0" required="true";
	property name="ModuleID" type="uuid" default="" maxlength="35";
	property name="DateCreate" type="date" default="" required="true";
	property name="DateLastUpdate" type="date" default="" required="true";
	property name="Displaytype" type="string" default="field" required="true" maxlength="25";
	variables.instance = StructNew();
	//  INIT 

	public fieldtypeBean function init(uuid FieldTypeID="#CreateUUID()#", string Label="", string RbLabel="", string Fieldtype="", string Bean="", boolean IsData="0", boolean IsLong="0", boolean IsMultiselect="0", string ModuleID="", string DateCreate="", string DateLastUpdate="", string Displaytype="field") output=false {
		setFieldTypeID( arguments.FieldTypeID );
		setLabel( arguments.Label );
		setRbLabel( arguments.RbLabel );
		setFieldtype( arguments.Fieldtype );
		setBean( arguments.Bean );
		setIsData( arguments.IsData );
		setIsLong( arguments.IsLong );
		setIsMultiselect( arguments.IsMultiselect );
		setModuleID( arguments.ModuleID );
		setDateCreate( arguments.DateCreate );
		setDateLastUpdate( arguments.DateLastUpdate );
		setDisplaytype( arguments.Displaytype );
		return this;
	}

	public FieldtypeBean function setAllValues(required struct values) output=false {
		variables.instance = arguments.values;
		return this;
	}

	public struct function getAllValues() output=false {
		return variables.instance;
	}

	public function setFieldTypeID(required uuid FieldTypeID) output=false {
		variables.instance['fieldtypeid'] = arguments.FieldTypeID;
	}

	public uuid function getFieldTypeID() output=false {
		return variables.instance.FieldTypeID;
	}

	public function setLabel(required string Label) output=false {
		variables.instance['label'] = arguments.Label;
	}

	public function getLabel() output=false {
		return variables.instance.Label;
	}

	public function setRbLabel(required string RbLabel) output=false {
		variables.instance['rblabel'] = arguments.RbLabel;
	}

	public function getRbLabel() output=false {
		return variables.instance.RbLabel;
	}

	public function setFieldtype(required string Fieldtype) output=false {
		variables.instance['fieldtype'] = arguments.Fieldtype;
	}

	public function getFieldtype() output=false {
		return variables.instance.Fieldtype;
	}

	public function setBean(required string Bean) output=false {
		variables.instance['bean'] = arguments.Bean;
	}

	public function getBean() output=false {
		return variables.instance.Bean;
	}

	public function setIsData(required boolean IsData) output=false {
		variables.instance['isdata'] = arguments.IsData;
	}

	public boolean function getIsData() output=false {
		return variables.instance.IsData;
	}

	public function setIsLong(required boolean IsLong) output=false {
		variables.instance['islong'] = arguments.IsLong;
	}

	public boolean function getIsLong() output=false {
		return variables.instance.IsLong;
	}

	public function setIsMultiSelect(required boolean IsMultiSelect) output=false {
		variables.instance['IsMultiSelect'] = arguments.IsMultiSelect;
	}

	public boolean function getIsMultiSelect() output=false {
		return variables.instance.IsMultiSelect;
	}

	public function setModuleID(required string ModuleID) output=false {
		variables.instance['moduleid'] = arguments.ModuleID;
	}

	public function getModuleID() output=false {
		return variables.instance.ModuleID;
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

	public function setDisplaytype(required string Displaytype) output=false {
		variables.instance['displaytype'] = arguments.Displaytype;
	}

	public function getDisplaytype() output=false {
		return variables.instance.Displaytype;
	}

}
