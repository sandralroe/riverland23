<!--- license goes here --->
<cfoutput>
	<cfsilent>
		<cfparam name="objectParams.items" default="[]">
		<cfparam name="objectParams.viewoptions" default="dayGridMonth,dayGridWeek,dayGridDay,timeGridWeek,timeGridDay,listMonth,listWeek">
		<cfparam name="objectParams.viewdefault" default="dayGridMonth">
		<cfparam name="objectParams.displaylist" default="#variables.Mura.content('displaylist')#">
		<cfparam name="objectParams.format" default="calendar">
		<cfparam name="objectParams.nextn" default="#variables.Mura.content('next')#">
		<cfparam name="objectParams.categoryid" default="">
		<cfparam name="objectParams.startrow" default="1">
		<cfparam name="objectParams.tag" default="">
		<cfparam name="objectParams.layout" default="default">
		<cfparam name="objectParams.dateparams" default="false">
		<cfparam name="objectParams.categoryids" default="">
		<cfparam name="objectParams.searchBar" default="false">

		<cfif not variables.Mura.getContentRenderer().useLayoutManager()>
			<cfset objectparams.displaylist=variables.Mura.content('displayList')>
			<cfset objectparams.sortBy=variables.Mura.content('sortBy')>
			<cfset objectparams.sortDirection=variables.Mura.content('sortDirection')>
			<cfset objectparams.nextn=variables.Mura.content('nextn')>
			<cfset objectparams.layout='default'>
			<cfset objectParams.format='calendar'>
		</cfif>

		<cfif isJson(objectParams.items)>
			<cfset objectParams.items=deserializeJSON(objectParams.items)>
		<cfelseif isSimpleValue(objectParams.items)>
			<cfset objectParams.items=listToArray(objectParams.items)>
		</cfif>
		<cfif not isArray(objectParams.items)>
			<cfset objectParam.items=[]>
		</cfif>
		<cfif not arrayFind(objectParams.items,variables.Mura.content('contentid'))>
			<cfset arrayPrepend(objectParams.items,variables.Mura.content('contentid'))>
		</cfif>
	</cfsilent>
	<cfif objectParams.format eq 'list'>
		<cfset objectParams.sourcetype='calendar'>
		<cfset structDelete(objectParams,'isbodyobject')>
		#variables.dspObject(object='collection',objectid=variables.Mura.content('contentid'),params=objectParams)#
	<cfelse>
		
		<div class="mura-calendar-wrapper">
			<div id="mura-calendar-error" class="alert alert-warning" role="alert" style="display:none;">
				<button type="button" class="close" data-dismiss="alert"><span aria-hidden="true">&times;</span><span class="sr-only">#variables.Mura.rbKey('calendar.close')#</span></button>
				<i class="fa fa-warning"></i> #variables.Mura.rbKey('calendar.eventfetcherror')#
			</div>

			<cfif arrayLen(objectParams.items) gt 1>
				<cfsilent>
					<cfset colorIndex=0>
					<cfset calendars=variables.Mura.getBean('contentManager')
						.findMany(
							contentids=objectParams.items,
							siteid=variables.Mura.event('siteid'),
							showNavOnly=0,
							contentpoolid=variables.Mura.siteConfig('contentpoolid')
						)>
				</cfsilent>
				<div class="mura-calendar__filters" style="display:none;">
				<cfloop condition="calendars.hasNext()">
					<cfsilent>
						<cfset calendar=calendars.next()>
						<cfset i=calendars.currentIndex()-1>
						<cfset colorIndex=colorIndex+1>
						<cfif colorIndex gt arrayLen(this.calendarcolors)>
							<cfset colorIndex=1>
						</cfif>
					</cfsilent>
					<div class="mura-calendar__filter-item">
						<label class="mura-calendar__filter-item__option">
							<input type="checkbox" class="input-style--swatch" data-index="#i#" data-contentid="#calendar.getContentID()#" data-color="#this.calendarcolors[colorIndex].text#!important" style="display:none;">
							<span>
								<span class="mura-calendar__filter-item__swatch"></span>
								<span class="mura-calendar__filter-item__swatch-label">#esapiEncode('html',calendar.getMenuTitle())#</span>
							</span>
						</label>
					</div>
				</cfloop>
				</div>
			</cfif>
			<div class="fc-line-break" style="display:none;"></div>
			<div class="fc-filters" style="display:none;">
				<cfscript>
					categoryIterator=Mura.getFeed('category')
						.where()
						.prop('categoryid').isIn(objectParams.categoryids)
						.getIterator();
					categories=[];
					if(categoryIterator.hasNext()){
						categoryOptions=listToArray(objectParams.categoryids);
						for(cid in categoryOptions){
							categoryIterator.reset();
							while(categoryIterator.hasNext()){
								category=categoryIterator.next();
								if(category.get('categoryid') == cid){
									arrayAppend(categories,category);
									break;
								}
							}
						}
					}
				</cfscript>
				<cfset filterClass="filter-item" />
				<cfif objectParams.searchBar>
					<div class="#filterClass#">
						<p>Search</p>
						<div class="search-item">
							<span class="fa fa-search"></span><input type="text" class="form-control" />
						</div>
					</div>
				</cfif>
				<cfif arrayLen(categories)>
					<cfloop array="#categories#" index="category">
						<cfset subCategeries=Mura.getFeed('category').where().prop('parentid').isEQ(category.getCategoryID()).getIterator()>
						<div class="#filterClass#">
							<p>#esapiEncode('html',category.getName())#</p>
							<select name="categoryid" class="#this.formSelectClass#">
								<option value="">All</option>
								<cfloop condition="subCategeries.hasNext()">
									<cfset subcategory=subCategeries.next()>
									<option value="#subcategory.getCategoryID()#">#esapiEncode('html',subcategory.getName())#</option>
								</cfloop>
							</select>
						</div>
					</cfloop>
				</cfif>
			</div>
			<div id="mura-calendar" class="mura-calendar-object"></div>
		</div>
		<script>
		Mura(function(){
			Mura(".fc-filters .filter-item select, .fc-filters .filter-item input").val(""); //reset filters always
			<cfset muraCalenderView='muraCalenderView' & replace(variables.Mura.content('contentid'),'-','','all')>
			<cfset muraHiddenCals='muraHiddenCals' & replace(variables.Mura.content('contentid'),'-','','all')>
			var hiddenCalendars=window.sessionStorage.getItem('#muraHiddenCals#');

			if(hiddenCalendars){
				hiddenCalendars=hiddenCalendars.split(',');
			} else {
				hiddenCalendars=[];
			}

			var muraCalendarView=JSON.parse(window.sessionStorage.getItem('#muraCalenderView#'));
			if(muraCalendarView == null){ 
				muraCalendarView={
					type:'#esapiEncode("javascript",objectParams.viewdefault)#'
				};
			}

			<cfif objectParams.dateparams>
				var defaultDate= '#variables.Mura.getCalendarUtility().getDefaultDate()#';
			<cfelse>
				if(muraCalendarView.defaultDate){
				var defaultDate=  muraCalendarView.defaultDate;
				} else {
					var defaultDate= '#variables.Mura.getCalendarUtility().getDefaultDate()#';
				}
			</cfif>

			var colors=#lcase(serializeJSON(this.calendarcolors))#;
			var calendars=#lcase(serializeJSON(objectparams.items))#;
			var eventSources=[
				<cfset colorIndex=0>
				<cfloop array="#objectParams.items#" index="i">
					<cfsilent>
						<cfset colorIndex=colorIndex+1>
						<cfif colorIndex gt arrayLen(this.calendarcolors)>
							<cfset colorIndex=1>
						</cfif>
					</cfsilent>
					{
						id: '#esapiEncode("javascript",i)#'
						, events: function(fetchInfo, successCallback, failureCallback) {

							console.log(fetchInfo.start)
							Mura.post(
								Mura.getAPIEndpoint() + '/findCalendarItems?calendarid=#esapiEncode("javascript",i)#'
								, {
									method: 'getFullCalendarItems'
									, calendarid: '#esapiEncode("javascript",i)#'
									, siteid: '#variables.Mura.content('siteid')#'
									, categoryid: '#esapiEncode('javascript',variables.Mura.event('categoryid'))#'
									, tag: '#esapiEncode('javascript',variables.Mura.event('tag'))#'
									, format: 'fullcalendar'
									, showNavOnly: 0
									, showExcludeSearch: 0
									, searchtext: ""
									, useCategoryIntersect: false
									, start: (fetchInfo.start.getUTCFullYear()) + "-" + (fetchInfo.start.getMonth() + 1)+ "-" + (fetchInfo.start.getUTCDate())
        							, end:  (fetchInfo.end.getUTCFullYear()) + "-" + (fetchInfo.end.getMonth() + 1)+ "-" + (fetchInfo.end.getUTCDate())

								}
								).then(
									function(items){
										successCallback(items);
									},
									failureCallback
								);
						}
						, color: '#this.calendarcolors[colorIndex].background#'
						, textColor: '#this.calendarcolors[colorIndex].text#'
						, failure: function() {
							Mura('##mura-calendar-error').show();
						}
					},
				</cfloop>
			];

			Mura('.mura-calendar__filters').show();

			Mura.loader()
				.loadcss(Mura.rootpath + '/core/vendor/fullcalendar_v5/fullcalendar.min.css',{media:'all'})
				.loadjs(
					Mura.rootpath + '/core/vendor/fullcalendar_v5/fullcalendar.min.js',
					function(){
						var calendarEl = document.getElementById('mura-calendar');
						var calendar = new FullCalendar.Calendar(calendarEl,{
							timeZone: 'local'
							, initialDate: defaultDate
							, buttonText: {
								day: '#variables.Mura.rbKey('calendar.day')#'
								, Day: '#variables.Mura.rbKey('calendar.agendaday')#'
								, week: '#variables.Mura.rbKey('calendar.week')#'
								, agendaWeek: '#variables.Mura.rbKey('calendar.agendaweek')#'
								, month: '#variables.Mura.rbKey('calendar.month')#'
                                , today: '#variables.Mura.rbKey('calendar.today')#'
                                , listMonth: '#variables.Mura.rbKey('calendar.listMonth')#'
							}
							,dayHeaderFormat: {
								weekday:'narrow'
							}
							, firstDay: 0 // (0=Sunday, 1=Monday, etc.)
							, weekends: true // show weekends?
							, headerToolbar: {
								left: 'today prev,next'
								, center: 'title'
								, right: '#esapiEncode("javascript",objectParams.viewoptions)#'
							}
							<cfif isNumeric(variables.Mura.event('day')) and variables.Mura.event('day')>
								, initialView: 'timeGridDay'
							<cfelse>
								, initialView:  muraCalendarView.type
							</cfif>
							, datesSet: function(view,element){
								if(view.activeEnd){
									var newDefaultDate=new Date((new Date(view.activeStart).getTime() + new Date(view.activeEnd).getTime()) / 2)
								} else {
									var newDefaultDate=view.activeStart;
								}
								window.sessionStorage.setItem('#muraCalenderView#',JSON.stringify({
									type:view.type,
									defaultDate:newDefaultDate
								}));
							}
							, loading: function(isLoading) {
								if (!isLoading){
									var lb=Mura(".fc-line-break").detach().css('display','');
									var filters=Mura(".fc-filters").detach().css('display','');
									var calendar=Mura("##mura-calendar .fc-toolbar");
									lb.each(function(){
										calendar.append(this);
									})
									// filters.each(function(){
									// 	calendar.append(this);
									// })

									//Mura("##mura-calendar .fc-toolbar").append(Mura(".fc-line-break").detach().css('display',''))
									//.append(Mura(".fc-filters").detach().css('display',''));
								}
							}
							, dayMaxEventRows: false
							, height: 'auto'
							, eventDisplay: 'block'
						});

						calendar.render();

						let timeout = null; // search while typing
						let updateEventSourcesData = (eventSource) => {
							let categories = Mura("select.#this.formSelectClass#").map(function(obj){
								let val = Mura(obj).val();
								if (val.length) return val;
							}).join(',');
							eventSource.extraParams.categoryid = categories;
							eventSource.extraParams.useCategoryIntersect = categories.includes(',');
							eventSource.extraParams.searchtext = Mura('.fc-filters .#filterClass# .search-item input[type=text]').val().trim();
							return eventSource;
						}
						let doSearch = () => {
							calendar.removeAllEventSources();
							Mura.each(eventSources, function (index,val) {
								eventSources[index] = updateEventSourcesData(eventSources[index]);
								calendar.addEventSource(eventSources[index]);
							});
						}
						<cfif arrayLen(objectParams.items) eq 1>
							calendar.addEventSource(eventSources[0]);
						<cfelse>
							Mura('.mura-calendar__filter-item').each(function(){
								var optionContainer=Mura(this);
								var calendarToggleInput=optionContainer.find('.input-style--swatch');

								if(hiddenCalendars.indexOf(calendarToggleInput.data('contentid')) == -1){
									calendarToggleInput.attr('checked',true);
								} else {
									calendarToggleInput.attr('checked',false);
								}

								calendarToggleInput.on('change',function(){
									var swatch=optionContainer.find('.mura-calendar__filter-item__swatch');
									var self=Mura(this);
									if(self.is(':checked')){
										swatch.attr('style', 'background-color:' + self.data('color'));
										calendar.addEventSource(eventSources[self.data('index')]);

										var temp=[];
										var contentid=self.data('contentid');
										for(var i in hiddenCalendars){
											if(hiddenCalendars[i] !=contentid){
												temp.push(hiddenCalendars[i])
											}
										}
										hiddenCalendars=temp;
									} else {
										swatch.css('background-color','');
										calendar.getEventSourceById(eventSources[self.data('index')].id).remove();
										hiddenCalendars.push(self.data('contentid'));
									}
									window.sessionStorage.setItem('#muraHiddenCals#',hiddenCalendars.join(','));
								}).trigger('change');
							});
						</cfif>

						Mura("select.#this.formSelectClass#").on("change",function(e){
							doSearch();
						});

						<cfif objectParams.searchBar>
							Mura('.fc-filters .#filterClass# .search-item input[type=text]').on('keyup',function(e){
								let self = Mura(this);
								clearTimeout(timeout)
								timeout = setTimeout(() => {
									doSearch();
									self.focus();
								}, 500);
							});
						</cfif>	

					}
				);
		});
		</script>
	</cfif>
</cfoutput>

<cfsilent>
<!-- delete params that we don't want to persist --->
<cfset structDelete(objectParams,'dateparams')>
<cfset structDelete(objectParams,'tag')>
<cfset structDelete(objectParams,'sortby')>
<cfset structDelete(objectParams,'sortdirection')>
</cfsilent>
