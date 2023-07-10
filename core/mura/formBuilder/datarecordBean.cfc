//   license goes here 
/**
 * This provides dataRecordBean functionality
 */
component displayname="DataRecordBean" output="false" extends="mura.baseobject" hint="This provides dataRecordBean functionality" {
	property name="DataRecordID" type="uuid" default="" required="true" maxlength="35";
	property name="DatasetID" type="uuid" default="" required="true" maxlength="35";
	property name="Label" type="string" default="" required="true" maxlength="150";
	property name="Value" type="string" default="" maxlength="35";
	property name="OrderNo" type="numeric" default="0" required="true";
	property name="IsSelected" type="numeric" default="0" required="true";
	property name="RemoteID" type="string" default="" maxlength="35";
	property name="DateCreate" type="date" default="" required="true";
	property name="DateLastUpdate" type="date" default="" required="true";
	variables.instance = StructNew();
	//  INIT 

	public DataRecordBean function init(uuid DataRecordID="#CreateUUID()#", string DatasetID="", string Label="", string Value="", numeric OrderNo="0", numeric IsSelected="0", string RemoteID="", string DateCreate="", string DateLastUpdate="") output=false {
		super.init( argumentcollection=arguments );
		setDataRecordID( arguments.DataRecordID );
		setDatasetID( arguments.DatasetID );
		setLabel( arguments.Label );
		setValue( arguments.Value );
		setOrderNo( arguments.OrderNo );
		setRemoteID( arguments.RemoteID );
		setDateCreate( arguments.DateCreate );
		setDateLastUpdate( arguments.DateLastUpdate );
		setIsSelected( arguments.IsSelected );
		return this;
	}

	public DatasetBean function setAllValues(required struct AllValues) output=false {
		variables.instance = arguments.AllValues;
		return this;
	}

	public struct function getAllValues() output=false {
		return variables.instance;
	}

	public function setDataRecordID(required uuid DataRecordID) output=false {
		variables.instance['datarecordid'] = arguments.DataRecordID;
	}

	public uuid function getDataRecordID() output=false {
		return variables.instance.DataRecordID;
	}

	public function setDatasetID(required string DatasetID) output=false {
		variables.instance['datasetid'] = arguments.DatasetID;
	}

	public function getDatasetID() output=false {
		return variables.instance.DatasetID;
	}

	public function setLabel(required string Label) output=false {
		variables.instance['label'] = arguments.Label;
	}

	public function getLabel() output=false {
		return variables.instance.Label;
	}

	public function setValue(required string Value) output=false {
		variables.instance['value'] = arguments.Value;
	}

	public function getValue() output=false {
		return variables.instance.Value;
	}

	public function setOrderNo(required numeric OrderNo) output=false {
		variables.instance['orderno'] = arguments.OrderNo;
	}

	public function getOrderNo() output=false {
		return variables.instance.OrderNo;
	}

	public function setIsSelected(required numeric IsSelected) output=false {
		variables.instance['isselected'] = arguments.IsSelected;
	}

	public function getIsSelected() output=false {
		return variables.instance.IsSelected;
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

}
