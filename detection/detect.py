from flask import Flask, Response
from ultralytics import YOLO
from playsound import playsound
from dotenv import load_dotenv
import cv2
import time
import threading
import requests
import os

app = Flask(__name__)

load_dotenv()

BACKEND_URL = os.getenv("BACKEND_URL")
ALERT_COOLDOWN = 12

last_alert_time = 0
latest_frame = None
lock = threading.Lock()

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

model = YOLO("yolov8n.pt")
cap = cv2.VideoCapture(0)

# ================= ALERT =================
def send_alert(image_path):
    try:
        with open(image_path, "rb") as img:
            requests.post(BACKEND_URL, files={"image": img})
        print("📡 Alert sent")
    except Exception as e:
        print("Alert error:", e)

# ================= DETECTION LOOP =================
def detection_loop():
    global last_alert_time, latest_frame

    while True:
        success, frame = cap.read()
        if not success:
            continue

        frame = cv2.resize(frame, (640, 480))
        results = model(frame, conf=0.5)

        for box in results[0].boxes:
            cls_id = int(box.cls[0])
            label = model.names[cls_id]

            if label == "person":
                x1, y1, x2, y2 = map(int, box.xyxy[0])

                cv2.rectangle(frame, (x1, y1), (x2, y2), (0,255,0), 2)
                cv2.putText(frame, "Person", (x1, y1 - 10),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0,255,0), 2)

                current_time = time.time()

                if current_time - last_alert_time > ALERT_COOLDOWN:
                    print("🚨 Intruder Detected!")

                    crop = frame[y1:y2, x1:x2]

                    os.makedirs("assets", exist_ok=True)
                    image_path = os.path.join(
                        BASE_DIR, "assets", f"intruder_{int(current_time)}.jpg"
                    )

                    cv2.imwrite(image_path, crop)

                    # 🔊 Sound
                    sound_path = os.path.join(BASE_DIR, "assets", "siren.wav")

                    threading.Thread(
                        target=playsound,
                        args=(sound_path,)
                    ).start()

                    # 📡 Backend
                    threading.Thread(
                        target=send_alert,
                        args=(image_path,)
                    ).start()

                    last_alert_time = current_time

        # Store latest frame
        with lock:
            latest_frame = frame

# ================= STREAM =================
def generate_frames():
    global latest_frame

    while True:
        with lock:
            if latest_frame is None:
                continue

            _, buffer = cv2.imencode('.jpg', latest_frame)
            frame_bytes = buffer.tobytes()

        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')

@app.route('/video')
def video():
    return Response(generate_frames(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

# ================= MAIN =================
if __name__ == "__main__":
    print("Backend URL:", BACKEND_URL)

    # 🔥 Start detection ALWAYS
    threading.Thread(target=detection_loop, daemon=True).start()

    app.run(host='0.0.0.0', port=5001)