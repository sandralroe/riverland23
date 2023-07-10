<cfparam name="F" default="Main">


<cfif F IS "Main">
	<cfquery name="getSemesters" datasource="webdirectory">
		select * from semesterlist ORDER BY orderID ASC
	</cfquery>
	<cfquery name="getCommunication" datasource="webdirectory">
		select * from communicationList ORDER BY cmORderID ASC
	</cfquery>
		<cfquery name="getProgramList" datasource="webdirectory">
		select * from programlist ORDER BY pos_name ASC
	</cfquery>

 <script src='https://www.google.com/recaptcha/api.js'></script>
	<cfform action="index.cfm?F=Step2" method="post" class="pure-form pure-form-stacked">


	
		
				<div class="mura-form-dropdown">
				<label for="programOption">
					Choose Your Program
				</label>
				<select name="programOption">
						<cfoutput query="getProgramList">
					<option value="#majorID#">
					#pos_name#
					</option>
					</cfoutput>
				</select>
			</div>
		<div class="mura-form-dropdown">
				<label for="state">
					Choose Start Date
				</label>
				<select name="StartDate">
						<cfoutput query="getSemesters">
					<option value="#semesterID#">
					#semester#
					</option>
					</cfoutput>
				</select>
			</div>


			
			<div class="mura-form-textfield ">
				<label for="first-name">
					First Name
				</label>
				<input type="text" name="firstname" value="" id="firstname"
				       required class=""/>
			</div>
			
			<div class="mura-form-textfield ">
				<label for="last-name">
					Last Name
				</label>
				<input type="text" name="lastname" value="" id="lastname"
				       required class=""/>
			</div>
            	<div class="mura-form-textfield ">
				<label for="birthdate">
					Birthdate
				</label>
				<input type="date" name="birthdate" value="" placeholder="MM/DD/YYYY" id="birthdate"
				       required class=""/>
			</div>
			<div class="mura-form-textfield ">
				<label for="address">
					Address
				</label>
				<input type="text" name="address" value="" id="address"
				       required class=""/>
			</div>
			<div class="mura-form-textfield ">
				<label for="city">
					City
				</label>
				<input type="text" name="city" value="" id="city"
				       required class=""/>
			</div>
			<div class="mura-form-dropdown">
				<label for="state">
					State
				</label>
				<select name="state">
					<option value="AL">
						Alabama
					</option>
					<option value="AK">
						Alaska
					</option>
					<option value="AZ">
						Arizona
					</option>
					<option value="AR">
						Arkansas
					</option>
					<option value="CA">
						California
					</option>
					<option value="CO">
						Colorado
					</option>
					<option value="CT">
						Connecticut
					</option>
					<option value="DE">
						Delaware
					</option>
					<option value="DC">
						District Of Columbia
					</option>
					<option value="FL">
						Florida
					</option>
					<option value="GA">
						Georgia
					</option>
					<option value="HI">
						Hawaii
					</option>
					<option value="ID">
						Idaho
					</option>
					<option value="IL">
						Illinois
					</option>
					<option value="IN">
						Indiana
					</option>
					<option value="IA">
						Iowa
					</option>
					<option value="KS">
						Kansas
					</option>
					<option value="KY">
						Kentucky
					</option>
					<option value="LA">
						Louisiana
					</option>
					<option value="ME">
						Maine
					</option>
					<option value="MD">
						Maryland
					</option>
					<option value="MA">
						Massachusetts
					</option>
					<option value="MI">
						Michigan
					</option>
					<option value="MN" selected="selected">
						Minnesota
					</option>
					<option value="MS">
						Mississippi
					</option>
					<option value="MO">
						Missouri
					</option>
					<option value="MT">
						Montana
					</option>
					<option value="NE">
						Nebraska
					</option>
					<option value="NV">
						Nevada
					</option>
					<option value="NH">
						New Hampshire
					</option>
					<option value="NJ">
						New Jersey
					</option>
					<option value="NM">
						New Mexico
					</option>
					<option value="NY">
						New York
					</option>
					<option value="NC">
						North Carolina
					</option>
					<option value="ND">
						North Dakota
					</option>
					<option value="OH">
						Ohio
					</option>
					<option value="OK">
						Oklahoma
					</option>
					<option value="OR">
						Oregon
					</option>
					<option value="PA">
						Pennsylvania
					</option>
					<option value="RI">
						Rhode Island
					</option>
					<option value="SC">
						South Carolina
					</option>
					<option value="SD">
						South Dakota
					</option>
					<option value="TN">
						Tennessee
					</option>
					<option value="TX">
						Texas
					</option>
					<option value="UT">
						Utah
					</option>
					<option value="VT">
						Vermont
					</option>
					<option value="VA">
						Virginia
					</option>
					<option value="WA">
						Washington
					</option>
					<option value="WV">
						West Virginia
					</option>
					<option value="WI">
						Wisconsin
					</option>
					<option value="WY">
						Wyoming
					</option>
				</select>
			</div>
			<div class="mura-form-textfield ">
				<label for="zipcode">
					Zip Code
				</label>
				<input type="text" name="zipcode" value="" id="zipcode"
				       required class=""/>
			</div>
			<div class="mura-form-textfield ">
				<label for="phone">
					Phone
				</label>
				<input type="text" name="phone" value="" id="phone"
				       required class=""/>
			</div>
			<div class="mura-form-textfield ">
				<label for="email">
					E-mail
				</label>
				<input type="text" name="email" value="" id="email"
				       required/>
			</div>
			<div class="mura-form-checkbox ">
				<label for="textmessage">
					Yes, send me text messages.
				</label>
				<input id = "textMessage" type = "checkbox" checked = "checked">
                  YES
			</div>
			<div class="mura-form-dropdown">
				<label for="communicationMethod">
					How did you hear about us? 
				</label>
				<select name="communicationMethod">
						<cfoutput query="getCommunication">
					<option value="#commID#">
					#communicationMethod#
					</option>
					</cfoutput>
				</select>
			</div>
			<div class="g-recaptcha" data-sitekey="6Lfd4wcUAAAAAJKgvROyUuSjyEnUEj-Szl7FZWTm"></div>
		<input type="submit" value="Submit">
		
	</cfform>
</cfif>
<cfif F is "Step2">
<cfquery name="getSemesters" datasource="webdirectory">
		select semester from semesterlist WHERE semester = '#form.semester#'
	</cfquery>
<cfset recaptcha = FORM["g-recaptcha-response"]>
		<cfif len(recaptcha)>

   <cfset DateToday = now() />
     <cfquery name="PostProspect" datasource="webdirectory">
	insert into prospects (firstname, lastname, birthdate, address, city, state, zipcode, phone, email, textmessage, program, semester, communicationMethod, daterequest)
	values ( <cfqueryparam value="#form.firstname#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.lastname#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.lname#" cfsqltype="cf_sql_varchar">
    , <cfqueryparam value="#form.birthdate#" cfsqltype="cf_sql_varchar">    
	, <cfqueryparam value="#form.address#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.city#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.state#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.zipcode#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.phone#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.textmessage#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.program#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.semester#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.communicationMethod#" cfsqltype="cf_sql_varchar">
	, #datetoday#)
</cfquery>
	<cfmail	to = "sandra.roe@riverland.edu" from = "webmaster@riverland.edu" subject = "POS Web Prospect">
	Prospect form success
	</cfmail>

	<cfelse>
		OOOPS this form will not be processed. Please go back and make sure you verify you are not a 
		robot.
		<cfabort>
		     </cfif> 
		</cfif>
