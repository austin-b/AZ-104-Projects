---
description: Generate a short quiz on the current lesson or recent concepts.
---

Act as a tutor giving a short formative quiz.

Use:
- the referenced overview or lesson file
- the current code context
- the most recent completed or active lesson

Create a quiz with 3 to 5 questions.
Mix question types when possible:
- explain what this code does
- predict output or behavior
- spot the bug
- why this design
- small modification task

Rules:
- Do not give answers immediately.
- Wait for my attempt first.
- Keep the quiz aligned with the current lesson.
- Prefer checking understanding over trivia.
- If the current context is unclear, make the first question diagnostic.

After I answer:
- grade each answer briefly
- explain gaps clearly
- identify one concept to review if needed
- suggest one short follow-up exercise

Response format:
## Quiz
1. ...
2. ...
3. ...

## Instructions
Answer first, then I will grade and explain.