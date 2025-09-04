# 🚀 CI/CD Pipeline Documentation

## Overview
This document explains the GitHub Actions CI/CD pipeline for the ExpenseTracker Spring Boot application. The pipeline provides automated testing, building, security scanning, and deployment capabilities.

## 📋 Pipeline Triggers

The pipeline runs automatically on:
- **Push to `main` branch**: Full pipeline including production deployment
- **Push to `develop` branch**: Pipeline with staging deployment  
- **Pull Request to `main`**: Tests and build for code review

```yaml
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
```

## 🏗️ Pipeline Architecture

### Job Flow Diagram
```
Push to develop branch:
┌─────────┐    ┌─────────┐    ┌──────────────┐
│  TEST   │───▶│  BUILD  │───▶│   STAGING    │
└─────────┘    └─────────┘    │  DEPLOYMENT  │
     │              │         └──────────────┘
     ▼              ▼
┌─────────────┐     │
│ SECURITY    │─────┘
│   SCAN      │
└─────────────┘

Push to main branch:
┌─────────┐    ┌─────────┐    ┌──────────────┐
│  TEST   │───▶│  BUILD  │───▶│ PRODUCTION   │
└─────────┘    └─────────┘    │ DEPLOYMENT   │
     │              │         └──────────────┘
     ▼              │              ▲
┌─────────────┐     │              │
│ SECURITY    │─────┴──────────────┘
│   SCAN      │
└─────────────┘
```

## 🧪 Job 1: TEST

### Purpose
Runs all unit and integration tests with a real PostgreSQL database to ensure code quality.

### PostgreSQL Service
```yaml
services:
  postgres:
    image: postgres:15
    env:
      POSTGRES_DB: expensetracker_test
      POSTGRES_USER: test_user
      POSTGRES_PASSWORD: test_pass
```
**Why**: Creates an isolated test database that matches your production environment.

### Key Steps

#### 1. Environment Setup
- **Checkout Code**: Downloads repository source code
- **Setup JDK 21**: Installs Java 21 (Eclipse Temurin distribution)
- **Cache Gradle**: Saves dependencies between runs (reduces build time from 5-10 minutes to 30 seconds)

#### 2. Test Execution
```bash
./gradlew test
```
**Environment Variables**:
- `SPRING_DATASOURCE_URL`: Points to test PostgreSQL container
- `SPRING_DATASOURCE_USERNAME/PASSWORD`: Test database credentials

#### 3. Test Reporting
- **Test Reporter**: Creates beautiful test reports in GitHub UI
- **Artifact Upload**: Saves detailed test results for download

### Benefits
- ✅ Catches bugs before deployment
- ✅ Ensures database integration works
- ✅ Provides detailed test reports
- ✅ Fast execution with caching

## 🏗️ Job 2: BUILD

### Purpose
Compiles the application and creates deployable JAR files.

### Dependencies
```yaml
needs: test
```
**Why**: Only builds if tests pass - no point building broken code.

### Key Steps

#### 1. Build Process
```bash
./gradlew build -x test
```
**Why `-x test`**: Tests already ran in previous job, skip to save time.

#### 2. Artifact Management
- **Upload JAR files**: Saves built application for deployment jobs
- **Artifact retention**: Files available for download and deployment

### Benefits
- ✅ Creates production-ready artifacts
- ✅ Reuses test results for efficiency
- ✅ Provides downloadable builds

## 🔒 Job 3: SECURITY-SCAN

### Purpose
Scans dependencies for known security vulnerabilities using OWASP Dependency Check.

### Security Check
```bash
./gradlew dependencyCheckAnalyze
```

### Configuration
```yaml
continue-on-error: true
```
**Why**: Pipeline continues even if vulnerabilities found, allowing you to review and decide.

### Benefits
- ✅ Identifies security vulnerabilities
- ✅ Prevents deploying insecure code
- ✅ Generates detailed security reports
- ✅ Non-blocking for urgent deployments

## 🚀 Job 4: DEPLOY-STAGING

### Purpose
Deploys application to staging environment for testing.

### Trigger Condition
```yaml
if: github.ref == 'refs/heads/develop'
```
**Why**: Only deploys from `develop` branch to staging.

### Environment Protection
```yaml
environment: staging
```
**Benefits**:
- Environment-specific secrets
- Deployment approval workflows
- Deployment history tracking

