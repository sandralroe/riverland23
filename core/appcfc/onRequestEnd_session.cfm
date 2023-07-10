<cfscript>
    //https://luceeserver.atlassian.net/browse/LDEV-2396
    try{
        for(prop in session){
            if(!isSimpleValue(session['#prop#'])){
                session['#prop#']=session['#prop#'];
            }
        }
    } catch (any e){}
</cfscript>