<!--- License goes here --->
<cfcomponent extends="mura.baseobject" hint="This provides ability to hold a cookie based session to a remote website">

<cfset variables.httpSession=structNew()>
<cfset variables.host="">
<cfset variables.port="">
<cfset variables.timeout="5">
<cfset variables.protocal="http">
<cfset variables.configBean="">
<cfset variables.referer="">
<cfset variables.resolveurl="Yes">
<cfset variables.charset="UTF-8">
<cfset variables.throwOnError="yes">
<cfset variables.userAgent=CGI.http_user_agent>

<cffunction name="setConfigBean" output="false">
	<cfargument name="configBean">
	<cfset variables.configBean=arguments.configBean>
	<cfreturn this />
</cffunction>

<cffunction name="setHost" output="false">
	<cfargument name="Host">
	<cfset variables.host=arguments.Host>
	<cfreturn this>
</cffunction>

<cffunction name="getHost" output="false">
	<cfreturn variables.host>
</cffunction>

<cffunction name="setReferer" output="false">
	<cfargument name="referer">
	<cfset variables.referer=arguments.referer>
	<cfreturn this>
</cffunction>

<cffunction name="getReferer" output="false">
	<cfreturn variables.referer>
</cffunction>

<cffunction name="setUserAgent" output="false">
	<cfargument name="userAgent">
	<cfset variables.userAgent=arguments.userAgent>
	<cfreturn this>
</cffunction>

<cffunction name="getUserAgent" output="false">
	<cfreturn variables.userAgent>
</cffunction>

<cffunction name="setThrowOnError" output="false">
	<cfargument name="throwOnError">
	<cfset variables.throwOnError=arguments.throwOnError>
	<cfreturn this>
</cffunction>

<cffunction name="getThrowOnError" output="false">
	<cfreturn variables.throwOnError>
</cffunction>

<cffunction name="setCharSet" output="false">
	<cfargument name="charSet">
	<cfset variables.charSet=arguments.charSet>
	<cfreturn this>
</cffunction>

<cffunction name="getCharSet" output="false">
	<cfreturn variables.charSet>
</cffunction>

<cffunction name="getResolveurl" output="false">
	<cfreturn variables.resolveurl>
</cffunction>

<cffunction name="setResolveurl" output="false">
	<cfargument name="resolveurl">
	<cfset variables.resolveurl=arguments.resolveurl>
	<cfreturn this>
</cffunction>

<cffunction name="setTimeout" output="false">
	<cfargument name="timeout">
	<cfset variables.timeout=arguments.timeout>
	<cfreturn this>
</cffunction>

<cffunction name="getTimeout" output="false">
	<cfreturn variables.timeout>
</cffunction>

<cffunction name="setPort" output="false">
	<cfargument name="port">
	<cfset variables.port=arguments.port>
	<cfreturn this>
</cffunction>

<cffunction name="getPort" output="false">
	<cfreturn variables.port>
</cffunction>

<cffunction name="setProtocal" output="false">
	<cfargument name="protocal">
	<cfset variables.protocal=arguments.protocal>
	<cfreturn this>
</cffunction>

<cffunction name="getProtocal" output="false">
	<cfreturn variables.protocal>
</cffunction>

<cffunction name="getBaseURL" output="false">
	<cfset var str="">

	<cfset str=getProtocal() & "://" & getHost()>

	<cfif len(getPort())>
		<cfset str=str & ":" & getPort()>
	</cfif>

	<cfreturn str>
</cffunction>

