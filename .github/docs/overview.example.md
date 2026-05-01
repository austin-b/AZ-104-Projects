# Learning Path: Terraform on Azure – Fundamentals

## Goal

Learn to use Terraform to provision and manage basic infrastructure on Azure, with an emphasis on understanding rather than copy-pasting.

By the end of this path, I should be able to:
- Write readable Terraform configuration for simple Azure resources.
- Organize configuration into logical files and modules.
- Use variables and outputs effectively.
- Manage state safely (local and remote).
- Apply changes with confidence and understand what Terraform is doing.

## Audience and starting point

Assume:
- I am comfortable with basic terminal usage and Git.
- I know the high-level idea of “infrastructure as code” but not Terraform details.
- I have an Azure subscription or sandbox environment available.

If any of these assumptions are false, ask me and adjust the early steps.

## Final deliverable

A small but realistic Terraform project that:

- Creates:
  - a resource group
  - a storage account
  - a container inside that storage account
- Uses:
  - separate files for main configuration, variables, and outputs
  - a simple module for the storage account
  - a remote backend (e.g., Azure Storage) for state, once the basics are working
- Includes:
  - a `README.md` explaining how to init, plan, apply, and destroy
  - at least one example of using `terraform console` or output values to inspect state

The repository should be something I would actually reuse as a starting template.

## Prerequisites

Before starting, I should:

- Have Terraform installed and on my PATH.
- Have the Azure CLI installed and be able to log in.
- Know how to:
  - run commands like `terraform init`, `plan`, `apply`
  - create and switch Git branches
- Have a personal or sandbox Azure subscription where I can safely create resources.

If any prerequisite is missing, guide me to a short setup step first.

## Scope boundaries

What **is** in scope:
- Terraform basics (providers, resources, data sources).
- Variables, outputs, and locals.
- Basic modules and file layout.
- State, including:
  - local state
  - moving to a remote backend
  - basic state safety practices
- Basic drift and change workflows (plan/apply/destroy).
- Azure resource group and storage account as the concrete example.

What is **not** in scope for this path:
- Complex network topologies or production-grade landing zones.
- Multi-account or multi-subscription strategies.
- Advanced testing frameworks (e.g., Terratest).
- CI/CD pipelines for Terraform.
- Deep Azure-specific architecture design (beyond what’s needed for the example).

Those can become later learning paths.

## Learning outcomes

By the end of this path, I should be able to:

- Explain, in my own words:
  - what a Terraform provider is
  - what state is and why it matters
  - how `plan` differs from `apply`
  - how variables and outputs flow through a configuration
- Create a new Terraform project from scratch for a simple use case.
- Use modules to isolate some part of the configuration.
- Safely evolve a configuration (add/change resources) and understand the plan.
- Diagnose and fix common Terraform errors (auth, missing provider, resource already exists, state mismatch).

## Reference code

If a `reference/` directory with a completed project exists in this repo:

- Treat it as the *end state* for this learning path.
- Do **not** show it to me at the beginning.
- You may look at it to infer structure and lesson ordering.
- Only refer to specific snippets if:
  - I explicitly ask to see a reference, or
  - We are comparing my solution to the reference as a review step.

## Lesson sequence

Use this sequence unless I explicitly ask to jump or reorder:

1. **Environment and project setup**
   - verify Terraform and Azure CLI
   - create a new project folder
   - create a minimal `main.tf` with an Azure provider

2. **First resource: resource group**
   - understand provider configuration
   - create a basic resource group
   - run `init`, `plan`, and `apply`

3. **Variables and outputs**
   - introduce `variables.tf` and `outputs.tf`
   - parameterize resource names and location
   - output key values (e.g., resource group name)

4. **Storage account and container**
   - add a storage account resource
   - add a container resource
   - adjust variables and outputs accordingly

5. **Project structure and modules**
   - extract storage account into a simple module
   - wire up module inputs and outputs
   - reason about what belongs in root vs module

6. **State management**
   - explain local state and where it lives
   - inspect state with `terraform state` or `terraform console`
   - migrate to a remote backend in Azure Storage (if appropriate)

7. **Change and destroy workflows**
   - add or change a property and review the plan
   - handle a common error or drift scenario
   - destroy the stack safely and confirm resources are gone

8. **Review and reflection**
   - quick quiz on key concepts
   - review my project structure
   - identify next steps (e.g., tags, locks, more resources, testing)

## Step policy

For this path:

- One main task at a time.
- Target 5–20 minutes per task.
- Always:
  - say the current lesson step
  - say why it matters
  - give a clear success check
- After completion, verify:
  - commands run successfully
  - resources exist or change as expected
  - I can explain what changed in Terraform and in Azure

If I seem to be struggling, slow down and split steps.

## Quiz policy for this path

Quiz after roughly:

- finishing lesson 3 (variables/outputs)
- finishing lesson 5 (modules)
- finishing lesson 6 or 7 (state and workflows)

Quizzes should favor:
- “explain in your own words” questions
- small “predict what this plan will do” scenarios
- errors I might realistically see in a real project

## Common mistakes to watch for

Watch for and help me correct:

- forgetting to run `terraform init` after changing providers
- misconfigured Azure authentication
- hard-coding values that should be variables
- misunderstanding the difference between plan and apply
- editing 