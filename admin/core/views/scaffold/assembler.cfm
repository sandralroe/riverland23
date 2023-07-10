<!--- License goes here --->

<cfoutput>

<script src="#$.globalConfig('rootPath')#/core/vendor/vue/vue.js"></script>
<script src="#$.globalConfig('rootPath')##application.configBean.getAdminDir()#/assets/js/scaffold/assembler.js"></script>
<script src="#$.globalConfig('rootPath')##application.configBean.getAdminDir()#/assets/js/scaffold/Sortable.min.js"></script>
<script src="#$.globalConfig('rootPath')##application.configBean.getAdminDir()#/assets/js/scaffold/vuedraggable.min.js"></script>

<script>
	var Assembler = "";
	var Scaffolder = "";
	var Master = "";
</script>

<style>
.mura ##container-assembler ##assembler-properties .sortable-ghost {
	background-color: ##eee;
	border-color: ##eee;
}
.mura ##container-assembler ##assembler-properties sortable-list div {
  list-style: none;
  margin: 0;
  padding: 0;
}
</style>

<div id="alert-assembler-saved"></div>

<div class="mura-header">
  <h1>Custom Mura ORM Entity</h1>

	<div class="nav-module-specific btn-group">
		<!---<a class="btn" href="./?muraAction=scaffold.assembler"><i class="mi-plus-circle"></i> New Entity</a>--->
    <a class="btn" href="./?muraAction=cArch.list&siteid=#esapiEncode('url',rc.siteid)#&activeTab=2"><i class="mi-arrow-circle-left"></i> Back</a>
  </div>

</div> <!-- /.mura-header -->

<div class="block block-constrain" id="container">

	<!--- Tab navigation --->
  <ul class="mura-tabs nav-tabs" data-toggle="tabs">
    <li class="active"><a href="##tabDef" onclick="return false;"><span>Definition</span></a></li>
    <li class=""><a href="##tabJson" onclick="return false;"><span>JSON</span></a></li>
  </ul>	<!--- /Tab Nav --->

	<!--- assembler --->
	<div id="container-assembler">

	  <!--- start tab content --->
		<div class="block-content tab-content">
			<!-- definitions-->
			<div class="tab-pane active" id="tabDef">
				<div class="block block-bordered">

					<div class="block-content">
						<div class="alert alert-warning">
						   IMPORTANT: After updating dynamically created entities, a reload of the Mura application may be required.
						</div>
							<component :is="currentView" :data="data" :isupdate="isupdate" :rendertypes="rendertypes" :fieldtypes="fieldtypes" :datatypes="datatypes" :model="model" transition="fade" transition-mode="out-in"></component>
					</div>
				</div> <!-- /.block-bordered -->
			</div> <!-- /tabDef -->

			<!-- json -->
			<div class="tab-pane" id="tabJson">
				<div class="block block-bordered">
					<div class="block-content">
						<h3>JSON Preview</h3>
						<pre id="assembler-preview">{{JSON.stringify(model,null,2)}}</pre>
					</div>
				</div> <!-- /.block-bordered -->
			</div> <!-- /tabJson -->

		</div> <!-- /.block-content.tab-content -->

		<div class="mura-actions" style="display:none">
			<div class="form-actions" v-if="currentView==='assembler-template'">
				<button v-else class="btn" disabled><i class="mi-ban"></i> Save</button>
				<button v-if="this.entityissaved" @click='clickDelete' class="btn"><i class="mi-trash"></i> Delete</button>
				<button v-if="model.entityname != '' && model.table != ''" @click='clickSave' class="btn mura-primary"><i class="mi-check-circle"></i> Save</button>
			</div>
			<div class="form-actions" v-else-if="currentView==='assembler-property-form-template'">
				<button  class="btn" @click='clickCancel'><i class="mi-arrow-circle-left"></i> Cancel</button>
				<button class="btn" v-if="isupdate && data.fieldtype != 'id'" @click="clickDeleteProperty"><i class="mi-trash"></i> Delete</button>
				<button  class="btn mura-primary" @click="clickUpdateProperty"><i class="mi-check-circle"></i> <span v-if="isupdate">Update</span><span v-else>Add</span> Property</button>
			</div>
			<div class="form-actions" v-else-if="currentView==='assembler-related-form-template'">
				<button  class="btn" @click='clickCancel'><i class="mi-arrow-circle-left"></i> Cancel</button>
								<button class="btn" v-if="isupdate" @click="clickDeleteRelated"><i class="mi-trash"></i> Delete</button>
				<button  class="btn mura-primary" @click="clickUpdateRelated"><i class="mi-check-circle"></i> <span v-if="isupdate">Update</span><span v-else>Add</span> Relationship</button>
			</div>
		</div>

	</div> <!--- /container-assembler --->

</div> <!-- /.block-constrain -->

</cfoutput>

<!--- vue templates --->
<cfinclude template="assembler_templates.cfm">
