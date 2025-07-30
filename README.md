# AI Code Prompts

This repository provides a powerful, reusable, and composable framework for instructing AI code assistants. It allows you to combine a core set of rules with project-specific prompts to ensure consistent, high-quality code generation across different tools like **Cursor**, **Windsurf**, **Claude**, and **Gemini**.

## ✨ Key Features

*   **Unified & Consistent**: A single `core_prompt.md` establishes the foundational rules for safety, quality, and interaction style for any AI assistant.
*   **Composable**: Mix and match application-specific prompts (e.g., for a "Web App" and a "Service API") in a single project.
*   **Project-Specific Context**: A `PROJECT.md` template is deployed to every project, ensuring the AI has specific details about your goals, tech stack, and architecture.
*   **Tool Agnostic**: The deployment script generates configurations for multiple tools simultaneously:
    *   `.cursor.json` & `.windsurf.json` for tools that read modular file lists.
    *   `.claude.md` & `.gemini.md` for tools that prefer a single, combined context file.
*   **DRY (Don't Repeat Yourself)**: Define a prompt once and reuse it everywhere, ensuring consistency and easy updates.

## 🚀 Quick Start

Run the interactive deployment script from the root of this repository.

```bash
# in this repo
chmod +x deploy_prompts.sh
./deploy_prompts.sh
```
You'll be asked for:
1) Deployment directory (existing directory OK)
2) Project name (metadata only)
3) One or more app types

The script will copy the **selected** prompts to your target directory, generate a consolidated `combined_prompt.md`, and create convenience aliases: `.claude.md`, `.gemini.md`. It will also write `.cursor.json` & `.windsurf.json` that reference the same modular files.

> **Note on Re-running**: The script is designed to be run multiple times on the same directory. It will perform a clean deployment:
> *   **It overwrites** all generated files (`combined_prompt.md`, `.cursor.json`, etc.) to ensure they are up-to-date.
> *   **It removes** any old application-specific prompt directories that are no longer selected.
> *   **It does NOT overwrite** your existing `PROJECT.md` file, to prevent data loss.

> The `README.md` is for this repository and is **not** copied by the script.

## 🧠 Philosophy
- **DRY**: One set of prompts shared across tools.
- **Composable**: Mix multiple app types per project.
- **Portable**: Works with any editor; no vendor lock-in.

## 🛠 Adding a New App Type
1. Create `prompt/<your_type>/<your_file>.md`
2. Add `<your_type>` to the `APP_TYPES` array in `deploy_prompts.sh`
3. Commit and re-run the script

## 🧪 Optional: Combined Prompt
The script generates `combined_prompt.md` in the destination directory. This file is a concatenation of the `core_prompt.md` and any selected application-specific prompts.

**Important**: This combined prompt does **not** include the contents of `PROJECT.md`. Instead, it contains a reference telling the AI to read `PROJECT.md` as the primary source of truth for project context. This means you will likely need to provide both `combined_prompt.md` (or its aliases) and your completed `PROJECT.md` to your AI assistant.

## 📝 Licensing
Add your preferred license here.
