# Documentación

Validaciones SAST (Static Application Security Testing)

## Resumen de Herramientas y Estándares

Esta tabla resume las herramientas de análisis estático implementadas, los estándares que utilizan y su alineación con los principios de Clean Code:

| Herramienta | Lenguaje | Categoría | Estándar Utilizado | Criterios de Fallo | Clean Code |
|-------------|----------|-----------|-------------------|-------------------|------------|
| **Ruff** | Python | Lint / Code Quality | PEP 8, Python Best Practices | Cualquier violación detectada | ✅ **Alineado** - PEP 8 es el estándar de Python que promueve legibilidad, mantenibilidad y consistencia |
| **Bandit** | Python | Security Analysis | OWASP, CWE, Python Security | Severidad HIGH o superior | ✅ **Alineado** - Detecta patrones inseguros y vulnerabilidades que comprometen la calidad y seguridad del código |
| **Safety** | Python | Dependency Security | CVE Database, PyPI Advisory | Severidad CRITICAL o HIGH | ✅ **Alineado** - Mantener dependencias actualizadas y sin vulnerabilidades es parte de código sostenible |
| **Checkstyle** | Java | Code Style | Google Java Style Guide / Sun Conventions | Errores > 0 o Total > 10 | ✅ **Alineado** - Enforza convenciones de nombres, formato y diseño que mejoran legibilidad |
| **ESLint 9** | TypeScript/JS | Code Quality & Security | ESLint Recommended, TypeScript-ESLint, Security Plugin | Errores > 0 o Total > 10 | ✅ **Alineado** - Detecta errores, malas prácticas y vulnerabilidades de seguridad en tiempo de desarrollo |
| **NPM Audit** | TypeScript/JS | Dependency Security | npm Advisory Database, CVE | Severidad CRITICAL o HIGH | ✅ **Alineado** - Gestión responsable de dependencias para reducir deuda técnica y riesgos de seguridad |

### Análisis de Alineación con Clean Code

Todas las herramientas implementadas están **completamente alineadas** con los principios de Clean Code de Robert C. Martin:

#### ✅ Principios Cumplidos:

1. **Legibilidad y Expresividad**
   - Ruff (PEP 8), Checkstyle y ESLint enforzan nombres descriptivos, formato consistente y estructura clara
   - Facilita que el código sea leído como prosa

2. **Responsabilidad Única y Diseño Simple**
   - Checkstyle y ESLint detectan complejidad ciclomática excesiva
   - Promueven funciones pequeñas y clases cohesivas

3. **Sin Duplicación (DRY)**
   - ESLint y Ruff detectan código duplicado y patrones repetitivos
   - Fomentan la reutilización y abstracción apropiada

4. **Seguridad y Robustez**
   - Bandit, Safety y NPM Audit previenen vulnerabilidades
   - Clean Code incluye código seguro y mantenible

5. **Mantenibilidad**
   - Todos los linters enforzan estándares que facilitan el mantenimiento a largo plazo
   - Reducen la deuda técnica

#### 📊 Criterios de Severidad

Los criterios de fallo están configurados de forma **balanceada**:
- **Strict para seguridad**: Critical y High bloquean el merge (principio de seguridad primero)
- **Permisivo para calidad**: Hasta 10 violaciones menores permitidas (balance entre calidad y pragmatismo)
- **Zero tolerance para errores**: Los errores de nivel "error" deben ser 0 (código que funciona correctamente)

Esta configuración permite:
- ✅ Mantener alta calidad sin bloquear el desarrollo
- ✅ Priorizar vulnerabilidades críticas
- ✅ Promover mejora continua gradual

### Implementaciones

- **[SAST para Aplicaciones Python](./SAST_for_ServerlessPython.md)**
  - Análisis estático de seguridad para proyectos Python Serverless
  - 3 herramientas: Ruff (Lint), Bandit (Security), Safety (Dependencies)
  - Integración con GitLab MR y bloqueo automático

- **[SAST para Aplicaciones Java Maven](./SAST_for_MavenJava.md)**
  - Análisis estático de seguridad para proyectos Java Maven
  - Checkstyle para validación de estándares de código
  - Integración con GitLab MR y bloqueo automático

- **[SAST para Aplicaciones TypeScript](./SAST_for_Typescript.md)**
  - Análisis estático de seguridad para proyectos TypeScript
  - 2 herramientas: ESLint 9 (Code Quality), NPM Audit (Dependencies Security)
  - Integración con GitLab MR y bloqueo automático


 