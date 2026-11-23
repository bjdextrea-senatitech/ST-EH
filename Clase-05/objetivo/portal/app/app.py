#!/usr/bin/env python3
"""Portal ERP Qhapaq — aplicación DELIBERADAMENTE vulnerable (solo laboratorio).
OWASP Top 10 Web + API. No usar este código en producción jamás."""
import os, re, sqlite3, time, hashlib, base64, hmac, json, threading, urllib.request, urllib.parse
from flask import Flask, request, make_response, redirect, g, jsonify

app = Flask(__name__)
DB = "/tmp/qhapaq.db"
JWT_SECRET = "qhapaq"          # secreto débil a propósito (crackeable)
saldo_lock_desactivado = True  # race condition a propósito
# nonce aleatorio que solo lleva la sesión REAL del admin (el bot). No se puede forjar
# a ciegas: solo se consigue robando la cookie del admin con XSS almacenado.
ADMIN_NONCE = base64.urlsafe_b64encode(os.urandom(9)).decode()

# ---------- base de datos ----------
def db():
    if "db" not in g:
        g.db = sqlite3.connect(DB); g.db.row_factory = sqlite3.Row
    return g.db

def init():
    c = sqlite3.connect(DB); x = c.cursor()
    x.executescript("""
    DROP TABLE IF EXISTS users; DROP TABLE IF EXISTS invoices; DROP TABLE IF EXISTS comments; DROP TABLE IF EXISTS coupons;
    CREATE TABLE users (id INTEGER PRIMARY KEY, username TEXT, password TEXT, email TEXT, role TEXT, saldo INTEGER, secreto TEXT);
    CREATE TABLE invoices (id INTEGER PRIMARY KEY, owner_id INTEGER, cliente TEXT, monto INTEGER, detalle TEXT);
    CREATE TABLE comments (id INTEGER PRIMARY KEY, autor TEXT, cuerpo TEXT);
    CREATE TABLE coupons (code TEXT PRIMARY KEY, valor INTEGER, usado INTEGER);
    """)
    x.executemany("INSERT INTO users VALUES (?,?,?,?,?,?,?)", [
        (1,"admin","S3cr3t_Adm1n_2026","admin@qhapaq.pe","admin",0,"QHAPAQ{23-sqli-login-bypass-admin}"),
        (2,"rhuaman","Qhapaq2024#","rhuaman@qhapaq.pe","user",50,"QHAPAQ{27-exposicion-excesiva-de-datos-api}"),
        (3,"gerencia","Gerencia#2025","gerencia@qhapaq.pe","user",9999,None),
    ])
    x.executemany("INSERT INTO invoices VALUES (?,?,?,?,?)", [
        (1001,2,"Andes Ficticios SAC",1200,"Servicio de soporte - rhuaman"),
        (1002,3,"Inca Demo EIRL",48000,"Contrato anual confidencial - QHAPAQ{26-idor-bola-factura-ajena}"),
        (1003,1,"Pacha Pruebas SRL",300,"Caja chica"),
    ])
    x.execute("INSERT INTO comments VALUES (1,'soporte','Bienvenidos al nuevo portal del ERP.')")
    x.execute("INSERT INTO coupons VALUES ('BIENVENIDA50',50,0)")
    c.commit(); c.close()

@app.teardown_appcontext
def _close(e):
    d = g.pop("db", None)
    if d: d.close()

# ---------- helpers JWT (HS256 hecho a mano, secreto débil) ----------
def b64(x): return base64.urlsafe_b64encode(x).rstrip(b"=").decode()
def b64d(x): return base64.urlsafe_b64decode(x + "=" * (-len(x) % 4))
def jwt_make(payload):
    h = b64(b'{"alg":"HS256","typ":"JWT"}'); p = b64(json.dumps(payload).encode())
    sig = b64(hmac.new(JWT_SECRET.encode(), f"{h}.{p}".encode(), hashlib.sha256).digest())
    return f"{h}.{p}.{sig}"
def jwt_read(tok):
    try:
        h,p,s = tok.split("."); alg = json.loads(b64d(h)).get("alg")
        if alg == "none":                       # acepta alg:none (vulnerable)
            return json.loads(b64d(p))
        good = b64(hmac.new(JWT_SECRET.encode(), f"{h}.{p}".encode(), hashlib.sha256).digest())
        if hmac.compare_digest(good, s): return json.loads(b64d(p))
    except Exception: return None
    return None
