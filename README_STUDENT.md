# Branch: student/decebal-andrei-iordache

Student: **Decebal-Andrei Iordache**
Creat: 2026-03-14

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

```
feat: ex1_1 navigare sistem fisiere
feat: ex2_3 pipeline complex csv
feat: boss_fight downloads manager
```

## Workflow zilnic

```bash
cd ~/Linux_tutorial
git pull origin main           # ia ultimele fisiere demo de la profesor
git checkout student/decebal-andrei-iordache
git status                     # verifica ce ai de trimis

# Dupa ce rezolvi un exercitiu:
chmod +x solutii/ex1_1.sh
bash solutii/ex1_1.sh          # testeaza
git add solutii/ex1_1.sh
git commit -m "feat: ex1_1 navigare sistem fisiere"
git push
```
