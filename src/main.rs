use std::net::SocketAddr;

use axum::{
    body,
    response::{IntoResponse, Response},
    routing::{get, post},
    Json, Router,
};
use reqwest::StatusCode;
use serde::{Deserialize, Serialize};
use tower_http::cors::{Any, CorsLayer};

#[tokio::main]
async fn main() {
    // initialize tracing
    tracing_subscriber::fmt::init();
    let cors = CorsLayer::new().allow_origin(Any).allow_headers(Any);

    // build our application with a route
    let app = Router::new()
        // `GET /` goes to `root`
        .route("/", get(|| async { "You got me at home /" }))
        // `POST /users` goes to `create_user`
        .route("/line", post(send_line_msg))
        .layer(cors);

    // run our app with hyper
    // `axum::Server` is a re-export of `hyper::Server`
    let addr = SocketAddr::from(([0, 0, 0, 0], 3000));
    tracing::debug!("listening on {}", addr);
    println!("axum server starting on {}", "0.0.0.0:3000");
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}

async fn send_line_msg(Json(payload): Json<MsgToBeSend>) -> impl IntoResponse {
    let token = "E0f4wLwsZSbGrAvws6MS9q5w6E5mqZRG9dZQWTM7X8F";
    let bearer = format!("Bearer {}", token);
    let url = "https://notify-api.line.me/api/notify";
    let msg = format!("\n ข้อความ: {} \n จาก: {}", payload.msg, payload.name);
    let line_msg = LineMsg { message: msg };

    let client = reqwest::Client::new();
    let res = client
        .post(url)
        .header("Authorization", bearer)
        .header("Content-Type", "application/x-www-form-urlencoded")
        .form(&line_msg)
        .send()
        .await;
    println!("res: {:?}", res);
    match res {
        Ok(_) => (StatusCode::OK, line_msg),
        Err(err) => {
            println!("error: {}", err);
            (StatusCode::INTERNAL_SERVER_ERROR, line_msg)
        }
    }
}

#[derive(Deserialize)]
struct MsgToBeSend {
    msg: String,
    name: String,
}

#[derive(Serialize)]
struct LineMsg {
    message: String,
}
impl IntoResponse for LineMsg {
    fn into_response(self) -> Response {
        Response::new(body::boxed(self.message))
    }
}
