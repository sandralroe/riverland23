<cfoutput>

	<div class="container">
		<div class="row">
		<div class="col-md-9 bg-warning">
	 <h1>#$.content('title')#</h1>
		 #Mura.renderEditableAttribute(attribute="body",type="htmlEditor")#	#Mura.dspObject(
		object="folder",
		params=objectParams
		)#	
		</div>
		<div class="col-md-3 bg-success padding0">#Mura.dspObjects(4)#
		</div>
	</div>

				
				</div>
			</div>

</cfoutput>
