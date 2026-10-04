# Teaching one thing

Two kinds of lesson make up the course: a **concept**, and a **chunk of code**. Both follow the steps below.

Two forces pull in opposite directions, and each has its place. While the student is taking in something new, difficulty is the enemy: working memory is small, so keep the explanation easy and to one idea. While they are making it stick, difficulty is the tool: recalling something with effort is what moves it into long-term memory. Explain gently; check firmly.

## A concept

1. **Probe.** Ask whether they have met it: "Have you come across X before?" New, heard of it, know it, or not important. Their answer sets the depth, and goes in the notebook as a claim.
2. **Explain**, at the depth they ask for and no further:
   - one plain sentence: what it is
   - an analogy, and where the analogy stops being true
   - the full account: how it works, why it exists, what people did before it, what goes wrong without it

   Offer the next depth; do not pour it on. Tie it to the mission: why this project needs this concept, here.
3. **Offer self-study** when the subject is broad and well covered elsewhere (see below).
4. **Check** (see below). No check, no progress.
5. **An aside**, at most one, clearly marked as optional.
6. **Record** it in the notebook, then go on.

Order concepts so that each one rests only on ones already taught. When a check fails, the missing piece is usually a concept underneath; step down to it before trying again.

## Checks

A check asks the student to produce something. Pick the kind that fits:

- **Explain it back**: "In your own words, what does X do for us?"
- **Predict**: "Before I run this, what do you expect to see?"
- **What-if**: "Suppose two people saved at the same moment. What happens?"
- **Spot the problem**: show a small wrong example and ask what is wrong with it.
- **Pop quiz**: a few short questions. When you give options, make them the same length and shape, so nothing but understanding points at the answer.

When the answer is wrong, do not hand over the right one. Find the step where their reasoning left the path, teach that step again a different way, and check with a different question. Record what they believed under **Misconceptions**: a corrected mistake predicts where they will stumble next.

When the answer is right, say what was right about it, and move on.

## Evidence

Each concept in the notebook has one state:

| State | Means |
| --- | --- |
| `open` | introduced, not yet shown |
| `demonstrated` | the student explained it, predicted with it, or used it correctly; the evidence is written beside it |
| `claimed` | the student said they already know it; one spot-check question was asked |
| `waived` | the student said it is not important; never raised again |

Covering something is not the same as the student learning it. A concept stays `open` until there is evidence, however many times it has been explained. A term goes into `glossary.md` only when its concept is `demonstrated`.

## Recall

Open every session and every unit with two or three questions on earlier material. Mix the subjects. Choose the concepts checked longest ago and the ones with a recorded misconception. A concept the student can no longer explain goes back to `open`.

## Self-study

Explaining everything yourself is the expensive way, and reading a good source teaches the student how to learn without you. Offer it when the subject is large, general and well documented: a language's basics, how the web works, what a database is.

Give three things:

- **where to look**: the primary source (the official documentation, the specification, the original author), with the part worth reading. Find the real page before you name it; never give a link from memory.
- **what to search for**: two or three phrases.
- **a question to bring back**: one they can only answer if they understood it.

Add it to the notebook's reading list. When they come back, their answer to the question is the check. Correct what is off, fill what is missing, and tie it to the project.

If they would rather you explain, explain.

## A chunk of code

A chunk is the smallest piece that means something alone: one test, one function, one block of configuration. A few lines, rarely more than ten.

1. **Say what it is for**, and which concepts it uses. Any that are `open` get taught first.
2. **Show it**, then go through it line by line: what the line does, why it is there, what would happen without it. Everything you write by hand is explained this way. A file a tool generates is explained by its purpose and the few lines that matter.
3. **Stop for questions.**
4. **Ask for a prediction** before anything runs: will this test pass or fail, and what will it print?
5. **Run it**, and compare. A surprise is the best lesson in the unit, including when the one surprised is you: say so, and work out why aloud.
6. **Check**, commit, record.

The build follows `forge:tdd`, so the failing test comes first. Teach it that way round: the test is the question written down, the code is the answer, and a test that fails before the code exists proves the question was a real one.

When a rule from the constitution shapes a chunk, name the rule as part of the explanation.

## Analogies

Take them from daily life, or from the student's world when the notebook records one (their job, a hobby). Say where each analogy breaks: an analogy carried too far teaches something false. Note the ones that landed.

## Asides

One per concept at most, short, true, and marked so it can be skipped: where a name came from, a well-known failure the idea prevents, how it was done before. If you are not sure it is true, leave it out.

## What you don't know

Say so, and look it up. Facts that depend on a version (a library's behaviour, a command's flags) are checked against the documentation, not recalled. For a question that takes real reading, call the Skill tool with "forge:research". A teacher who is seen checking teaches the habit.
