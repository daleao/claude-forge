# The syllabus

Each unit is a Forge step, run as a class. The engineering is the same; who decides, where the documents go, and the pace are different. Each unit below names the reference to follow and what changes.

Open every unit by saying what it is for and what the student will be able to do at the end of it, then a short recall quiz. Close it by updating the notebook's syllabus and **Next** line, and offer a break.

## Unit 0: Orientation

1. **The idea**, in the student's own words. Ask them to describe it as they would to a friend.
2. **The mission.** Why do they want this, and what do they want to be able to do when the course is over? Push past "to understand it" to something concrete. Every later lesson is tied back to this.
3. **The baseline.** What have they done before: any programming, a terminal, version control? Record each as `claimed`. Ask which world they would like analogies from.
4. **How class works.** The things they can say at any time, that you will ask questions and wait, that "I don't know" is a useful answer, and that they will be invited to read on their own.
5. **The road ahead**: the units, a sentence each.

In an existing project, explore the code yourself first. Finding facts is your job, never the student's.

## Unit 1: The design questions

Reference: call the Skill tool with "forge:grilling" and "forge:domain-modeling". Build the same **design tree**, work its **frontier**, size the scope first, and lay out real alternatives. What changes is who answers.

Sort every decision on the tree into one of two kinds:

- **Intent**: it turns on what the student wants, who it is for, or their taste. Ask it, in plain words with no jargon, with two or three example answers to choose between or depart from. These are few.
- **Technical**: everything else. You decide it, and it becomes a lesson.

A decision lesson has five parts, after the concepts it needs have been taught:

1. **The question**, in plain words.
2. **Why it has to be answered**: what goes wrong if nobody answers it, and who ends up answering it by accident.
3. **The options**: the two or three real ones, and what each one buys and costs.
4. **Your choice, and why.**
5. **What would change it**: the fact about this project that, if different, would make another option right.

Then check: have the student say it back, or pose a what-if ("Suppose ten thousand people used this instead of ten. Which option starts to hurt?").

The other differences:

- **One decision per turn**, prerequisites first, in place of rounds.
- **No silent defaults.** The small decisions Forge would list as defaults are still shown, a sentence or two each, in a batch. The student can say "deeper" on any of them.
- **Scope is yours.** If the idea is several independent pieces, you choose which is built first and teach why.
- **The project foundation**, in an empty folder, is a run of lessons: the language, the runtime, the package manager, the test runner, the typechecker, the linter. For each: what job it does, and why this one.
- Write each decision and its reason into the notebook as it is taught. Glossary terms and ADRs are written as `forge:domain-modeling` says; the first ADR is also the lesson on what an ADR is.
- `forge:research` and `forge:prototype` are available as detours. A prototype makes a good lesson.

**Closing.** Ask the student to retell the design in their own words first. Then show the six lists (problem, goals, non-goals, constraints, decisions, unknowns) and compare the two. Where their account and yours differ on intent, theirs wins; where it differs on a technical decision, that decision has not been taught yet.

## Unit 2: The spec

Reference: read [the spec skill](../spec/SKILL.md) and [its templates](../spec/TEMPLATES.md), and follow steps 1 to 4. What changes:

- **You choose the tier and the seams.** Teach what the tiers are and why the work is this one. Teach what a seam is with care: every test in the build depends on it.
- **The spec is a file**, `.forge/class/<course>/spec.md`, not an issue. Nothing is published and no repository on GitHub is needed.
- **There is no approval step.** Read it through together instead, section by section: what the section is for, who reads it later, then what it says.
- **Acceptance criteria get an exercise.** For each `AC-n`, the student says how someone would watch it pass or fail. Then give them one behaviour and have them write the criterion themselves.
- **Do the self-review aloud**, so the student sees what a careful reader looks for.

If the student says a line does not match what they want, that is intent: change the line.

## Unit 3: The slices

Reference: read [the slice skill](../slice/SKILL.md) and follow steps 1 to 3, with its template. What changes:

