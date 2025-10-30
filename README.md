# TrossApp

**Professional work order management system with skills-based matching**

[![Flutter](https://img.shields.io/badge/Flutter-3.35.5-blue.svg)](https://flutter.dev/)
[![Node.js](https://img.shields.io/badge/Node.js-24.9.0-green.svg)](https://nodejs.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> 📊 **Project Status:** See [docs/PROJECT_STATUS.md](docs/PROJECT_STATUS.md) for current implementation status and quality metrics.

---

## 🎯 Overview

TrossApp is a modern, full-stack application designed for efficient work order management with intelligent skills-based matching. Built with Flutter for cross-platform frontend and Node.js/Express for a robust backend API.

### ✨ Key Features

- **Cross-Platform UI**: Flutter web/mobile with Material 3 design
- **RESTful API**: Node.js/Express backend with comprehensive error handling
- **Real-Time Communication**: Frontend ↔ Backend connectivity testing
- **Professional Architecture**: Clean, KISS principles, minimal complexity
- **Development Ready**: Complete monorepo setup with testing framework

## 🏗️ Architecture

```
TrossApp/
├── frontend/          # Flutter application
│   ├── lib/
│   │   └── main.dart  # Main application entry
│   ├── pubspec.yaml   # Flutter dependencies
│   └── test/          # Flutter unit tests
├── backend/           # Node.js API server
│   ├── server.js      # Express server with CORS, security
│   ├── package.json   # Backend dependencies
│   └── __tests__/     # Jest test suite
├── scripts/           # Development automation
│   ├── start-dev.bat  # Start development environment
│   └── stop-dev.bat   # Clean shutdown script
├── docs/              # Documentation
└── package.json       # Monorepo configuration
```

## 🚀 Quick Start

### Prerequisites

- **Node.js**: v18+ (tested on v24.9.0)
- **Flutter**: v3.35.5+
- **Git**: Latest version

### 1️⃣ Clone & Install

```bash
git clone <repository-url>
cd TrossApp
npm install
cd frontend && flutter pub get
```

### 2️⃣ Development Mode

```bash
# Option 1: Use our automation scripts (Windows)
./scripts/start-dev.bat

# Option 2: Manual startup
npm run dev:backend    # Backend on :3001
npm run dev:frontend   # Frontend on :8080
```

### 3️⃣ Access Application

- **Frontend**: http://localhost:8080
- **Backend API**: http://localhost:3001/api/health
- **API Testing**: http://localhost:3001/api/hello

## 🧪 Testing

```bash
# Run all tests
npm test

# Individual test suites
npm run test:backend   # Jest tests (16/16 passing)
npm run test:frontend  # Flutter tests (1/1 passing)
npm run test:e2e       # Playwright end-to-end
```

## 📱 Frontend Stack

**Framework**: Flutter 3.35.5

- **Language**: Dart ^3.9.2
- **UI**: Material 3 with custom TrossApp branding
- **HTTP**: http ^1.5.0 for API communication
- **Architecture**: StatefulWidget with clean state management

**Design System**:

- **Primary**: Bronze (#CD7F32)
- **Secondary**: Honey Yellow (#FFB90F)
- **Accent**: Walnut (#8B4513)
- **Responsive**: Mobile-first with desktop optimization

## 🔧 Backend Stack

**Runtime**: Node.js 24.9.0

- **Framework**: Express ^5.1.0
- **Security**: Helmet ^8.1.0, CORS ^2.8.5
- **Logging**: Morgan ^1.10.1
- **Testing**: Jest ^30.2.0, Supertest ^7.1.4

**API Endpoints**:

- `GET /api/hello` - Frontend connectivity test with metrics
- `GET /api/health` - System health, uptime, memory usage

## 🔒 Security Features

- **Helmet.js**: Content Security Policy, XSS protection
- **CORS**: Configured for development origins
- **Input Validation**: JSON body parsing with size limits
- **Error Handling**: Secure error messages, no stack traces in production
- **Process Management**: Graceful shutdown handling

## 🚦 Development Workflow

### Code Quality

```bash
npm run lint     # ESLint + Flutter analyze
npm run format   # Prettier + dart format
npm run clean    # Reset build artifacts
```

### All Available Scripts

```bash
# Development
npm run dev:backend       # Start backend server (nodemon)
npm run dev:frontend      # Start Flutter web (Chrome)

# Testing
npm test                  # Run all tests (backend + frontend)
npm run test:backend      # Backend Jest tests (46/46 passing)
npm run test:frontend     # Flutter tests
npm run test:e2e          # Playwright end-to-end tests
npm run test:all          # All tests including E2E
npm run test:watch        # Watch mode for backend tests
npm run test:coverage     # Generate coverage reports

# Database
npm run db:start          # Start PostgreSQL (Docker)
npm run db:stop           # Stop PostgreSQL
npm run db:migrate        # Run migrations
npm run db:seed           # Seed database
npm run db:reset          # Reset database
npm run db:backup         # Backup database

# Build & Deploy
npm run build:all         # Build backend + frontend
npm run docker:build      # Build production Docker images
npm run docker:up         # Start production containers
npm run deploy:prod       # Full production deployment

# CI/CD
npm run ci:test           # CI test suite
npm run ci:build          # CI build process
npm run ci:deploy         # CI deployment

# Utilities
npm run clean:flutter     # Clean Flutter build cache
```

### Performance Monitoring

- Backend: Memory usage, uptime tracking
- Frontend: Response time metrics, connection status
- Load Testing: Artillery configuration included

## 📂 Project Structure Details

### Monorepo Benefits

- **Shared Dependencies**: npm workspaces
- **Unified Scripts**: Cross-platform development commands
- **Consistent Tooling**: ESLint, Prettier, Jest configuration
- **Simple Deployment**: Single repository, coordinated releases

### File Organization

```
├── backend/
│   ├── server.js           # 🔥 Main Express application
│   ├── package.json        # Backend-specific dependencies
│   └── __tests__/
│       ├── server.test.js  # API endpoint tests
│       └── setup.js        # Test environment configuration
├── frontend/
│   ├── lib/main.dart       # 🎨 Flutter application
│   ├── pubspec.yaml        # Flutter dependencies & metadata
│   └── test/app_test.dart  # Widget tests
```

## 🌍 Deployment Options

### Development

- **Local**: Flutter web-server + Node.js
- **Docker**: Containerized development environment

### Production (Recommended)

- **Frontend**: Vercel, Netlify (Flutter web build)
- **Backend**: Railway, Render, AWS ECS
- **Database**: PostgreSQL (when needed)
- **Monitoring**: Application insights, error tracking

## 🤝 Contributing

1. **Clone** the repository
2. **Create** feature branch: `git checkout -b feature/amazing-feature`
3. **Test** your changes: `npm test`
4. **Commit** with conventional format: `git commit -m 'feat: add amazing feature'`
5. **Push** and create Pull Request

### Code Standards

- **KISS Principle**: Keep it simple, stupid
- **Clean Code**: Self-documenting, minimal complexity
- **Consistent Naming**: camelCase (JS), snake_case (Dart)
- **Error Handling**: Comprehensive, user-friendly messages

## 📋 TODO Roadmap

### Phase 1: MVP Foundation ✅

- [x] Backend API with health checks
- [x] Flutter frontend with backend connectivity
- [x] Security middleware (Helmet, CORS)
- [x] Comprehensive test suites
- [x] Development automation scripts

### Phase 2: Core Features (Next)

- [ ] User authentication & authorization
- [ ] Work order CRUD operations
- [ ] Skills-based matching algorithm
- [ ] Real-time notifications

### Phase 3: Advanced Features

- [ ] Mobile app deployment
- [ ] Advanced analytics dashboard
- [ ] Integration APIs
- [ ] Performance optimization

## 📞 Support

**Team**: TrossApp Development Team
**License**: MIT
**Node.js**: v24.9.0+
**Flutter**: v3.35.5+

---

_Built with ❤️ using Flutter & Node.js_

## 🗂️ Project Organization

```
TrossApp/
├── README.md              # 👈 YOU ARE HERE - Master control document
├── docs/
│   ├── INITIAL DOCUMENTATION DO NOT DISTURB/  # 🔒 Original AI docs (READ-ONLY)
│   ├── MVP_SCOPE.md       # ✅ Refined scope for $50k budget
│   └── DEVELOPMENT_WORKFLOW.md  # ✅ Team processes & standards
├── backend/               # 🚧 Node.js API (not started)
├── frontend/              # 🚧 Flutter app (not started)
├── infrastructure/        # 🚧 AWS configs (not started)
└── scripts/              # 🚧 Automation scripts (not started)
```

## 🎯 What We Have Completed

### ✅ Foundation Documents

1. **MVP Scope** → `docs/MVP_SCOPE.md`
   - Realistic feature set for budget/timeline
   - Core: Work orders, basic assignment, mobile app, customer portal
   - Excluded: AI/ML, complex billing, real-time chat (Phase 2+)

2. **Development Workflow** → `docs/DEVELOPMENT_WORKFLOW.md`
   - Coding standards (Node.js/TypeScript, Flutter/Dart)
   - Git workflow, testing strategy, CI/CD pipeline
   - Sprint structure (2-week sprints)

3. **Original Requirements** → `docs/INITIAL DOCUMENTATION DO NOT DISTURB/`
   - 🔒 Protected AI-generated analysis (9 files)
   - User stories, technical requirements, API specs
   - System architecture, UI wireframes, launch strategy

## 🚀 Next Actions

### Immediate (Next Session)

- [ ] **Complete development workflows** - finish any missing pieces
- [ ] **Technical architecture** - simplified MVP architecture diagram
- [ ] **Project scaffolding** - create basic project structure

### Sprint 1 Prep

- [ ] **Environment setup** - dev environment guide
- [ ] **Database schema** - MVP database design
- [ ] **API specification** - core endpoints definition

## 🧠 AI Assistant Memory

### Key Decisions Made

- **MVP Focus**: Core work order management only (no AI/ML in Phase 1)
- **Tech Stack**: Flutter + Node.js (chosen for stability & team skills)
- **Architecture**: Simplified monolith for MVP (not microservices)
- **Deployment**: AWS Elastic Beanstalk (simpler than ECS for MVP)

### Documentation Rules

- ✅ **Main README**: Project control center (this file)
- ✅ **docs/ folder**: Deep documentation only
- 🔒 **Protected docs**: Never modify `INITIAL DOCUMENTATION DO NOT DISTURB/`
- ❌ **No duplicate READMEs**: One source of truth

### Convention Tracking

- **Branch naming**: `feature/[issue]-[description]`
- **Commit format**: `type(scope): description`
- **File naming**: UPPERCASE for important docs, lowercase for code
- **Status tracking**: Use emoji in this README for quick visual parsing

### 🚨 CRITICAL FILE CREATION RULE 🚨

**AI MUST NEVER CREATE ANY NEW FILE WITHOUT EXPLICIT APPROVAL**

Before creating ANY file, AI must:

1. **Identify the need**: What problem does this file solve?
2. **Check existing solutions**: Why don't we already have this covered?
3. **Review project docs**: Have we missed something in existing documentation?
4. **Justify the location**: Where does this belong in our structure?
5. **Get explicit approval**: Wait for human "YES, CREATE THIS FILE" confirmation

**Current Phase**: Setup & Configuration ONLY

- ✅ Use bash commands (git init, npm init, flutter create, etc.)
- ✅ Install, update, configure existing tools
- ✅ Build directory structures with existing commands
- ❌ NO script writing
- ❌ NO new file creation without discussion
- ❌ NO "helpful" automation files

## 🔗 Quick Links

- [MVP Scope](docs/MVP_SCOPE.md) - What we're building
- [Development Workflow](docs/DEVELOPMENT_WORKFLOW.md) - How we work
- [Original Requirements](docs/INITIAL%20DOCUMENTATION%20DO%20NOT%20DISTURB/) - Full background

---

**Last Updated**: 2025-09-30 | **Next Review**: After completing development workflows
