#!/bin/bash
# =============================================================
# setup_student.sh
# Initializeaza mediul de lucru pentru un student nou
# Utilizare: bash scripts/setup_student.sh "Prenume Nume"
# =============================================================

set -euo pipefail

# --- Culori ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[1;34m'; RESET='\033[0m'
ok()   { echo -e "${GREEN}[OK]${RESET}   $1"; }
err()  { echo -e "${RED}[ERR]${RESET}  $1" >&2; }
warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
info() { echo -e "${BLUE}[INFO]${RESET} $1"; }

# --- Validare argument ---
NAME="${1:-}"
if [ -z "$NAME" ]; then
    err "Lipsa argument: numele studentului"
    echo ""
    echo "  Utilizare:  bash scripts/setup_student.sh \"Prenume Nume\""
    echo "  Exemplu:    bash scripts/setup_student.sh \"Ion Popescu\""
    exit 1
fi

# Converteste "Prenume Nume" -> "prenume-nume" (valid pentru branch Git)
BRANCH_SUFFIX=$(echo "$NAME" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[ăâ]/a/g; s/[îÎ]/i/g; s/[șş]/s/g; s/[țţ]/t/g' \
    | tr ' ' '-' \
    | tr -cd '[:alnum:]-')
BRANCH="student/${BRANCH_SUFFIX}"

echo ""
echo -e "${BLUE}================================================${RESET}"
echo -e "${BLUE} Setup student: ${NAME}${RESET}"
echo -e "${BLUE} Branch:        ${BRANCH}${RESET}"
echo -e "${BLUE}================================================${RESET}"
echo ""

# --- Verificare: root-ul repository-ului ---
if [ ! -f "scripts/setup_student.sh" ]; then
    err "Ruleaza scriptul din directorul root al repository-ului!"
    echo ""
    echo "  cd ~/Linux_tutorial"
    echo "  bash scripts/setup_student.sh \"$NAME\""
    exit 1
fi

# --- Configurare identitate Git (doar daca nu e setata) ---
CURRENT_NAME="$(git config --global user.name 2>/dev/null || true)"
if [ -z "$CURRENT_NAME" ]; then
    git config --global user.name "$NAME"
    ok "Git user.name setat: $NAME"
else
    info "Git user.name exista deja: $CURRENT_NAME"
fi

CURRENT_EMAIL="$(git config --global user.email 2>/dev/null || true)"
if [ -z "$CURRENT_EMAIL" ]; then
    warn "Git user.email nu este setat. Seteaza manual:"
    echo "    git config --global user.email \"email@example.com\""
fi

# Credential helper (salveaza tokenul dupa prima autentificare)
git config --global credential.helper store 2>/dev/null || true
git config --global core.editor "nano" 2>/dev/null || true

# --- Actualizeaza main ---
info "Actualizez branch-ul main..."
git fetch origin 2>/dev/null || warn "Nu am putut face fetch (verifica conexiunea la internet)"
git checkout main
git pull origin main 2>/dev/null || warn "git pull esuat --- lucrez cu versiunea locala"
ok "Branch main actualizat"

# --- Creeaza / comuta pe branch-ul studentului ---
echo ""
info "Configurez branch-ul $BRANCH..."

REMOTE_EXISTS=false
LOCAL_EXISTS=false

git ls-remote --exit-code --heads origin "$BRANCH" > /dev/null 2>&1 && REMOTE_EXISTS=true || true
git branch --list "$BRANCH" | grep -q "." && LOCAL_EXISTS=true || true

if $REMOTE_EXISTS; then
    info "Branch exista pe remote. Comut si sincronizez..."
    if $LOCAL_EXISTS; then
        git checkout "$BRANCH"
        git pull origin "$BRANCH" 2>/dev/null || true
    else
        git checkout --track "origin/$BRANCH"
    fi
elif $LOCAL_EXISTS; then
    info "Branch exista local (nepublicat). Comut pe el..."
    git checkout "$BRANCH"
else
    info "Creez branch nou: $BRANCH"
    git checkout -b "$BRANCH"
fi

ok "Branch activ: $(git branch --show-current)"

# --- Structura de directoare in repo (pe branch) ---
echo ""
info "Creez structura de directoare in repository..."
mkdir -p solutii boss_fight
ok "solutii/ si boss_fight/ create"

# --- README pe branch (daca nu exista) ---
if [ ! -f "README_STUDENT.md" ]; then
    cat > README_STUDENT.md << MDEOF
# Branch: ${BRANCH}

Student: **${NAME}**
Creat: $(date '+%Y-%m-%d')

## Structura solutii

| Fisier                      | Exercitiu          | Nivel          |
|-----------------------------|--------------------|----------------|
| solutii/ex1_1.sh            | E1 - Navigare FS   | 1 - Usor       |
| solutii/ex1_2.sh            | E2 - Creare struct | 1 - Usor       |
| ...                         | ...                | ...            |
| solutii/ex1_10.sh           | E10 - awk intro    | 1 - Usor       |
| solutii/ex2_1.sh            | M1 - Permisiuni    | 2 - Mediu      |
| ...                         | ...                | ...            |
| solutii/ex2_10.sh           | M10 - awk raport   | 2 - Mediu      |
| solutii/ex3_1.sh            | H1 - Raport CSV    | 3 - Greu       |
| ...                         | ...                | ...            |
| solutii/ex3_10.sh           | H10 - Pipeline ETL | 3 - Greu       |
| boss_fight/downloads_manager.sh | Boss Fight     | Final          |

## Format commit obligatoriu

\`\`\`
feat: ex1_1 navigare sistem fisiere
feat: ex2_3 pipeline complex csv
feat: boss_fight downloads manager
\`\`\`

## Workflow zilnic

\`\`\`bash
cd ~/Linux_tutorial
git pull origin main           # ia ultimele fisiere demo de la profesor
git checkout ${BRANCH}
git status                     # verifica ce ai de trimis

# Dupa ce rezolvi un exercitiu:
chmod +x solutii/ex1_1.sh
bash solutii/ex1_1.sh          # testeaza
git add solutii/ex1_1.sh
git commit -m "feat: ex1_1 navigare sistem fisiere"
git push
\`\`\`
MDEOF

    git add README_STUDENT.md
    git commit -m "chore: initializare branch student ${NAME}"
    ok "README_STUDENT.md creat si comis"
fi

# --- Directoare de lucru in home ---
echo ""
info "Creez directoarele de lucru in ~/lab-linux/..."
mkdir -p "${HOME}/lab-linux/"{solutii,date,scripturi,config,secure,exercitii,downloads,backup}
ok "~/lab-linux/* create"

# Symlink la demo/ pentru acces rapid
DEMO_SRC="$(pwd)/demo"
DEMO_LINK="${HOME}/lab-linux/demo"
if [ ! -e "$DEMO_LINK" ] && [ -d "$DEMO_SRC" ]; then
    ln -sf "$DEMO_SRC" "$DEMO_LINK"
    ok "Symlink ~/lab-linux/demo -> $DEMO_SRC"
fi

# --- Genereaza datele de exercitiu ---
echo ""
info "Generez sistem_mare.log..."
bash scripts/generate_data.sh

# --- Rezumat final ---
echo ""
echo -e "${GREEN}================================================${RESET}"
echo -e "${GREEN} Setup complet pentru: ${NAME}${RESET}"
echo -e "${GREEN} Branch: ${BRANCH}${RESET}"
echo -e "${GREEN}================================================${RESET}"
echo ""
echo " Pasii urmatori:"
echo ""
echo " 1. Publica branch-ul pe GitHub (PRIMA data --- necesita PAT):"
echo "    git push -u origin ${BRANCH}"
echo "    # Username: username-ul tau GitHub"
echo "    # Password: PAT-ul tau (ghp_xxxxx) --- NU parola contului!"
echo ""
echo " 2. Verifica ca esti pe branch-ul corect:"
echo "    git branch --show-current"
echo ""
echo " 3. Incepe cu primul exercitiu:"
echo "    nano solutii/ex1_1.sh"
echo "    chmod +x solutii/ex1_1.sh && bash solutii/ex1_1.sh"
echo "    git add solutii/ex1_1.sh"
echo "    git commit -m \"feat: ex1_1 navigare sistem fisiere\""
echo "    git push"
echo ""
echo " 4. Ia ultimele fisiere demo cand profesorul le actualizeaza:"
echo "    git pull origin main"
echo ""
