# Copilot Learning Assistant Starter README

This repository structure turns GitHub Copilot in VS Code into a reusable learning assistant rather than a tool that only generates final answers. Repository-wide custom instructions provide the default teaching behavior, while prompt files let specific workflows such as starting a lesson, getting the next task, asking for hints, or taking a quiz be reused across different topics.

## What this structure does

The setup separates always-on behavior from task-specific interactions. GitHub documents repository-wide custom instructions in `.github/copilot-instructions.md`, and prompt files are reusable Markdown-based prompts for specific tasks that can be invoked when needed in supported IDEs such as VS Code.

Instead of asking Copilot to both define the lesson and teach it from scratch every time, this structure gives it three layers of context:

- A repository-wide instruction file that makes Copilot behave like a tutor.
- One or more reusable prompt files for common learning actions.
- A path-specific `overview.md` that defines the goals, scope, sequence, and success criteria for a given learning track.

This keeps the teaching style stable while letting the subject matter change from project to project.

## Recommended layout

A practical repository layout looks like this:

```text
.github/
  copilot-instructions.md
  instructions/
    terraform.instructions.md
  prompts/
    start-lesson.prompt.md
    next-task.prompt.md
    hint-ladder.prompt.md
    quiz-me.prompt.md
    review-my-work.prompt.md
    explain-this-code.prompt.md
    recover-when-stuck.prompt.md
learning/
  terraform-azure-fundamentals/
    overview.md
    reference/
```

### Folder roles

| Path | Purpose |
|---|---|
| `.github/copilot-instructions.md` | Repository-wide learning behavior that applies across the workspace. |
| `.github/instructions/terraform.instructions.md` | Topic-specific or file-type-specific rules, such as Terraform guidance. |
| `.github/prompts/` | Reusable prompt files for lesson starts, task progression, hints, quizzes, and reviews. |
| `learning/<path>/overview.md` | Curriculum anchor for one learning path, including goals, sequence, and constraints. |
| `learning/<path>/reference/` | Optional final reference implementation used as an end-state, not a starting point. |

## How the pieces work together

### 1. `copilot-instructions.md`

This file defines the default teaching contract. GitHub and VS Code describe repository-wide custom instructions as natural-language Markdown files that guide how Copilot should behave across the project.

In this setup, the main instructions should make Copilot:

- teach instead of immediately solve
- give one task at a time
- prefer hints before full answers
- review work against the current learning objective
- quiz periodically
- use any referenced `overview.md` as the curriculum source of truth

### 2. Prompt files

Prompt files are reusable prompts for specific workflows, and GitHub describes them as a separate customization mechanism from always-on instructions.

Typical prompt files in this structure are:

- `start-lesson.prompt.md`
- `next-task.prompt.md`
- `hint-ladder.prompt.md`
- `quiz-me.prompt.md`
- `review-my-work.prompt.md`
- `explain-this-code.prompt.md`
- `recover-when-stuck.prompt.md`

These are useful because they reduce prompt repetition and make it easier to reuse the same learning system for Terraform, Python, Linux scripting, certification prep, or any other topic with a good overview file.

### 3. `overview.md`

The overview file is the curriculum and pacing document for a single path. It should tell Copilot what the learner is trying to achieve, what is in scope, how the lessons should progress, what the final deliverable looks like, and how to verify progress.

A good `overview.md` usually includes:

- learning goal
- learner starting point
- final deliverable
- prerequisites
- scope boundaries
- learning outcomes
- lesson sequence
- step policy
- quiz policy
- common mistakes
- stretch goals

Without an overview, Copilot can still help, but it is more likely to improvise the sequence rather than follow a coherent path.

## How to use it in practice

### Start a new learning path

1. Create a folder under `learning/` for the topic.
2. Add an `overview.md` that defines the path.
3. Optionally add a `reference/` folder with the completed end-state project.
4. Add topic-specific instruction files only if needed, such as Terraform-specific coaching rules.

Example:

```text
learning/
  terraform-azure-fundamentals/
    overview.md
    reference/
```

### Start a session in VS Code

Open the repository in VS Code with Copilot enabled. Repository instructions apply across the workspace, and prompt files can be invoked for specific workflows in supported IDEs.

A practical session flow is:

1. Open the relevant `overview.md`.
2. Invoke the `start-lesson` prompt.
3. Complete the task Copilot gives you.
4. Use `review-my-work` after each step.
5. Use `next-task` to continue.
6. Use `hint-ladder` when blocked.
7. Use `quiz-me` after a concept chunk.

