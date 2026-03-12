# Linux Tutorial — Data Engineering & Analytics Nivel 1

> Repository gestionat de **Ing. Aldica Victor-Mihai** | Data Engineer @ ING Hubs

## Structura repository

```
Linux_tutorial/
├── demo/                     ← Fisierele de date pentru exercitii (read-only)
│   ├── tranzactii.csv        col: id,client,categorie,suma,data,metoda_plata
│   ├── angajati.csv          col: id,nume,departament,salariu,data_angajare,oras
│   ├── produse.csv           col: id,nume_produs,categorie,pret,furnizor,stoc
│   ├── app.log               format: TIMESTAMP NIVEL [serviciu] mesaj
│   ├── server_access.log     format: Apache Combined Log (col.9=status)
│   ├── config_app.txt        format: cheie=valoare cu comentarii #
│   └── useri.txt             format: /etc/passwd
├── scripts/
│   ├── setup_student.sh      ← Ruleaza O SINGURA DATA la inceput
│   └── generate_data.sh      ← Genereaza sistem_mare.log (200 linii)
└── student/PRENUME-NUME/     ← Branch-ul fiecarui student (creat de setup_student.sh)
    ├── solutii/              ex1_N.sh, ex2_N.sh, ex3_N.sh
    └── boss_fight/           downloads_manager.sh
```

## Setup rapid (studenti)

```bash
# 1. Cloneaza
git clone https://github.com/SirVicCreamy/Linux_tutorial
cd Linux_tutorial

# 2. Configureaza identitatea Git si ruleaza setup-ul
git config --global user.name "Prenume Nume"
git config --global user.email "email@example.com"
bash scripts/setup_student.sh "Prenume Nume"

# 3. Publica branch-ul (necesita PAT GitHub, nu parola contului)
git push -u origin student/prenume-nume
```

## Format log (app.log si sistem_mare.log)

```
2026-02-17T09:31:55 ERROR   [payment-service] Payment gateway unreachable: HTTP 503
│                   │        │                 │
$1 (timestamp)     $2       $3 ([serviciu])  $4+ (mesaj)
```

Coloana `$2` = nivel (`INFO`/`DEBUG`/`WARN`/`ERROR`)  
Coloana `$3` = serviciu (format `[name]`)

## Format server_access.log

```
192.168.1.10 - - [17/Feb/2026:09:15:23 +0000] "GET /api/users HTTP/1.1" 200 4823
                                                                           │
                                                                          $9 = status code
```

## Reguli pentru studenti

- **Nu** comite direct pe `main` — branch-ul tau este `student/prenume-nume`
- Format commit: `feat: ex1_1 descriere-fara-diacritice`
- Ia mereu ultimele fisiere demo: `git pull origin main`
