from ultralytics import YOLO
from playsound import playsound
import cv2
import time
import threading
import requests
import os

last_alert_time = 0
ALERT_COOLDOWN = 12  # seconds

def send_alert_to_backend(image_path):
    url = "http://localhost:5000/api/alerts"

    try:
        with open(image_path, "rb") as img:
            files = {"image": img}
            response = requests.post(url, files=files)

        print("📡 Sent to backend:", response.status_code)

    except Exception as e:
        print("❌ Failed to send alert:", e)

model = YOLO("yolov8n.pt")
cap = cv2.VideoCapture(0)

while True:
    ret, frame = cap.read()
    if not ret:
        break

    # resize to reduce storage
    frame = cv2.resize(frame, (640, 480))

    results = model(frame, conf=0.5)

    for box in results[0].boxes:
        cls_id = int(box.cls[0])
        label = model.names[cls_id]

        if label == "person":
            current_time = time.time()

            if current_time - last_alert_time > ALERT_COOLDOWN:
                print("🚨 Intruder Detected!")

                x1, y1, x2, y2 = map(int, box.xyxy[0])
                person_crop = frame[y1:y2, x1:x2]

                os.makedirs("assets", exist_ok=True)
                image_path = f"assets/intruder_{int(current_time)}.jpg"

                cv2.imwrite(image_path, person_crop)
                print("🖼 Image saved:", image_path)

                threading.Thread(
                    target=playsound,
                    args=("assets/siren.wav",)
                ).start()

                threading.Thread(
                    target=send_alert_to_backend,
                    args=(image_path,)
                ).start()

                last_alert_time = current_time

    annotated = results[0].plot()
    cv2.imshow("YOLO Detection", annotated)

    if cv2.waitKey(1) == 27:
        break

cap.release()
cv2.destroyAllWindows()