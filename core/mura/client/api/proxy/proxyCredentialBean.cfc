component extends="mura.bean.beanORM" table="tproxycredential" entityName="proxyCredential" scaffold=false bundleable=true {
    property name="credentialid" fieldtype="id";
    property name="site" fieldtype="many-to-one" relatesto="site" fkcolumn="siteid" required=true;
    property name="proxy" fieldtype="many-to-one" relatesto="proxy" fkcolumn="proxyid";
    property name="name" datatype="varchar" required=true length="200" maxlength="200";
    property name="type" datatype="varchar" required=true length="200" maxlength="200";
    property name="data" datatype="text" encrypted=true required=true;
    /*property name="clientid" datatype="text"  encrypted=true length="255";
	property name="clientsecret"  encrypted=true type="string" length="255";
	property name="refreshToken" datatype="text" length="255";
	property name="redirectURI" datatype="text" length="255";
    property name="revokeURI" datatype="text" length="255";*/
    property name="created" datatype="timestamp";
    property name="lastupdate" datatype="timestamp";
    property name="lastupdateby" datatype="varchar" length=50;
    property name="lastupdatebyid" datatype="varchar" length=35;
    
    function allowAccess(mura){
		return getCurrentUser().isSuperUser();
	}

    function allowRead(){
        return getCurrentUser().isSuperUser();
    }

    function allowSave(){
        return getCurrentUser().isSuperUser();
    }

    function allowDelete(){
        return getCurrentUser().isSuperUser();
    }
}