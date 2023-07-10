<cfsetting requesttimeout=300>
<cfscript>
/* license goes here */
//  Give Mura 5 minutes for setup script to run to prevent it timing out when server configuration request timeout is too small

/* --------------------------------------------------------------------
  RenderSetup is checked here to prove we got here for a legitimate
  reason and we aren't accessing these files directly (and illegally).
  If renderSetup is not found or is false then do not render.


  /core/appcfc/onRequestStart_include.cfm
---------------------------------------------------------------------*/
if ( !structKeyExists( request, 'renderMuraSetup' ) || !request.renderMuraSetup ) {
	abort;
}

if ( isDefined('url.checkmappings') ){
  if(!fileExists(variables.baseDir & "/plugins/mappings.cfm")){
    include "./../appcfc/buildPluginMappings.cfm";
    writeOutput("mappings created.");
  } else {
    writeOutput("mappings already existed.");
  }
  abort;
}

if ( isDefined('url.prewarm') ){
  include "./prewarming/wrapper.cfm";
}

/* --------------------------------------------------------------------
  - Read values from existing settings.ini.cfm file.
  - Param some form values.
---------------------------------------------------------------------*/
include "inc/_defaults.cfm";
/* --------------------------------------------------------------------
  If the setup form was submitted, go ahead and try to process it
---------------------------------------------------------------------*/
if ( form.action == 'doSetup' ) {
	include "inc/_udf.cfm";
	include "inc/_process.cfm";
}
/* --------------------------------------------------------------------
  If we were able to process the setup form
  - Tell mura to refresh on next hit
  - Show a happy congrats screen
---------------------------------------------------------------------*/
if ( variables.setupProcessComplete ) {
	application.appAutoUpdated = true;
	include "inc/_wrapperStart.cfm";
	include "inc/_done.cfm";
	include "inc/_wrapperEnd.cfm";
	abort;

}
/* --------------------------------------------------------------------
  if we made it this far, they aren't setup and need to
  see the setup form.
---------------------------------------------------------------------*/
include "inc/_wrapperStart.cfm";
include "inc/_form.cfm";
include "inc/_wrapperEnd.cfm";
</cfscript>
