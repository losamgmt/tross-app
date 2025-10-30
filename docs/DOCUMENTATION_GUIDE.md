# Documentation Standards# Documentation Structure Guide

**Last Updated:** October 24, 2025 **Last Updated:** October 16, 2025

**Philosophy:** KISS - Self-documenting code, minimal strategic docs**Purpose:** Maintain DRY, maintainable documentation across TrossApp

---

## Principles## 📚 DOCUMENTATION HIERARCHY

### 1. Self-Documenting Code First### Single Source of Truth Principle

Code should be clear enough to read without extensive documentation. Use:Each document has **ONE specific purpose**. Never duplicate information across files.

- Descriptive variable/function names

- Clear file organization```

- JSDoc/dartdoc for complex logicREADME.md → NEW USER ONBOARDING

- Type annotations ├─ Links to: PROJECT_STATUS.md (current state)

  └─ Links to: DEVELOPMENT_ROADMAP.md (future plans)

### 2. Docs Explain Architecture, Not Implementation

PROJECT_STATUS.md → CURRENT STATE & QUALITY (SSOT for grades/assessment)

Documentation answers **WHY**, not **HOW**: └─ Contains: Implementation status, assessment, technical debt

- ✅ Design decisions and tradeoffs

- ✅ System architecture and data flowDEVELOPMENT_ROADMAP.md → FUTURE PLANS & EXECUTION

- ✅ Strategic choices and patterns └─ Links to: PROJECT_STATUS.md (current state reference)

- ❌ Code examples (reference actual files instead)

- ❌ Implementation details (live in code)PRE_COMMIT_CHECKLIST.md → DEVELOPER WORKFLOW

- ❌ Historical tracking (use git history)CONTRIBUTORS.md → CONTRIBUTION GUIDELINES

````

### 3. Keep Docs Tight

---

Every doc must be:

- **Concise** - No bloat, no repetition## 📄 DOCUMENT PURPOSES

- **Focused** - Single Responsibility Principle

- **Current** - Archive outdated content immediately### 1. README.md (12K)

- **Maintainable** - Short files, clear structure**Audience:** New developers, external users

- **Scannable** - Headers, bullets, tables**Purpose:** Project onboarding and setup

**Contains:**

**Target:** Most docs under 150 lines. Architecture docs under 300 lines.- Project overview

- Quick start guide

### 4. Reference, Don't Duplicate- Installation instructions

- Available npm scripts

Point to code instead of copying it:- Architecture diagram

```markdown- Basic usage examples

❌ BAD:

## Example Usage**NEVER Contains:**

\`\`\`javascript- ❌ Current implementation status (use PROJECT_STATUS.md)

function validateUser(id) {- ❌ Quality grades/scores (use PROJECT_STATUS.md)

  return toSafeInteger(id);- ❌ Future roadmap (use DEVELOPMENT_ROADMAP.md)

}- ❌ Detailed technical decisions (use PROJECT_STATUS.md)

\`\`\`

**Cross-References:**

✅ GOOD:```markdown

## Validation Pattern> 📊 **Project Status:** See [PROJECT_STATUS.md](PROJECT_STATUS.md)

See `backend/validators/type-coercion.js` for implementation.> 🗺️ **Development Plan:** See [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md)

````

### 5. Archive Aggressively---

Move to `archive/` immediately:### 2. PROJECT_STATUS.md (23K) ⭐ **SINGLE SOURCE OF TRUTH**

- Completed phase docs**Audience:** Team members, stakeholders

- Historical status reports**Purpose:** Comprehensive current state documentation

- Work session summaries**Contains:**

- Troubleshooting notes- **ONLY PLACE** for quality grades/scores (96/100)

- Migration records- **ONLY PLACE** for detailed assessment

- Current implementation status

Only keep **current, useful** documentation in main `docs/`.- Recent work summary

- Technical debt tracking

---- What's done vs. what's next

## Document Types**Sections:**

1. Executive Summary (with grade)

### Architecture Docs2. Implementation Status

**Purpose:** Explain system design decisions 3. Recent Work

**Examples:** VALIDATION.md, DATABASE_ARCHITECTURE.md 4. Professional Assessment (summary)

**Structure:** Philosophy → Architecture → Design Decisions → Code References5. Detailed Categorical Assessment (10 categories with scoring)

6. Cleanup Completion Summary

### Guides7. Next Steps & Priorities

**Purpose:** How to work with specific subsystems 8. Technical Debt

**Examples:** auth/AUTH_GUIDE.md, testing/TESTING_GUIDE.md 9. Documentation Structure

**Structure:** Overview → Key Concepts → Patterns → Related Docs10. Lessons Learned

11. Conclusion

### Status & Planning

**Purpose:** Current state and next steps **Update Frequency:** After major milestones or weekly

**Examples:** PROJECT_STATUS.md, MVP_SCOPE.md

**Structure:** Current State → Metrics → Next Steps---

### Operations### 3. DEVELOPMENT_ROADMAP.md (51K)

**Purpose:** Running, deploying, maintaining the system **Audience:** Development team

**Examples:** DEPLOYMENT.md, CI_CD.md, PROCESS_MANAGEMENT.md **Purpose:** Future planning and execution strategy

**Structure:** Prerequisites → Steps → Troubleshooting**Contains:**

- 4-week MVP plan

---- Week-by-week breakdown

- Feature specifications

## File Naming- Implementation details

