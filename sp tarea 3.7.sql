# ==========================================
# sp_menu.py
# CRUD básico con Procedimientos Almacenados (MySQL)
# Autor: Cristofer Vergara
# ==========================================

import mysql.connector

# ---------- CONFIGURACIÓN DE CONEXIÓN ----------
DB_CONFIG = {
    "host": "localhost",
    "user": "root",             # Usuario de MySQL
    "password": "TU_CONTRASEÑA", # 🔒 Cambia por tu contraseña real
    "database": "empresa"
}

# ---------- FUNCIÓN DE CONEXIÓN ----------
def conectar():
    """Crea y devuelve una conexión a MySQL."""
    return mysql.connector.connect(**DB_CONFIG)

# ---------- FUNCIONES DE CRUD ----------
def sp_insertar(nombre, cargo, sueldo):
    try:
        cnx = conectar()
        cur = cnx.cursor()
        args = [nombre, cargo, sueldo, 0]
        cur.callproc("sp_insertar_empleado", args)
        cnx.commit()
        print("✅ Empleado insertado correctamente.")
    except mysql.connector.Error as e:
        print("❌ Error en sp_insertar:", e)
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_activos():
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_listar_empleados_activos")
        print("\n=== EMPLEADOS ACTIVOS ===")
        for result in cur.stored_results():
            for (id_, nombre, cargo, sueldo, created_at, updated_at) in result.fetchall():
                ua = updated_at if updated_at else "-"
                print(f"ID:{id_:<3} | {nombre:<15} | {cargo:<12} | ${sueldo:,.0f} | Creado:{created_at} | Actualizado:{ua}")
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_activos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_listar_todos():
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_listar_empleados_todos")
        print("\n=== EMPLEADOS (TODOS) ===")
        for result in cur.stored_results():
            for (id_, nombre, cargo, sueldo, eliminado, created_at, updated_at, deleted_at) in result.fetchall():
                estado = "ACTIVO" if eliminado == 0 else "ELIMINADO"
                ua = updated_at if updated_at else "-"
                da = deleted_at if deleted_at else "-"
                print(f"ID:{id_:<3} | {nombre:<15} | {cargo:<12} | ${sueldo:,.0f} | {estado:<9} | Creado:{created_at} | Actualizado:{ua} | Eliminado:{da}")
    except mysql.connector.Error as e:
        print("❌ Error en sp_listar_todos:", e)
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_borrado_logico(id_empleado):
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_borrado_logico_empleado", [id_empleado])
        cnx.commit()
        print(f"✅ Borrado lógico aplicado al ID {id_empleado}.")
    except mysql.connector.Error as e:
        print("❌ Error en sp_borrado_logico:", e)
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

def sp_restaurar(id_empleado):
    try:
        cnx = conectar()
        cur = cnx.cursor()
        cur.callproc("sp_restaurar_empleado", [id_empleado])
        cnx.commit()
        print(f"✅ Empleado ID {id_empleado} restaurado correctamente.")
    except mysql.connector.Error as e:
        print("❌ Error en sp_restaurar:", e)
        if cnx: cnx.rollback()
    finally:
        if cur: cur.close()
        if cnx and cnx.is_connected(): cnx.close()

# ---------- MENÚ PRINCIPAL ----------
def menu():
    while True:
        print("\n===== MENÚ EMPLEADOS (MySQL + SP) =====")
        print("1) Insertar empleado")
        print("2) Listar empleados ACTIVOS")
        print("3) Listar empleados (TODOS)")
        print("4) Borrado lógico por ID")
        print("5) Restaurar por ID")
        print("0) Salir")
        opcion = input("Selecciona una opción: ").strip()

        if opcion == "1":
            nombre = input("Nombre: ").strip()
            cargo = input("Cargo: ").strip()
            try:
                sueldo = float(input("Sueldo: ").strip())
                sp_insertar(nombre, cargo, sueldo)
            except ValueError:
                print("❌ Sueldo inválido.")
        elif opcion == "2":
            sp_listar_activos()
        elif opcion == "3":
            sp_listar_todos()
        elif opcion == "4":
            try:
                id_emp = int(input("ID a eliminar: ").strip())
                sp_borrado_logico(id_emp)
            except ValueError:
                print("❌ ID inválido.")
        elif opcion == "5":
            try:
                id_emp = int(input("ID a restaurar: ").strip())
                sp_restaurar(id_emp)
            except ValueError:
                print("❌ ID inválido.")
        elif opcion == "0":
            print("👋 Saliendo del sistema...")
            break
        else:
            print("❌ Opción no válida.")

if __name__ == "__main__":
    menu()