<cffunction
	name="GetResponseCookies"
	access="public"
	returntype="struct"
	output="false"
	hint="This parses the response of a CFHttp call and puts the cookies into a struct.">
	<cfargument
		name="Response"
		type="struct"
		required="true"
		hint="The response of a CFHttp call."
		/>

	<cfset var LOCAL = StructNew() />

	<cfset LOCAL.Cookies = StructNew() />

	<cfif NOT StructKeyExists(
		ARGUMENTS.Response.ResponseHeader,
		"Set-Cookie"
		)>

		<cfreturn LOCAL.Cookies />

	</cfif>

	<cfset LOCAL.ReturnedCookies = ARGUMENTS.Response.ResponseHeader[ "Set-Cookie" ] />

	<cfif not isStruct(LOCAL.ReturnedCookies) and not isArray(LOCAL.ReturnedCookies)>
		<cfset local.temp=structNew()>
		<cfset local.temp["1"]=LOCAL.ReturnedCookies>
		<cfset LOCAL.ReturnedCookies=duplicate(local.temp)>
	<cfelseif isArray(LOCAL.ReturnedCookies)>
		<cfset LOCAL.temp = structNew()>
		<cfloop from="1" to="#arrayLen(LOCAL.ReturnedCookies)#" index="LOCAL.CookieIndex">
			<cfset local.temp["#LOCAL.CookieIndex#"]=LOCAL.ReturnedCookies[LOCAL.CookieIndex]>
		</cfloop>
		<cfset LOCAL.ReturnedCookies=duplicate(local.temp)>
	</cfif>

	<cfloop
		item="LOCAL.CookieIndex"
		collection="#LOCAL.ReturnedCookies#">

		<cfset LOCAL.CookieString = URLDecode(LOCAL.ReturnedCookies[ LOCAL.CookieIndex ]) />

		<cfloop
			index="LOCAL.Index"
			from="1"
			to="#ListLen( LOCAL.CookieString, ';' )#"
			step="1">

			<cfset LOCAL.Pair = ListGetAt(
				LOCAL.CookieString,
				LOCAL.Index,
				";"
				) />

			<cfset LOCAL.Name = ListFirst( LOCAL.Pair, "=" ) />

			<cfif (ListLen( LOCAL.Pair, "=" ) GT 1)>
				<cfset LOCAL.Value = ListRest( LOCAL.Pair, "=" ) />
			<cfelse>
				<cfset LOCAL.Value = "" />
			</cfif>

			<cfif (LOCAL.Index EQ 1)>
				<cfset LOCAL.Cookies[ LOCAL.Name ] = StructNew() />
				<cfset LOCAL.Cookie = LOCAL.Cookies[ LOCAL.Name ] />
				<cfset LOCAL.Cookie.Value = LOCAL.Value />
				<cfset LOCAL.Cookie.Attributes = StructNew() />

			<cfelse>

				<cfset LOCAL.Cookie.Attributes[ LOCAL.Name ] = LOCAL.Value />

			</cfif>

		</cfloop>


	</cfloop>


	<!--- Return the cookies. --->
	<cfreturn LOCAL.Cookies />
</cffunction>

<cffunction name="get" output="true">
	<cfargument name="url" default="/">
	<cfargument name="data" default="#structNew()#">
	<cfargument name="referer" default="">

	<cfset arguments.paramType="url">
	<cfset arguments.httpMethod="get">

	<cfif not len(arguments.referer)>
		<cfset arguments.referer=getReferer()>
	</cfif>

	<cfif len(variables.configBean.getProxyServer())>
		<cfreturn callWithProxyServer(argumentCollection=arguments)>
	<cfelse>
		<cfreturn callWithOutProxyServer(argumentCollection=arguments)>
	</cfif>

</cffunction>

<cffunction name="post" output="true">
	<cfargument name="url" default="/">
	<cfargument name="data" default="#structNew()#">
	<cfargument name="referer" default="">

	<cfset arguments.paramType="formField">
	<cfset arguments.httpMethod="post">

	<cfif not len(arguments.referer)>
		<cfset arguments.referer=getReferer()>
	</cfif>

	<cfif len(variables.configBean.getProxyServer())>
		<cfreturn callWithProxyServer(argumentCollection=arguments)>
	<cfelse>
		<cfreturn callWithOutProxyServer(argumentCollection=arguments)>
	</cfif>

</cffunction>

