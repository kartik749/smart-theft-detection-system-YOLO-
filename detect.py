from ultralytics import YOLO
from playsound import playsound
import cv2
import time
import threading

model = YOLO("yolov8n.pt")
cap = cv2.VideoCapture(0)

last_alert = 0

while True:
    ret, frame = cap.read()
    if not ret:
        break

    results = model(frame, conf=0.5)

    for box in results[0].boxes:
        cls_id = int(box.cls[0])
        label = model.names[cls_id]

        if label == "person":
            if time.time() - last_alert > 10:
                print("🚨 Intruder Detected!")

                x1, y1, x2, y2 = map(int, box.xyxy[0])
                person_crop = frame[y1:y2, x1:x2]

                cv2.imwrite("intruder.jpg", person_crop)

                # 🔊 play siren
                threading.Thread(target=playsound,args=("siren.wav",)).start()

                last_alert = time.time()

    annotated = results[0].plot()
    cv2.imshow("YOLO Detection", annotated)

    if cv2.waitKey(1) == 27:
        break

cap.release()
cv2.destroyAllWindows()