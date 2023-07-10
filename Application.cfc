/* License goes here */
component output="false" {

	include "core/appcfc/applicationSettings.cfm";


	if(not hasPluginMappings){
		//Try and include plugin mappings
		canWriteMode=true;
		hasMappings=true;
		canWriteMappings=true;
		try{
			include "plugins/mappings.cfm";
		}
		catch(any e){
			if(e.type eq 'missingInclude'){
				hasMappings=false;
			}
		}

		if(not hasMappings){
			variables.tracePoint=initTracePoint("Writing plugin/mappings.cfm");
			include "core/appcfc/buildPluginMappings.cfm";
			commitTracePoint(variables.tracePoint);
		}

	}

	if(not hasPluginCFApplication){
		//Try and include plugin mappings
		canWriteMode=true;
		hasMappings=true;
		canWriteMappings=true;
		try{
			include "plugins/cfapplication.cfm";
		}
		catch(any e){
			if(e.type eq 'missingInclude'){
				hasMappings=false;
			}
		}

		if(not hasMappings){
			variables.tracePoint=initTracePoint("Writing config/cfapplication.cfm");
			include "core/appcfc/buildPluginCFApplication.cfm";
			commitTracePoint(variables.tracePoint);
		}

	}

	include "core/appcfc/onApplicationStart_method.cfm";
	include "core/appcfc/onRequestStart_scriptProtect_method.cfm";
	include "core/appcfc/onRequestEnd_method.cfm";
	include "core/appcfc/onSessionStart_method.cfm";
	include "core/appcfc/onSessionEnd_method.cfm";
	include "core/appcfc/onError_method.cfm";
	include "core/appcfc/onMissingTemplate_method.cfm";
}
