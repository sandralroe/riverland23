/* license goes here */
component extends="controller" output="false" {

	public function setTrashManager(trashManager) output=false {
		variables.trashManager=arguments.trashManager;
	}

	public function before(rc) output=false {
		if ( 
			not getCurrentUser().isAdminUser()
		) {
			secure(arguments.rc);
		}
		param default=1 name="arguments.rc.pageNum";
		param default=session.siteID name="arguments.rc.siteID";
		param default="" name="arguments.rc.keywords";
	}

	public function list(rc) output=false {
		param name='rc.sinceDate' default="#LSdateFormat(dateAdd('d', -7, now()), session.dateKeyFormat)#";
		param name='rc.beforeDate' default="#LSdateFormat(now(), session.dateKeyFormat)#";
		arguments.rc.trashIterator=variables.trashManager.getIterator(argumentCollection=arguments.rc);
		arguments.rc.trashIterator.setNextN(20);
	}

	public function empty(rc) output=false {
		variables.trashManager.empty(argumentCollection=arguments.rc);
		variables.fw.redirect(action="cTrash.list",append="siteID",path="./");
	}

	public function detail(rc) output=false {
		arguments.rc.trashItem=variables.trashManager.getTrashItem(arguments.rc.objectID);
	}

	public function restore(rc) output=false {
		var obj="";
		var it="";
		var objectID="";
		if ( structKeyExists(arguments.rc,"deleteid") ) {
			it=variables.trashManager.getIterator(deleteID=arguments.rc.deleteID);
			while ( it.hasNext() ) {
				obj=it.next();
				objectID=obj.getObjectID();
				obj=obj.getObject();
				if(!isSimpleValue(obj)){
					if ( structKeyExists(arguments.rc,"parentid")
					and len(arguments.rc.parentid) == 35
					and arguments.rc.parentID == objectID ) {
						obj.setParentID(obj.getparentid());
					}
					obj.setTopOrBottom("bottom").save();
				}
			}
		} else {
			obj=variables.trashManager.getTrashItem(arguments.rc.objectID).getObject();
			if ( structKeyExists(arguments.rc,"parentid") && len(arguments.rc.parentid) == 35 ) {
				obj.setParentID(arguments.rc.parentid);
			}
			obj.save();
		}
		arguments.restoreID=arguments.rc.objectID;
		variables.fw.redirect(action="cTrash.list",append="restoreID,siteID,keywords,pageNum",path="./");
	}

}
