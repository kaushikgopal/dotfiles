# Command to create or update work session checkpoints
name = "checkpoint"
description = "Create a checkpoint to resume work seamlessly, or update existing checkpoint"
prompt = """

- i want you to first write down this plan in detail, into @.ai/plans
- i should be able to give this plan to another agent like yourself, and be able to resume to this point we have now reached.
- make sure to include all the necessary context and information, so i don't have to repeat myself with another agent
- If a checkpoint file exists that looks similar
   - point it out to the user and ask them if they want to update the fil
   - otherwise create new file without confirmation
- new file format:
  - `checkpoint-[YYYYMMDD-HHMMSS].md`
  - If working on specific feature: `checkpoint-[feature-name]-[YYYYMMDD-HHMMSS].md`
"""