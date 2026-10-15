Slice #{{SLICE}} passed its gate and is about to merge. While building it, its agents made the choices below on the human's behalf. Check each one against the human's rulings and the constitution, which bind every agent. You are given these three and nothing else: judge the choices as written, not the code.

## The choices

{{CHOICES}}

## The human's rulings

{{RULINGS}}

## The constitution

{{CONSTITUTION}}

## Your answer

A choice contradicts a ruling or a rule when following the choice means not following the ruling: it decides differently what the ruling decided, or does what the rule forbids. A choice about something no ruling and no rule speaks to contradicts nothing, however you would have decided it.

Your final message is the answer, nothing before or after it. One line per contradiction:

```
CONTRADICTS <the choice, shortened> — <the ruling or rule, quoted> — <why the two cannot both hold>
```

or, when there is none, the single line `NONE`.