### Suggested rhythm

| Stage | Prompt to use | Purpose |
|---|---|---|
| Beginning a path | `start-lesson.prompt.md` | Establish current lesson and first task. |
| During implementation | `next-task.prompt.md` | Move forward in small, controlled steps. |
| When stuck | `hint-ladder.prompt.md` | Get incremental help without losing the learning benefit. |
| After a step | `review-my-work.prompt.md` | Check correctness and get focused improvement suggestions. |
| After a concept block | `quiz-me.prompt.md` | Reinforce understanding with short questions. |
| When reading unfamiliar code | `explain-this-code.prompt.md` | Build conceptual understanding from working examples. |
| When blocked or confused | `recover-when-stuck.prompt.md` | Diagnose the blocker and restore momentum. |

## Writing a good `overview.md`

The overview file is the most important path-specific artifact. The better it defines the target, sequence, and constraints, the more consistent Copilot becomes as a learning assistant.

A strong overview should answer:

- What am I learning?
- What should I be able to do at the end?
- What assumptions are being made about my current skill level?
- What is in scope and out of scope?
- What order should topics be taught in?
- How should progress be checked?
- When should quizzes happen?
- What mistakes should Copilot watch for?

For example, a Terraform overview might specify a path from provider setup to first resources, then variables and outputs, then modules, then state management, then change and destroy workflows.

## Terraform-specific guidance

A Terraform-specific instruction file is useful because Terraform learning benefits from stronger guardrails than general coding. It should reinforce safe workflows such as running `terraform plan` before `apply`, understanding state, reading errors carefully, and avoiding premature complexity in modules or dynamic expressions.

A good Terraform instruction file should encourage Copilot to:

- teach providers, resources, variables, outputs, modules, and state clearly
- favor small infrastructure changes and readable configuration
- help interpret plans before applying changes
- diagnose authentication, configuration, and state issues methodically
- avoid hiding risky or destructive behavior behind large rewrites

This keeps the interaction educational and reduces the risk of learning bad habits.

## Design principles behind this setup

This structure works best when it follows a few simple principles:

- **Stable behavior, flexible content**: the main instructions stay mostly the same, while `overview.md` changes by topic.
- **One task at a time**: learning degrades when Copilot collapses multiple concepts into one response.
- **Hints before answers**: this preserves active problem-solving.
- **Verification before advancing**: lessons should not move forward until the current step works.
- **Review and quiz loops**: these convert passive reading into active learning.

## Common mistakes

These are the most common ways this setup becomes less effective:

- The overview is too vague, so Copilot invents its own lesson sequence.
- The prompt files overlap too much, so every interaction feels the same.
- The learner asks for the full solution too often, which turns the workflow into assisted coding instead of learning.
- Topic-specific rules are missing when the subject has special safety concerns, such as Terraform state or infrastructure changes.
- The reference implementation is used too early, which weakens discovery and practice.

## Tips for keeping it reusable

To reuse this structure across multiple topics:

- Keep `.github/copilot-instructions.md` generic and teaching-focused.
- Add topic-specific instruction files only when the subject needs extra rules.
- Use the same prompt library across all learning paths.
- Standardize the shape of every `overview.md` so Copilot can recognize goals, scope, lesson order, and checks quickly.
- Keep each learning path in its own folder under `learning/`.

This makes it easy to create new paths such as:

- `learning/python-flask-api/`
- `learning/linux-automation/`
- `learning/terraform-azure-fundamentals/`
- `learning/cert-study-az-104/`

## Example workflow

A simple end-to-end workflow might look like this:

1. Open `learning/terraform-azure-fundamentals/overview.md`.
2. Run the `start-lesson` prompt.
3. Implement the first task, such as creating a provider block and a resource group.
4. Ask Copilot to review the work using `review-my-work`.
5. Continue with `next-task`.
6. Use `quiz-me` after variables and outputs.
7. Use `hint-ladder` if blocked on modules or state.
8. Finish with a review and a short reflection.

That pattern is simple enough to repeat, but structured enough to keep the learning experience coherent.

## Setup notes

Custom instructions should be written in Markdown and stored in `.github/copilot-instructions.md` at the repository root.

Prompt files are reusable Markdown prompt definitions available in supported IDEs, including VS Code, and they are intended for task-specific invocation rather than always-on behavior.

Because prompt files are more granular and reusable than a single large chat prompt, they are especially useful for standardizing recurring tasks such as lesson starts, reviews, quizzes, and code explanation workflows.