#!/bin/bash

# Export Account, Contact, and User data
# sfdx data:tree:export -q "SELECT Name FROM Account" --target-org TargetOrgAlias --output-dir ./data --plan

# Import Account, Contact, and User data
# sfdx data:tree:import -p ./data/FileName.json --target-org ORG_ALIAS

# Prompt for Export / Import sandbox name
until read -r -p "Export_Sandbox Name: " export_sandboxName && test "$export_sandboxName" != ""; do
  continue
done

until read -r -p "Import_Sandbox Name: " import_sandboxName && test "$import_sandboxName" != ""; do
  continue
done


# Export Account, Contact, and User data
sfdx data:tree:export -q "SELECT Name, Industry, Phone, BillingStreet, BillingCity, BillingState, BillingPostalCode, ParentId, RecordtypeId, (SELECT FirstName, LastName, Email, Phone, AccountId FROM Contacts) FROM Account LIMIT 1" --target-org $export_sandboxName --output-dir ./data --plan
sfdx data:tree:export -q "SELECT FirstName, LastName, Email, Phone, AccountId FROM Contact LIMIT 200" --target-org $export_sandboxName --output-dir ./data --plan
sfdx data:tree:export -q "SELECT Id, FirstName, LastName, Email, Contact.Id, Contact.FirstName, Contact.LastName, Contact.Email, Account.Id, Account.Name, UserRole.Name, Profile.Name FROM User WHERE IsActive = true LIMIT 200" --target-org $export_sandboxName --plan --output-dir ./data



# Import data to the specified sandbox
echo "+++++++++++++"
echo "Creation des fournisseurs sur la sandbox $import_sandboxName."
sf data import tree --plan Data/Fournisseurs-plan.json -o "$import_sandboxName"
echo "+++++++++++++"
echo "Creation des Accounts parent sur la sandbox $import_sandboxName."
sf data import tree --plan Data/Account-plan.json -o "$import_sandboxName"
echo "+++++++++++++"
echo "Creation des Utilisateurs sur la sandbox $import_sandboxName."
sf data import tree --plan Data/User-plan.json -o "$import_sandboxName"
