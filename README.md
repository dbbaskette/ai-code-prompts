# AI Code Prompts

Reusable, unified prompts for AI code assistants: **Cursor**, **Windsurf**, **Claude**, and **Gemini**.

## 📦 What's Inside
- `prompt/_base/core_prompt.md` — shared base rules
- App-specific prompts:
  - `prompt/app_web/web_app_prompt.md`
  - `prompt/service_api/api_service_prompt.md`
  - `prompt/spring_boot_service/spring_prompt.md`
  - `prompt/cli_tool/cli_prompt.md`
  - `prompt/ml_pipeline/ml_prompt.md`
  - `prompt/data_pipeline/dp_prompt.md`
  - `prompt/mcp_server/mcp_prompt.md`
- `deploy_prompts.sh` — interactive script to deploy prompts into an existing project directory
- `.cursor.json`, `.windsurf.json` — sample metadata referencing the shared prompts

## 🚀 Quick Start
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
The script generates `combined_prompt.md` in the destination directory by concatenating `_base` and the selected app prompts. This is handy for tools that prefer a single file for context.

## 📝 Licensing
Add your preferred license here.
