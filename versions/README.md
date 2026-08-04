# Versioni congelate del manoscritto

Ogni sottocartella è uno snapshot immutabile del paper a una **milestone del journal**.
Non modificare nulla qui dentro: la versione di lavoro è `elsarticle-template-num-names.tex`
nella root del repo.

## Contenuto di ogni snapshot

| File | Cosa |
|---|---|
| `main.tex` | il sorgente del paper a quella data |
| `bibliography.bib` | la bibliografia a quella data |
| `*.pdf` | il PDF compilato |

Le figure **non** sono duplicate: `images/` pesa 38 MB e replicarla a ogni versione
gonfierebbe il repo. Le immagini di qualsiasi versione passata sono comunque
recuperabili da git (`git show <tag>:images/<file>`).

## Versioni

### `v1_submitted/` — manoscritto sottomesso ad Annals of Nuclear Energy

- Corrisponde al commit `9136939` ("Initial Overleaf Import"), taggato `submitted-v1`
- `main.tex` e `bibliography.bib` sono **identici byte per byte** al commit sottomesso

**Attenzione sul PDF.** `v1_submitted.pdf` NON è compilato dai sorgenti che stanno
in questa cartella: quei sorgenti **non compilano** (errore fatale su una chiave di
citazione non-ASCII, nessun PDF prodotto). Il PDF viene dalla versione corretta con
i tre fix puramente tecnici elencati sotto, che **non alterano una sola parola del
testo scientifico**:

1. chiave di citazione `Pungerčič` → `Pungercic` in `.tex` e `.bib` (una chiave con
   caratteri non-ASCII rompe `\csname`); il nome dell'autore nel campo `author`
   conserva i diacritici corretti
2. aggiunto `\usepackage[hidelinks]{hyperref}` prima di `cleveref` (serve un `\url`
   catcode-safe per gli URL in bibliografia)
3. due voci `@online` → `@misc` con campo `url` (`@online` non esiste in
   `elsarticle-num-names.bst`)

Per ottenere il PDF esattamente come è stato sottomesso al journal, usare il file
inviato tramite il sistema editoriale.

## Prossime versioni previste

- `v2_revision1/` — risposta al primo round di revisori
