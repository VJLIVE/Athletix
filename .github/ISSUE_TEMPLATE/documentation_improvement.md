---
name: "Documentation Improvement"
description: "Suggest improvements or updates to the project documentation."
title: "[Docs] <brief description>"
labels: [documentation]
assignees: []

body:
  - type: markdown
    attributes:
      value: |
        ## Documentation Improvement
        Thank you for helping us improve our documentation! Please provide as much detail as possible.

  - type: textarea
    id: description
    attributes:
      label: Description
      description: Describe the documentation improvement you are suggesting.
      placeholder: "What part of the documentation needs improvement? Why?"
    validations:
      required: true

  - type: textarea
    id: changes
    attributes:
      label: Changes Implemented (if applicable)
      description: If you have already made changes, please describe them here.
      placeholder: "List the files or sections you updated, and what you changed."
    validations:
      required: false

  - type: textarea
    id: benefits
    attributes:
      label: Benefits
      description: What are the benefits of this documentation improvement?
      placeholder: "Easier onboarding, better code understanding, etc."
    validations:
      required: false

  - type: textarea
    id: next_steps
    attributes:
      label: Next Steps (optional)
      description: Suggest any follow-up actions or improvements.
      placeholder: "Continue adding doc comments, keep README up to date, etc."
    validations:
      required: false 