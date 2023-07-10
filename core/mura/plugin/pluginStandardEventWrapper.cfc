/* license goes here */
/**
 * This provides functionality to parse runtime context and provide it to the executing event handler method
 */
component extends="mura.baseobject" output="false" hint="This provides functionality to parse runtime context and provide it to the executing event handler method" {
	variables.eventHandler="";
	variables.eventName="";
	variables.objectName="";

	public function init(eventHandler, eventName) output=false {
		variables.eventHandler=arguments.eventHandler;
		variables.eventName=arguments.eventName;
		variables.objectName=getMetaData(variables.eventHandler).name;
		variables.utility=getBean('utility');
		return this;
	}

	public function splitContexts(context) output=false {
		var contexts=structNew();
		if ( listLast(getMetaData(arguments.context).name, '.') == "MuraScope" ) {
			contexts.muraScope=arguments.context;
			contexts.event=arguments.context.event();
		} else {
			contexts.muraScope=arguments.context.getValue("muraScope");
			contexts.event=arguments.context;
		}
		return contexts;
	}

	public function handle(context) output=false {
		var contexts=splitContexts(arguments.context);
		var tracePoint=0;
		var handler="";

		if ( structKeyExists(variables.eventHandler,variables.eventName) ) {
			tracePoint=initTracePoint("#variables.objectName#.#variables.eventName#");

			var args={
					event=contexts.event,
					mura=contexts.muraScope,
					m=contexts.muraScope,
					$=contexts.muraScope
				};

			variables.utility.invokeMethod(component=variables.eventHandler,methodName=variables.eventName,args=args);
		} else {
			tracePoint=initTracePoint("#variables.objectName#.handle");
			variables.eventHandler.handle(event=contexts.event, mura=contexts.muraScope, $=contexts.muraScope);
		}
		commitTracePoint(tracePoint);
		request.muraHandledEvents["#variables.eventName#"]=true;
	}

	public function validate(context) output=false {
		var contexts=splitContexts(arguments.context);
		var verdict="";
		var tracePoint=0;
		if ( structKeyExists(variables.eventHandler,variables.eventName) ) {
			var args={
					event=contexts.event,
					mura=contexts.muraScope,
					m=contexts.muraScope,
					$=contexts.muraScope
				};

			verdict=variables.utility.invokeMethod(component=variables.eventHandler,methodName=variables.eventName,args=args);

		} else {
			tracePoint=initTracePoint("#variables.objectName#.validate");
			verdict=variables.eventHandler.validate(event=contexts.event, mura=contexts.muraScope, $=contexts.muraScope);
		}
		commitTracePoint(tracePoint);
		request.muraHandledEvents["#variables.eventName#"]=true;
		if ( isdefined("verdict") ) {
			return verdict;
		}
	}

	public function translate(context) output=false {
		var contexts=splitContexts(arguments.context);
		var tracePoint=0;
		if ( structKeyExists(variables.eventHandler,variables.eventName) ) {
			tracePoint=initTracePoint("#variables.objectName#.#variables.eventName#");

			var args={
					event=contexts.event,
					mura=contexts.muraScope,
					m=contexts.muraScope,
					$=contexts.muraScope
				};

			variables.utility.invokeMethod(component=variables.eventHandler,methodName=variables.eventName,args=args);
		} else {
			tracePoint=initTracePoint("#variables.objectName#.translate");
			variables.eventHandler.translate(event=contexts.event, mura=contexts.muraScope, $=contexts.muraScope, m=contexts.muraScope);
		}
		commitTracePoint(tracePoint);
		request.muraHandledEvents["#variables.eventName#"]=true;
	}

}
