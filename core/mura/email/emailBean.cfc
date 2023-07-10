//  License goes here 
component extends="mura.bean.bean" output="false" {
	property name="emailID" type="string" default="" required="true";
	property name="siteID" type="string" default="" required="true";
	property name="subject" type="string" default="";
	property name="bodyHTML" type="string" default="" html="true";
	property name="bodyText" type="string" default="";
	property name="format" type="string" default="";
	property name="createdDate" type="date" default="";
	property name="deliveryDate" type="date" default="";
	property name="status" type="string" default="";
	property name="groupID" type="string" default="";
	property name="lastUpdate" type="date" default="";
	property name="lastUpdateBy" type="string" default="";
	property name="LastUpdateByID" type="string" default="";
	property name="numberSent" type="numeric" default="0" required="true";
	property name="replyTo" type="string" default="";
	property name="fromLabel" type="string" default="";
	property name="template" type="string" default="";
	variables.primaryKey = 'emailid';
	variables.entityName = 'email';
	variables.instanceName= 'subject';

	public function Init() output=false {
		super.init(argumentCollection=arguments);
		variables.instance.emailID="";
		variables.instance.siteid="";
		variables.instance.subject="";
		variables.instance.bodyhtml="";
		variables.instance.bodytext="";
		variables.instance.format="";
		variables.instance.createdDate="#now()#";
		variables.instance.deliveryDate="";
		variables.instance.status="";
		variables.instance.groupID="";
		variables.instance.LastUpdateBy = "";
		variables.instance.LastUpdateByID = "";
		variables.instance.numberSent=0;
		variables.instance.ReplyTo="";
		variables.instance.FromLabel="";
		variables.instance.template="";
		return this;
	}

	public function setEmailManager(emailManager) output=false {
		variables.emailManager=arguments.emailManager;
		return this;
	}

	public function setConfigBean(configBean) output=false {
		variables.configBean=arguments.configBean;
		return this;
	}

	public function getEmailID() output=false {
		if ( !len(variables.instance.EmailID) ) {
			variables.instance.EmailID = createUUID();
		}
		return variables.instance.EmailID;
		return this;
	}

	public function setCreatedDate(required string CreatedDate) output=false {
		variables.instance.CreatedDate = parseDateArg(arguments.CreatedDate);
		return this;
	}

	public function setDeliveryDate(required string DeliveryDate) output=false {
		variables.instance.DeliveryDate = parseDateArg(arguments.DeliveryDate);
		return this;
	}

	public function setLastUpdateBy(required string LastUpdateBy) output=false {
		variables.instance.LastUpdateBy = left(trim(arguments.LastUpdateBy),50);
		return this;
	}

	public function setGroupList(required string groupList) output=false {
		variables.instance.groupID = arguments.groupList;
		return this;
	}

	public function save() output=false {
		setAllValues(variables.emailManager.save(this).getAllValues());
		return this;
	}

	public function delete() output=false {
		variables.emailManager.delete(getEmailID());
	}

	public function getPrimaryKey() output=false {
		return "emailID";
	}

}