def current_user():
    t = request.cookies.get("token","")
    d = jwt_read(t)
    if not d: return None
    r = db().execute("SELECT * FROM users WHERE id=?", (d.get("uid"),)).fetchone()
    return r

PAGE = """<!doctype html><html><head><meta charset=utf-8><title>Portal ERP Qhapaq</title>
<style>body{{font-family:system-ui;background:#11161C;color:#E8EEF2;max-width:780px;margin:2rem auto;padding:0 1rem}}
a{{color:#4CC9F0}} .box{{background:#1C2530;border:1px solid #2FBF71;padding:1rem;border-radius:8px;margin:1rem 0}}
input{{padding:.4rem;margin:.2rem}} h1{{color:#2FBF71}}</style></head><body>{body}</body></html>"""

@app.route("/")
def home():
    u = current_user()
    quien = f"Sesión: <b>{u['username']}</b> ({u['role']})" if u else "No has iniciado sesión"
    return PAGE.format(body=f"""<h1>Portal ERP Qhapaq</h1><div class=box>{quien}</div>
    <p><a href=/login>Login</a> · <a href=/buscar?q=>Buscar facturas</a> · <a href=/comentarios>Comentarios</a>
    · <a href=/perfil>Perfil</a> · <a href=/registro>Registro</a></p>
    <!-- TODO quitar antes de produccion: /api, /debug, /backup.sql -->""")

# ---------- A03: SQL injection (login bypass + UNION) ----------
@app.route("/login", methods=["GET","POST"])
def login():
    if request.method == "GET":
        return PAGE.format(body="""<h1>Login</h1><form method=post>
        <input name=username placeholder=usuario><input name=password type=password placeholder=clave>
        <button>Entrar</button></form>""")
    u = request.form.get("username",""); p = request.form.get("password","")
    q = f"SELECT * FROM users WHERE username='{u}' AND password='{p}'"   # concatenación directa
    try:
        row = db().execute(q).fetchone()
    except Exception as e:
        return PAGE.format(body=f"<h1>Error SQL</h1><pre>{e}</pre><p>query: {q}</p>")  # error verboso
    if row:
        resp = make_response(redirect("/perfil"))
        resp.set_cookie("token", jwt_make({"uid": row["id"], "role": row["role"]}))
        return resp
    return PAGE.format(body="<h1>Credenciales inválidas</h1><a href=/login>volver</a>")

# ---------- A03: SQLi en búsqueda (UNION / extracción) ----------
@app.route("/buscar")
def buscar():
    q = request.args.get("q","")
    sql = f"SELECT cliente, monto, detalle FROM invoices WHERE cliente LIKE '%{q}%'"
    try:
        rows = db().execute(sql).fetchall()
    except Exception as e:
        return PAGE.format(body=f"<h1>Error</h1><pre>{e}</pre><p>{sql}</p>")
    items = "".join(f"<li>{r['cliente']} — S/{r['monto']} — {r['detalle']}</li>" for r in rows)
    return PAGE.format(body=f"<h1>Resultados</h1><p>query: <code>{sql}</code></p><ul>{items}</ul><a href=/>inicio</a>")

# ---------- A03: SQLi clásica por id (numérica, ideal para sqlmap) ----------
@app.route("/factura")
def factura():
    fid = request.args.get("id","1001")
    sql = f"SELECT cliente, monto, detalle FROM invoices WHERE id={fid}"   # sin comillas: inyección numérica
    try:
        rows = db().execute(sql).fetchall()
    except Exception as e:
        return PAGE.format(body=f"<h1>Error</h1><pre>{e}</pre>")
    items = "".join(f"<li>{r['cliente']} — S/{r['monto']} — {r['detalle']}</li>" for r in rows)
    return PAGE.format(body=f"<h1>Factura</h1><ul>{items}</ul>")

# ---------- A03: XSS reflejado ----------
@app.route("/saludo")
def saludo():
    n = request.args.get("nombre","visitante")
    return PAGE.format(body=f"<h1>Hola {n}</h1>")   # sin escapar

