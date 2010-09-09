<!---
	
	Copyright 2008, Bob Silverberg
	
	Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in 
	compliance with the License.  You may obtain a copy of the License at 
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software distributed under the License is 
	distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
	implied.  See the License for the specific language governing permissions and limitations under the 
	License.
	
--->
<cfcomponent output="false" name="AbstractClientRuleScripter" hint="I am a base object which all concrete ClientRuleScripters extend.">
	
	<cfproperty name="defaultFailureMessage" type="string" default=""/>
	
	<cffunction name="init" access="Public" returntype="any" output="false" hint="I build a new ClientRuleScripter">
		<cfargument name="Translator" type="Any" required="yes" />
		<cfargument name="getSafeFormName" type="Any" required="yes" />
		<cfargument name="defaultFailureMessagePrefix" type="string" required="yes" />
		<cfset variables.Translator = arguments.Translator />
		<cfset variables.getSafeFormName = arguments.getSafeFormName />
		<cfset variables.defaultFailureMessagePrefix = arguments.defaultFailureMessagePrefix />
		<cfreturn this />
	</cffunction>

	<cffunction name="generateValidationScript" returntype="any" access="public" output="false" hint="I generate the JS script required to implement a validation.">
		<cfargument name="validation" type="any" required="yes" hint="The validation object that describes the validation." />
		<cfargument name="formName" type="Any" required="yes" />
		<cfargument name="locale" type="Any" required="no" default="" />
		<cfset var safeFormName = variables.getSafeFormName(arguments.formName) />
		<cfset var theScript = "if ($form_#safeFormName#.find("":input[name='#arguments.validation.getClientFieldName()#']"").length) { " />
		<cfset var customMessage = arguments.validation.getFailureMessage() />
		
		<cfset theScript &= generateRuleScript(argumentCollection=arguments,customMessage=customMessage,defaultFailureMessagePrefix=variables.defaultFailureMessagePrefix) />
		<cfset theScript &= "}" />
		<cfreturn theScript />
	</cffunction>

	<cffunction name="generateRuleScript" returntype="any" access="public" output="false" hint="I generate the JS script required to implement a validation.">
		<cfargument name="validation" type="any" required="yes" hint="The validation object that describes the validation." />
		<cfargument name="formName" type="Any" required="yes" />
		<cfargument name="defaultFailureMessagePrefix" type="Any" required="yes" />
		<cfargument name="customMessage" type="Any" required="no" default="" />
		<cfargument name="locale" type="Any" required="no" default="" />

		<cfreturn generateAddRule(argumentCollection=arguments) />
		
	</cffunction>

	<cffunction name="generateAddRule" returntype="any" access="public" output="false" hint="I generate the JS script required to implement a validation.">
		<cfargument name="validation" type="any" required="yes" hint="The validation object that describes the validation." />
		<cfargument name="formName" type="Any" required="yes" />
		<cfargument name="customMessage" type="Any" required="no" default="" />
		<cfargument name="locale" type="Any" required="no" default="" />

		<cfset var paramName = "" />
		<cfset var paramList = "" />
		<cfset var ruleDef = getRuleDef(arguments.validation) />
		<cfset var safeFormName = variables.getSafeFormName(arguments.formName) />
		
		<cfif len(ruleDef) GT 0>
			<cfif len(arguments.customMessage) GT 0>
				<cfset arguments.customMessage = ", messages: {#ListFirst(ruleDef,':')#: '#JSStringFormat(variables.Translator.translate(arguments.customMessage,arguments.locale))#'}" />
			</cfif>
			<cfreturn "$form_#safeFormName#.find("":input[name='#arguments.validation.getClientFieldName()#']"").rules('add',{#ruleDef##arguments.customMessage#});" />
		</cfif>
		
	</cffunction>

	<cffunction name="getRuleDef" returntype="any" access="private" output="false" hint="I return just the rule definition which is required for the generateAddRule method.">
		<cfargument name="validation" type="any" required="yes" hint="The validation object that describes the validation." />

		<cfset var paramName = "" />
		<cfset var paramList = "" />
		<cfset var ruleDef = lCase(arguments.validation.getValType()) & ": " />
		<cfset var parameters = arguments.validation.getParameters() />

		<cfif structCount(parameters) GT 0>
			<cfif structCount(parameters) EQ 1>
				<cfset paramName = structKeyArray(parameters) />
				<cfset paramName = paramName[1] />
				<cfset ruleDef &= parameters[paramName] />
			<cfelse>
				<cfset ruleDef &= "[" />
				<cfloop collection="#parameters#" item="paramName">
					<cfset paramList = listAppend(paramList,parameters[paramName]) />
				</cfloop>
				<cfset ruleDef &= paramList & "]" />
			</cfif>
		<cfelse>
			<cfset ruleDef &= "true" />
		</cfif>

		<cfreturn ruleDef />
		
	</cffunction>

	<cffunction name="generateAddMethod" returntype="any" access="public" output="false" hint="I generate the JS script required to implement a validation.">
		<cfargument name="theCondition" type="any" required="yes" hint="The conditon to test." />
		<cfargument name="customMessage" type="any" required="no" default="" hint="A custom message to display on failure." />
		<cfargument name="locale" type="Any" required="no" default="" />

		<cfset var theScript = "" />
		<cfset var messageScript = "" />
		<cfif Len(arguments.customMessage) GT 0>
			<cfset messageScript = "#variables.Translator.translate(arguments.customMessage,arguments.locale)#" />
		</cfif>

		<cfoutput>
        <cfsavecontent variable="theScript">
        jQuery.validator.addMethod("#getValType()#", #theCondition#, jQuery.format("#messageScript#"));
        </cfsavecontent>
        </cfoutput>
        
        <cfreturn trim(theScript)/>
		
	</cffunction>
	
	<cffunction name="getValType" returntype="string" access="public" output="false" hint="I generate the JS script required to implement a validation.">
		<cfreturn lcase(ListLast(getMetadata(this).name,"_")) />
	</cffunction>
	
</cfcomponent>