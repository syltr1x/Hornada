use axum::{
    http::Method,
    routing::{get, put},
    Json, Router,
    extract::{Path, State},
    http::StatusCode,
    extract::Query,
};
use serde::{Deserialize, Serialize};
use sqlx::{FromRow, SqlitePool, sqlite::SqlitePoolOptions};
use tower_http::cors::{Any, CorsLayer};
use std::collections::HashMap;



#[derive(Clone)]
struct AppState {
    db: SqlitePool,
}

#[derive(Serialize, FromRow)]
struct Pedido {
    id: i64,
    name: String,
    address: String,
    date: i64,
    total: i64,
    method: String,
    completed: bool,
    paid: bool,
}
#[derive(Serialize, Deserialize, FromRow)]
struct Balance {
    id: i64,
    person: String,
    reason: String,
    total: i64,
    r#type: String,
    method: String,
}
#[derive(Serialize, FromRow)]
struct PedidoDetalle {
    id: i64,
    order_id: i64,
    quant: i64,
    flavour: String,
}

#[derive(Serialize)]
struct PedidoCompleto {
    id: i64,
    name: String,
    address: String,
    date: i64,
    total: i64,
    method: String,
    paid: bool,
    details: Vec<PedidoDetalle>,
}

#[derive(Deserialize)]
struct NuevoPedido {
    name: String,
    address: String,
    details: Vec<NewProduct>,
    date: i64,
    total: i64,
}
#[derive(Serialize, Deserialize, FromRow)]
struct Spending {
    id: i64,
    date: i64,
    person: String,
    quant: i64,
    reason: String,
    r#type: String,
    total: i64,
    method: String,
    desc: String,
}
#[derive(Serialize, Deserialize, FromRow)]
struct NewSpending {
    date: i64,
    person: String,
    quant: i64,
    reason: String,
    r#type: String,
    total: i64,
    method: String,
    desc: String,
}
#[derive(Serialize, FromRow, Deserialize)]
struct StockSabor {
    id: i64,
    flavour: String,
    quant: i64,
}
#[derive(Deserialize)]
struct NewProduct {
    flavour: String,
    quant: i64,
}
#[derive(Deserialize)]
struct UpdProduct {
    quant: i64
}
#[derive(Deserialize)]
struct PayQuery {
    method: String,
}


#[tokio::main]
async fn main() {
    let db = SqlitePoolOptions::new()
        .max_connections(5)
        .connect("sqlite:db.db")
        .await
        .expect("No se pudo abrir la base de datos");

    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS Orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            address TEXT NOT NULL,
            date INTEGER NOT NULL,
            total INTEGER NOT NULL DEFAULT 0,
            method TEXT NOT NULL DEFAULT 'Indefinido',
            completed BOOL NOT NULL DEFAULT FALSE,
            paid BOOL NOT NULL DEFAULT FALSE
        );
        "#,
    )
    .execute(&db)
    .await
    .unwrap();
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS OrderDetails (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id INTEGER NOT NULL,
            quant INTEGER NOT NULL,
            flavour TEXT NOT NULL,

            FOREIGN KEY (order_id)
                REFERENCES Orders(id)
                ON DELETE CASCADE
        );
        "#,
    )
    .execute(&db)
    .await
    .unwrap();
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS Inventory (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quant INTEGER NOT NULL,
            flavour TEXT NOT NULL
        );
        "#,
    )
    .execute(&db)
    .await
    .unwrap();
    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS Balance (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date INTEGER NOT NULL,
            person TEXT NOT NULL,
            quant INTEGER NOT NULL,
            reason TEXT NOT NULL,
            type TEXT NOT NULL,
            total INTEGER NOT NULL,
            method TEXT NOT NULL,
            desc TEXT NOT NULL
        );
        "#,
    )
    .execute(&db)
    .await
    .unwrap();
    let state = AppState { db };

    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods([Method::GET, Method::POST])
        .allow_headers(Any);

    let app = Router::new()
        .route("/balance", get(get_balance).post(post_balance))
        .route("/spending/{id}", get(get_spending))//.put(update_spending).delete(delete_spending))
        .route("/inventory", get(get_inventory).post(post_inventory))
        .route("/inventory/{id}", put(update_inventory))
        .route("/inventory/sold", get(get_sold))
        .route("/inventory/dif", get(get_difference))
        .route("/pedidos/{id}/complete", put(complete_order))
        .route("/pedidos", get(get_pedidos).post(post_pedido))
        .route("/pedidos/{id}",
        get(get_pedido)
        .delete(delete_pedido))
        .route("/pedidos/{id}/pay", put(pay_order))
        .route("/completed", get(get_completed))
        .with_state(state)
        .layer(cors);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000")
        .await
        .unwrap();

    println!("Servidor en http://localhost:3000");

    axum::serve(listener, app).await.unwrap();
}