# ---------- A03: XSS almacenado + HTML injection ----------
@app.route("/comentarios", methods=["GET","POST"])
def comentarios():
    if request.method == "POST":
        autor = request.form.get("autor","anon"); cuerpo = request.form.get("cuerpo","")
        db().execute("INSERT INTO comments (autor,cuerpo) VALUES (?,?)", (autor,cuerpo)); db().commit()
        return redirect("/comentarios")
    rows = db().execute("SELECT * FROM comments").fetchall()
    lista = "".join(f"<div class=box><b>{r['autor']}</b>: {r['cuerpo']}</div>" for r in rows)  # sin escapar
    return PAGE.format(body=f"""<h1>Comentarios</h1>{lista}
    <form method=post><input name=autor placeholder=autor><br>
    <textarea name=cuerpo placeholder=comentario></textarea><br><button>Publicar</button></form>""")

# ---------- A01: CSRF (cambio de email sin token) + perfil ----------
@app.route("/perfil", methods=["GET","POST"])
def perfil():
    u = current_user()
    if not u: return redirect("/login")
    if request.method == "POST":
        nuevo = request.form.get("email","")
        db().execute("UPDATE users SET email=? WHERE id=?", (nuevo, u["id"])); db().commit()
        return redirect("/perfil")
    sec = u["secreto"] or "-"
    return PAGE.format(body=f"""<h1>Perfil de {u['username']}</h1>
    <div class=box>email: {u['email']}<br>rol: {u['role']}<br>saldo: S/{u['saldo']}<br>secreto: {sec}</div>
    <form method=post><input name=email placeholder='nuevo email'><button>Actualizar</button></form>
    <!-- este formulario no lleva token anti-CSRF -->""")

# ---------- A04/Mass assignment: registro que respeta 'role' del cliente ----------
@app.route("/registro", methods=["GET","POST"])
def registro():
    if request.method == "GET":
        return PAGE.format(body="""<h1>Registro</h1><form method=post>
        <input name=username placeholder=usuario><input name=password placeholder=clave>
        <button>Crear</button></form>""")
    d = request.form.to_dict()
    role = d.get("role","user")   # asignación masiva: si mandas role=admin, te lo da
    cur = db().execute("INSERT INTO users (username,password,email,role,saldo) VALUES (?,?,?,?,0)",
                       (d.get("username"), d.get("password"), d.get("email",""), role))
    db().commit()
    extra = "<div class=box>QHAPAQ{30-asignacion-masiva-de-rol}</div>" if role=="admin" else ""
    return PAGE.format(body=f"<h1>Creado</h1><p>usuario id {cur.lastrowid}, rol <b>{role}</b></p>{extra}<a href=/login>login</a>")

# ========== API REST ==========
# ---------- API1 BOLA / IDOR: factura por id sin comprobar dueño ----------
@app.route("/api/invoices/<int:iid>")
def api_invoice(iid):
    r = db().execute("SELECT * FROM invoices WHERE id=?", (iid,)).fetchone()
    if not r: return jsonify(error="no existe"), 404
    return jsonify(id=r["id"], owner_id=r["owner_id"], cliente=r["cliente"], monto=r["monto"], detalle=r["detalle"])

# ---------- API3 Excessive data exposure: devuelve password y secreto ----------
@app.route("/api/users/<int:uid>")
def api_user(uid):
    r = db().execute("SELECT * FROM users WHERE id=?", (uid,)).fetchone()
    if not r: return jsonify(error="no existe"), 404
    return jsonify({k: r[k] for k in r.keys()})   # expone password, secreto, todo

# ---------- A03: XSS almacenado — trofeo que exige la sesion REAL del admin ----------
@app.route("/admin/trofeo")
def admin_trofeo():
    # Solo lo abre la cookie robada al admin: necesita rol admin Y el nonce real
    # (un token forjado con alg:none no conoce el nonce, asi que esta via EXIGE el XSS).
    t = request.cookies.get("token","")
    d = jwt_read(t) or {}
    if d.get("role") == "admin" and d.get("n") == ADMIN_NONCE:
        return jsonify(flag="QHAPAQ{33-xss-almacenado-roba-sesion-admin}")
    return jsonify(error="esta pagina solo la ve el admin con su sesion real"), 403

# ---------- API5 BFLA: endpoint admin sin verificar rol del token ----------
@app.route("/api/admin/flag")
def api_admin_flag():
    u = current_user()
    # BUG: comprueba que haya token, pero NO que el rol sea admin
    if not u: return jsonify(error="necesitas token"), 401
    return jsonify(flag="QHAPAQ{29-bfla-funcion-admin-sin-control}")

