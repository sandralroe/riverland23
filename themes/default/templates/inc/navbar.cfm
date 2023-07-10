<cfoutput>
<div class="sticky-top">
	<nav class="navbar navbar-expand-lg bg-white navbar-light navbar-static-top py-4 shadow-sm">
		<div class="container">
			
			<a class="navbar-brand" title="#esapiEncode('html_attr', Mura.siteConfig('site'))#" href="#Mura.createHREF(filename='')#">#Mura.siteConfig('site')#</a>

			<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="##siteNavbar" aria-controls="siteNavbar" aria-expanded="false" aria-label="Toggle navigation">
				<span class="navbar-toggler-icon"></span>
			</button>

			<div class="navbar-collapse collapse" id="siteNavbar">

				<cf_CacheOMatic key="dspPrimaryNav">
					<!---
						For information on dspPrimaryNav(), visit:
						http://docs.getmura.com/v6/front-end/template-variables/document-body/
					--->
					#Mura.dspPrimaryNav(
						viewDepth=3
						, id='navPrimary'
						, class='navbar-nav ml-auto mr-5'
						, displayHome='never'
						, closeFolders='72F9687F-C642-4F08-80B7182B81B91E7C'
						, showCurrentChildrenOnly=false
						, liClass='nav-item'
						, liHasKidsClass='dropdown'
						, liHasKidsAttributes=''
						, liCurrentClass=''
						, liCurrentAttributes=''
						, liHasKidsNestedClass=''
						, aHasKidsClass='dropdown-toggle'
						, aHasKidsAttributes=''
						, aCurrentClass='nav-link'
						, aCurrentAttributes=''
						, ulNestedClass='dropdown-menu'
						, ulNestedAttributes=''
						, aNotCurrentClass='nav-link'
						, siteid=Mura.event('siteid')
					)#
				</cf_CacheOMatic>
				<script>
					Mura(function(){
						#serializeJSON(Mura.getCurrentURLArray())#.forEach(
							function(value){
								navItem=Mura("##navPrimary [href='" + value + "']");
								if(navItem.length){
									var navItem=Mura("##navPrimary [href='" + value + "']").closest("li");
									if(navItem.length){
										navItem.addClass("active");
									}
								}
							}
						);
					})
				</script>

				<form method="post" id="searchForm" class="form-inline" role="search" action="#m.createHREF(filename='search-results')#">
					<div class="input-group">
						<input type="text" name="Keywords" id="navKeywords" class="form-control" value="#esapiEncode('html', Mura.event('keywords'))#" placeholder="#Mura.rbKey('search.search')#" aria-label="Search">
						<div class="input-group-append">
							<button class="input-group-text" id="search-submit">
								<i class="fa fa-search" aria-hidden="true"></i>
								<span class="sr-only">Search</span>
							</button>
						</div>
					</div>
					<input type="hidden" name="display" value="search">
					<input type="hidden" name="newSearch" value="true">
					<input type="hidden" name="noCache" value="1">
					#variables.Mura.renderCSRFTokens(format='form',context='search')#
				</form>

			</div><!--- /.navbar-collapse --->
		</div><!--- /.container --->
	</nav><!--- /nav --->
</div>
</cfoutput>
