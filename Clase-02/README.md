# Clase 02 · El proceso de pentesting

**SENATI · DC05 Ethical Hacking y Seguridad Ofensiva · Capítulo 2 del sílabo**
Tipos de pentesting · PTES / OWASP / OSSTMM · fases · marco legal · reportes.

Hoy haces un pentest **completo y pequeño** contra la empresa ficticia *Inversiones Qhapaq SAC*, que corre en contenedores dentro de tu VM: de la autorización firmada al informe ejecutivo.

| Archivo | Qué es |
|---|---|
| `Clase02_Proceso_de_Pentesting.pptx` | Teoría (~25 min) |
| `laboratorio-clase02.md` | **La guía del laboratorio**, fase por fase de PTES |
| `objetivo/` | La empresa Qhapaq: `docker-compose.yml` + 3 servidores |
| `scripts/00-verificar-entorno.sh` | Revisa herramientas, Docker y objetivos (solo lee) |
| `plantillas/carta-autorizacion-con-fallas.md` | Ejercicio: encuentra los errores de la autorización |
| `plantillas/reglas-de-enfrentamiento.md` | Tus RoE para Qhapaq |
| `plantillas/bitacora-pentest.md` | Bitácora con horas, servicios, hipótesis y banderas |
| `plantillas/hallazgo.md` · `plantillas/informe-ejecutivo.md` | Formato de reporte |

Empieza por aquí (dentro de tu VM Linux, con la carpeta en `~/Clase-02`):

```bash
cd ~/Clase-02/objetivo
docker compose up -d --build
bash ../scripts/00-verificar-entorno.sh
```

> `172.30.0.30` está **fuera de alcance**. Todo acceso a ese servidor queda registrado.
