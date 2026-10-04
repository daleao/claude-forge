# The course files

Everything under `.forge/class/<course>/` is committed. Commit it with the work it describes.

## `notebook.md`

The course's only memory between sessions. Whoever reads it next knows nothing else. Update it after every concept and every decision, before anything else can go wrong.

```md
# Course: <name>

Base branch: <the branch the course started from>
Course branch: class/<course>
Gate: <the verify command, once the foundation slice defines it>
Position: <unit, and where in it>
Next: <the next step, specific enough to act on with nothing else in context>

## Mission

**Why**: <one to three sentences, the student's words: what they want this for>

**Success looks like**:
- <something the student will be able to do or explain>

## Student

- Baseline: <what they said they have done before>
- Analogies from: <their world, if they named one>
- Preferences: <pace, depth, how they like to be checked, anything they asked for>

## Syllabus

- [x] Unit 0: Orientation
- [ ] Unit 1: The design questions
- [ ] Unit 2: The spec
- [ ] Unit 3: The slices
- [ ] Unit 4: slice 01 <name>
- [ ] Final: Audit and review

## Concepts

| Concept | State | Evidence | Last checked |
| --- | --- | --- | --- |
| <name> | open / demonstrated / claimed / waived | <what the student said or did> | <date> |

## Misconceptions

- <what the student believed> → <what corrected it>

## Decisions

- **<the question>**: <the choice> — <why> — <what would change it> — taught: yes / no

## Parked questions

- <a question the student asked to come back to>

## Reading list

- <source, and the part worth reading> — <the question to bring back> — offered / read
```

Rules:

- **Evidence or it stays open.** `demonstrated` needs the student's own words or a correct prediction in the Evidence column. See "Evidence" in [LESSON.md](LESSON.md).
- **Claims record their depth.** "Has used git to commit and push; never branched" is more useful than "knows git".
- **Decisions carry their reason.** A later session cannot ask the conversation why; the line is all it has. A decision marked `taught: no` is a lesson still owed.
- **Waived means waived.** Do not bring it back in a quiz or an aside.
- **Keep it a ledger, not a diary.** What is known, what was decided, what comes next. No account of who said what.

## `glossary.md`

The technical terms the student now owns. It is separate from the project's `GLOSSARY.md`, which holds the domain's language and is kept as `forge:domain-modeling` says.

```md
# <Course> glossary

**<Term>**:
<One or two plain sentences saying what it is. The student's own wording where it was right.>
_Not to be confused with_: <a near neighbour, if there is one>
```

Rules:

- **A term is added only once its concept is `demonstrated`.** The glossary records what has been learned; it is not something the student reads in order to learn.
- **Define what the term is**, not how to use it.
- **Use the glossary's own terms inside later definitions**, and in every lesson after. One word for one thing.
- **Revise in place** when the student's understanding deepens.
