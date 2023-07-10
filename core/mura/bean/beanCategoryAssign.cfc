component extends="mura.bean.beanORM" table="tentitycategoryassign" entityname="entityCategoryAssign" displayName="Category Assignment" orderby="categoryName" public=true {

    property name="assignmentid" fieldtype="id";
    property name="category" fieldtype="many-to-one" cfc="category" fkcolumn="categoryid";
	property name="parent" fieldtype="many-to-one" cfc="category" fkcolumn="parentid" persistent=false;
	property name="kids" fieldtype="one-to-many" cfc="category" fkcolumn="categoryid" loadkey="parentid" nested=true orderby="name asc";
    property name="site" fieldtype="many-to-one" cfc="site" fkcolumn="siteid";
    property name="entityid" fieldtype="index" datatype="varchar" length=35 required=true;
    property name="entitytype" datatype="varchar" length=100 required=true;
    property name="categoryName" datatype="varchar" length=250 persistent=false default="";
	property name="parentName" datatype="varchar" length=250 persistent=false default="";
	property name="filename" datatype="varchar" length=250 persistent=false default="";
    property name="path" datatype="varchar" length=250 persistent=false default="";
    
    function getLoadSQLColumnsAndTables(){
        return "tentitycategoryassign.*,category.name as categoryName, parentCategory.name as parentName,
            category.parentid, category.filename, category.path
            FROM tentitycategoryassign
            INNER JOIN tcontentcategories category on (tentitycategoryassign.categoryid=category.categoryid)
            LEFT JOIN tcontentcategories parentCategory on (category.parentid=parentCategory.categoryid)";
    }

    function getKidsIterator(){
        return getBean('category').getFeed().where().prop('parentid').isEQ(get('parentid')).getIterator();
    }

    function getKids(){
        return getKidsIterator();
    }

    function getKidQuery(){
        return getKidsIterator().getQuery();
    }
 
}
  