async fn get_pedidos(
    State(state): State<AppState>,
) -> Json<Vec<Pedido>> {
    let pedidos = sqlx::query_as::<_, Pedido>(
        "SELECT id, name, address, date, total, method, completed, paid FROM Orders WHERE completed = FALSE",
    )
    .fetch_all(&state.db)
    .await
    .unwrap();

    Json(pedidos)
}
async fn get_completed(
    State(state): State<AppState>,
) -> Json<Vec<Pedido>> {
    let pedidos = sqlx::query_as::<_, Pedido>(
        "SELECT id, name, address, date, total, method, completed, paid FROM Orders WHERE completed = TRUE",
    )
    .fetch_all(&state.db)
    .await
    .unwrap();

    Json(pedidos)
}
async fn complete_order(
    State(state): State<AppState>,
    Path(id): Path<i64>,
) -> StatusCode {
    let resultado = sqlx::query(
        "
        UPDATE Orders SET completed = TRUE WHERE id = ?",
    )
    .bind(id)
    .execute(&state.db)
    .await
    .unwrap();

    if resultado.rows_affected() == 0 {
        StatusCode::NOT_FOUND
    } else {
        StatusCode::NO_CONTENT
    }
}

async fn get_pedido(
    State(state): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<PedidoCompleto>, StatusCode> {

    let pedido = sqlx::query_as::<_, Pedido>(
        "
        SELECT id, name, address, date, total, method, completed, paid
        FROM Orders
        WHERE id = ?
        ",
    )
    .bind(id)
    .fetch_optional(&state.db)
    .await
    .unwrap();

    let Some(pedido) = pedido else {
        return Err(StatusCode::NOT_FOUND);
    };

    let details = sqlx::query_as::<_, PedidoDetalle>(
        "
        SELECT
            id,
            order_id,
            quant,
            flavour
        FROM OrderDetails
        WHERE order_id = ?
        ",
    )
    .bind(id)
    .fetch_all(&state.db)
    .await
    .unwrap();

    Ok(Json(PedidoCompleto {
        id: pedido.id,
        name: pedido.name,
        address: pedido.address,
        date: pedido.date,
        total: pedido.total,
        method: pedido.method,
        paid: pedido.paid,
        details,
    }))
}

async fn post_pedido(
    State(state): State<AppState>,
    Json(nuevo): Json<NuevoPedido>,
) -> StatusCode {

    let resultado = sqlx::query(
        "INSERT INTO Orders (name, address, date, total) VALUES (?, ?, ?, ?)"
    )
    .bind(&nuevo.name)
    .bind(&nuevo.address)
    .bind(&nuevo.date)
    .bind(&nuevo.total)
    .execute(&state.db)
    .await
    .unwrap();

    let pedido_id = resultado.last_insert_rowid();

    for detalle in nuevo.details {
        sqlx::query(
            "INSERT INTO OrderDetails (order_id, quant, flavour)
             VALUES (?, ?, ?)"
        )
        .bind(pedido_id)
        .bind(detalle.quant)
        .bind(detalle.flavour)
        .execute(&state.db)
        .await
        .unwrap();
    }

    StatusCode::CREATED
}
async fn delete_pedido(
    State(state): State<AppState>,
    Path(id): Path<i64>,
) -> StatusCode {
    sqlx::query(
        "DELETE FROM Orders WHERE id = ?",
    )
    .bind(id)
    .execute(&state.db)
    .await
    .unwrap();

    StatusCode::NO_CONTENT
}
async fn get_sold(
    State(state): State<AppState>,
) -> Json<Vec<StockSabor>> {

    let inventario = sqlx::query_as::<_, StockSabor>(
        r#"
        SELECT
            pd.flavour,
            CAST(SUM(pd.quant) AS INTEGER) AS quant
        FROM OrderDetails pd
        INNER JOIN Orders p
            ON p.id = pd.order_id
        WHERE p.completed = FALSE
        GROUP BY pd.flavour
        ORDER BY pd.flavour
        "#,
    )
    .fetch_all(&state.db)
    .await
    .unwrap();

    Json(inventario)
}
async fn get_inventory(
    State(state): State<AppState>,
) -> Json<Vec<StockSabor>> {

    let inventario = sqlx::query_as::<_, StockSabor>(
        "
        SELECT id, quant, flavour
        FROM Inventory
        ",
    )
    .fetch_all(&state.db)
    .await
    .unwrap();

    Json(inventario)
}
async fn post_inventory(
     State(state): State<AppState>,
    Json(nuevo): Json<NewProduct>,
) -> StatusCode {

    let _resultado = sqlx::query(
        "INSERT INTO Inventory (quant, flavour) VALUES (?, ?)"
    )
    .bind(&nuevo.quant)
    .bind(&nuevo.flavour)
    .execute(&state.db)
    .await
    .unwrap();


    StatusCode::CREATED
}
async fn update_inventory(
    State(state): State<AppState>,
    Path(id): Path<i64>,
    Json(update): Json<UpdProduct>,
) -> StatusCode {
    let resultado = sqlx::query(
        "
        UPDATE Inventory
        SET quant = ?
        WHERE id = ?
        ",
    )
    .bind(update.quant)
    .bind(id)
    .execute(&state.db)
    .await
    .unwrap();

    if resultado.rows_affected() == 0 {
        StatusCode::NOT_FOUND
    } else {
        StatusCode::NO_CONTENT
    }
}
async fn get_difference(
    State(state): State<AppState>,
) -> Json<Vec<StockSabor>> {

    let sold = sqlx::query_as::<_, StockSabor>(
        r#"
        SELECT
            0 AS id,
            pd.flavour,
            CAST(SUM(pd.quant) AS INTEGER) AS quant
        FROM OrderDetails pd
        INNER JOIN Orders p
            ON p.id = pd.order_id
        WHERE p.completed = FALSE
        GROUP BY pd.flavour
        "#,
    )
    .fetch_all(&state.db)
    .await
    .unwrap();


    let inventario = sqlx::query_as::<_, StockSabor>(
        r#"
        SELECT id, flavour, quant
        FROM Inventory
        "#,
    )
    .fetch_all(&state.db)
    .await
    .unwrap();


    let mut sold_map: HashMap<String, i64> = HashMap::new();

    for item in sold {
        sold_map.insert(item.flavour, item.quant);
    }


    let mut diferencia = Vec::new();


    for item in inventario {

        let vendido = sold_map
            .get(&item.flavour)
            .unwrap_or(&0);


        diferencia.push(StockSabor {
            id: item.id,
            flavour: item.flavour,
            quant: item.quant - vendido,
        });
    }


    Json(diferencia)
}
async fn pay_order(
    State(state): State<AppState>,
    Path(id): Path<i64>,
    Query(query): Query<PayQuery>,
) -> StatusCode {
    let resultado = sqlx::query(
        "UPDATE Orders SET paid = TRUE, method = ? WHERE id = ?",
    )
    .bind(query.method)
    .bind(id)
    .execute(&state.db)
    .await
    .unwrap();

    if resultado.rows_affected() == 0 {
        StatusCode::NOT_FOUND
    } else {
        StatusCode::NO_CONTENT
    }
}
async fn get_balance(
    State(state): State<AppState>,
) -> Json<Vec<Balance>> {
    let balance = sqlx::query_as::<_, Balance>(
        r#"
        SELECT
            id,
            person,
            reason,
            total,
            type,
            method
        FROM Balance
        ORDER BY date DESC
        "#,
    )
    .fetch_all(&state.db)
    .await
    .unwrap();

    Json(balance)
}
async fn post_balance(
    State(state): State<AppState>,
    Json(nuevo): Json<NewSpending>,
) -> StatusCode {
    sqlx::query(
        r#"
        INSERT INTO Balance
        (
            date,
            person,
            quant,
            reason,
            type,
            total,
            method,
            desc
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        "#,
    )
    .bind(nuevo.date)
    .bind(&nuevo.person)
    .bind(nuevo.quant)
    .bind(&nuevo.reason)
    .bind(&nuevo.r#type)
    .bind(nuevo.total)
    .bind(&nuevo.method)
    .bind(&nuevo.desc)
    .execute(&state.db)
    .await
    .unwrap();

    StatusCode::CREATED
}
async fn get_spending(
    State(state): State<AppState>,
    Path(id): Path<i64>,
) -> Json<Spending> {
    let balance = sqlx::query_as::<_, Spending>(
        r#"
        SELECT
            id,
            date,
            person,
            quant,
            reason,
            type,
            total,
            method,
            desc
        FROM Balance
        WHERE id = ?
        "#,
    )
    .bind(id)
    .fetch_one(&state.db)
    .await
    .unwrap();

    Json(balance)
}