# ---------- API/JWT: funcion admin que SI valida el rol (se llega forjando el token) ----------
@app.route("/api/admin/config")
def api_admin_config():
    u = current_user()
    if not u or u["role"] != "admin":
        return jsonify(error="solo admin"), 403
    return jsonify(flag="QHAPAQ{28-jwt-secreto-debil-forjado}", jwt_secret=JWT_SECRET)

# ---------- A10 SSRF ----------
@app.route("/interno/metadata")
def interno_metadata():
    if request.remote_addr not in ("127.0.0.1","::1","localhost"):
        return jsonify(error="solo accesible desde la propia maquina"), 403
    return jsonify(servicio="metadata interna", flag="QHAPAQ{31-ssrf-a-servicio-interno}")

@app.route("/api/fetch")
def api_fetch():
    url = request.args.get("url","")
    try:
        data = urllib.request.urlopen(url, timeout=3).read(400).decode("latin-1")
    except Exception as e:
        return jsonify(error=str(e)), 400
    return jsonify(url=url, body=data)

# ---------- Race condition: canje de cupón / saldo ----------
@app.route("/api/canjear", methods=["POST"])
def canjear():
    u = current_user()
    if not u: return jsonify(error="token requerido"), 401
    code = (request.json or {}).get("code","")
    cup = db().execute("SELECT * FROM coupons WHERE code=?", (code,)).fetchone()
    if not cup: return jsonify(error="cupon invalido"), 404
    if cup["usado"]:
        return jsonify(error="ya usado"), 409
    time.sleep(0.15)   # ventana de carrera a propósito
    db().execute("UPDATE coupons SET usado=1 WHERE code=?", (code,))
    db().execute("UPDATE users SET saldo=saldo+? WHERE id=?", (cup["valor"], u["id"]))
    db().commit()
    nuevo = db().execute("SELECT saldo FROM users WHERE id=?", (u["id"],)).fetchone()["saldo"]
    extra = "  QHAPAQ{32-race-condition-doble-canje}" if nuevo > 50 + cup["valor"] else ""
    return jsonify(ok=True, saldo=nuevo, nota=extra.strip())

# ---------- A05 misconfig: debug / backup expuestos ----------
@app.route("/debug")
def debug():
    return jsonify(env=dict(os.environ), jwt_secret=JWT_SECRET, flag="QHAPAQ{24-configuracion-debug-expuesta}")

@app.route("/backup.sql")
def backup():
    return ("-- respaldo parcial\n-- usuario admin: S3cr3t_Adm1n_2026\n"
            "-- QHAPAQ{25-archivo-de-respaldo-accesible}\n", 200, {"Content-Type":"text/plain"})

# ========== EL "BOT" DEL ADMIN ==========
# Simula al administrador que cada pocos segundos abre /comentarios con su sesion
# iniciada. Si un comentario lee document.cookie y la manda a una URL, el bot
# reproduce lo que haria el navegador del admin: hace esa peticion llevando SU cookie.
# Asi el XSS almacenado "roba" de verdad la sesion del admin hacia el listener del alumno.
_bot_cookie = None
def admin_bot():
    global _bot_cookie
    # token REAL del admin (firmado con el secreto), con el nonce que da el trofeo
    _bot_cookie = jwt_make({"uid": 1, "role": "admin", "n": ADMIN_NONCE})
    visto = 0
    url_re = re.compile(r"https?://[^\s\"'<>]+")
    while True:
        time.sleep(5)
        try:
            c = sqlite3.connect(DB); c.row_factory = sqlite3.Row
            filas = c.execute("SELECT id, cuerpo FROM comments WHERE id > ?", (visto,)).fetchall()
            c.close()
        except Exception:
            continue
        for f in filas:
            visto = max(visto, f["id"])
            cuerpo = f["cuerpo"] or ""
            # el navegador del admin solo "filtra" la cookie si el payload la lee
            if "document.cookie" not in cuerpo:
                continue
            m = url_re.search(cuerpo)
            if not m:
                continue
            destino = m.group(0) + urllib.parse.quote(f"token={_bot_cookie}")
            try:
                urllib.request.urlopen(destino, timeout=3)   # entrega la cookie del admin
            except Exception:
                pass

if __name__ == "__main__":
    init()
    threading.Thread(target=admin_bot, daemon=True).start()
    # debug=True recarga con 2 procesos; use_reloader=False para que el bot corra una sola vez
    app.run(host="0.0.0.0", port=5000, debug=True, use_reloader=False)
