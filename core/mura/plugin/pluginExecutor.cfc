/* license goes here */
/**
 * This provides a thread safe context to execute plugin cfm base event handling
 */
component extends="mura.baseobject" output="false" hint="This provides a thread safe context to execute plugin cfm base event handling" {
	variables.configBean="";
	variables.settingsManager="";
	variables.pluginManager="";

	public function init(configBean, settingsManager, pluginManager) output=false {
		variables.configBean=arguments.configBean;
		variables.settingsManager=arguments.settingsManager;
		variables.pluginManager=arguments.pluginManager;
		return this;
	}

	public function displayObject(objectID, event, rsDisplayObject, $, mura, m) output=true {
		var rs="";
		var str="";
		var pluginConfig="";
		var tracePoint=0;
		request.pluginConfig=variables.pluginManager.getConfig(arguments.rsDisplayObject.pluginID);
		request.pluginConfig.setSetting("pluginMode","object");
		request.scriptEvent=arguments.event;
		pluginConfig=request.pluginConfig;
		if ( arguments.rsDisplayObject.location == "global" ) {
			pluginConfig.setSetting("pluginPath","#variables.configBean.getContext()#/plugins/#pluginConfig.getDirectory()#/");
			tracePoint=initTracePoint("/plugins/#pluginConfig.getDirectory()#/#arguments.rsDisplayObject.displayObjectFile#");
			savecontent variable="str" {
				include "/plugins/#pluginConfig.getDirectory()#/#arguments.rsDisplayObject.displayObjectFile#";
			}
			commitTracePoint(tracePoint);
		} else {
			pluginConfig.setSetting("pluginPath","#variables.configBean.getContext()#/#variables.settingsManager.getSite(event.getValue('siteID')).getDisplayPoolID()#/includes/plugins/#pluginConfig.getDirectory()#/");
			tracePoint=initTracePoint("/#variables.configBean.getWebRootMap()#/#variables.settingsManager.getSite(event.getValue('siteID')).getDisplayPoolID()#/includes/plugins/#pluginConfig.getDirectory()#/#arguments.rsDisplayObject.displayObjectFile#");
			savecontent variable="str" {
				include "/#variables.configBean.getWebRootMap()#/#variables.settingsManager.getSite(event.getValue('siteID')).getDisplayPoolID()#/includes/plugins/#pluginConfig.getDirectory()#/#arguments.rsDisplayObject.displayObjectFile#";
			}
			commitTracePoint(tracePoint);
		}
		structDelete(request,"pluginConfig");
		structDelete(request,"scriptEvent");
		return trim(str);
	}

	public function executeScript(required any event="", required any scriptFile="", required any pluginConfig="", $, mura, m) output=false {
		var scriptEvent=arguments.event;
		var tracePoint=0;
		request.pluginConfig=arguments.pluginConfig;
		request.scriptEvent=arguments.event;
		tracePoint=initTracePoint(arguments.scriptFile);
		include arguments.scriptFile;
		commitTracePoint(tracePoint);
		structDelete(request,"pluginConfig");
		structDelete(request,"scriptEvent");
		return event;
	}

	public function renderScript(required any event="", required any scriptFile="", required any pluginConfig="", $, mura, m) output=true {
		var rs="";
		var str="";
		var tracePoint=0;
		var attributes=structNew();
		request.pluginConfig=arguments.pluginConfig;
		request.pluginConfig.setSetting("pluginMode","object");
		request.scriptEvent=arguments.event;
		pluginConfig.setSetting("pluginPath","#variables.configBean.getContext()#/plugins/#pluginConfig.getDirectory()#/");
		attributes=arguments.event.getAllValues();
		tracePoint=initTracePoint(arguments.scriptFile);
		savecontent variable="str" {
			include arguments.scriptFile;
		}
		commitTracePoint(tracePoint);
		structDelete(request,"pluginConfig");
		structDelete(request,"scriptEvent");
		return trim(str);
	}

}