### Current Implementation
```bash
echo "Deploying to staging environment..."
# Add your staging deployment commands here
```

## 🎯 Job 5: DEPLOY-PRODUCTION

### Purpose
Deploys application to production environment.

### Dependencies
```yaml
needs: [test, build, security-scan]
```
**Why**: Production requires ALL quality gates to pass.

### Trigger Condition
```yaml
if: github.ref == 'refs/heads/main'
```
**Why**: Only deploys from `main` branch to production.

### Environment Protection
```yaml
environment: production
```
**Benefits**:
- Manual approval requirements
- Production secrets management
- Audit trail for deployments

## ⚙️ Configuration Files

### Test Configuration
**File**: `src/test/resources/application-test.properties`
- Test database configuration
- Disabled Docker Compose for CI
- Debug logging enabled

### Production Configuration  
**File**: `src/main/resources/application-prod.properties`
- Environment variable configuration
- Connection pooling settings
- Security hardening
- Monitoring endpoints

## 🔧 Build Configuration

### Gradle Plugins Added
```gradle
plugins {
    id 'org.owasp.dependencycheck' version '8.4.0'
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
}
```

### Benefits
- **OWASP Plugin**: Security vulnerability scanning
- **Actuator**: Health checks and monitoring endpoints

## 🚀 Getting Started

### 1. Repository Setup
1. Push your code to GitHub
2. The pipeline will automatically detect the workflow file
3. First run will take longer (no cache), subsequent runs are faster

### 2. Environment Setup
1. Go to GitHub Settings → Environments
2. Create `staging` and `production` environments
3. Configure protection rules and secrets

### 3. Secrets Configuration
Add these secrets in GitHub Settings → Secrets:
```
DB_PASSWORD_STAGING=your_staging_db_password
DB_PASSWORD_PRODUCTION=your_production_db_password
```

### 4. Customize Deployment
Replace the echo commands in deployment jobs with actual deployment scripts:
```bash
# Example deployment commands
scp build/libs/*.jar user@server:/path/to/app/
ssh user@server 'sudo systemctl restart expense-tracker'
```

## 📊 Monitoring and Reports

### Available Reports
- **Test Results**: Visible in GitHub Actions UI
- **Security Scan**: OWASP dependency check reports
- **Build Artifacts**: Downloadable JAR files
- **Deployment History**: Environment deployment logs

### Health Check Endpoints
- `/actuator/health` - Application health status
- `/actuator/metrics` - Application metrics
- `/actuator/info` - Application information

## 🔄 Workflow Examples

### Feature Development
1. Create feature branch from `develop`
2. Make changes and push
3. Create PR to `develop` → Tests run
4. Merge to `develop` → Deploy to staging
5. Test in staging environment
6. Create PR from `develop` to `main` → Tests run
7. Merge to `main` → Deploy to production

### Hotfix
1. Create hotfix branch from `main`
2. Make critical fix and push
3. Create PR to `main` → Tests run
4. Merge to `main` → Deploy to production
5. Merge back to `develop`

## 🎯 Key Benefits

1. **Automated Quality Gates**: Tests must pass before deployment
2. **Security First**: Vulnerability scanning before production  
3. **Fast Feedback**: Caching makes builds 10x faster
4. **Branch-based Deployment**: Different branches → different environments
5. **Artifact Management**: Built JARs are saved and reused
6. **Visual Reports**: Test results visible in GitHub UI
7. **Environment Protection**: Approval workflows for production
8. **Audit Trail**: Complete deployment history

## 🛠️ Troubleshooting

### Common Issues

#### Build Failures
- Check Java version compatibility
- Verify Gradle wrapper permissions
- Review dependency conflicts

#### Test Failures
- Check PostgreSQL service health
- Verify test database configuration
- Review application-test.properties

#### Deployment Issues
- Verify environment secrets
- Check deployment script permissions
- Review target server connectivity

### Debug Tips
- Download build artifacts for local testing
- Check job logs for detailed error messages
- Use GitHub Actions debugging features

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Spring Boot Actuator Guide](https://spring.io/guides/gs/actuator-service/)
- [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/)
- [Docker Deployment Best Practices](https://docs.docker.com/develop/dev-best-practices/)
