<cfset StructDelete(Application, 'langdata') />

<cfset tmp = application.beanFactory.getBean( 'translang' ).init() />

done.
<!--- <cfdump var="#application.langdata#"> --->