from flask import Flask, render_template, jsonify
import os

app = Flask(__name__)

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/health")
def health():
    return jsonify(status="ok"), 200

@app.route("/api/hello")
def api():
    return jsonify(message="Hello from Raf's ECS Fargate!", instance=os.uname().nodename)

if __name__ == "__main__":
    # Dev only – Gunicorn used in Docker
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", 5000)))