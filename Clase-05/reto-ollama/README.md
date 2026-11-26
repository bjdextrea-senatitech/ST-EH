# Reto final 🤖 — Triage automatizado con Ollama (IA local)

**Idea:** montar un "copiloto" de pentesting que corre **100% en tu Kali, sin enviar nada a internet**.
Lee la salida de tus escaneos y te dice **qué atacar primero y con qué**, para que no pierdas tiempo
mirando 15 servicios a ciegas. Es exactamente lo que harias tras el `nmap` del laboratorio de hoy.

## Pasos
```bash
bash 00-instalar-ollama.sh            # instala ollama + modelo pequeño (llama3.2:3b)
bash triage.sh 10.55.0.0/24           # escanea, resume y pide prioridades al modelo
```

## Qué entregar
1. La salida del `triage.sh` contra `qhapaq-sede`.
2. Tu **crítica** a lo que dijo el modelo: ¿acertó los CVE (OMIGOD, mod_copy, Heartbleed...)?
   ¿alucinó alguna versión o exploit que no existe? ¿qué priorizó mal?
3. Una mejora al *prompt* de `triage.sh` que haga mejores sugerencias (pégala en tu bitácora).

## Nivel PRO (opcional)
- Haz que el script le pase también la salida de `enum` (smbclient, snmpwalk) y pida el **siguiente comando exacto**.
- Prueba otro modelo (`qwen2.5:3b`, `phi3:mini`) y compara calidad vs velocidad.

## Por qué NO se le delega la decisión final (discusión en clase)
- El LLM **alucina**: puede inventar un CVE o un exploit que no aplica a esa versión.
- Puede sugerir acciones **fuera de alcance** o destructivas: el permiso y el juicio son del humano.
- Es un **acelerador de triage**, no un sustituto de entender el servicio. Siempre se verifica a mano.
