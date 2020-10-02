<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Registers To Complete</label>
    <protected>false</protected>
    <values>
        <field>ChildObjectName__c</field>
        <value xsi:type="xsd:string">Attendance__c</value>
    </values>
    <values>
        <field>ChildSOQLClause__c</field>
        <value xsi:type="xsd:string">IsMyAttendance__c = true AND RegisterCompletedDate__c = null</value>
    </values>
    <values>
        <field>JunctionObjectFieldName__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>JunctionObjectName__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>JunctionObjectRecordTitle__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>JunctionObjectWhere__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>LookupFieldName__c</field>
        <value xsi:type="xsd:string">Session__c</value>
    </values>
    <values>
        <field>MatchingFieldName__c</field>
        <value xsi:type="xsd:string">TutorId__c</value>
    </values>
    <values>
        <field>ParentMatchingFieldName__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>ParentObjectName__c</field>
        <value xsi:type="xsd:string">Session__c</value>
    </values>
    <values>
        <field>ParentSOQLClause__c</field>
        <value xsi:type="xsd:string">SessionDate__c &lt;= TODAY AND RegisterCompleted__c = null ORDER BY SessionDate__c</value>
    </values>
</CustomMetadata>
