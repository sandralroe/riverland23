<cfif this.SSR>
	
<cfoutput>
<cfif len(m.event('mxp_anon'))>
	<div class="alert-success">
		Your preference has been save.
	</div>
</cfif>
<form>
<h3>Privacy Settings</h3>
<div class="#this.formRadioWrapperClass#">
	<input type="radio" class="#this.formRadioClass#" id="mxp_anon1" name="mxp_anon" value="false"<cfif not isDefined('cookie.mxp_anon')> checked</cfif>>
  <label for="mxp_anon1" class="#this.formRadioLabelClass#">For a better experience, allow this site to store some identifying information</label>
</div>
<div class="#this.formRadioWrapperClass#">
	<input type="radio" class="#this.formRadioClass#" id="mxp_anon2" name="mxp_anon" value="true"<cfif isDefined('cookie.mxp_anon')> checked</cfif>>
  <label for="mxp_anon2" class="#this.formRadioLabelClass#">Do not allow this site to store some identifying information</label>
</div>
<div class="#this.formButtonWrapperClass#">
<button type="submit" class="#this.formButtonSubmitclass#">Apply</button>
</div>
</form>
</cfoutput>

<cfelse>
	<cfset objectParams.render="client">
	<cfset objectParams.async=false>
</cfif>