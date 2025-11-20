---
layout: post
title:  "User Manual"
date:   2025-11-20 17:59:43 -0500
categories: documentation
---
## Introduction

The Eviction Mediation Platform is designed to facilitate early-stage dispute resolution between landlords and tenants in Franklin County. By providing an online mediation space, the system aims to reduce court filings, promote fair agreements, and support both parties in resolving rental disputes efficiently. The site will also serve to educate tenants and unfamiliar landlords with the mediation process. This manual serves as a comprehensive guide for users to navigate the platform, from account creation to participation in mediation. Additionally, it details the roles and permissions available, ensuring a clear definition of each user’s capabilities within the system.

## User Roles and Permissions

### Overview of Roles

a. There are 4 role types in our system: Admin, Mediator, Tenant, and Landlord. For any given user, its role is stored in the ‘Role’ attribute in the Users table (in the DB).
b. Tenants and Landlords serve as our primary end users available to the public.
c. Mediators serve as another end user, but their creation is verified and restricted. They will be available to employees and volunteers and will act as the 3rd party mediator between tenants and landlords.
d. Admins have the highest level of access; they will be reserved for a few direct employees to manage the mediators.

### Role-Specific Permissions and Capabilities

a. Tenants

* Can create accounts freely.
* Tenants can request and accept negotiations between their landlords. Once these begin, they may request a 3rd party mediator at any time during these negotiations.
* Tenants can access our financial calculator(document generator) to assist in generating proposal solution forms. We have found that mediation is more successful when a tenant comes with a potential solution.

b. Landlords

* Can create their accounts freely.
* Landlords can accept and request negotiation requests from their Tenants. Once these begin, they may request a 3rd party mediator at any time during these negotiations.
* Landlords can access our financial calculator(document generator) to assist in generating proposal solution forms.

c. Mediators

* These accounts will need to be created by an admin for a mediator user.
* Mediators will be assigned to mediation between landlords and tenants by an admin once a mediation becomes flagged.
* Mediators will be able to update their status whether they are available for work and will have a cap (that can be changed) on how many active mediations they can be a part of at one time.

d. Administrators

* Admin accounts will need to be set up by other admins or directly in the backend environment.
* One of their main responsibilities is to assign mediators to requested mediations.
* These accounts will be able to monitor all user interactions with the system, access demographic data that has been collected, and directly alter other user attributes.
* Additionally, these users will be tasked with addressing issues brought up in our mediation screening questions.

## Getting Started

### Accessing the Application

* Hosting: There is no permanent link available for the app yet; whenever that is established, more detailed instructions can be provided about accessing the app. As of AU2025, control of the Eviction 1 Github repository will be transferred to Felix, the course’s instructor.
* Accessing: The group currently envisions a flyer that would be attached to an eviction notice that would advertise for tenants to use the site to avoid court by using the platform. Also, advertising to landlords to use the site at court would be done which would inform them of the (proposed) benefits of reduced evictions filing fees(if the mediation fails in good faith).

### Creating an Account

1. To create an account, click the **Sign Up** option.
2. Next, fill out the form displayed. Then read and accept the Terms and Conditions and click the **Sign Up** button.
3. You will be sent a confirmation code through either email or SMS which you will be required to enter to verify your account. Once the code is entered you have gained access to the site.
4. Congrats! You have successfully created an account!

### Logging In and Out

1. After creating your account, enter your email/phone number and password and select the **Log In** button.
2. All accounts have two factor authentication automatically enabled so you will be prompted to enter the verification code sent to your sign up email/phone number(this can be disabled in account settings).
3. To log out simply select the **Log Out** button in the navigation bar.

### Revamped Resources Page

* The work of the second group of the SP25 semester with their education platform will be used to create an informative Resources page.
* Tenants will be able to watch videos about the eviction/mediation process and how to mediate effectively. Also, tenants will be able to use a question-based, guided resource locator that helps them find resources that best help them with their situation.
* Landlords will also have educational resources which will guide them on how to mediate effectively and also help unfamiliar landlords/property managers understand the eviction/mediation process.

### Landlord Navigation

* How to Navigate:
  * Get an overview of the site and how to use it on the **Home** tab
  * Check the **Messages** tab for updates on negotiations
  * View and manage your documents on the **Documents** tab
  * Learn about mediation and access useful resources on the **Resources** tab
  * Update your profile & settings from the **Account** tab
* Accepting/Requesting Negotiation with Your Tenant:
  * Go to the **Messages** tab.
  * Accept/Request the negotiation from your tenant.
* If you want to start a Mediation:
  * Request a mediator in the **Messages** tab.
* If you want to stop a Negotiation/Mediation:
  * Go to the **Messages** tab and access your negotiation/mediation and select the end negotiation button to end it.

### Tenant Navigation

* How to Navigate:
  * Get an overview of the site and how to use it on the **Home** tab
  * Check the **Messages** tab for updates on negotiations
  * Need more information? Visit the **Resources** tab to learn about the mediation process and get guided to resources that benefit you most
  * View and manage your documents on the **Documents** tab
  * Update your profile & settings from the **Account** tab
* Accepting/Requesting Negotiation with Your Landlord:
  * Go to the **Messages** tab.
  * Accept/Request the negotiation from your landlord.
* If you want to start a Mediation:
  * Request a mediator in the **Messages** tab.
* If you want to stop a Negotiation/Mediation:
  * Go to the **Messages** tab and access your negotiation/mediation and select the end negotiation button to end it.

### Mediator Navigation

* Mediator Availability:
  * Your status is listed on the **Home** tab.
  * You can easily update it by clicking the quick link on the home page which take you to the **Account** tab or manually navigate to and update it on the **Account** tab.
* How to Navigate:
  * Access assigned mediations on the **Mediations** tab.
  * View account details on the **Account** tab.
  * Update password on the **Account** tab.

### Admin Navigation

* Mediator Availability:
  * All mediators and their statuses are listed on the **Home** tab.
* How to Navigate:
  * Check flagged and current mediations in the **Mediations** tab.
  * Update a Mediator’s account in the **Manage Accounts** tab.

## Appendices

### Glossary

A

* Admin – A user role with the highest level of access, responsible for overseeing the system, managing user accounts, and ensuring compliance with policies.

D

* Database (DB) - The structured storage system where user accounts, roles, negotiations, and mediation data are stored and managed.
* Demographic Data - Information about users collected within the system, used for monitoring and reporting purposes.

E

* Eviction Mediation - A structured process where tenants and landlords resolve rental disputes with the help of a neutral third-party mediator, aiming to avoid court filings.

F

* Financial Calculator - A document generator tool provided within the platform to help users generate proposal solutions by assessing their financial situation.

M

* Mediation - The process of dispute resolution facilitated by a neutral party (Mediator) between tenants and landlords.
* Mediator- A verified user role responsible for facilitating negotiations between landlords and tenants. These accounts are created by Admins.

N

* Negotiation Request - A request initiated by a tenant or landlord to begin discussions aimed at resolving a rental dispute through the platform.

P

* Proposal Solution Form - A structured document generated within the system that presents possible resolutions based on the financial calculator’s output.

R

* Role - A system attribute defining a user’s level of access and permissions (Admin, Mediator, Tenant, or Landlord).

T

* Tenant - A primary end user of the system, who can request mediation with their landlord and access financial planning tools.

### References & Additional Resources

1. [Self Help Center](https://franklincountymunicourt.org/Departments-Services/Self-Help/External-Resources/Legal-Help)
