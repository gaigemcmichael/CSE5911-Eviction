---
layout: post
title:  "User Manual"
date:   2025-12-04
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
2. Next, fill out the form displayed, including your email address and phone number.
3. Read and accept the Terms and Conditions and click the **Sign Up** button.
4. You will be sent a verification code via SMS to your phone number to verify your account.
5. Enter the verification code when prompted.
6. Congrats! You have successfully created an account with two-factor authentication enabled for enhanced security!

### Logging In and Out

**Logging In:**

1. Enter your email address and password, then click the **Log In** button.
2. You will receive a verification code via SMS to your registered phone number (two-factor authentication).
3. Enter the verification code when prompted to complete login.
4. Two-factor authentication is enabled by default for all accounts for your security. You can disable it in your Account settings if preferred.

**Logging Out:**

* To log out, simply click the **Log Out** button in the navigation bar.

**Email Notifications:**

* You will receive email notifications for important events such as:
  * Welcome email
  * New mediation requests
  * Unread message reminders (after 4 hours)

## Features & Enhancements

### Two-Factor Authentication (2FA)

All accounts now include SMS-based two-factor authentication for enhanced security:

* Automatically enabled when you create your account
* Verification codes sent via SMS to your registered phone number
* Provides an extra layer of protection for your account
* Can be disabled in Account settings if you prefer (though we recommend keeping it enabled)

### Bidirectional Mediation Requests

Both tenants and landlords can now initiate mediation:

* **Tenants** can request negotiations with their landlords
* **Landlords** can also request negotiations with their tenants
* If the other party doesn't have an account, they will automatically receive an email invitation to join the platform
* This flexibility allows either party to take the first step toward resolving disputes

### Resources Page

Comprehensive educational resources to help you through the mediation process:

* **FAQ Section:** Answers to common questions about eviction and mediation
* **Tenant Resources:**
  * Information about tenant rights and responsibilities
  * Guided resource locator to find help specific to your situation
  * Tips for preparing for mediation
  * Financial assistance resources
* **Landlord Resources:**
  * Guide to effective mediation techniques
  * Overview of the eviction and mediation process
  * Information for property managers new to mediation
  * Legal requirements and best practices

### Post-Mediation Survey

After completing a mediation or negotiation:

* You'll be asked to complete a brief survey about your experience
* Questions cover ease of use, communication effectiveness, and device compatibility
* Your feedback helps improve the platform for future users
* Survey responses are confidential and used for platform improvement only

### Landlord Navigation

**How to Navigate:**

* **Home Tab:** Overview of the site and quick access to key features
* **Messages Tab:** View and manage all negotiations and mediations
* **Documents Tab:** Generate, view, download, and sign documents
* **Resources Tab:** Access educational content and mediation guides
* **Account Tab:** Update your profile, password, and notification settings

**Starting or Accepting a Negotiation:**

1. Go to the **Messages** tab
2. To **request negotiation** with your tenant:
   * Click the option to request negotiation
   * If your tenant doesn't have an account, they'll automatically receive an email invitation
   * Enter the tenant's contact information and property address
3. To **accept a negotiation request** from your tenant:
   * You'll see pending requests in the Messages tab
   * Review the request details and click Accept

**Requesting a Mediator:**

* Once negotiations have begun, either party can request a neutral third-party mediator
* Go to the **Messages** tab, open the active negotiation, and click "Request Mediator"
* You'll need to complete a brief screening questionnaire
* An admin will assign a mediator to your case

**Ending a Negotiation/Mediation:**

* Go to the **Messages** tab
* Open the active negotiation/mediation
* Click the "End Negotiation" button
* You'll be asked to provide feedback about the other party's good faith participation
* After ending, you'll have the option to complete a brief survey about your experience

### Tenant Navigation

**How to Navigate:**

* **Home Tab:** Overview of the site and quick access to key features
* **Messages Tab:** View and manage all negotiations and mediations
* **Resources Tab:** Educational videos, FAQ, and guided resource locator
* **Documents Tab:** Generate payment plans, view, download, and sign documents
* **Account Tab:** Update your profile, address, password, and notification settings

**Starting or Accepting a Negotiation:**

1. Go to the **Messages** tab
2. To **request negotiation** with your landlord:
   * Click the option to request negotiation
   * Fill out the intake questionnaire with information about your situation
   * Provide your landlord's contact information
   * If your landlord doesn't have an account, they'll receive an email invitation
3. To **accept a negotiation request** from your landlord:
   * You'll see pending requests in the Messages tab
   * Review the request details and click Accept
   * Fill out the intake questionnaire

**Using the Financial Calculator:**

* Available in the **Documents** tab
* Helps you create a payment plan proposal
* Enter your income, expenses, and proposed payment amounts
* Generates a professional document you can share with your landlord

**Requesting a Mediator:**

* Once negotiations have begun, either party can request a neutral third-party mediator
* Go to the **Messages** tab, open the active negotiation, and click \"Request Mediator\"
* You'll need to complete a brief screening questionnaire
* An admin will assign a mediator to your case

**Ending a Negotiation/Mediation:**

* Go to the **Messages** tab
* Open the active negotiation/mediation
* Click the \"End Negotiation\" button
* You'll be asked to provide feedback about the other party's good faith participation
* After ending, you'll have the option to complete a brief survey about your experience

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

* Role - A system attribute defining a user's level of access and permissions (Admin, Mediator, Tenant, or Landlord).

T

* Tenant - A primary end user of the system, who can request mediation with their landlord and access financial planning tools.
* Two-Factor Authentication (2FA) - A security feature that requires users to verify their identity with a code sent via SMS in addition to their password.

## Platform Status

### Current Capabilities (As of December 2025)

The Eviction Mediation Platform currently provides:

* **Core Features:**

* Two-factor authentication for all users
* Bidirectional mediation requests (tenant or landlord can initiate)
* Real-time messaging between parties
* Three-way mediation with neutral mediators
* Document generation and e-signatures
* Email notifications for major events
* Educational resources page with FAQ and videos
* Post-mediation surveys for feedback

### Your Feedback Matters

After completing a mediation, you'll be asked to complete a brief survey. Your feedback helps the development team:

* Identify areas for improvement
* Prioritize new features
* Enhance user experience
* Measure platform effectiveness

Thank you for helping us improve the platform for all users!

### References & Additional Resources

1. [Franklin County Municipal Court Self Help Center](https://franklincountymunicourt.org/Departments-Services/Self-Help/External-Resources/Legal-Help)
2. [Ohio Legal Help - Eviction Resources](https://www.ohiolegalhelp.org/)
3. [Legal Aid Society of Columbus](https://www.columbuslegalaid.org/)
