component extends="mura.bean.bean"{

    remote function getPersonas(siteid) {
        var Mura = application.serviceFactory.getBean('Mura').init(arguments.siteid);

        var personaids = {};
        var personas=Mura.getFeed('persona').where().prop('selfidq').isNEQ('null').getQuery();
        
        return personas;
    }

    remote function getStages(siteid){
        var Mura = application.serviceFactory.getBean('Mura').init(arguments.siteid);

        var stageids='';
        var stages=Mura.getFeed('stage').where().prop('selfidq').isNEQ('null').getQuery();

        return stages;
    }

    remote function getDynamicProps(siteid){
        var Mura = application.serviceFactory.getBean('Mura').init(arguments.siteid);
        
        Mura.setCustomMuraScopeKey('mxp',new MXP.lib.core.utility.muraScopeUtility(Mura));
        
        return {
            stages=getStages(),
            personas=getPersonas(),
            currentstageid=Mura.MXP.getTrackingProperty('stageid'),
            currentpersonaid=Mura.MXP.getTrackingProperty('personaid'),
            ispreview=(isDefined('session.mura.mxp.preview') and session.mura.mxp.preview)
        };
    }

    remote function previewExperience(siteid){
        var Mura = application.serviceFactory.getBean('Mura').init(arguments.siteid);

        url.mxp_preview=true;
        url.personaid=Mura.event('personaid');
        url.stageid=Mura.event('stageid');
      
        Mura.setCustomMuraScopeKey('mxp',new MXP.lib.core.utility.muraScopeUtility(Mura));

        Mura.announceEvent('onMXPSiteRequestStart');

        return true;
    }

    remote function clearExperience(siteid){
        var Mura = application.serviceFactory.getBean('Mura').init(arguments.siteid);

        url.mxp_clear=true;

        Mura.setCustomMuraScopeKey('mxp',new MXP.lib.core.utility.muraScopeUtility(Mura));

        Mura.announceEvent('onMXPSiteRequestStart');

        return true;

    }

    remote function saveExperience(siteid,personaid,stageid){
       return  updateExperience(argumentCollection=arguments);
    }

    //todo: work on / test updateExperience
    remote function updateExperience(siteid,personaid,stageid){
        var Mura = application.serviceFactory.getBean('Mura').init(siteid);

        Mura.setCustomMuraScopeKey('mxp',new MXP.lib.core.utility.muraScopeUtility(Mura));

        stageOrderArray=getBean('marketingManager').getStageOrderArray(Mura.event('siteid'));
        selected = {};
        selected.stageSelected=false;
        selected.personaSelected=false;

        if(isDefined('arguments.personaid')){
            personaCheck=Mura.getBean('persona').loadBy(personaid=arguments.personaid);
            if(personaCheck.exists()){
                Mura.mxp.setTrackingProperty(property='personaid',propertyValue=arguments.personaid,resetExp=false);
                selected.personaSelected=true;
            }
        }

        if(isDefined('arguments.stageid')){
            stageCheck=Mura.getBean('stage').loadBy(stageid=arguments.stageid);
            if(stageCheck.exists()){
                Mura.mxp.setTrackingProperty(property='stageid',propertyValue=arguments.stageid,resetExp=false);
                selected.stageSelected=true;
            } else if(arrayLen(stageOrderArray)) {
                Mura.mxp.setTrackingProperty(property='stageid',propertyValue=stageOrderArray[1],resetExp=false);
                selected.stageSelected=true;
            }
        } else if(arrayLen(stageOrderArray)) {
            if(!len(Mura.mxp.getTrackingProperty('stageid')) || !Mura.getBean('stage').loadBy(stageid=Mura.mxp.getTrackingProperty('stageid')).exists() ){
                Mura.mxp.setTrackingProperty(property='stageid',propertyValue=stageOrderArray[1],resetExp=false);
                selected.stageSelected=true;
            }
        }

        if(selected.stageSelected || selected.personaSelected){
            sessionData.mura.mxp.preview=false;
            logText('MXP: Persona/Stage update from Matrix Selection');
            commitTracepoint(initTracePoint("MXP: Persona/Stage update from Matrix Selection"));
            Mura.announceEvent('mxpLocalPersonaUpdate');
            getBean('marketingManager').resetCurrentUser($=Mura);
        }

        return selected;

    }
}