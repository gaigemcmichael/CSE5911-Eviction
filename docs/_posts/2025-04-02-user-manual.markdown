---
layout: post
title:  "User Manual"
date:   2025-04-02 20:05:26 -0500
categories: documentation
---
## Introduction

The Eviction Mediation Platform is designed to facilitate early-stage dispute resolution between landlords and tenants in Franklin County. By providing an online mediation space, the system aims to reduce court filings, promote fair agreements, and support both parties in resolving rental disputes efficiently. This manual serves as a comprehensive guide for users to navigate the platform, from account creation to participation in mediation. Additionally, it details the roles and permissions available, ensuring a clear definition of each user’s capabilities within the system.

## User Roles and Permissions

### Overview of Roles

a. There are 4 role types in our system: Admin, Mediator, Tenant, and Landlord. For any given user, its role is stored in the ‘Role’ attribute in the Users table (in the DB).
b. Tenants and Landlords serve as our primary end users available to the public.
c. Mediators serve as another end user, but their creation is verified and restricted. They will be available to employees and volunteers and will act as the 3rd party mediator between tenants and landlords.
d. Admins have the highest level of access; they will be reserved for a few direct employees. 

### Role-Specific Permissions and Capabilities

a. Tenants

* Can create accounts freely.
* Tenants can request negotiations between their landlords. Once these begin, they may request a 3rd party mediator at any time during these negotiations.
* Tenants can access our financial calculator to assist in generating proposal solution forms. We have found that mediation is more successful when a tenant comes with a potential solution.

b. Landlords

* Can create their accounts freely.
* Landlords can accept negotiation requests from their Tenants. Once these begin, they may request a 3rd party mediator at any time during these negotiations. 
* Landlords can access our financial calculator to assist in generating proposal solution forms. 

c. Mediators

* These accounts will need to be created by an admin for a mediator user.
* Mediators will be assigned to mediation between landlords and tenants.
* Mediators will be able to flag whether they are available for work and will have a cap (that can be changed) on how many active mediations they can be a part of at one time.

d. Administrators

* Admin accounts will need to be set up by other admins or directly in the backend environment.
* These accounts will be able to monitor all user interactions with the system, access demographic data that has been collected, and directly alter other user attributes.
* Additionally, these users will be tasked with addressing issues brought up in our mediation screening questions.

## Getting Started

### Accessing the Application

There is no permanent link available for the app yet; whenever that is established, more detailed instructions can be provided about accessing the app. As of SP2025, control of the Eviction 1 Github repository has been transferred to Felix, the course’s instructor.

### Creating an Account

1. To create an account, click the **Sign Up** option.
2. Next, fill out the form displayed. Then read and accept the Terms and Conditions and click the **Sign Up** button.
3. Congrats! You have successfully created an account!

### Logging In and Out

1. After creating your account, enter your email and password and select the **Log In** button.
2. To log out simply select the **Log Out** button on the dashboard.

### Landlord Navigation

- How to Navigate: 
  - Check the **Messages** tab for updates on negotiations 
  - View and manage your documents on the **Documents** tab 
  - Update your profile & settings from the **Account** tab 
- Accepting Negotiation from Your Tenant: 
  - Go to the **Messages** tab. 
  - Accept the negotiation from your tenant. 
- If you want to start a Mediation: 
  - Request a mediator in the **Messages** tab. 
- If you want to stop a Negotiation/Mediation: 
  - Go to the **Messages** tab and access your negotiation/mediation to end it.
 
### Tenant Navigation 

- How to Navigate: 
  - Check the **Messages** tab for updates on negotiations 
  - Need more information? Visit the **Resources** tab 
  - View and manage your documents on the **Documents** tab 
  - Update your profile & settings from the **Account** tab 
- Start a Negotiation: 
  - Go to the **Messages** tab. 
  - Initiate a negotiation with your landlord. 
- If you want to start a Mediation: 
  - Request a mediator in the **Messages** tab. 
- If you want to stop a Negotiation/Mediation: 
  - Go to the **Messages** tab and access your negotiation/mediation to end it. 

### Mediator Navigation 

- Mediator Availability: 
  - Your status is listed on the **Home** tab. 
  - You can update it on the **Account** tab. 
- How to Navigate: 
  - Access assigned mediations on the **Mediations** tab. 
  - View account details on the **Account** tab. 
  - Update password on the **Account** tab. 

### Admin Navigation 

- Mediator Availability: 
  - All mediators and their statuses are listed on the **Home** tab. 
- How to Navigate: 
  - Check flagged and current mediations in the **Mediations** tab. 
  - Update a Mediator’s account in the **Manage Accounts** tab. 

## Appendices

### Glossary

A
*	Admin – A user role with the highest level of access, responsible for overseeing the system, managing user accounts, and ensuring compliance with policies.

D
*	Database (DB) - The structured storage system where user accounts, roles, negotiations, and mediation data are stored and managed.
*	Demographic Data - Information about users collected within the system, used for monitoring and reporting purposes.

E
*	Eviction Mediation - A structured process where tenants and landlords resolve rental disputes with the help of a neutral third-party mediator, aiming to avoid court filings.

F
*	Financial Calculator - A tool provided within the platform to help users generate proposal solutions by assessing their financial situation.

M
*	Mediation - The process of dispute resolution facilitated by a neutral party (Mediator) between tenants and landlords.
*	Mediator- A verified user role responsible for facilitating negotiations between landlords and tenants. These accounts are created by Admins.

N
*	Negotiation Request - A request initiated by a tenant or landlord to begin discussions aimed at resolving a rental dispute through the platform.

P
*	Proposal Solution Form - A structured document generated within the system that presents possible resolutions based on the financial calculator’s output.

R
*	Role - A system attribute defining a user’s level of access and permissions (Admin, Mediator, Tenant, or Landlord).

T
*	Tenant - A primary end user of the system, who can request mediation with their landlord and access financial planning tools.


### References & Additional Resources

1. [Self Help Center](https://franklincountymunicourt.org/Departments-Services/Self-Help/External-Resources/Legal-Help)
