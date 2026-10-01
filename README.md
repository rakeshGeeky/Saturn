# Salesforce DX Project

Salesforce DX is a development approach that brings source-driven development, team collaboration, and continuous integration to the Salesforce Platform. Instead of working directly in an org through a web browser, you work with metadata as source files in a local DX project, track changes in version control, and deploy through automated processes.

This project template gets you started with the tools and structure you need to build Salesforce applications using source control, scratch orgs, and the Salesforce CLI.

## Prerequisites

Before you start, make sure you have:

- **Salesforce CLI** - Download from [developer.salesforce.com/tools/salesforcecli](https://developer.salesforce.com/tools/salesforcecli). See [Install Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm) for details.
- **VS Code with Salesforce Extension Pack** - See [Installation Instructions](https://developer.salesforce.com/docs/platform/sfvscode-extensions/guide/install.html) for details. Includes the Agentforce Vibes extension.
- **A development org** - Sign up for a free Developer Edition org [here](https://developer.salesforce.com/signup).
- **Dev Hub enabled** (optional, required to create scratch orgs) - You can enable Dev Hub in your development org under Setup > Dev Hub.  See [Provide Developers Access to Salesforce DX Tools](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_setup_dx_tools.htm).

## Project Structure

Your DX project follows this structure:

- **`force-app/main/default/`** - Your metadata source files live in this default package directory. You can configure additional package directories in the `sfdx-project.json` file.
- **`config/`** - Scratch org definitions and project settings
- **`scripts/`** - Automation scripts for common tasks
- **`sfdx-project.json`** - Project manifest that defines package directories, namespace, API version, and other project-level settings

See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm).

## Get Started

Ready to start developing? The [Get Started with Salesforce DX](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_get_started_dx.htm) guide walks you through your first project, from creating a scratch org to creating a simple Apex class or LWC to deploying your code to a sandbox.

## Common Salesforce CLI Commands

Here are common CLI commands that you'll use the most:

- `sf org login web`: Authorize an org
- `sf org open`: Open your org in a browser
- `sf org create scratch`: Create a scratch org
- `sf project deploy start`: Deploy metadata to your org
- `sf project retrieve start`: Retrieve metadata from your org
- `sf template generate <artifact>`: Scaffold new components, such as Apex classes and triggers, LWC components, Lightning apps, and more
- `sf apex <command>`: Run Apex tests, run anonymous Apex blocks, and view logs
- `sf data <command>`: Work with test data
- `sf alias <command>`: Manage org aliases
- `sf config <command>`: Configure CLI settings

## Use Agentforce Vibes to Build Lightning Apps

Transform your ideas into custom Lightning apps that extend CRM workflows directly in Lightning Experience. Through natural conversations with Agentforce Vibes, implement custom objects and fields, complex business logic, and dynamic UI components. See [Build a Lightning App Using Agentforce Vibes](https://developer.salesforce.com/docs/platform/einstein-for-devs/guide/lexapp-overview.html).

## Additional Resources

- [Agentforce Vibes Developer Guide](https://developer.salesforce.com/docs/platform/einstein-for-devs/guide/einstein-overview.html)
- [Salesforce CLI Installation Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)
- [Salesforce CLI Plugin Development Guide](https://developer.salesforce.com/docs/platform/salesforce-cli-plugin/guide/conceptual-overview.html)
- [Salesforce VS Code Extensions Documentation](https://developer.salesforce.com/tools/vscode/)

## Workbook-Driven Implementation Status

The repository now includes the initial Salesforce metadata skeleton derived from the Zime Care Orchestration workbook.

Coverage so far includes:
- Core patient-journey domain objects and fields
- Account-level identifiers and operational flags for the patient engagement flow
- Core Apex automation stubs for journey transitions, messaging, phone normalization, FHIR lookups, and due processing
- A deployment manifest for the initial build set

This is the foundation for the remaining modules in the workbook (security, custom metadata, flows, LWC, and integrations), which can be added in subsequent implementation passes.

The implementation now also includes workbook-aligned workflow services for consent capture, safety keyword scanning, clinical threshold handling, banned phrase validation, and patient matching, which mirror the major orchestration patterns in the workbook.

The flow layer has been extended with workbook-based record-triggered flow metadata for account normalization, message-template approval guardrails, banned-phrase scans, clinical-threshold evaluation, consent capture/withdrawal, safety escalation, journey state routing, and appointment synchronization, covering the next wave of the orchestration automation described in the workbook.

The implementation continues with workbook-aligned service logic for patient outreach eligibility, appointment-driven journey synchronization, and safety-case escalation handling, which closes the gap between the domain model and the live care-orchestration workflow.

## Lightning App

The **Zime Care Orchestration** Lightning app brings patient Accounts, Leads, Opportunities, care journeys, appointments, patient intake, clinical observations, medication statements, messages, tasks, safety cases, reports, and dashboards into one navigation bar. Care-team users can open the app from the Salesforce App Launcher after deployment and receive app/tab access through their assigned profiles or permission sets.

Care journey state changes are now guarded by `CareJourneyTrigger` against the workbook transition map, with an admin bypass custom permission. The daily due batch implements the workbook's due, snooze expiry, outreach retry-gap, future-appointment exclusion, and lost-to-follow-up checks. Due care journeys can be processed on a schedule by `ZcoJourneyDueScheduler`. Schedule it from Execute Anonymous after deployment, choosing an agreed local time:

```apex
System.schedule(
    'ZCO Daily Journey Due Processing',
    '0 0 2 * * ?',
    new ZcoJourneyDueScheduler()
);
```


## Validate and Deploy

After authenticating your Salesforce org with `sf org login web --alias <alias>`, validate the source before deploying:

```sh
sf project deploy validate --source-dir force-app --target-org <alias> --test-level RunLocalTests
sf project deploy start --source-dir force-app --target-org <alias> --test-level RunLocalTests
```

The validation command performs a check-only deployment; the start command applies the metadata. The workbook implementation was validated against the connected development org with local Apex tests.

The workbook backlog is not fully complete. Remaining work includes integrating actual WhatsApp/TeleCMI/FHIR/scheduler services, completing the draft flows and safety/consent suppression behavior, creating patient and coordinator Lightning record pages/components, and resolving org setup decisions such as Person Accounts, named credentials, queues, and clinical configuration with the org owner.
