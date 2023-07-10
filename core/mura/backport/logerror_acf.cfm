<cfscript>
    function logError(e){
        writeLog(type="Error", log="exception", text="#serializeJSON(arguments.e)#");
    }
</cfscript>