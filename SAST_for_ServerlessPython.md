# SAST para Aplicaciones Python - Flujo de CI

Este documento detalla los 3 bloques de analisis estatico de seguridad (SAST - Static Application Security Testing) implementados para aplicaciones Python en el pipeline de CI/CD.

## Tabla de Contenidos

- [1. Lint Check - Ruff](#1-lint-check---ruff)
- [2. Security Check - Bandit](#2-security-check---bandit)
- [3. Dependency Security - Safety](#3-dependency-security---safety)

---

## 1. Lint Check - Ruff

**Descripción**: Ruff es un linter extremadamente rápido para Python, escrito en Rust. Combina la funcionalidad de múltiples herramientas (Flake8, isort, pydocstyle, etc.) en una sola.

**Propósito**: Mantener la calidad del código, detectar errores de sintaxis y garantizar el cumplimiento de estándares de codificación.

**Qué detecta**:
- Errores de sintaxis y lógica básica
- Importaciones no utilizadas o mal organizadas
- Variables no utilizadas
- Complejidad ciclomática excesiva
- Violaciones de PEP 8 y mejores prácticas de Python

### 1.1 Instalación

Para configurar Ruff en tu proyecto, debes agregar el archivo `pyproject.toml` en la raíz del proyecto.

Puedes utilizar como referencia el [pyproject.toml](./pyproject.toml) de este repositorio, que ya cuenta con las configuraciones necesarias.

El archivo incluye:
- Reglas de linting habilitadas
- Exclusiones de directorios
- Longitud máxima de línea
- Configuraciones específicas para el proyecto

### 1.2 Ejecutar Pruebas

Para facilitar la ejecución de Ruff, se debe agregar un archivo `Makefile` en la raíz del proyecto.

Puedes utilizar como referencia el [Makefile](./Makefile) de este repositorio, que ya cuenta con las configuraciones necesarias.

Con el Makefile configurado, puedes ejecutar:

```bash
# Ejecutar lint usando el Makefile
make lint
```

Alternativamente, puedes ejecutar Ruff directamente:

```bash
# Instalar Ruff (si no está instalado)
pip install ruff

# Ejecutar el análisis en todo el proyecto
ruff check .

# Ejecutar con autofix para problemas que se pueden corregir automáticamente
ruff check . --fix

# Verificar solo archivos específicos
ruff check path/to/file.py
```

### 1.3 Check de Resultados

Si en las notificaciones obtienes una respuesta como esta:

![Error de Lint](./python_lint_error.png)

Es porque falló la ejecución del análisis de Ruff. Para identificar los problemas:

1. **Verificar los artefactos del pipeline**: Revisa los artefactos generados durante la ejecución del pipeline
2. **Ubicar el reporte**: Busca el archivo `gl-code-quality-report.json` en los artefactos
3. **Analizar errores**: Este archivo JSON contiene el detalle de todos los errores y warnings encontrados por Ruff

El archivo `gl-code-quality-report.json` sigue el formato estándar de GitLab Code Quality y contiene:
- Ubicación exacta de cada error (archivo y línea)
- Descripción del problema
- Severidad del issue
- Código de la regla violada

**Ejemplo de un error en el reporte:**

```json
{
  "check_name": "I001",
  "description": "I001: Import block is un-sorted or un-formatted",
  "severity": "major",
  "fingerprint": "a1e2471a3a7155ea",
  "location": {
    "path": "flask-server.py",
    "positions": {
      "begin": {
        "line": 1,
        "column": 1
      },
      "end": {
        "line": 16,
        "column": 46
      }
    }
  }
}
```

También puedes ver un resumen de los errores detectados directamente en los comentarios del Merge Request:

![Comentarios de errores en MR](./python_lint_error_comment.png)

---

## 2. Security Check - Bandit

**Descripción**: Bandit es una herramienta diseñada específicamente para encontrar problemas comunes de seguridad en código Python.

**Propósito**: Identificar vulnerabilidades de seguridad y patrones de código inseguros antes de que lleguen a producción.

**Qué detecta**:
- Uso de funciones inseguras (eval, exec, pickle)
- Manejo inadecuado de secretos y credenciales
- Inyección SQL y command injection
- Problemas de criptografía débil
- Configuraciones inseguras de SSL/TLS
- Path traversal y otros problemas de seguridad comunes

### 2.1 Instalación

La configuración de Bandit se incluye en el archivo `pyproject.toml` en la raíz del proyecto.

Puedes utilizar como referencia el [pyproject.toml](./pyproject.toml) de este repositorio. La configuración de Bandit se encuentra en la sección `[tool.bandit]`:

```toml
[tool.bandit]
exclude_dirs = ["tests", "test", ".venv", "venv", "node_modules", ".git"]
skips = ["B101", "B106"]
```

Esta configuración incluye:
- **exclude_dirs**: Directorios que Bandit debe ignorar durante el análisis
- **skips**: Códigos de reglas específicas que se omiten (ej. B101: assert_used, B106: hardcoded_password_funcarg)

### 2.2 Ejecutar Pruebas

Para ejecutar Bandit localmente en tu proyecto:

```bash
# Instalar Bandit (si no está instalado)
pip install bandit

# Ejecutar el análisis en todo el proyecto
bandit -r .

# Ejecutar con configuración desde pyproject.toml
bandit -r . --configfile pyproject.toml

# Generar reporte en formato JSON
bandit -r . -f json -o bandit-report.json

# Verificar solo archivos específicos
bandit path/to/file.py
```

### 2.3 Check de Resultados

Si recibes una notificación como esta en Slack:

![Error de Bandit](./python_bandit_error.png)

Es porque falló el test de seguridad de Bandit. **Importante**: El pipeline solo falla si Bandit encuentra issues de severidad **HIGH**.

Para identificar los problemas detectados:

1. **Verificar los artefactos del pipeline**: Revisa los artefactos generados durante la ejecución del pipeline
2. **Ubicar el reporte**: Busca el archivo `bandit-report.json` en los artefactos
3. **Analizar vulnerabilidades**: Este archivo JSON contiene el detalle de todas las vulnerabilidades de seguridad encontradas

El archivo `bandit-report.json` contiene:
- Descripción de cada vulnerabilidad
- Nivel de severidad (LOW, MEDIUM, HIGH)
- Nivel de confianza del hallazgo
- Ubicación exacta en el código (archivo y línea)
- Información adicional y recomendaciones

---

## 3. Dependency Security - Safety

**Descripción**: Safety verifica las dependencias del proyecto contra bases de datos de vulnerabilidades conocidas (CVE).

**Propósito**: Asegurar que las librerías de terceros utilizadas no contengan vulnerabilidades de seguridad conocidas.

**Qué detecta**:
- Paquetes con vulnerabilidades CVE conocidas
- Versiones obsoletas con parches de seguridad disponibles
- Dependencias con niveles críticos de severidad
- Alertas de seguridad de la comunidad Python

### 3.1 Instalación

Para configurar Safety en tu proyecto, debes agregar el archivo `.safety-policy.yml` en la raíz del proyecto.

Puedes utilizar como referencia el [.safety-policy.yml](./.safety-policy.yml) de este repositorio, que ya cuenta con las configuraciones necesarias.

El archivo de política de Safety permite:
- Definir el nivel de severidad mínimo para fallar el build
- Ignorar vulnerabilidades específicas (con justificación)
- Configurar el comportamiento del escaneo
- Establecer excepciones temporales

### 3.2 Ejecutar Pruebas

Safety 3.x requiere autenticación. Existen dos métodos de autenticación:

#### Método 1: Login Interactivo (Recomendado para desarrollo local)

```bash
# Instalar Safety (si no está instalado)
pip install safety

# Registrarse (si no tienes cuenta)
safety auth register

# Hacer login (abre el navegador para autenticación)
safety auth login

# Verificar estado de autenticación
safety auth
```

Una vez autenticado, Safety recordará tus credenciales localmente.

#### Método 2: API Key

Para obtener tu API Key:
1. Crea una cuenta en [Safety](https://platform.safetycli.com/)
2. Ve a la sección **Teams and API Keys** en tu dashboard
3. Copia tu API key

```bash
# Configurar API key como variable de entorno
export SAFETY_API_KEY=your-api-key

# O usar el flag --key directamente
safety --key your-api-key scan
```

#### Ejecutar escaneos

Safety 3.x detecta automáticamente:
- requirements.txt
- pyproject.toml
- Python virtual environments

```bash
# Escanear el directorio actual (auto-detecta todas las dependencias Python)
safety scan

# Generar reporte en formato JSON
safety scan --output json > safety-report.json

# Ver resumen del escaneo
safety scan
```

Safety 3.x utiliza el comando `scan` que automáticamente detecta todos los archivos de dependencias en tu proyecto sin necesidad de especificarlos manualmente.

### 3.3 Check de Resultados

**Importante**: El pipeline solo falla si Safety encuentra vulnerabilidades de severidad **CRITICAL** o **HIGH**.

Si el test falla, recibirás una notificación indicando que se encontraron vulnerabilidades críticas o de alta severidad en las dependencias del proyecto.

Para identificar las vulnerabilidades detectadas:

1. **Verificar los artefactos del pipeline**: Revisa los artefactos generados durante la ejecución del pipeline
2. **Ubicar el reporte**: Busca el archivo `safety-report.json` en los artefactos
3. **Revisar los comentarios del MR**: Safety también agrega comentarios en el Merge Request con un resumen de las vulnerabilidades encontradas
4. **Actualizar dependencias**: Actualiza las versiones de los paquetes afectados antes de realizar el merge

El archivo `safety-report.json` contiene:
- Paquete vulnerable y versión instalada
- Vulnerabilidad CVE detectada
- Nivel de severidad (CRITICAL, HIGH, MEDIUM, LOW)
- Versión segura recomendada
- Descripción de la vulnerabilidad

---