<cffunction name="callWithOutProxyServer" output="false" access="private">
	<cfargument name="url">
	<cfargument name="data">
	<cfargument name="httpMethod">
	<cfargument name="paramType">
	<cfargument name="referer">

	<cfset var key="">
	<cfset var objGet ="">
	<cfset var response ="">
	<cfset var strCookie ="">
	<cfset var tempValue ="">
	<cfset var tempNew=structNew()>

	<cfhttp attributeCollection='#getHTTPAttrs(
				method="#arguments.httpMethod#",
				url="#getBaseURL()##arguments.url#",
				useragent="#getUserAgent()#",
				result="objGet",
				resolveurl="#getResolveURL()#",
				timeout="#getTimeout()#",
				throwOnError="#getThrowOnError()#",
				charset="#getCharSet()#")#'>

	<cfif len(arguments.referer)>
		<cfhttpparam
		type="HEADER"
		name="referer"
		value="#arguments.referer#"
		/>
	</cfif>

	<!--- Loop over the cookies we found. --->
	<cfloop
		item="strCookie"
		collection="#variables.httpSession#">

		<!--- Send the cookie value with this request. --->
		<cfhttpparam
			type="COOKIE"
			name="#strCookie#"
			value="#variables.httpSession[ strCookie ].Value#"
			/>

	</cfloop>

	<cfif not structIsEmpty(arguments.data)>
	<cfloop
		item="key"
		collection="#arguments.data#">
 		<cfif isSimpleValue(arguments.data[ key ])>
		<!--- Send the cookie value with this request. --->
		<cfhttpparam
			type="#arguments.paramType#"
			name="#key#"
			value="#arguments.data[ key ]#"
			/>
		<cfelse>
			<cfwddx action="cfml2wddx" input="#arguments.data[ key ]#" output="tempValue">
			<cfhttpparam
			type="#arguments.paramType#"
			name="#key#"
			value="#tempValue#"
			/>
		</cfif>

	</cfloop>
	</cfif>

	</cfhttp>

	<cfset tempNew=GetResponseCookies( objGet )>

	<cfset structAppend(variables.httpSession,tempNew,"true")>

	<cfif isJSON(objGet.fileContent)>
		<cfset response=deserializeJSON(objGet.fileContent)>
	<cfelseif isWDDX(objGet.fileContent)>
		<cfwddx action="wddx2cfml" input="#objGet.fileContent#" output="response">
	<cfelse>
		<cfset response=objGet.fileContent>
	</cfif>

	<cfreturn response>

</cffunction>

<cffunction name="callWithProxyServer" output="false" access="private">
	<cfargument name="url">
	<cfargument name="data">
	<cfargument name="httpMethod">
	<cfargument name="paramType">
	<cfargument name="referer">

	<cfset var key="">
	<cfset var objGet ="">
	<cfset var response ="">
	<cfset var strCookie ="">
	<cfset var tempValue ="">
	<cfset var tempNew=structNew()>

	<cfif structKeyExists(arguments,"params") and isStruct(arguments.params)>
		<cfset StructAppend(arguments.data, params, "yes")>
	</cfif>

	<cfhttp attributeCollection='#getHTTPAttrs(
		method="#arguments.httpMethod#",
		url="#getBaseURL()##arguments.url#",
		useragent="#getUserAgent()#",
		result="objGet",
		resolveurl="#getResolveURL()#",
		timeout="#getTimeout()#",
		throwOnError="#getThrowOnError()#",
		charset="#getCharSet()#")#'>

	<cfif len(arguments.referer)>
		<cfhttpparam
		type="HEADER"
		name="referer"
		value="#arguments.referer#"
		/>
	</cfif>

	<!--- Loop over the cookies we found. --->
	<cfloop
		item="strCookie"
		collection="#variables.httpSession#">

		<!--- Send the cookie value with this request. --->
		<cfhttpparam
			type="COOKIE"
			name="#strCookie#"
			value="#variables.httpSession[ strCookie ].Value#"
			/>

	</cfloop>

	<cfif not structIsEmpty(arguments.data)>
	<cfloop
		item="key"
		collection="#arguments.data#">
 		<cfif isSimpleValue(arguments.data[ key ])>
		<!--- Send the cookie value with this request. --->
		<cfhttpparam
			type="#arguments.paramType#"
			name="#key#"
			value="#arguments.data[ key ]#"
			/>
		<cfelse>
			<cfwddx action="cfml2wddx" input="#arguments.data[ key ]#" output="tempValue">
			<cfhttpparam
			type="#arguments.paramType#"
			name="#key#"
			value="#tempValue#"
			/>
		</cfif>

	</cfloop>
	</cfif>

	</cfhttp>

	<cfset tempNew=GetResponseCookies( objGet )>

	<cfset structAppend(variables.httpSession,tempNew,"true")>

	<cfif isJSON(objGet.fileContent)>
		<cfset response=deserializeJSON(objGet.fileContent)>
	<cfelseif isWDDX(objGet.fileContent)>
		<cfwddx action="wddx2cfml" input="#objGet.fileContent#" output="response">
	<cfelse>
		<cfset response=objGet.fileContent>
	</cfif>

	<cfreturn response>

</cffunction>

</cfcomponent>
