# Eviction Mediation Platform

A Ruby on Rails application facilitating early-stage dispute resolution between landlords and tenants in Franklin County, Ohio.

## Overview

The Eviction Mediation Platform provides an online mediation space to reduce court filings, promote fair agreements, and support both parties in resolving rental disputes efficiently. The platform serves tenants, landlords, mediators, and administrators with role-specific features and workflows.

## Key Features

* **Two-Factor Authentication** - SMS-based verification for enhanced security
* **Bidirectional Mediation Requests** - Either party can initiate negotiations
* **Real-Time Messaging** - ActionCable-powered chat for instant communication
* **Three-Way Mediation** - Neutral mediators with separate communication channels
* **Document Management** - PDF generation and e-signature workflows
* **Email Notifications** - Automated alerts for all major platform events
* **Resources Hub** - Educational content, FAQ, and guided resource locator
* **Admin Tools** - Mediator management, case assignment, and screening workflows

## Quick Start

### Prerequisites

* Ruby 3.4.1
* Rails 8.0.1
* Microsoft SQL Server (Developer Edition or Azure SQL Edge via Docker)
* Node.js (for asset pipeline)
* Docker (recommended for database)

### Environment Setup

1. Clone the repository
2. Install dependencies: `bundle install`
3. Configure credentials (see Developer Manual for details):
   * Database credentials
   * SMTP credentials (for email notifications)
   * Twilio credentials (for SMS 2FA)
4. Initialize database: `rails db:prepare`
5. Start server: `rails server`

For detailed setup instructions, see the **Developer Manual** in `docs/_posts/`.

## Documentation

Comprehensive documentation is available in the `docs/` directory:

* **[Developer Manual](docs/_posts/2025-03-04-developer-manual.markdown)** - Setup, architecture, deployment, and handoff information
* **[User Manual](docs/_posts/2025-04-02-user-manual.markdown)** - End-user guide for all roles

### For Future Development Teams

The Developer Manual includes critical handoff information:

* **Credentials Setup** - Required SMTP and Twilio account setup
* **Environment Configuration** - All required environment variables
* **Project Status** - Completed milestones, known issues, and what's left to do
* **Feature Roadmap** - Prioritized list of future enhancements
* **Testing** - Running the test suite (40 tests, 171 assertions)

## Testing

Run the test suite:

```bash
rails test
```

All tests should pass (40 runs, 171 assertions, 0 failures, 0 errors).

## Technology Stack

* **Backend:** Ruby on Rails 8.0.1
* **Database:** Microsoft SQL Server (Azure SQL Edge)
* **Real-Time:** ActionCable (WebSockets)
* **Frontend:** ERB views, plain JavaScript
* **Email:** ActionMailer with SMTP
* **SMS:** Twilio API
* **Containerization:** Docker

## Project Status

### Completed (Fall 2024 - Autumn 2025)

✅ Core mediation workflows
✅ Two-factor authentication
✅ Email notification system
✅ Document management with e-signatures
✅ Resources page with educational content
✅ Admin and mediator tools
✅ Comprehensive test suite
✅ Production deployment infrastructure

### Future Enhancements

* SMS notifications for mediation events
* Admin analytics dashboard
* Automated data deletion (1-year retention)
* Chat escalation suggestions (AI-powered)
* Mobile applications (iOS/Android)
* Multi-language support

## Contributing

This project is maintained as part of CSE 5911 at The Ohio State University. For future development teams:

1. Review the Developer Manual thoroughly
2. Set up all required credentials (SMTP, Twilio, database)
3. Run the test suite to verify your environment
4. Contact stakeholders at Franklin County Municipal Court

## Contact

For questions about the platform or development:

* Franklin County Municipal Court: [Contact Information]
* Course Instructor: Felix Engelmann (engelmann.17@osu.edu)

---

**Note:** Detailed setup instructions, architecture documentation, and handoff information are in the Developer Manual. Start there for all development activities.
