/*  License goes here */
component extends="controller" output="false" {

	public function setPluginManager(pluginManager) output=false {
		variables.pluginManager=arguments.pluginManager;
	}

	public function setClusterManager(clusterManager) output=false {
		variables.clusterManager=arguments.clusterManager;
	}

	public function before(rc) output=false {
		param default="false" name="arguments.rc.addsite";

		//This is a patch for when using fw1 plugin framework
		if(!isDefined('variables.settingsManager')){
			variables.settingsManager=getBean('settingsManager');
			variables.permUtility=getBean('permUtility');
			variables.pluginManager=getBean('pluginManager');
			structDelete(application,'muraAdmin');
		}

		if ( !(
				(
					arguments.rc.$.currentUser().isAdminUser()
					and !listFindNoCase('list,editPlugin,deployPlugin,updatePlugin,updatePluginVersion,siteCopy,sitecopyselect,sitecopyresult',listLast(rc.muraAction,"."))
					and arguments.rc.addsite == 'false'
				)
				or arguments.rc.$.currentUser().isSuperUser()
				) ) {
			secure(arguments.rc);
		}
	}

	public function list(rc) output=false {
		param default="" name="arguments.rc.orderID";
		param default="" name="arguments.rc.orderno";
		param default="" name="arguments.rc.deploy";
		param default="" name="arguments.rc.action";
		param default="" name="arguments.rc.siteid";
		param default="site" name="arguments.rc.siteSortBy";

		if ( isdefined("arguments.rc.refresh") ) {
			variables.fw.redirect(action="cSettings.list",path="./");
		}
		if ( rc.$.validateCSRFTokens(context='updatesites') ) {
			variables.settingsManager.saveOrder(arguments.rc.orderno,arguments.rc.orderID);
			variables.settingsManager.saveDeploy(arguments.rc.deploy,arguments.rc.orderID);
		}
		arguments.rc.rsSites=variables.settingsManager.getList(sortBy=arguments.rc.siteSortBy);
		arguments.rc.rsPlugins=variables.pluginManager.getAllPlugins();
	}

	public function editSite(rc) output=false {
		arguments.rc.siteBean=variables.settingsManager.read(arguments.rc.siteid);
		arguments.rc.oauthSettingBean=getBean('oauthSetting').loadBy(siteid=arguments.rc.siteid);
	}

	public function deletePlugin(rc) output=false {
		if ( arguments.rc.$.validateCSRFTokens(context=arguments.rc.moduleid) ) {
			variables.pluginManager.deletePlugin(arguments.rc.moduleID);
		}
		location(url="./?muraAction=cSettings.list&refresh=1##tabPlugins", addtoken="false");
	}

	public function editPlugin(rc) output=false {
		arguments.rc.pluginXML=variables.pluginManager.getPluginXML(arguments.rc.moduleID);
		arguments.rc.rsSites=variables.settingsManager.getList();
	}

	public function updatePluginVersion(rc) output=false {
		arguments.rc.pluginConfig=variables.pluginManager.getConfig(arguments.rc.moduleID);
	}

	public function deployPlugin(rc) output=false {
		var tempID="";
		param default="" name="arguments.rc.moduleID";
		if ( len(arguments.rc.moduleid) && arguments.rc.$.validateCSRFTokens(context=arguments.rc.moduleid)
		or arguments.rc.moduleid == '' && arguments.rc.$.validateCSRFTokens(context='newplugin') ) {
			tempID=variables.pluginManager.deploy(arguments.rc.moduleID);
		}
		if ( isDefined('tempid') && len(tempID) ) {
			arguments.rc.moduleID=tempID;
			variables.fw.redirect(action="cSettings.editPlugin",append="moduleid",path="./");
		} else {
			if ( len(arguments.rc.moduleID) ) {
				variables.fw.redirect(action="cSettings.editPlugin",append="moduleid",path="./");
			} else {

			location(url="./?muraAction=cSettings.list&refresh=1##tabPlugins",addtoken="false");

			}
		}
	}

	public function updatePlugin(rc) output=false {
		if ( arguments.rc.$.validateCSRFTokens(context=arguments.rc.moduleid) ) {
			arguments.rc.moduleID=variables.pluginManager.updateSettings(arguments.rc);
		}
		location(url="./?muraAction=cSettings.list&refresh=1##tabPlugins",addtoken="false");
	}

	public function updateSite(rc) output=false {
		var bean=variables.settingsManager.read(siteid=arguments.rc.siteid);
		var sessionData=arguments.rc.$.getSession();

		if ( bean.getIsNew() && arguments.rc.$.validateCSRFTokens()
		or !bean.getIsNew() && arguments.rc.$.validateCSRFTokens(context=arguments.rc.siteID) ) {
			request.newImageIDList="";
			if ( arguments.rc.action == 'Update' ) {
				//this lock name needs to match the one in /app/core/appcfc/onRequestStart_include.cfm
				lock name="appInitBlock#application.instanceID#" type="exclusive" timeout="600" {
					//application.appInitialized=false;
					bean=variables.settingsManager.update(arguments.rc);
				}
				if ( !structIsEmpty(bean.getErrors()) ) {
					getCurrentUser().setValue("errors",bean.getErrors());
				} else {
					if ( len(request.newImageIDList) ) {
						arguments.rc.fileid=request.newImageIDList;
						variables.fw.redirect(action="cArch.imagedetails",append="siteid,fileid,compactDisplay",path="./");
					}
				}
			}
			if ( arguments.rc.$.currentUser().isSuperUser() && arguments.rc.action == 'Add' ) {

				lock name="appInitBlock#application.instanceID#" type="exclusive" timeout="200" {
					bean=variables.settingsManager.create(arguments.rc);
					//variables.settingsManager.setSites();
				}
				
				sessionData.userFilesPath = "#application.configBean.getAssetPath()#/#rc.siteid#/assets/";
				sessionData.siteid=arguments.rc.siteid;
				if ( !structIsEmpty(bean.getErrors()) ) {
					getCurrentUser().setValue("errors",bean.getErrors());
				} else {
					if ( len(request.newImageIDList) ) {
						arguments.rc.fileid=request.newImageIDList;
						variables.fw.redirect(action="cArch.imagedetails",append="siteid,fileid,compactDisplay",path="./");
					}
				}
			}
			if ( arguments.rc.$.currentUser().isSuperUser() && arguments.rc.action == 'Delete' ) {
				variables.settingsManager.delete(arguments.rc.siteid);
				sessionData.siteid="default";
				sessionData.userFilesPath = "#application.configBean.getAssetPath()#/default/assets/";
				arguments.rc.siteid="default";
			}
		}
		if ( arguments.rc.$.currentUser().isSuperUser() ) {
			variables.fw.redirect(action="cSettings.list",path="./");
		} else {
			variables.fw.redirect(action="cDashboard.main",append="siteid",path="./");
		}
	}

	public function sitecopyselect(rc) output=false {
		arguments.rc.rsSites=variables.settingsManager.getList();
	}

	public function exportHTML(rc) output=false {
		variables.settingsManager.getSite(arguments.rc.siteID).exportHTML();
	}

	public function sitecopy(rc) output=false {
		if ( arguments.rc.$.validateCSRFTokens(context='sitecopy') && arguments.rc.fromSiteID != arguments.rc.toSiteID ) {
			getBean('publisher').copy(fromSiteID=rc.fromSiteID,toSiteID=rc.toSiteID);
		}
		variables.fw.redirect(action="cSettings.sitecopyresult",append="fromSiteID,toSiteID",path="./");
	}

	public function createBundle(rc) output=false {
		param default="" name="arguments.rc.moduleID";
		param default="copy" name="arguments.rc.bundleImportKeyMode";
		param default="" name="arguments.rc.BundleName";
		param default=false name="arguments.rc.includeTrash";
		param default=false name="arguments.rc.includeVersionHistory";
		param default=false name="arguments.rc.includeMetaData";
		param default=false name="arguments.rc.includeMailingListMembers";
		param default=false name="arguments.rc.includeUsers";
		param default=false name="arguments.rc.includeFormData";
		param default=false name="arguments.rc.saveFile";
		param default="" name="arguments.rc.saveFileDir";
		param default="" name="arguments.rc.bundleMode";
		param default=false name="arguments.rc.includeStructuredAssets";

		if ( len(arguments.rc.saveFileDir) ) {
			if ( directoryExists(arguments.rc.saveFileDir) ) {
				arguments.rc.saveFile=true;
			} else {
				arguments.rc.saveFileDir="";
				arguments.rc.saveFile=false;
			}
		}
		arguments.rc.bundleFilePath=application.serviceFactory.getBean("Bundle").Bundle(
			siteID=arguments.rc.siteID,
			moduleID=arguments.rc.moduleID,
			BundleName=arguments.rc.BundleName,
			includeVersionHistory=arguments.rc.includeVersionHistory,
			includeStructuredAssets=arguments.rc.includeStructuredAssets,
			includeTrash=arguments.rc.includeTrash,
			includeMetaData=arguments.rc.includeMetaData,
			includeMailingListMembers=arguments.rc.includeMailingListMembers,
			includeUsers=arguments.rc.includeUsers,
			includeFormData=arguments.rc.includeFormData,
			saveFile=arguments.rc.saveFile,
			saveFileDir=arguments.rc.saveFileDir,
			bundleMode=arguments.rc.bundleMode
			);
	}

	public function selectBundleOptions(rc) output=false {
		arguments.rc.rsplugins=application.serviceFactory.getBean("pluginManager").getSitePlugins(arguments.rc.siteID);
	}

}