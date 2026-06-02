# Shipper

## Overview
**Shipper** is a set of intelligent agents and command-line interfaces for **OpenCode**, designed to automate the end-to-end software development lifecycle. By integrating directly with existing project management and version control systems, Shipper creates a seamless, "natural" workflow where AI handles research, implementation, testing, and review autonomously.

## Core Philosophy
Development teams shouldn't have to switch contexts between their ticket system, code editor, and communication tools. Shipper bridges this gap by treating tickets as the single source of truth, enabling agents to operate within the established infrastructure of teams using tools like JIRA, Linear, GitHub, and GitLab. Every agentic workflow, task definition, and review process is managed via **Markdown-based agent definitions**. During installation, the framework dynamically injects your chosen **MCP (Model Context Protocol) tool names** into these files, ensuring seamless integration with your environment.

## Key Functionality: The `/shipper` commands
Shipper operates via three primary commands:

* **/shipper:refine**: Pulls a ticket from the management system and refines it into a detailed User Story. After user validation, it updates the ticket status accordingly.
* **/shipper:ship**: Triggers the full implementation pipeline. It pulls the ticket, plans the architecture, writes the code, runs tests, creates a Merge Request (MR), handles automated reviews, and fixes findings until the feature is production-ready.
* **/shipper:fix-review-issues**: Fetches manual annotations or comments from the review system, addresses the technical debt or feedback, and re-triggers the testing/validation pipeline.

## The Pipeline
Shipper manages the entire loop:
1. **Research**: Reviewing relevant documentation and external sources.
2. **Planning**: Defining the implementation strategy based on current project docs.
3. **Coding**: Executing the plan.
4. **Testing**: Ensuring quality.
5. **Integration**: Pushing to the repository and opening a Merge Request.
6. **Review**: Self-healing loops based on review feedback.
7. **Notification**: Informing the user upon completion.

## Installation & Configuration
Shipper prioritizes flexibility. It includes an automated installation script that detects the environment and configures the necessary integrations:
* **Documentation**: Connects to your knowledge base (e.g., `context7`).
* **Project Management**: Integrates with trackers like Linear or JIRA.
* **Communication**: Hooks into messaging platforms (e.g., Slack) for real-time updates.

*Users can choose to install the configuration globally or project-specifically.*

## Roadmap & Potential Features
* **Advanced Agent Management**: Native support for Claude Managed Agents or similar high-performance LLM orchestrators.
* **Centralized Configuration**: A unified config file to manage tool mappings and model selection per task type.

## References & Inspiration
* [Twitter/X Announcement](https://x.com/zodchiii/status/2060674246880149900)
* [Conceptual Article](https://pub.spillwave.com/opencode-agents-another-path-to-self-healing-documentation-pipelines-51cd74580fc7)
* [Installation Logic Example](https://github.com/darrenhinde/OpenAgentsControl/blob/main/install.sh)
* [Usage Patterns](https://github.com/Cluster444/agentic/blob/master/docs/usage.md)
