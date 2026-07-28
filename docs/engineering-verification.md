# Engineering Formula Verification

For engineering/process-calculation apps, formula code is high risk even when it
is small. AI-generated formulas must be verified against independent references
before acceptance.

## Formula checklist

For each critical formula, document:

- formula name;
- source/reference;
- assumptions;
- valid input range;
- units for every variable;
- expected output units;
- numeric tolerance;
- at least one worked example;
- Swift Testing coverage for the worked example;
- edge cases and invalid inputs.

## Worked example template

```markdown
## <Formula name>

- Source:
- Assumptions:
- Valid range:
- Inputs:
- Formula:
- Worked example:
- Expected result:
- Tolerance:
- Swift test:
```

## Minimum tests

- known worked example from an independent source;
- invalid input cases (`<= 0`, empty, out of physical range as applicable);
- unit conversion boundaries;
- round-trip properties when meaningful, e.g. bar → psi → bar ≈ original value.

If no independent source is available, the planner must flag the formula as a
research task before implementation.
