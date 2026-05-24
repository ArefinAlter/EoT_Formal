# Publishing EoT_Formal to GitHub

Step-by-step for Windows. Your repo root is `F:\EoT_Formal`.

> Before you push: confirm `data/` contains only the **mock** CSVs. Do not publish real, confidential interview data. `.gitignore` already blocks `data/real_*.csv` and `data/*_confidential*.csv`, but double-check.

## 0. One-time prerequisites
- Install **Git**: https://git-scm.com/download/win
- (Recommended) Install the **GitHub CLI** `gh`: https://cli.github.com/
- Set your identity (once per machine):
```bash
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

## 1. Open a terminal in the repo
Git Bash:
```bash
cd /f/EoT_Formal
```
PowerShell:
```powershell
cd F:\EoT_Formal
```

## 2. Initialize and make the first commit
```bash
git init
git add .
git status                       # sanity-check what will be committed
git commit -m "fsQCA + BRS pipeline with mock data and figures"
git branch -M main
```

## 3. Create the GitHub repo and push

### Option A — GitHub CLI (simplest)
```bash
gh auth login                    # once: pick GitHub.com, HTTPS, browser
gh repo create EoT_Formal --public --source=. --remote=origin --push
```
Use `--private` instead of `--public` if you are not ready to share.

### Option B — manual (no CLI)
1. On github.com: **New repository** -> name it `EoT_Formal` -> **do not** add a README/.gitignore (you already have them) -> Create.
2. Then:
```bash
git remote add origin https://github.com/<your-username>/EoT_Formal.git
git push -u origin main
```
If prompted for a password, use a **Personal Access Token** (GitHub no longer accepts account passwords): github.com -> Settings -> Developer settings -> Personal access tokens.

### Option C — from R with usethis
```r
install.packages(c("usethis", "gitcreds"))
usethis::use_git()               # init + first commit
usethis::create_github_token()   # opens browser; copy token
gitcreds::gitcreds_set()         # paste token
usethis::use_github(private = FALSE)
```

## 4. Generate outputs before committing (optional)
If you want the figures/tables in the repo, run the pipeline first, then commit:
```r
setwd("F:/EoT_Formal"); source("run_all.R")
```
```bash
git add output
git commit -m "Add generated figures and solution tables"
git push
```
Large `.rds` files are git-ignored by default (regenerate from code). To share them, edit `.gitignore`.

## 5. Updating later
```bash
git add -A
git commit -m "describe your change"
git push
```

## Notes
- GitHub rejects single files larger than 100 MB. The mock CSVs are tiny; only worry about this if you later add big binaries (use Git LFS if so).
- To pin package versions for reproducibility, run `renv::init()` in R before publishing and commit `renv.lock`.
