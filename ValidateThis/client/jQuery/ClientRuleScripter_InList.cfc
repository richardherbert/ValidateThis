<!---
	
	Copyright 2010, Adam Drew
	
	Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in 
	compliance with the License.  You may obtain a copy of the License at 
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software distributed under the License is 
	distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
	implied.  See the License for the specific language governing permissions and limitations under the 
	License.

--->

<cfcomponent output="false" name="ClientRuleScripter_InList" extends="AbstractClientRuleScripter" hint="I am responsible for generating JS code for the InList validation.">

	<cffunction name="generateInitScript" returntype="any" access="public" output="false" hint="I generate the validation 'method' function for the client during fw initialization.">
		<cfargument name="defaultMessage" type="string" required="false" default="value was not found in list.">
		<cfset var theCondition="function(value,element,options) { return true; }"/>
		
		<!--- JAVASCRIPT VALIDATION METHOD --->
		<cfsavecontent variable="theCondition">function(value,element,options) {
			var theDelim = (options.delim) ? options.delim : ",";
			var theList = options.list.split(theDelim);
			var isValid = false;
			$(theList).each(function(){
				if (value.toLowerCase() == this.toLowerCase()){
					isValid = true;
				}
			});
			return isValid;
		}</cfsavecontent>
			
		 <cfreturn generateAddMethod(theCondition,arguments.defaultMessage)/>
	</cffunction>

	<cffunction name="generateRuleScript" returntype="any" access="public" output="false" hint="I generate the JS script required to implement a validation.">
		<cfargument name="validation" type="any" required="yes" hint="The validation struct that describes the validation." />
		<cfargument name="selector" type="string" required="no" default="" />
		<cfargument name="customMessage" type="string" required="no" default="" />
		<cfargument name="locale" type="string" required="no" default="" />
		
		<cfset var theScript = "" />
		<cfset var valType = getValType() />       
		<cfset var params = arguments.validation.getParameters()/>
		<cfset var options = true/>
		<cfset var messageScript = "" />

		<cfif Len(arguments.customMessage) eq 0>
			<cfset arguments.customMessage = createDefaultFailureMessage("#arguments.validation.getPropertyDesc()# was not found in list:") />
		</cfif>

		<cfif arguments.validation.hasParameter("list")>
			<cfset options = structNew()/>
			<cfset options['list'] = arguments.validation.getParameterValue("list")/>
			<cfset arguments.customMessage = arguments.customMessage & " #arguments.validation.getParameterValue('list')#"/>
			<cfif arguments.validation.hasParameter("delmin")>
				<cfset options['delim'] = arguments.validation.getParameterValue("delim",",")/>
			</cfif>
		</cfif>
		
		<cfset messageScript = variables.Translator.translate(arguments.customMessage,arguments.locale) />
		
		<cfoutput>
		<cfsavecontent variable="theScript">
		#arguments.selector#.rules("add", {
			#valType# : #serializeJSON(options)#,
			messages: {"#valType#": "#messageScript#"}
		});
		</cfsavecontent>
		</cfoutput>
		
		<cfreturn theScript/>
	</cffunction>

</cfcomponent>