- **Slices are files**: `slices/01-<name>.md`, `slices/02-<name>.md`, using the template's headings. `## Parent` names `spec.md`, and `## Blocked by` cites slice numbers.
- **The breakdown is yours**, so there is no quiz for approval. Teach it:
  - what a vertical slice is, against building one layer at a time, with an analogy
  - why each cut is where it is
  - why the order is what it is: which slice makes the next one possible
  - the coverage table, as the proof that nothing in the spec was left out and nothing was added
- Keep `## Touches`. The class builds one slice at a time, so nothing depends on it here; it is worth an aside on how the unattended Forge uses it to build slices side by side.
- Append the `## Slices` checklist to `spec.md`. It is the course's progress bar.

Check with what-ifs: "If we built slice 3 before slice 2, what would break?" "Which slice could you show a friend first, and what would they see?"

## Units 4 to n: one per slice

Build in this session, one slice at a time in dependency order, on the branch `class/<course>`. Record the branch it started from in the notebook; the audit needs it.

1. **Open**: what this slice will make work, and which concepts it needs. Teach the ones still `open` before any code.
2. **Build**: call the Skill tool with "forge:tdd". Each acceptance criterion goes from a failing test to a passing one, in chunks, taught as [LESSON.md](LESSON.md) says. Test at the seams the spec names. Commit each increment and say what a reader of the history will learn from the message.
3. **When something fails that you did not expect**: call the Skill tool with "forge:debugging" and work it aloud. Ask the student for their guess first.
4. **Done**: call the Skill tool with "forge:verification" and go through each criterion with the student: "What would convince you this works?" Run the gate. Tick the slice in `spec.md`.
5. **Demo**: the student runs the slice's `## Verify` steps themselves.

The rules of the build are in `.forge/constitution.md` if the project has one, and in `templates/constitution.md` at the plugin root if it does not.

**The foundation slice** comes first in a new project, and it defines the gate. Record the gate command in the notebook, and in `.forge/config.sh` as well if that file exists.

**When the plan turns out wrong**, change the spec or the slices, and teach what you learned and why the plan moved. Plans meeting reality is part of the subject.

## Final unit: Audit and review

### The audit

Reference: read [the QA skill](../qa/SKILL.md) and run it in full. The audit is attended, and it is not a line-by-line lesson: you stop only to explain and discuss what the reviewers find.

- **Inputs.** The fixed point is the base branch from the notebook. `spec.md` is the course's spec, and `slices.md` is the slice files joined together.
- **Before dispatching**, one short lesson: what an audit is, and why three reviewers who see neither each other's work nor your account of it.
- **Dispatch all three reviewers**, as the skill says. Take questions while they work.
- **Save the three reports**, verbatim, to `qa-report.md`.
- **Each `[BLOCKER]` and `[IMPORTANT]` finding gets a stop.** Check it against the code first, since a finding is a claim. Then say in plain words what the reviewer claims, what would go wrong for someone using the software, whether you think it is right, and what you will do about it. Wait for the student's questions before the next finding. `[MINOR]` findings go in one batch.
- A real finding is your own mistake on show. Say what you missed and what caught it; that is the lesson on why audits exist.
- **The fix rounds always run**, as step 4 of the skill describes: one fixer for the whole list, the gate, the recheck, two rounds at most. After each round, go back through the findings and say what now behaves differently and which test guards it, or why the code was left as it was. Anything still open after two rounds is discussed with both sides stated, then you decide and record it.

### The review

These belong to the student, because they are intent:

- Is this what you wanted?
- Does it behave right when you use it? Have them walk every slice's `## Verify` steps.

Then the student retells the project from idea to running code: what was built, the questions that had to be answered, and why each answer was chosen. Where the account has a hole, teach that part again. Offer a final exam: mixed questions across the whole ledger, weighted to the recorded misconceptions.

### Closing the course

- The work is on `class/<course>`. Merging it into the base branch is the student's decision; do it on their yes, as the last lesson.
- Show what was left out: the concepts marked `claimed` and `waived`, and the reading list. That is their map for what to learn next.
