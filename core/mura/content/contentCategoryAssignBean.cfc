/* license goes here */
component extends="mura.bean.beanORM" table="tcontentcategoryassign" entityname="contentCategoryAssign" bundleable=false hint="This provides content category assignment functionality"{

    property name="content" fieldtype="many-to-one" cfc="content" fkcolumn="contenthistid" loadkey="contenthistid";
    property name="activeContent" fieldtype="many-to-one" cfc="content" fkcolumn="contentid" loadkey="contentid";
    property name="category" fieldtype="many-to-one" cfc="category" fkcolumn="categoryid";
	property name="parent" fieldtype="many-to-one" cfc="category" fkcolumn="parentid" persistent=false;
	property name="kids" fieldtype="one-to-many" cfc="category" fkcolumn="categoryid" loadkey="parentid" nested=true orderby="name asc";
    property name="site" fieldtype="many-to-one" cfc="site" fkcolumn="siteid";
    property name="isfeature" datatype="int" default=0;
    property name="featureStart" datatype="datetime";
    property name="featureSop" datatype="datetime";
	property name="categoryName" datatype="varchar" length=250 persistent=false default="";
	property name="parentName" datatype="varchar" length=250 persistent=false default="";
	property name="filename" datatype="varchar" length=250 persistent=false default="";
	property name="path" datatype="varchar" length=250 persistent=false default="";

	function getLoadSQLColumnsAndTables(){
		return "tcontentcategoryassign.*,category.name as categoryName, parentCategory.name as parentName,
			category.parentid, category.filename, category.path
			FROM tcontentcategoryassign
			INNER JOIN tcontentcategories category on (tcontentcategoryassign.categoryid=category.categoryid)
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
