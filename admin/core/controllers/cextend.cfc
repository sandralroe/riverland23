/* license goes here */
component extends="controller" output="false" {

	public function before(rc) output=false {
		if ( 
			not getCurrentUser().isAdminUser()
		 ) {
			secure(arguments.rc);
		}
		application.classExtensionManager=variables.configBean.getClassExtensionManager();
		param default="" name="arguments.rc.subTypeID";
		param default="" name="arguments.rc.extendSetID";
		param default="" name="arguments.rc.attibuteID";
		param default="" name="arguments.rc.siteID";
		param default=0 name="arguments.rc.hasAvailableSubTypes";
	}

	public function exportsubtype(rc) output=false {
		param default="list" name="arguments.rc.action";
		if ( arguments.rc.action == 'export' ) {
			variables.fw.redirect(action="cExtend.export",append="siteid",path="./");
		}
		arguments.rc.subtypes = application.classExtensionManager.getSubTypes(arguments.rc.siteID,false);
	}

	public function importsubtypes(rc) output=false {
		var file = "";
		var fileContent = "";
		var fileManager=getBean("fileManager");
		param default="" name="arguments.rc.action";
		if ( arguments.rc.action == 'import' && arguments.rc.$.validateCSRFTokens(context='import') ) {
			if ( structKeyExists(arguments.rc,"newfile") && len(arguments.rc.newfile) ) {
				file = fileManager.upload( "newFile" );
				fileContent=fileRead("#file.serverdirectory#/#file.serverfile#");
				application.classExtensionManager.loadConfigXML( xmlParse(filecontent) ,arguments.rc.siteid);
				variables.fw.redirect(action="cExtend.listSubTypes",append="siteid",path="./");
			}
		}
	}

	public function export(rc) output=false {
		param default="" name="arguments.rc.exportClassExtensionID";
		extendArray = [];
		arguments.rc.exportXML = "";
		if ( Len(arguments.rc.exportClassExtensionID) ) {
			extendArray = ListToArray( arguments.rc.exportClassExtensionID );
			arguments.rc.exportXML = application.classExtensionManager.getSubTypesAsXML(extendArray, false);
		}
	}

	public function download(rc) output=false {
		param default="" name="arguments.rc.exportClassExtensionID";
		extendArray = [];
		arguments.rc.exportXML = "";
		if ( Len(arguments.rc.exportClassExtensionID) ) {
			extendArray = ListToArray( arguments.rc.exportClassExtensionID );
			arguments.rc.exportXML = application.classExtensionManager.getSubTypesAsXML(extendArray, false);
		}
	}

	public function updateSubType(rc) output=false {
		if ( !arguments.rc.hasAvailableSubTypes ) {
			arguments.rc.availableSubTypes="";
		}
		arguments.rc.subtypeBean=application.classExtensionManager.getSubTypeByID(arguments.rc.subTypeID);
		arguments.rc.subtypeBean.set(arguments.rc);
		if ( arguments.rc.$.validateCSRFTokens(context=arguments.rc.subtypeid) ) {
			if ( arguments.rc.action == 'Update' ) {
				arguments.rc.subtypeBean.save();
			}
			if ( arguments.rc.action == 'Delete' ) {
				arguments.rc.subtypeBean.delete();
			}
			if ( arguments.rc.action == 'Add' ) {
				arguments.rc.subtypeBean.save();
			}
		}
		if ( arguments.rc.action != 'delete' ) {
			arguments.rc.subTypeID=rc.subtypeBean.getSubTypeID();
			variables.fw.redirect(action="cExtend.listSets",append="subTypeID,siteid",path="./");
		} else {
			variables.fw.redirect(action="cExtend.listSubTypes",append="siteid",path="./");
		}
	}

	public function updateSet(rc) output=false {
		arguments.rc.extendSetBean=application.classExtensionManager.getSubTypeBean().getExtendSetBean();
		arguments.rc.extendSetBean.set(arguments.rc);
		if ( arguments.rc.$.validateCSRFTokens(context=arguments.rc.extendsetid) ) {
			if ( arguments.rc.action == 'Update' ) {
				arguments.rc.extendSetBean.save();
			}
			if ( arguments.rc.action == 'Delete' ) {
				arguments.rc.extendSetBean.delete();
			}
			if ( arguments.rc.action == 'Add' ) {
				arguments.rc.extendSetBean.save();
			}
		}
		if ( arguments.rc.action != 'delete' ) {
			variables.fw.redirect(action="cExtend.editAttributes",append="subTypeId,extendSetID,siteid",path="./");
		} else {
			variables.fw.redirect(action="cExtend.listSets",append="subTypeId,siteid",path="./");
		}
	}

	public function updateRelatedContentSet(rc) output=false {
		arguments.rc.rcsBean = getBean('relatedContentSet').loadBy(relatedContentSetID=arguments.rc.relatedContentSetID);
		if ( !arguments.rc.hasAvailableSubTypes ) {
			arguments.rc.availableSubTypes="";
		}
		arguments.rc.rcsBean.set(arguments.rc);
		if ( arguments.rc.$.validateCSRFTokens(context=arguments.rc.relatedContentSetID) ) {
			if ( listFindNoCase("Update,Add", arguments.rc.action) ) {
				arguments.rc.rcsBean.save();
			}
			if ( arguments.rc.action == 'Delete' ) {
				arguments.rc.rcsBean.delete();
			}
		}
		variables.fw.redirect(action="cExtend.listSets",append="subTypeId,siteid",path="./");
	}

	public function updateAttribute(rc) output=false {
		arguments.rc.attributeBean=application.classExtensionManager.getSubTypeBean().getExtendSetBean().getattributeBean();
		arguments.rc.attributeBean.set(arguments.rc);
		if ( arguments.rc.$.validateCSRFTokens(context=arguments.rc.attributeid) ) {
			if ( arguments.rc.action == 'Update' ) {
				arguments.rc.attributeBean.save();
			}
			if ( arguments.rc.action == 'Delete' ) {
				arguments.rc.attributeBean.delete();
			}
			if ( arguments.rc.action == 'Add' ) {
				arguments.rc.attributeBean.save();
			}
		}
		variables.fw.redirect(action="cExtend.editAttributes",append="subTypeId,extendSetID,siteid",path="./");
	}

	public function saveAttributeSort(rc) output=false {
		application.classExtensionManager.saveAttributeSort(arguments.rc.attributeID);
		abort;
	}

	public function saveExtendSetSort(rc) output=false {
		application.classExtensionManager.saveExtendSetSort(arguments.rc.extendSetID);
		abort;
	}

	public function saveRelatedSetSort(rc) output=false {
		application.classExtensionManager.saveRelatedSetSort(arguments.rc.relatedContentSetID);
		abort;
	}

}