- Success metrics

- Use `SCREAMING_SNAKE_CASE.md` for top-level docs- Risk management

- Use `lowercase-kebab-case.md` for subdirectory docs

- Be specific: `VALIDATION.md` not `DATA.md`**NEVER Contains:**

- Avoid dates in filenames (use git history)- ❌ Current quality scores (references PROJECT_STATUS.md instead)

- ❌ Implementation status (references PROJECT_STATUS.md instead)

---

**Cross-References:**

## Update Process```markdown

> 📊 **Current Status:** See [PROJECT_STATUS.md](PROJECT_STATUS.md)

When making changes:```

1. Update relevant doc immediately (don't let docs drift)

2. Update "Last Updated" date**Update Frequency:** Weekly during active development

3. Archive outdated content (don't delete - move to `archive/`)

4. Update `docs/README.md` if structure changes---

---### 4. PRE_COMMIT_CHECKLIST.md (14K)

**Audience:** Developers

## Related**Purpose:** Code review workflow

**Contains:**

- **[docs/README.md](README.md)** - Documentation index- Pre-commit checklist items

- **[PROJECT_STATUS.md](PROJECT_STATUS.md)** - Current project state- Code quality standards

- Testing requirements
- Security checks

**Update Frequency:** Rarely (only when workflow changes)

---

### 5. CONTRIBUTORS.md (80 bytes)

**Audience:** External contributors  
**Purpose:** Contribution guidelines  
**Contains:**

- How to contribute
- Code of conduct reference

**Update Frequency:** Rarely

---

## 🔄 MAINTENANCE RULES

### Golden Rules of DRY Documentation

1. **One Source, One Truth**
   - Quality grades ONLY in `PROJECT_STATUS.md`
   - Future plans ONLY in `DEVELOPMENT_ROADMAP.md`
   - Setup instructions ONLY in `README.md`

2. **Link, Don't Duplicate**

   ```markdown
   ❌ BAD: "Current grade: 96/100" (in multiple files)
   ✅ GOOD: "See PROJECT_STATUS.md for current quality metrics"
   ```

3. **Update Strategy**
   - Change once, reflect everywhere (via links)
   - Never copy/paste between docs
   - Use cross-references liberally

4. **Review Checklist**
   Before committing doc changes, ask:
   - [ ] Is this information already in another doc?
   - [ ] Should I link instead of duplicate?
   - [ ] Will this create maintenance burden?

---

## 🔍 QUICK REFERENCE

**"What's the current quality grade?"**  
→ `PROJECT_STATUS.md` (search for "Final Grade")

**"What features are planned?"**  
→ `DEVELOPMENT_ROADMAP.md` (Week 1-4 sections)

**"How do I set up the project?"**  
→ `README.md` (Quick Start section)

**"What needs to be fixed?"**  
→ `PROJECT_STATUS.md` (Technical Debt section)

**"What was recently implemented?"**  
→ `PROJECT_STATUS.md` (Recent Work section)

**"What's the pre-commit workflow?"**  
→ `PRE_COMMIT_CHECKLIST.md`

---

## ⚠️ COMMON PITFALLS

### Anti-Patterns to Avoid

1. **Duplicate Grades/Scores**

   ```markdown
   ❌ README.md: "Grade: 96/100"
   ❌ ROADMAP.md: "Foundation: 96/100"
   ❌ STATUS.md: "Final Grade: 96/100"

   ✅ STATUS.md: "Final Grade: 96/100"
   ✅ README.md: "See PROJECT_STATUS.md for quality metrics"
   ✅ ROADMAP.md: "See PROJECT_STATUS.md for current status"
   ```

2. **Duplicating Implementation Details**

   ```markdown
   ❌ Multiple files: "We implemented JWT with refresh token rotation..."
   ✅ PROJECT_STATUS.md: Full implementation details
   ✅ Other files: Link to PROJECT_STATUS.md
   ```

3. **Copying Future Plans**
   ```markdown
   ❌ Multiple files: "Week 1: Add TokenService tests (6 hours)..."
   ✅ DEVELOPMENT_ROADMAP.md: Full plan details
   ✅ PROJECT_STATUS.md: "See DEVELOPMENT_ROADMAP.md for execution plan"
   ```

---

## 📊 VERIFICATION

### How to Verify DRY Compliance

```bash
# Check for duplicate grade references (should ONLY be in PROJECT_STATUS.md)
grep -n "96/100\|Grade.*A\|Final Grade" *.md

# Expected output:
# PROJECT_STATUS.md:5:**Grade:** A (96/100)
# PROJECT_STATUS.md:201:**Final Grade: A (96/100)**
# (Other files should have NO matches)

# Check for duplicate roadmap content
grep -n "Week 1.*TokenService\|Week 2.*Work Orders" *.md

# Expected output:
# DEVELOPMENT_ROADMAP.md:... (ONLY in roadmap)
```

---

## 🎯 SUMMARY

**Maintainable Documentation = DRY Documentation**

- **README.md**: "How do I start?" (onboarding)
- **PROJECT_STATUS.md**: "Where are we now?" (current state + **GRADES**)
- **DEVELOPMENT_ROADMAP.md**: "Where are we going?" (future plans)

**When in doubt:** Link, don't duplicate!

---

_This guide ensures TrossApp documentation remains **elegant, consistent, concise, correct, complete, professional, simple, readable, and maintainable**._
