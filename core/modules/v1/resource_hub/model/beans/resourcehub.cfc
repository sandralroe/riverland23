component extends="mura.bean.bean"{
    remote function processFilterArgs(){
        var Mura = application.serviceFactory.getBean('$').init();

        var hasMXP=Mura.getServiceFactory().containsBean('marketingManager');

        if (not isDefined('session.mura.mxp')){
            if(hasMXP){
                session.mura.mxp=getBean('marketingManager').getDefaults();
            } else {
                session.mura.mxp={};
            }
        }
        
        param name="session.mura.mxp.trackingProperties.personaid" default='';
        param name="session.mura.mxp.trackingProperties.stageid" default='';
        param name="session.resourceFilter" default={};
        param name="session.resourceFilter.personaid" default=session.mura.mxp.trackingProperties.personaid;
        param name="session.resourceFilter.categoryid" default='';
        param name="session.resourceFilter.subtype" default='';
        param name="session.resourceFilter.hasFilter" default=false;
        param name="session.resourceFilter.selectedcats" default=[];

        param name="form.personaid" default='';
        param name="form.categoryid" default='';
        param name="form.subtype" default='';
        param name="form.selectedcats" default=[];
        param name="form.newfilter" default=false;
        
        session.resourceFilter.hasMXP=hasMXP;

        var isNewFilter=isdefined("form.newfilter") && isBoolean(form.newfilter) && form.newfilter;
        
        //selectedcats
        if(isNewFilter || len(form.selectedcats)){
            form.selectedcats=filterListArgs(form.selectedcats);
            if(!len(form.selectedcats)){
                if (isNewFilter){
                    session.resourceFilter.selectedcats=[];
                }else{
                    // session.resourceFilter.selectedcats=session.resourceFilter.selectedcats;
                    session.resourceFilter.hasFilter=true;
                }
            } else {
                session.resourceFilter.selectedcats=urldecode(form.selectedcats);
                session.resourceFilter.hasFilter=true;
            }    
        } else {
            // session.resourceFilter.selectedcats=session.resourceFilter.selectedcats;//
            session.resourceFilter.hasFilter=true;
        }

        //personas
        if(isNewFilter || len(form.personaid)){
            form.personaid=filterListArgs(form.personaid);
            if(!len(form.personaid)){
                if (isNewFilter){
                    session.resourceFilter.personaid='';
                }else{
                    // session.resourceFilter.personaid=session.resourceFilter.personaid;
                    session.resourceFilter.hasFilter=true;
                }
            } else {
                session.resourceFilter.personaid=form.personaid;
                session.resourceFilter.hasFilter=true;
            }
        } else {
            // session.resourceFilter.personaid=session.resourceFilter.personaid;//
            session.resourceFilter.hasFilter=true;
        }
        //categories

        if(isNewFilter || len(form.categoryid)){
            form.categoryid=filterListArgs(form.categoryid);
            if(!len(form.categoryid)){
                if (isNewFilter){
                    session.resourceFilter.categoryid='';
                }else{
                    // session.resourceFilter.categoryid=session.resourceFilter.categoryid;
                    session.resourceFilter.hasFilter=true;
                }
            } else {
                session.resourceFilter.categoryid=form.categoryid;
                session.resourceFilter.hasFilter=true;
            }
        } else {
            // session.resourceFilter.categoryid=session.resourceFilter.categoryid;//
            session.resourceFilter.hasFilter=true;
        }
        //subtypes
        if(isNewFilter || len(form.subtype)){
            form.subtype=filterListArgs(form.subtype);
            if(!Len(form.subtype)){
                if (isNewFilter){
                    session.resourceFilter.subtype='';
                }else{
                    // session.resourceFilter.subtype=session.resourceFilter.subtype;
                    session.resourceFilter.hasFilter=true;
                }
            } else {
                session.resourceFilter.subtype=form.subtype;
                session.resourceFilter.hasFilter=true;
            }
        } else {
            // session.resourceFilter.subtype=session.resourceFilter.subtype;//
            session.resourceFilter.hasFilter=true;
        }
        if (isJSON(session.resourceFilter.selectedcats)){
            session.resourceFilter.selectedcats = deserializeJSON(session.resourceFilter.selectedcats);
        }
        return session.resourceFilter;
    }


    function filterListArgs(list){
        var candidates=listToArray(list);
        var graduates=[];
        for(var candidate in candidates){
            if(!listFindNoCase('all,*,undefined,[]',candidate)){
                arrayAppend(graduates,candidate);
            }
        }

        return arrayToList(graduates);
    }
}