component extends="mura.bean.beanORM" entityName='oauthProvider' table="toauthproviders" bundleable="true" hint="This provides OAuth Providers CRUD functionality" {
    property name="providerid" fieldtype="id";
    property name="clientid" datatype="varchar" length=150;
    property name="clientsecret" datatype="varchar" length=150;
    property name="name" datatype="varchar" required=true;
    property name="site" fieldtype="many-to-one" cfc="site" fkcolumn="siteid" required=true;
    property name="created" ormtype="timestamp";
    property name="lastupdate" datatype="timestamp";
    property name="lastupdateby" datatype="varchar" length=50;
    property name="lastupdatebyid" datatype="varchar" length=35;
}
