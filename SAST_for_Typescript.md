# SAST para Aplicaciones TypeScript - Flujo de CI

Este documento detalla el análisis estático de seguridad (SAST - Static Application Security Testing) implementado para aplicaciones TypeScript en el pipeline de CI/CD.

## Tabla de Contenidos

- [1. ESLint Check - ESLint](#1-eslint-check---eslint)

---

## 1. ESLint Check - ESLint

**Descripción**: ESLint es una herramienta de análisis de código estático para identificar y reportar patrones problemáticos encontrados en código JavaScript/TypeScript. ESLint 9 es la versión más reciente que incluye mejoras significativas en rendimiento y nuevas reglas de seguridad.

**Propósito**: Mantener la calidad del código, detectar errores potenciales, vulnerabilidades de seguridad y garantizar el cumplimiento de estándares de codificación en proyectos TypeScript.

**Qué detecta**:
- Errores de sintaxis y lógica
- Problemas de tipos en TypeScript
- Variables no utilizadas o no definidas
- Código inalcanzable
- Patrones de código inseguros
- Violaciones de mejores prácticas
- Problemas de accesibilidad
- Vulnerabilidades de seguridad comunes

### 1.1 Instalación

Para configurar ESLint 9 en tu proyecto TypeScript, necesitas instalar las dependencias y crear el archivo de configuración.

**Instalación de dependencias:**

```bash
# Instalar ESLint 9 y plugins necesarios
npm install --save-dev eslint@9 \
  @eslint/js \
  typescript-eslint \
  eslint-plugin-security \
  eslint-plugin-import

# O con yarn
yarn add -D eslint@9 \
  @eslint/js \
  typescript-eslint \
  eslint-plugin-security \
  eslint-plugin-import
```

**Archivo de configuración eslint.config.js:**

ESLint 9 utiliza el nuevo formato de configuración plana (flat config). Crea un archivo `eslint.config.js` en la raíz del proyecto:

```javascript
import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import security from 'eslint-plugin-security';
import importPlugin from 'eslint-plugin-import';

export default [
  js.configs.recommended,
  ...tseslint.configs.recommended,
  security.configs.recommended,
  {
    files: ['**/*.ts', '**/*.tsx'],
    plugins: {
      '@typescript-eslint': tseslint.plugin,
      'security': security,
      'import': importPlugin,
    },
    languageOptions: {
      parser: tseslint.parser,
      parserOptions: {
        project: './tsconfig.json',
      },
    },
    rules: {
      // Reglas de TypeScript
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-unused-vars': 'error',
      '@typescript-eslint/explicit-function-return-type': 'warn',
      
      // Reglas de seguridad
      'security/detect-object-injection': 'warn',
      'security/detect-non-literal-regexp': 'warn',
      'security/detect-unsafe-regex': 'error',
      
      // Reglas generales
      'no-console': 'warn',
      'no-debugger': 'error',
      'no-eval': 'error',
    },
  },
  {
    ignores: [
      'node_modules/**',
      'dist/**',
      'build/**',
      'coverage/**',
      '*.config.js',
    ],
  },
];
```

**Elementos clave de la configuración:**
- **Configuraciones base**: Incluye reglas recomendadas de ESLint, TypeScript y seguridad
- **Plugins**: TypeScript ESLint, Security, Import
- **Parser**: Configurado para TypeScript con soporte de proyecto
- **Reglas personalizadas**: Ajustadas según las necesidades del proyecto
- **Ignores**: Directorios y archivos excluidos del análisis

### 1.2 Ejecutar Pruebas

Para ejecutar ESLint localmente en tu proyecto TypeScript:

**Agregar scripts en package.json:**

```json
{
  "scripts": {
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "lint:report": "eslint . --format json --output-file eslint-report.json"
  }
}
```

**Comandos de ejecución:**

```bash
# Ejecutar ESLint en todo el proyecto
npm run lint

# Ejecutar con auto-corrección
npm run lint:fix

# Generar reporte en formato JSON
npm run lint:report

# Ejecutar solo en archivos específicos
npx eslint src/**/*.ts

# Ejecutar con formato detallado
npx eslint . --format stylish

# Verificar archivos modificados (con git)
npx eslint $(git diff --name-only --diff-filter=ACMR | grep -E '\.(ts|tsx)$')
```

**Opciones útiles:**

```bash
# Ver solo errores (ignorar warnings)
npx eslint . --quiet

# Usar un archivo de configuración específico
npx eslint . --config eslint.config.custom.js

# Modo debug para troubleshooting
npx eslint . --debug

# Generar reporte HTML
npx eslint . --format html --output-file eslint-report.html
```

### 1.3 Check de Resultados

Si en las notificaciones obtienes un error indicando que falló el análisis de ESLint, significa que se encontraron violaciones que exceden los límites permitidos.

**Estándares de Calidad:**
- **Errores**: Deben ser 0
- **Total de Violaciones**: Debe ser <= 10

Para identificar los problemas:

1. **Verificar el detalle en el Merge Request**: Puedes ver un resumen de las violaciones directamente en los comentarios del MR con:
   - Archivo y línea donde ocurre la violación
   - Regla de ESLint violada
   - Descripción del problema
   - Severidad (error o warning)

2. **Descargar el reporte desde los artefactos**: Revisa los artefactos generados durante la ejecución del pipeline y descarga el archivo `eslint-report.json` o `eslint-report.html`

3. **Analizar el reporte**: El reporte contiene:
   - Ubicación exacta de cada violación (archivo, línea y columna)
   - Descripción detallada del problema
   - Severidad del issue (error: 2, warning: 1)
   - Regla de ESLint violada
   - Código fuente afectado
   - Resumen estadístico de errores y warnings

**Ejemplo de un error en el reporte JSON:**

```json
{
  "filePath": "/src/services/auth.ts",
  "messages": [
    {
      "ruleId": "@typescript-eslint/no-explicit-any",
      "severity": 2,
      "message": "Unexpected any. Specify a different type.",
      "line": 15,
      "column": 23,
      "nodeType": "TSAnyKeyword"
    }
  ],
  "errorCount": 1,
  "warningCount": 0
}
```

**Interpretación de resultados:**

- Si el **total de violaciones > 10**: El pipeline falla automáticamente
- Si hay **errores (severity: 2) > 0**: El pipeline falla automáticamente
- Los **warnings (severity: 1)** cuentan para el total de violaciones

**Recomendaciones:**

1. Ejecuta `npm run lint` localmente antes de hacer commit
2. Usa `npm run lint:fix` para corregir automáticamente las violaciones que sea posible
3. Revisa el reporte HTML o JSON para ver detalles de las violaciones
4. Configura tu IDE (VS Code, WebStorm) con el plugin de ESLint para ver errores en tiempo real
5. Considera usar Husky y lint-staged para ejecutar ESLint en pre-commit
6. Verifica que el total de violaciones esté dentro del límite permitido (≤ 10)

**Integración con IDE:**

Para VS Code, instala la extensión oficial de ESLint:
```bash
code --install-extension dbaeumer.vscode-eslint
```

Agrega en `.vscode/settings.json`:
```json
{
  "eslint.enable": true,
  "eslint.validate": ["typescript", "typescriptreact"],
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  }
}
```

---
