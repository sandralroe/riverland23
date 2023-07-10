<cfscript>
    function logError(e){
        cflog(type="Error", log="exception", exception=arguments.e);
    }
</cfscript>