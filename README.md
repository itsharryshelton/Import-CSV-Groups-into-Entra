# Import-CSV-Groups-into-Entra
Script for quickly importing security groups into Entra ID / Azure AD

Script will connect you to Azure AD (or now technically Entra ID) via PowerShell, and import your CSV of security groups into it, adding members, owners & descriptions.
Please not that at the moment this script only supports Entra Security Groups.

There are two versions of this script, please download the version you need:

**Main Script**  = you already have AzureAD Module installed or do not want it to check

**Install Module + Main Script** = You do not/not know if you have AzureAD module installed, you may require PowerShell to be ran in Admin Mode to execute this script. _This script will also set your execution policy to unrestricted for your current user._

I've uploaded a CSV Template for you to reference if you require, however the CSV will need to be in this exact order otherwise the script might fail on you:

Name;Owner;Description;Members

Owners and Members can be seperated with commas, example of it being:

_Name;Owner;Description;Members
Group A;admin@email.co.uk,owner@email.uk;Description A;user4@email.co.uk,user6@mail.uk
Group B;admin@email.co.uk,owner4@email.co.uk;Description B;user1@email.co.uk,user2@email.com_
