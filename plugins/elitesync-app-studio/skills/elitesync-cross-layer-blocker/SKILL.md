# elitesync-cross-layer-blocker

## Purpose

Handle blockers that may cross UI, backend, truth chain, release chain, or environment boundaries.

## Trigger

- A bug resists local UI fixes.
- A change might affect backend contracts, truth chains, release metadata, or protected surfaces.

## Required workflow

1. Stop the blind fix.
2. Write a blocker report that names the symptom, suspected layer, affected surfaces, and smallest safe next step.
3. Identify the likely layer boundary.
4. Ask for the smallest safe scope cut.
5. Hand the high-risk root-cause analysis to the architecture reviewer if needed.

## Stop condition

- The boundary is named.
- The smallest safe fix is identified.
- The next action is no longer ambiguous.

## Must not do

- Do not keep patching the wrong layer.
- Do not broaden the scope in the hope of fixing it faster.
