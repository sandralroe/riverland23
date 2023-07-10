<!--- license goes here --->
<cfif not listFindNoCase("Folder,Gallery",variables.$.content('type'))>
	<cfsilent>
		<cfif not isNumeric(variables.$.event('rate'))>
			<cfset variables.$.event('rate',0)>
		</cfif>

		<cfset variables.$.event('raterID',variables.$.getPersonalizationID()) />
		<cfif listFind(variables.$.event('doaction'),"saveRate") and variables.$.event('raterID') neq ''>
			<cfset variables.myRate=variables.$.getBean('raterManager').saveRate(
			variables.$.content('contentID'),
			variables.$.event('siteID'),
			variables.$.event('raterID'),
			variables.$.event('rate')) />
		<cfelse>
			<cfset variables.myRate = variables.$.getBean('raterManager').readRate(
			variables.$.content('contentID'),
			variables.$.content('siteID'),
			variables.$.event('raterID')) />
		</cfif>
		<cfset variables.rsRating=variables.$.getBean('raterManager').getAvgRating(variables.$.content('contentID'),variables.$.content('siteID')) />
	</cfsilent>
	<cfoutput>
		<script>
			$(function(){
				Mura.loader()
					.loadcss("#variables.$.globalConfig('context')#/core/modules/v1/rater/css/rater.min.css")
					.loadjs("#variables.$.globalConfig('context')#/core/modules/v1/rater/js/rater-jquery.min.js"
							,"#variables.$.globalConfig('context')#/core/modules/v1/rater/js/rater.min.js",
							function(){
								initRatings('rater1');
								$("##svRatings").show();
							});
			});
		</script>
		<div id="svRatings" class="mura-ratings #this.raterObjectWrapperClass#" style="display:none">
			<!--- Rater --->
			<div id="rateIt" class="#this.raterWrapperClass#">
				<#variables.$.getHeaderTag('subHead1')#>#variables.$.rbKey('rater.ratethis')#</#variables.$.getHeaderTag('subHead1')#>
				<form name="rater1" id="rater1" method="post" action="">
					<input type="hidden" id="rate" name="rate" value="##">
					<input type="hidden" id="userID" name="userID" value="#variables.$.event('raterID')#">
					<input type="hidden" id="loginURL" name="loginURL" value="#variables.$.siteConfig('loginURL')#&returnURL=#esapiEncode('url',variables.$.getCurrentURL(true,'doaction=saveRate&rate='))#">
					<input type="hidden" id="siteID" name="siteID" value="#variables.$.event('siteID')#">
					<input type="hidden" id="contentID" name="contentID" value="#variables.$.content('contentID')#">
					<input type="hidden" id="formID" name="formID" value="rater1">
					<fieldset>
						<label for="rater1_rater_input0radio1"><input type="radio" name="rater1_rater_input0" id="rater1_rater_input0radio1" value="1" class="stars" <cfif variables.myRate.getRate() eq 1>checked</cfif> >Not at All</label>
						<label for="rater1_rater_input0radio2"><input type="radio" name="rater1_rater_input0" id="rater1_rater_input0radio2" value="2" class="stars"  <cfif variables.myRate.getRate() eq 2>checked</cfif>>Somewhat</label>
						<label for="rater1_rater_input0radio3"><input type="radio" name="rater1_rater_input0" id="rater1_rater_input0radio3" value="3" class="stars" <cfif variables.myRate.getRate() eq 3>checked</cfif>>Moderately</label>
						<label for="rater1_rater_input0radio4"><input type="radio" name="rater1_rater_input0" id="rater1_rater_input0radio4" value="4" class="stars" <cfif variables.myRate.getRate() eq 4>checked</cfif> >Highly</label>
						<label for="rater1_rater_input0radio5"><input type="radio" name="rater1_rater_input0" id="rater1_rater_input0radio5" value="5" class="stars" <cfif variables.myRate.getRate() eq 5>checked</cfif>>Very Highly</label>
						<!---<input type="submit" value="rate it" class="submit">--->
					</fieldset>
				</form>
			</div>
			<!--- Average Rating --->

			<cfif variables.rsRating.theCount gt 0>
				<div id="avgrating" class="#this.avgRatingWrapperClass#">
				<#variables.$.getHeaderTag('subHead1')#>#variables.$.rbKey('rater.avgrating')# (<span id="numvotes">#variables.rsRating.theCount# <cfif variables.rsRating.theCount neq 1>#variables.$.rbKey('rater.votes')#<cfelse>#variables.$.rbKey('rater.vote')#</cfif></span>)</#variables.$.getHeaderTag('subHead1')#>
				<div id="avgratingstars" class="ratestars #variables.$.getBean('raterManager').getStarText(variables.rsRating.theAvg)#<!--- #replace(variables.rsRating.theAvg(),".","")# --->"><cfif isNumeric(variables.rsRating.theAvg)>#variables.rsRating.theAvg#<cfelse>0</cfif></div>
				</div>
			</cfif>

		</div>
	</cfoutput>
</cfif>
