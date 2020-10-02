<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Active Engagements</label>
    <protected>false</protected>
    <values>
        <field>ChildObjectName__c</field>
        <value xsi:type="xsd:string">Engagement__c</value>
    </values>
    <values>
        <field>ChildSOQLClause__c</field>
        <value xsi:type="xsd:string">EngagementStatus__c = &apos;Accepted&apos; AND PositionEndDate__c &gt; TODAY</value>
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
        <value xsi:type="xsd:string">Tutor__c</value>
    </values>
    <values>
        <field>MatchingFieldName__c</field>
        <value xsi:type="xsd:string">Tutor__c</value>
    </values>
    <values>
        <field>ParentMatchingFieldName__c</field>
        <value xsi:type="xsd:string">Tutor__c</value>
    </values>
    <values>
        <field>ParentObjectName__c</field>
        <value xsi:type="xsd:string">Contact</value>
    </values>
    <values>
        <field>ParentSOQLClause__c</field>
        <value xsi:nil="true"/>
    </values>
</CustomMetadata>
