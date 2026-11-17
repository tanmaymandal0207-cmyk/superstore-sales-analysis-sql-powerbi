# Changelog

## v2.0 — 6 Oct 2026

Professional restructure: SQL rebuilt as a numbered pipeline and the Power BI report documented.

### Added

- SQL pipeline in `sql/`: schema, load, data-quality checks, cleaning views, and sales / customer / product / time / shipping-and-discount analysis (`00`–`08`).
- Docs: [SQL analysis](docs/sql-analysis.md), [data model](docs/data-model.md), [DAX measures](docs/dax-measures.md), [report pages](docs/report-pages.md), [model review](docs/model-review.md).
- Dashboard screenshots in `assets/screenshots/` and README banner.

### Changed

- Power BI report moved to `dashboard/Superstore-Intelligence.pbix`.
- README rewritten: overview, preview, insights, architecture, SQL, model, licence.

### Removed

- MIT licence (all rights reserved).
- Single-file SQL script (replaced by `sql/`) and the old root-level `.pbix`.

## Repository maintenance

- 17 Oct 2026: `.gitignore` for CSV extracts, Power BI / Excel temp and OS files.
- 15 Nov 2026: added this changelog.
- 16 Nov 2026: README links the changelog and related projects; repository tree lists `CHANGELOG.md`.

## v1.0 — 28 Apr 2026

- First version: SQL script, Power BI file and README.
- 17 Nov 2026: added `data/README.md` (expected CSV files, column order, load checks), linked from How to Run and the repository tree.
