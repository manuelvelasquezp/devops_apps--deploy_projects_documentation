# Documentación - Jenkins Shared Library & Deploy Projects

Bienvenido a la documentación del sistema de CI/CD para proyectos ONPE.

## 📋 Índice de Documentación

### Despliegues

- **[Despliegues Masivos](./DesplieguesMasivos.md)**
  - Pipeline para desplegar múltiples aplicaciones en paralelo
  - Configuración, uso y troubleshooting
  - Flujo completo desde webhook hasta notificaciones Slack

### Seguridad y Calidad (SAST)

- **[SAST para Aplicaciones Python](./SAST_for_ServerlessPython.md)**
  - Análisis estático de seguridad para proyectos Python Serverless
  - 3 herramientas: Ruff (Lint), Bandit (Security), Safety (Dependencies)
  - Integración con GitLab MR y bloqueo automático

### Infraestructura

- **[Requisitos de Red](../devops_apps--jenkins_shared_library/NETWORK_REQUIREMENTS.md)**
  - Dominios externos requeridos para CI/CD
  - Configuración de firewall y security groups
  - Credenciales Jenkins necesarias

---

## 🚀 Guías Rápidas

### Para Desarrolladores

**Antes de crear un Merge Request:**
```bash
# Para proyectos Python
make ci-local

# Verificar lint
make lint

# Verificar seguridad
make security-check

# Verificar dependencias
make deps-check
```

### Para DevOps

**Ejecutar despliegue masivo:**
```groovy
massiveDeploy('develop', 'massive_deployments.json')
```

**Configurar nuevo proyecto Python:**
1. Crear `pyproject.toml` con configuración de Ruff y Bandit
2. Crear `.safety-policy.yml` con políticas de seguridad
3. Agregar pasos CI en `branches_config.json`:
   ```json
   {
     "develop": {
       "on_merge_pr": [
         "ci_validate_version",
         "ci_sast_lint",
         "ci_sast_bandit",
         "ci_sast_safety"
       ]
     }
   }
   ```

---

## 📚 Recursos Adicionales

### Repositorios Relacionados

- **[jenkins_shared_library](../devops_apps--jenkins_shared_library/)** - Funciones Groovy reutilizables
- **[deploy_projects](https://gitlab.dev.onpe.gob.pe/sggdi/proyectos/deployments/deploy_projects)** - Configuraciones de deployment

### Herramientas Externas

- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [Bandit Documentation](https://bandit.readthedocs.io/)
- [Safety CLI Documentation](https://docs.safetycli.com/)
- [Jenkins Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)

---

## 🔄 Flujo General de CI/CD

```
┌─────────────────────────────────────────────────────────────┐
│                   Developer Push to GitLab                   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │     GitLab Webhook → Jenkins          │
        └───────────────────────────────────────┘
                            │
        ┌───────────────────┴────────────────────┐
        │                                        │
        ▼                                        ▼
┌──────────────────┐                  ┌──────────────────┐
│  Merge Request   │                  │  Branch Merge    │
│  (on_merge_pr)   │                  │  (on_close_pr)   │
└──────────────────┘                  └──────────────────┘
        │                                        │
        ▼                                        ▼
┌──────────────────┐                  ┌──────────────────┐
│  CI Validation   │                  │   Deployment     │
│  - Lint          │                  │   - Build        │
│  - Security      │                  │   - Push ECR     │
│  - Dependencies  │                  │   - Update ECS   │
└──────────────────┘                  └──────────────────┘
        │                                        │
        ▼                                        ▼
┌──────────────────┐                  ┌──────────────────┐
│ Block/Unblock MR │                  │ Slack Notification│
│ + GitLab Comment │                  │ + Status Update  │
└──────────────────┘                  └──────────────────┘
```

---

## 🆘 Soporte

Para preguntas o issues:

- **Equipo:** DevOps ONPE
- **Canal Slack:** #devops-support
- **GitLab Issues:** [Crear issue](https://gitlab.dev.onpe.gob.pe/sggdi/proyectos/deployments/deploy_projects/-/issues)

---

## 📝 Contribuir a la Documentación

Si encuentras errores o quieres agregar documentación:

1. Crear branch: `git checkout -b docs/update-xxx`
2. Editar archivos .md
3. Crear MR con label `documentation`
4. Tag: `@devops-team` para revisión

---

**Última actualización:** 2024-12-03
**Versión:** 1.0.0