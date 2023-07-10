 <!--- license goes here --->
<cfoutput>
<div class="mura-header">
<h1>Copy Site</h1>
</div> <!-- /.mura-header -->

<div class="alert alert-warning"><span>IMPORTANT: All content in the destination site ("To") will be deleted and replaced with the source site's ("From") content.</span></div>

<div class="block block-constrain">
	<div class="block block-bordered">
	  <div class="block-content">


<form action="./" onsubmit="if(validateForm(this)){actionModal(function(){});return true;}else{return false;};">
<div class="mura-control-group">
   <label>From</label>
   <select name="fromSiteID" required="true" message="The 'SOURCE' site is required.">
	<option value="">--Select Source Site--</option>
	<cfloop query="rc.rsSites">
		<option value="#rc.rsSites.siteid#">#esapiEncode('html',rc.rsSites.site)#</option>
	</cfloop>
	</select>
 </div>
 <div class="mura-control-group">
  <label>To</label>
  	<select name="toSiteID" required="true" message="The 'DESTINATION' site is required.">
	<option value="">--Select Destination Site--</option>
	<cfloop query="rc.rsSites">
		<option value="#rc.rsSites.siteid#">#esapiEncode('html',rc.rsSites.site)#</option>
	</cfloop>
	</select>
</div>

<input type="hidden" name="muraAction" value="cSettings.sitecopy">

<input type="submit" value="Copy" class="btn">
#rc.$.renderCSRFTokens(context='sitecopy',format="form")#
</form>
		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
</cfoutput>