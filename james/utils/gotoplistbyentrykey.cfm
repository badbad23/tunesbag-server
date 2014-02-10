<!--- go to a plist by it's entrykey --->
<cfinclude template="/common/scripts.cfm">

<cfparam name="url.tab" type="string" default="" />
<cfparam name="url.entrykey" type="string" default="" />
<cfparam name="url.ajax" type="string" default="" />

<cflocation addtoken="false" url="#generateURLToPlist( url.entrykey, '', false )#&ajax=#url.ajax#&tab=#url.tab#" />