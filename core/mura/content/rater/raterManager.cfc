<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false" hint="This provides content rating service level logic functionality">
	<cffunction name="init">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfset variables.configBean=arguments.configBean />
		<cfreturn this>
	</cffunction>

	<cffunction name="getBean" output="false">
		<cfargument name="beanName" default="rateBean">
		<cfreturn super.getBean(arguments.beanName)>
	</cffunction>

	<cffunction name="getStarText" output="false">
		<cfargument name="avg" type="any" default="" required="yes"/>

		<cfset var num="" />
		<cfset var theAvg=arguments.avg />

		<cfif theAvg eq ''>
			<cfset theAvg=0 />
		</cfif>

		<cfscript>
			if (arguments.avg LTE  0) num = "zero";
			else if (arguments.avg LT   1) num = "half";
			else if (arguments.avg LT 1.5) num = "one";
			else if (arguments.avg LT   2) num = "onehalf";
			else if (arguments.avg LT 2.5) num = "two";
			else if (arguments.avg LT   3) num = "twohalf";
			else if (arguments.avg LT 3.5) num = "three";
			else if (arguments.avg LT   4) num = "threehalf";
			else if (arguments.avg LT 4.5) num = "four";
			else if (arguments.avg LT   5) num = "fourhalf";
			else if (arguments.avg GTE  5) num = "five";
		</cfscript>
		<cfreturn num />
	</cffunction>

	<cffunction name="saveRate" output="true">
		<cfargument name="contentID" type="string" default="" required="yes"/>
		<cfargument name="siteID" type="string" default="" required="yes"/>
		<cfargument name="userID" type="string" default="" required="yes"/>
		<cfargument name="rate" type="numeric" default="0" required="yes"/>

		<cfset var rating = getBean("rate") />
		<cfset var stats = getBean("contentManager").getStatsBean() />
		<cfset var rsRating = "" />
		<cfset var ln="l" &replace(arguments.contentID,"-","","all") />
		<cfset rating.setcontentID(arguments.contentID) />
		<cfset rating.setSiteID(arguments.siteID) />
		<cfset rating.setUserID(arguments.userID) />
		<cfset rating.load() />
		<cfset rating.setEntered(now()) />
		<cfset rating.setRate(arguments.rate) />
		<cfset rating.save() />
		<cfset rsRating=getAvgRating(arguments.contentID,arguments.siteID)/>

		<cflock name="#ln#" timeout="10">
			<cfset stats.setContentID(arguments.contentID)/>
			<cfset stats.setSiteID(arguments.siteID)/>
			<cfset stats.load()/>
			<cfset stats.setRating(rsRating.theAvg)/>
			<cfset stats.setTotalVotes(rsRating.theCount)/>
			<cfif isNumeric(rsRating.downVotes)>
				<cfset stats.setDownVotes(rsRating.downVotes)/>
			<cfelse>
				<cfset stats.setDownVotes(0)/>
			</cfif>
			<cfset stats.setUpVotes( stats.getTotalVotes()-stats.getDownVotes()) />
			<cfset stats.save()/>
		</cflock>
		<cfreturn rating />
	</cffunction>

	<cffunction name="readRate" output="true">
		<cfargument name="contentID" type="string" default="" required="yes"/>
		<cfargument name="siteID" type="string" default="" required="yes"/>
		<cfargument name="userID" type="string" default="" required="yes"/>

		<cfset var rating = getBean("rate") />

		<cfset rating.setcontentID(arguments.contentID) />
		<cfset rating.setSiteID(arguments.siteID) />
		<cfset rating.setUserID(arguments.userID) />
		<cfset rating.load() />

		<cfreturn rating />
	</cffunction>

	<cffunction name="getAvgRating" output="true">
		<cfargument name="contentID" type="string" default="" required="yes"/>
		<cfargument name="siteID" type="string" default="" required="yes"/>

		<cfset var rsAvgRating=""/>

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsAvgRating')#">
			select avg(tcontentratings.rate) as theAvg, count(tcontentratings.contentID) as theCount, (count(tcontentratings.contentID)-downVotes) as upVotes, downVotes from tcontentratings
			left join (select count(rate) as downVotes, contentID,siteID from tcontentratings
						where siteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/>
						and contentID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contentID#"/>
						and rate=1
						group by contentID,siteID) qDownVotes
						On (tcontentratings.contentID=qDownVotes.contentID
							and tcontentratings.siteID=qDownVotes.siteID)
			where tcontentratings.siteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/>
			and tcontentratings.contentID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contentID#"/>
			group by downVotes
		</cfquery>

		<cfreturn rsAvgRating />
	</cffunction>

	<cffunction name="getTopRated" output="true">
		<cfargument name="siteID" type="string" default="" required="yes"/>
		<cfargument name="threshold" type="numeric" default="0" required="yes"/>
		<cfargument name="limit" type="numeric" default="0" required="yes"/>
		<cfargument name="startDate" type="string" required="true" default="">
		<cfargument name="stopDate" type="string" required="true" default="">

		<cfset var rsTopRating=""/>
		<cfset var stop=""/>
		<cfset var start=""/>
		<cfset var dbType=variables.configBean.getDbType() />
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsTopRating')#">
			<cfif dbType eq "oracle" and arguments.limit>select * from (</cfif>
			SELECT <cfif dbType eq "mssql" and arguments.limit>Top #arguments.limit#</cfif> tcontent.ContentHistID, tcontent.ContentID, tcontent.Approved, tcontent.filename, tcontent.Active,
			tcontent.Type, tcontent.OrderNo, tcontent.ParentID, tcontent.siteID,  tcontent.moduleID,
			tcontent.Title, tcontent.menuTitle, tcontent.lastUpdate, tcontent.lastUpdateBy,
			tcontent.lastUpdateByID, tcontent.Display, tcontent.DisplayStart,
			tcontent.DisplayStop,  tcontent.isnav, tcontent.restricted, avg(tcontentratings.rate) AS theAvg,
			count(tcontentratings.contentID) AS theCount, tcontent.isfeature,tcontent.inheritObjects,tcontent.target,
			tcontent.targetParams,tcontent.islocked,tcontent.sortBy,tcontent.sortDirection,tcontent.releaseDate,
			tfiles.fileSize,tfiles.FileExt,tfiles.ContentType,tfiles.ContentSubType
			FROM tcontent INNER JOIN tcontentratings ON tcontent.contentid=tcontentratings.contentid and
														tcontent.siteid=tcontentratings.siteid
			LEFT JOIN tfiles On tcontent.FileID=tfiles.FileID and tcontent.siteID=tfiles.siteID
			WHERE
			tcontent.siteid='#arguments.siteid#'
			and   tcontent.Active=1
			and   (tcontent.Type ='Page'
					or tcontent.Type = 'Component'
					or tcontent.Type = 'Link'
					or tcontent.Type = 'File'
					or tcontent.Type = 'Folder'
					or tcontent.Type = 'Calendar'
					or tcontent.Type = 'Form'
					or tcontent.Type = 'Gallery')

			<cfif lsIsDate(arguments.startDate)>
				<cftry>
				<cfset start=lsParseDateTime(arguments.startDate) />
				and tcontentratings.entered >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createdatetime(year(start),month(start),day(start),0,0,0)#">
				<cfcatch>
				and tcontentratings.entered >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createdatetime(year(arguments.startDate),month(arguments.startDate),day(arguments.startDate),0,0,0)#">
				</cfcatch>
				</cftry>
			</cfif>

			<cfif lsIsDate(arguments.stopDate)>
				<cftry>
				<cfset stop=lsParseDateTime(arguments.stopDate) />
				and tcontentratings.entered <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createdatetime(year(stop),month(stop),day(stop),23,59,0)#">
				<cfcatch>
				and tcontentratings.entered <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createdatetime(year(arguments.stopDate),month(arguments.stopDate),day(arguments.stopDate),23,59,0)#">
				</cfcatch>
				</cftry>
			</cfif>

			group by tcontent.ContentHistID, tcontent.ContentID, tcontent.Approved, tcontent.filename,
			tcontent.Active, tcontent.Type, tcontent.OrderNo, tcontent.ParentID, tcontent.siteID, tcontent.moduleID,
			tcontent.Title, tcontent.menuTitle, tcontent.lastUpdate, tcontent.lastUpdateBy,
			tcontent.lastUpdateByID, tcontent.Display, tcontent.DisplayStart,
			tcontent.DisplayStop,  tcontent.isnav, tcontent.restricted,tcontent.isfeature,tcontent.inheritObjects,
			tcontent.target,tcontent.targetParams,tcontent.islocked,tcontent.sortBy,tcontent.sortDirection,
			tcontent.releaseDate,tfiles.fileSize,tfiles.FileExt,tfiles.ContentType,tfiles.ContentSubType

			<cfif arguments.threshold gt 1>
			HAVING count(tcontentratings.contentID) >= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.threshold#">
			</cfif>

			ORDER BY  theAvg desc, theCount desc

		<cfif listFindNoCase("mysql,postgresql", dbType) and arguments.limit>limit <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.limit#"></cfif>
		<cfif dbType eq "oracle" and arguments.limit>) where ROWNUM <=1 </cfif>
		</cfquery>

	<cfreturn rsTopRating />
	</cffunction>

</cfcomponent>
