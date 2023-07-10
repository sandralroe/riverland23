//   license goes here 
/**
 * This provides dataSetBean functionality
 */
component displayname="DatasetBean" output="false" extends="mura.baseobject" hint="This provides dataSetBean functionality" {
	property name="DatasetID" type="uuid" default="" required="true" maxlength="35";
	property name="ParentID" type="uuid" default="" maxlength="35";
	property name="Name" type="string" default="" maxlength="150";
	property name="SortColumn" type="string" default="orderby" required="true" maxlength="12";
	property name="SortDirection" type="string" default="asc" required="true" maxlength="4";
	property name="SortType" type="string" default="" maxlength="10";
	property name="IsGlobal" type="boolean" default="0" required="true";
	property name="IsSorted" type="boolean" default="0" required="true";
	property name="IsLocked" type="boolean" default="0" required="true";
	property name="IsActive" type="boolean" default="1" required="true";
	property name="SourceType" type="string" default="" maxlength="50";
	property name="Source" type="string" default="" maxlength="250";
	property name="DefaultID" type="string" default="" required="false" maxlength="35";
	property name="SiteID" type="string" default="" required="true" maxlength="25";
	property name="RemoteID" type="string" default="" maxlength="35";
	property name="DateCreate" type="date" default="" required="true";
	property name="DateLastUpdate" type="date" default="" required="true";
	property name="Model" type="Struct" default="" required="true";
	property name="DataRecords" type="Struct" default="" required="true";
	property name="DataRecordOrder" type="Array" default="" required="true";
	property name="IsSortChanged" type="boolean" default="0" required="true";
	property name="DeletedRecords" type="Struct" default="" required="false";
	variables.instance 			= StructNew();
	variables.DataRecordChecked	= false;
	//  INIT 

	public DatasetBean function init(uuid DatasetID="#CreateUUID()#", string ParentID="", string Name="", string SortColumn="orderby", string SortDirection="asc", string SortType="", boolean IsGlobal="0", boolean IsSorted="0", boolean IsLocked="0", boolean IsActive="1", string SourceType="", string Source="", string DefaultID="", string SiteID="", string RemoteID="", string DateCreate="", string DateLastUpdate="", Struct Model="#StructNew()#", Struct DataRecords="#StructNew()#", Array DataRecordOrder="#ArrayNew(1)#", boolean IsSortChanged="0", Struct DeletedRecords="#StructNew()#") output=false {
		super.init( argumentcollection=arguments );
		setDatasetID( arguments.DatasetID );
		setParentID( arguments.ParentID );
		setName( arguments.Name );
		setSortColumn( arguments.SortColumn );
		setSortDirection( arguments.SortDirection );
		setSortType( arguments.SortType );
		setIsGlobal( arguments.IsGlobal );
		setIsSorted( arguments.IsSorted );
		setIsLocked( arguments.IsLocked );
		setIsActive( arguments.IsActive );
		setSourceType( arguments.SourceType );
		setSource( arguments.Source );
		setSiteID( arguments.SiteID );
		setRemoteID( arguments.RemoteID );
		setDateCreate( arguments.DateCreate );
		setDateLastUpdate( arguments.DateLastUpdate );
		setModel( arguments.Model );
		setDataRecords( arguments.DataRecords );
		setDataRecordOrder( arguments.DataRecordOrder );
		setIsSortChanged( arguments.IsSortChanged );
		setDeletedRecords( arguments.DeletedRecords );
		return this;
	}

	public DatasetBean function setAllValues(required struct AllValues) output=false {
		variables.instance = arguments.AllValues;
		return this;
	}

	public struct function getAllValues() output=false {
		return variables.instance;
	}

	public function setDatasetID(required uuid DatasetID) output=false {
		variables.instance['datasetid'] = arguments.DatasetID;
	}

	public uuid function getDatasetID() output=false {
		return variables.instance.DatasetID;
	}

	public function setParentID(required string ParentID) output=false {
		variables.instance['parentid'] = arguments.ParentID;
	}

	public function getParentID() output=false {
		return variables.instance.ParentID;
	}

	public function setName(required string Name) output=false {
		variables.instance['name'] = arguments.Name;
	}

	public function getName() output=false {
		return variables.instance.Name;
	}

	public function setSortColumn(required string SortColumn) output=false {
		variables.instance['sortcolumn'] = arguments.SortColumn;
	}

	public function getSortColumn() output=false {
		return variables.instance.SortColumn;
	}

	public function setSortDirection(required string SortDirection) output=false {
		variables.instance['sortdirection'] = arguments.SortDirection;
	}

	public function getSortDirection() output=false {
		return variables.instance.SortDirection;
	}

	public function setSortType(required string SortType) output=false {
		variables.instance['sorttype'] = arguments.SortType;
	}

	public function getSortType() output=false {
		return variables.instance.SortType;
	}

	public function setIsGlobal(required boolean IsGlobal) output=false {
		variables.instance['isglobal'] = arguments.IsGlobal;
	}

	public boolean function getIsGlobal() output=false {
		return variables.instance.IsGlobal;
	}

	public function setIsSorted(required boolean IsSorted) output=false {
		variables.instance['issorted'] = arguments.IsSorted;
	}

	public boolean function getIsSorted() output=false {
		return variables.instance.IsSorted;
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

	public function setSourceType(required string SourceType) output=false {
		variables.instance['sourcetype'] = arguments.SourceType;
	}

	public function getSourceType() output=false {
		return variables.instance.SourceType;
	}

	public function setSource(required string Source) output=false {
		variables.instance['source'] = arguments.Source;
	}

	public function getSource() output=false {
		return variables.instance.Source;
	}

	public function setDefaultID(required string DefaultID) output=false {
		variables.instance['defaultid'] = arguments.DefaultID;
	}

	public function getDefaultID() output=false {
		return variables.instance.DefaultID;
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

	public function setModel(required Struct Model) output=false {
		variables.instance['model'] = arguments.Model;
	}

	public Struct function getModel() output=false {
		return variables.instance.Model;
	}

	public function setDataRecords(required struct DataRecords) output=false {
		variables.instance['datarecords'] = arguments.DataRecords;
	}

	public struct function getDataRecords() output=false {
		return variables.instance.DataRecords;
	}

	public function getDataRecord(required struct DataRecordID) output=false {
		if ( StructKeyExists( variables.instance.DataRecords,arguments.DataRecordID ) ) {
			return variables.instance.DataRecords[arguments.DataRecordID];
		}
		return false;
	}

	public function setDataRecordOrder(required Array DataRecordOrder) output=false {
		variables.instance['datarecordorder'] = arguments.DataRecordOrder;
	}

	public Array function getDataRecordOrder() output=false {
		return variables.instance.DataRecordOrder;
	}

	public function setIsSortChanged(required boolean IsSortChanged) output=false {
		variables.instance['issortchanged'] = arguments.IsSortChanged;
	}

	public boolean function getIsSortChanged() output=false {
		return variables.instance.IsSortChanged;
	}

	public function setDeletedRecords(required struct DeletedRecords) output=false {
		variables.instance['deletedrecords'] = arguments.DeletedRecords;
	}

	public struct function getDeletedRecords() output=false {
		return variables.instance.DeletedRecords;
	}

}
